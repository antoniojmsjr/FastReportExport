unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, frxClass,
  FRExport, FRExport.Interfaces, FRExport.Interfaces.Providers, FRExport.Types, //FRExport Classes
  Utils;

type
  TsrvFastReport = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  srvFastReport: TsrvFastReport;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  srvFastReport.Controller(CtrlCode);
end;

function TsrvFastReport.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsrvFastReport.ServiceStart(Sender: TService; var Started: Boolean);
var
  lFDConnection: TFDConnection;
  lQryCliente: TFDQuery;
  lError: string;
  lFRExportPDF: IFRExportPDF;
  lFRExportHTML: IFRExportHTML;
  lFRExportPNG: IFRExportPNG;
  lFileStream: TFileStream;
  lFileExport: string;
begin
  Started := True;
  Sleep(1000);

  LogMessage('Exportar PDF/HTML/PNG Fast Report.', EVENTLOG_INFORMATION_TYPE, 0, 1050);

  lFDConnection := nil;
  lQryCliente := nil;
  try
    lFDConnection := TFDConnection.Create(nil);
    lQryCliente := TFDQuery.Create(lFDConnection);
    lQryCliente.Connection := lFDConnection;

    //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
    if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
    begin
      LogMessage('Erro de conexão: ' + lError, EVENTLOG_ERROR_TYPE, 0, 1050);
      Exit;
    end;

    //SELECT TABELA CLIENTE
    if not TUtils.QueryOpen(lQryCliente, 'SELECT * FROM CLIENTE', lError) then
    begin
      LogMessage('Erro de consulta: ' + lError, EVENTLOG_ERROR_TYPE, 0, 1050);
      Exit;
    end;

    //EXPORT PDF/HTML/PNG

    //PROVIDER PDF
    lFRExportPDF := TFRExportProviderPDF.New;
    lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
    lFRExportPDF.frxPDF.Author := 'Antônio José Medeiros Schneider';
    lFRExportPDF.frxPDF.Creator := 'Antônio José Medeiros Schneider';

    //PROVIDER HTML
    lFRExportHTML := TFRExportProviderHTML.New;

    //PROVIDER PNG
    lFRExportPNG := TFRExportProviderPNG.New;

    //CLASSE DE EXPORTAÇÃO
    try
      TFRExport.New.
      DataSets.
        SetDataSet(lQryCliente, 'DataSetCliente').
      &End.
      Providers.
        SetProvider(lFRExportPDF).
        SetProvider(lFRExportHTML).
        SetProvider(lFRExportPNG).
      &End.
      Export.
        SetFileReport(TUtils.PathAppFileReport).
        Report(procedure(pfrxReport: TfrxReport)
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
            lfrxMemoView.Memo.Text := 'WINDOWS SERVICE';
          end;
        end).
        Execute;
    except
      on E: Exception do
      begin
        if E is EFRExport then
          LogMessage('Erro de exportação: ' + E.ToString, EVENTLOG_ERROR_TYPE, 0, 1050)
        else
          LogMessage('Erro de exportação: ' + E.Message, EVENTLOG_ERROR_TYPE, 0, 1050);
        Exit;
      end;
    end;

    LogMessage('Salvando PDF/HTML/PNG Fast Report.', EVENTLOG_INFORMATION_TYPE, 0, 1050);

    //SALVAR PDF
    if Assigned(lFRExportPDF.Stream) then
    begin
      lFileStream := nil;
      try
        lFileExport := Format('%s%s', [TUtils.PathApp, 'Cliente.pdf']);
        lFileStream := TFileStream.Create(lFileExport, fmCreate);
        lFileStream.CopyFrom(lFRExportPDF.Stream, 0);
      finally
        FreeAndNil(lFileStream);
      end;
    end;

    //SALVAR HTML
    if Assigned(lFRExportHTML.Stream) then
    begin
      lFileStream := nil;
      try
        lFileExport := Format('%s%s', [TUtils.PathApp, 'Cliente.html']);
        lFileStream := TFileStream.Create(lFileExport, fmCreate);
        lFileStream.CopyFrom(lFRExportHTML.Stream, 0);
      finally
        lFileStream.Free;
      end;
    end;

    //SALVAR PNG
    if Assigned(lFRExportPNG.Stream) then
    begin
      lFileStream := nil;
      try
        lFileExport := Format('%s%s', [TUtils.PathApp, 'Cliente.png']);
        lFileStream := TFileStream.Create(lFileExport, fmCreate);
        lFileStream.CopyFrom(lFRExportPNG.Stream, 0);
      finally
        lFileStream.Free;
      end;
    end;

  finally
    lQryCliente.Close;
    lFDConnection.Free;
  end;
end;

end.
