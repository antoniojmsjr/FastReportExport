unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Buttons, Horse,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, frxClass, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    btnStop: TBitBtn;
    btnStart: TBitBtn;
    edtPort: TEdit;
    btnBrowser: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnBrowserClick(Sender: TObject);
  private
    { Private declarations }
    procedure Status;
    procedure Start;
    procedure Stop;
    function GetFileName(const pFileName: string): string;
    procedure ExportFastReport(pReq: THorseRequest; pRes: THorseResponse; pNext: TNextProc);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Winapi.ShellApi, System.JSON, System.Win.ComObj, System.StrUtils, REST.JSON,
  Horse.StaticFiles, Utils, Data, FRExport, FRExport.Types,
  FRExport.Interfaces.Providers;

{$R *.dfm}

{ TfrmMain }

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  Start;
  Status;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  Stop;
  Status;
end;

procedure TfrmMain.btnBrowserClick(Sender: TObject);
var
  lLink: string;
begin
  lLink := Format('http://localhost:%s/export/43', [edtPort.Text]);
  ShellExecute(0, 'OPEN', PChar(lLink), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if THorse.IsRunning then
    Stop;
end;

function TfrmMain.GetFileName(const pFileName: string): string;
var
  lUUID: TGuid;
begin
  if (CreateGuid(lUUID) = S_OK) then
    Result := ReplaceStr(ReplaceStr(Format('%s-%s', [pFileName, GuidToString(lUUID)]), '{', ''), '}', '');
end;

procedure TfrmMain.Start;
begin
  THorse.Use('/', HorseStaticFile(TUtils.PathApp, ['']));
  THorse.MaxConnections := 100;

  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  //CERTO É POST, MAS COMO EXEMPLO PARA VISUALIZAR NO BROWSER VAI SER O GET
  THorse.Get('export/:estadoid', ExportFastreport);

  THorse.Listen(StrToInt(edtPort.Text));
end;

procedure TfrmMain.Status;
begin
  btnStop.Enabled := THorse.IsRunning;
  btnStart.Enabled := not THorse.IsRunning;
  edtPort.Enabled := not THorse.IsRunning;
  btnBrowser.Enabled := THorse.IsRunning;
end;

procedure TfrmMain.Stop;
begin
  THorse.StopListen;
end;

procedure TfrmMain.ExportFastReport(pReq: THorseRequest; pRes: THorseResponse;
  pNext: TNextProc);
var
  lFDConnection: TFDConnection;
  lQryEstadosBrasil: TFDQuery;
  lQryMunicipioEstado: TFDQuery;
  lQryMunicipioRegiao: TFDQuery;
  lQryEstadoRegiao: TFDQuery;
  lQryMunicipios: TFDQuery;
  lFRExportPDF: IFRExportPDF;
  lFileStream: TFileStream;
  lError: string;
  lFileExportPDF: string;
  lFiltro: Integer;
begin
  lFiltro := pReq.Params.Field('estadoid').AsInteger;
  lFDConnection := nil;
  try
    lFDConnection := TFDConnection.Create(nil);

    //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
    if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
    begin
      pRes.Send('Erro de conexão: ' + lError).Status(500);
      Exit;
    end;

    //CONSULTA BANCO DE DADOS
    try
      TData.QryEstadosBrasil(lFDConnection, lQryEstadosBrasil);
      TData.QryMunicipioEstado(lFDConnection, lQryMunicipioEstado);
      TData.QryMunicipioRegiao(lFDConnection, lQryMunicipioRegiao);
      TData.QryEstadoRegiao(lFDConnection, lQryEstadoRegiao);
      TData.QryMunicipios(lFDConnection, lQryMunicipios, lFiltro);
    except
      on E: Exception do
      begin
        pRes.Send(E.Message).Status(500);
        Exit;
      end;
    end;

    //EXPORT

    //PROVIDER PDF
    lFRExportPDF := TFRExportProviderPDF.New;
    lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
    lFRExportPDF.frxPDF.Author := 'Antônio José Medeiros Schneider';
    lFRExportPDF.frxPDF.Creator := 'Antônio José Medeiros Schneider';

    //CLASSE DE EXPORTAÇÃO
    try
      TFRExport.New.
      DataSets.
        SetDataSet(lQryEstadosBrasil, 'EstadosBrasil').
        SetDataSet(lQryMunicipioEstado, 'MunicipioEstado').
        SetDataSet(lQryMunicipioRegiao, 'MunicipioRegiao').
        SetDataSet(lQryEstadoRegiao, 'EstadoRegiao').
        SetDataSet(lQryMunicipios, 'Municipios').
      &End.
      Providers.
        SetProvider(lFRExportPDF).
      &End.
      Export.
        SetExceptionFastReport(True).
        SetFileReport(TUtils.PathAppFileReport). //LOCAL DO RELATÓRIO *.fr3
        Report(procedure(pfrxReport: TfrxReport) //CONFIGURAÇÃO DO COMPONENTE DE RELATÓRIO DO FAST REPORT
        var
          lfrxComponent: TfrxComponent;
          lfrxMemoView: TfrxMemoView absolute lfrxComponent;
        begin
          //CONFIGURAÇÃO DO COMPONENTE
          pfrxReport.ReportOptions.Author := 'Antônio José Medeiros Schneider';

          //PASSAGEM DE PARÂMETRO PARA O RELATÓRIO
          lfrxComponent := pfrxReport.FindObject('mmoProcess');
          if Assigned(lfrxComponent) then
          begin
            lfrxMemoView.Memo.Clear;
            lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['VCL HORSE']);
          end;
        end).
        Execute; //PROCESSAMENTO DO RELATÓRIO
    except
      on E: Exception do
      begin
        if E is EFRExport then
          pRes.Send(E.ToString).Status(500)
        else
          pRes.Send(E.Message + ' - ' + E.QualifiedClassName).Status(500);
        Exit;
      end;
    end;

    //EXPORT
    Sleep(1);
    try

      //SALVAR PDF
      if Assigned(lFRExportPDF.Stream) then
      begin
        lFileStream := nil;
        try
          lFileExportPDF := Format('%s%s.%s', [TUtils.PathApp, GetFileName('LocalidadesIBGE'), 'pdf']);
          lFileStream := TFileStream.Create(lFileExportPDF, fmCreate);
          lFileStream.CopyFrom(lFRExportPDF.Stream, 0);

          //ENVIO DO ARQUIVO
          pRes.SendFile(lFRExportPDF.Stream, 'LocalidadesIBGE.pdf', 'application/pdf');
        finally
          FreeAndNil(lFileStream);
        end;
      end;

    except
      on E: Exception do
      begin
        pRes.Send('Export error: '+ E.Message).Status(500);
        Exit;
      end;
    end;

  finally
    lFDConnection.Free;
  end;
end;

end.
