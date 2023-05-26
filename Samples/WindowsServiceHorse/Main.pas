unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, frxClass, System.StrUtils,
  FRExport, FRExport.Interfaces, FRExport.Interfaces.Providers, FRExport.Types, //FRExport Classes
  Utils, Data, Horse;

type
  TsrvFastReportHorse = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
  private
    { Private declarations }
    procedure ExportFastReport(pReq: THorseRequest; pRes: THorseResponse; pNext: TNextProc);
  public
    { Public declarations }
    function GetServiceController: TServiceController; override;
  end;

var
  srvFastReportHorse: TsrvFastReportHorse;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  srvFastReportHorse.Controller(CtrlCode);
end;

procedure TsrvFastReportHorse.ExportFastReport(pReq: THorseRequest;
  pRes: THorseResponse; pNext: TNextProc);
var
  lFDConnection: TFDConnection;
  lQryEstadosBrasil: TFDQuery;
  lQryMunicipioEstado: TFDQuery;
  lQryMunicipioRegiao: TFDQuery;
  lQryEstadoRegiao: TFDQuery;
  lQryMunicipios: TFDQuery;
  lFRExportPDF: IFRExportPDF;
  lError: string;
  lFiltro: Integer;
begin
  lFiltro := pReq.Params.Field('estadoid').AsInteger;

  lFDConnection := nil;
  try
    lFDConnection := TFDConnection.Create(nil);

    //CONEX�O COM O BANCO DE DADOS DE EXEMPLO
    if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
    begin
      pRes.Send('Erro de conex�o: ' + lError).Status(500);
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
    lFRExportPDF.frxPDF.Author := 'Ant�nio Jos� Medeiros Schneider';
    lFRExportPDF.frxPDF.Creator := 'Ant�nio Jos� Medeiros Schneider';

    //CLASSE DE EXPORTA��O
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
        SetFileReport(TUtils.PathAppFileReport). //LOCAL DO RELAT�RIO *.fr3
        Report(procedure(pfrxReport: TfrxReport) //CONFIGURA��O DO COMPONENTE DE RELAT�RIO DO FAST REPORT
        var
          lfrxComponent: TfrxComponent;
          lfrxMemoView: TfrxMemoView absolute lfrxComponent;
        begin
          //CONFIGURA��O DO COMPONENTE
          pfrxReport.ReportOptions.Author := 'Ant�nio Jos� Medeiros Schneider';

          //PASSAGEM DE PAR�METRO PARA O RELAT�RIO
          lfrxComponent := pfrxReport.FindObject('mmoProcess');
          if Assigned(lfrxComponent) then
          begin
            lfrxMemoView.Memo.Clear;
            lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['WINDOWS SERVER HORSE']);
          end;

          //VARI�VEIS DO RELAT�RIO
          pfrxReport.Variables.Variables['DATA_HORA_IMPRESSAO'] := QuotedStr(DateTimeToStr(Now));
        end).
        Execute; //PROCESSAMENTO DO RELAT�RIO
    except
      on E: Exception do
      begin
        if E is EFRExport then
          pRes.Send(E.ToString).Status(500)
        else
          pRes.Send(E.Message+' - ' + E.QualifiedClassName).Status(500);
        Exit;
      end;
    end;

    //EXPORT PDF
    try
      if Assigned(lFRExportPDF.Stream) then
        pRes.SendFile(lFRExportPDF.Stream, 'LocalidadesIBGE.pdf', 'application/pdf') //ENVIO DO ARQUIVO
      else
        pRes.Send('Export fail, stream empty.').Status(404);
    except
      on E: Exception do
        pRes.Send('Export error: ' + E.Message).Status(500);
    end;

  finally
    lFDConnection.Free;
  end;
end;

function TsrvFastReportHorse.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsrvFastReportHorse.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
  Started := True;
  ReportStatus;

  THorse.MaxConnections := 100;

  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  //CERTO � POST, MAS COMO EXEMPLO PARA VISUALIZAR NO BROWSER VAI SER O GET
  THorse.Get('export/:estadoid', ExportFastreport);

  THorse.Listen(9002);

  Sleep(1000);
end;

end.
