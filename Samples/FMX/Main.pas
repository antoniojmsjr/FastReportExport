unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TfrmMain = class(TForm)
    lytHeader: TLayout;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ExportReportThread;
    procedure ExportReport;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Utils, Data, FRExport, FRExport.Types, FRExport.Interfaces.Providers,
  System.Threading, frxClass;

{$R *.fmx}

{ TfrmMain }

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  ExportReport;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  ExportReportThread;
end;

procedure TfrmMain.ExportReport;
var
  lFDConnection: TFDConnection;
  lQryEstadosBrasil: TFDQuery;
  lQryMunicipioEstado: TFDQuery;
  lQryMunicipioRegiao: TFDQuery;
  lQryEstadoRegiao: TFDQuery;
  lQryMunicipios: TFDQuery;
  lFRExportPDF: IFRExportPDF;
  lFRExportHTML: IFRExportHTML;
  lFRExportPNG: IFRExportPNG;
  lFileStream: TFileStream;
  lFileExport: string;
  lError: string;
begin
  lFDConnection := nil;
  try
    lFDConnection := TFDConnection.Create(nil);

    //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
    if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
    begin
      ShowMessage('Erro de conexão: ' + lError);
      Exit;
    end;

    //CONSULTA BANCO DE DADOS
    try
      TData.QryEstadosBrasil(lFDConnection, lQryEstadosBrasil);
      TData.QryMunicipioEstado(lFDConnection, lQryMunicipioEstado);
      TData.QryMunicipioRegiao(lFDConnection, lQryMunicipioRegiao);
      TData.QryEstadoRegiao(lFDConnection, lQryEstadoRegiao);
      TData.QryMunicipios(lFDConnection, lQryMunicipios);
    except
      on E: Exception do
      begin
        ShowMessage(E.Message);
        Exit;
      end;
    end;

    //EXPORT PDF/HTML/PNG

    //PROVIDER PDF
    lFRExportPDF := TFRExportProviderPDF.New;
    lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
    lFRExportPDF.frxPDF.Author := 'Antônio José Medeiros Schneider';
    lFRExportPDF.frxPDF.Creator := 'Antônio José Medeiros Schneider';

    //PROVIDER HTML
    lFRExportHTML := TFRExportProviderHTML.New;
    lFRExportHTML.frxHTML.FixedWidth := True;

    //PROVIDER PNG
    lFRExportPNG := TFRExportProviderPNG.New;
    lFRExportPNG.frxPNG.JPEGQuality := 100;

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
            lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['FMX']);
          end;

          //VARIÁVEIS DO RELATÓRIO
          pfrxReport.Variables.Variables['DATA_HORA_IMPRESSAO'] := QuotedStr(DateTimeToStr(Now));
        end).
        Execute; //PROCESSAMENTO DO RELATÓRIO
    except
      on E: Exception do
      begin
        if E is EFRExport then
          ShowMessage('Erro de exportação: ' + E.ToString)
        else
          ShowMessage('Erro de exportação: ' + E.Message);
        Exit;
      end;
    end;

    //SALVAR PDF
    if Assigned(lFRExportPDF.Stream) then
    begin
      lFileStream := nil;
      try
        lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.pdf']);
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
        lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.html']);
        lFileStream := TFileStream.Create(lFileExport, fmCreate);
        lFileStream.CopyFrom(lFRExportHTML.Stream, 0);
      finally
        FreeAndNil(lFileStream);
      end;
    end;

    //SALVAR PNG
    if Assigned(lFRExportPNG.Stream) then
    begin
      lFileStream := nil;
      try
        lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.png']);
        lFileStream := TFileStream.Create(lFileExport, fmCreate);
        lFileStream.CopyFrom(lFRExportPNG.Stream, 0);
      finally
        FreeAndNil(lFileStream);
      end;
    end;

    ShowMessage('Ok');
  finally
    lFDConnection.Free;
  end;
end;

procedure TfrmMain.ExportReportThread;
var
  lTask: ITask;
begin
  lTask := TTask.Create(
  procedure
  var
    lFDConnection: TFDConnection;
    lQryEstadosBrasil: TFDQuery;
    lQryMunicipioEstado: TFDQuery;
    lQryMunicipioRegiao: TFDQuery;
    lQryEstadoRegiao: TFDQuery;
    lQryMunicipios: TFDQuery;
    lFRExportPDF: IFRExportPDF;
    lFRExportHTML: IFRExportHTML;
    lFRExportPNG: IFRExportPNG;
    lFileStream: TFileStream;
    lFileExport: string;
    lError: string;
    lExportError: Boolean;
    lExportErrorMessage: string;
    procedure ShowMessageThread(const pText: string);
    begin
      TThread.Synchronize(TThread.Current,
      procedure
      begin
        ShowMessage(pText);
      end);
    end;
  begin
    lExportError := False;
    lFDConnection := nil;
    try
      lFDConnection := TFDConnection.Create(nil);

      //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
      if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
      begin
        lExportErrorMessage := 'Erro de conexão: ' + lError;
        ShowMessageThread(lExportErrorMessage);
        Exit;
      end;

      //CONSULTA BANCO DE DADOS
      try
        TData.QryEstadosBrasil(lFDConnection, lQryEstadosBrasil);
        TData.QryMunicipioEstado(lFDConnection, lQryMunicipioEstado);
        TData.QryMunicipioRegiao(lFDConnection, lQryMunicipioRegiao);
        TData.QryEstadoRegiao(lFDConnection, lQryEstadoRegiao);
        TData.QryMunicipios(lFDConnection, lQryMunicipios);
      except
        on E: Exception do
        begin
          lExportErrorMessage := 'Erro de consulta: ' + lError;
          ShowMessageThread(lExportErrorMessage);
          Exit;
        end;
      end;

      //EXPORT PDF/HTML/PNG

      //PROVIDER PDF
      lFRExportPDF := TFRExportProviderPDF.New;
      lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
      lFRExportPDF.frxPDF.Author := 'Antônio José Medeiros Schneider';
      lFRExportPDF.frxPDF.Creator := 'Antônio José Medeiros Schneider';

      //PROVIDER HTML
      lFRExportHTML := TFRExportProviderHTML.New;
      lFRExportHTML.frxHTML.FixedWidth := True;

      //PROVIDER PNG
      lFRExportPNG := TFRExportProviderPNG.New;
      lFRExportPNG.frxPNG.JPEGQuality := 100;

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
              lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['FMX']);
            end;

            //VARIÁVEIS DO RELATÓRIO
            pfrxReport.Variables.Variables['DATA_HORA_IMPRESSAO'] := QuotedStr(DateTimeToStr(Now));
          end).
          Execute; //PROCESSAMENTO DO RELATÓRIO
      except
        on E: Exception do
        begin
          lExportError := True;
          if E is EFRExport then
            lExportErrorMessage := E.ToString
          else
            lExportErrorMessage := E.Message;
        end;
      end;

      if lExportError then
      begin
        ShowMessageThread(lExportErrorMessage);
        Exit;
      end;

      //SALVAR PDF
      if Assigned(lFRExportPDF.Stream) then
      begin
        lFileStream := nil;
        try
          lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.pdf']);
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
          lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.html']);
          lFileStream := TFileStream.Create(lFileExport, fmCreate);
          lFileStream.CopyFrom(lFRExportHTML.Stream, 0);
        finally
          FreeAndNil(lFileStream);
        end;
      end;

      //SALVAR PNG
      if Assigned(lFRExportPNG.Stream) then
      begin
        lFileStream := nil;
        try
          lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.png']);
          lFileStream := TFileStream.Create(lFileExport, fmCreate);
          lFileStream.CopyFrom(lFRExportPNG.Stream, 0);
        finally
          FreeAndNil(lFileStream);
        end;
      end;

      ShowMessageThread('Ok');
    finally
      lFDConnection.Free;
    end;
  end);
  lTask.Start;
end;

end.
