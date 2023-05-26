unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Comp.DataSet, frxClass,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, frxRich, frxADOComponents,
  frxDBXComponents, frxIBXComponents, frxDBSet;

type
  TfrmMain = class(TForm)
    frxReport: TfrxReport;
    qryMunicipioEstado: TFDQuery;
    conFastReportExport: TFDConnection;
    Panel1: TPanel;
    btnConectarDB: TButton;
    btnExportar: TButton;
    ckbExportThread: TCheckBox;
    frxdbMunicipioEstado: TfrxDBDataset;
    qryMunicipioRegiao: TFDQuery;
    frxdbMunicipioRegiao: TfrxDBDataset;
    qryEstadoRegiao: TFDQuery;
    frxDBEstadoRegiao: TfrxDBDataset;
    qryEstadosBrasil: TFDQuery;
    frxdbEstadosBrasil: TfrxDBDataset;
    qryMunicipios: TFDQuery;
    frxdbMunicipios: TfrxDBDataset;
    procedure btnExportarClick(Sender: TObject);
    procedure btnConectarDBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ExportThread;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Utils, FRExport, FRExport.Types, FRExport.Interfaces.Providers,
  System.Generics.Collections, System.Threading;

{$R *.dfm}

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  conFastReportExport.Close;
end;

procedure TfrmMain.btnConectarDBClick(Sender: TObject);
begin
  conFastReportExport.Open;

  qryEstadosBrasil.Close;
  qryEstadosBrasil.Open;

  qryMunicipioEstado.Close;
  qryMunicipioEstado.Open;

  qryMunicipioRegiao.Close;
  qryMunicipioRegiao.Open;

  qryEstadoRegiao.Close;
  qryEstadoRegiao.Open;

  qryMunicipios.Close;
  qryMunicipios.Open;

  btnExportar.Enabled := True;
end;

procedure TfrmMain.btnExportarClick(Sender: TObject);
var
  lFRExportPDF: IFRExportPDF;
  lFRExportHTML: IFRExportHTML;
  lFRExportPNG: IFRExportPNG;
  lFileStream: TFileStream;
  lFileExport: string;
begin
  if ckbExportThread.Checked then
  begin
    ExportThread;
    Exit;
  end;

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
        SetDataSet(qryEstadosBrasil, 'EstadosBrasil').
        SetDataSet(frxdbMunicipioEstado).
        SetDataSet(frxdbMunicipioRegiao).
        SetDataSet(qryEstadoRegiao, 'EstadoRegiao').
        SetDataSet(qryMunicipios, 'Municipios').
      &End.
      Providers.
        SetProvider(lFRExportPDF).
        SetProvider(lFRExportHTML).
        SetProvider(lFRExportPNG).
      &End.
      Export.
        SetFileReport(TUtils.PathAppFileReport). //LOCAL DO RELATÓRIO *.fr3
        Report(procedure(pfrxReport: TfrxReport) //CONFIGURAÇÃO DO COMPONENTE DE RELATÓRIO DO FAST REPORT
        var
          lfrxComponent: TfrxComponent;
          lfrxMemoView: TfrxMemoView absolute lfrxComponent;
        begin
          pfrxReport.ReportOptions.Author := 'Antônio José Medeiros Schneider';

          //PASSAGEM DE PARÂMETRO PARA O RELATÓRIO
          lfrxComponent := pfrxReport.FindObject('mmoProcess');
          if Assigned(lfrxComponent) then
          begin
            lfrxMemoView.Memo.Clear;
            lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['VCL']);
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
      lFileStream.Free;
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
      lFileStream.Free;
    end;
  end;

  ShowMessage('Ok');
end;

procedure TfrmMain.ExportThread;
var
  lTask: ITask;
begin
  lTask := TTask.Create(
  procedure
  var
    lFRExportPDF: IFRExportPDF;
    lFRExportHTML: IFRExportHTML;
    lFRExportPNG: IFRExportPNG;
    lFileStream: TFileStream;
    lFileExport: string;
    lExportError: Boolean;
    lExportErrorMessage: string;
  begin
    lExportError := False;

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
          SetDataSet(qryEstadosBrasil, 'EstadosBrasil').
          SetDataSet(frxdbMunicipioEstado).
          SetDataSet(frxdbMunicipioRegiao).
          SetDataSet(qryEstadoRegiao, 'EstadoRegiao').
          SetDataSet(qryMunicipios, 'Municipios').
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
              lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['VCL']);
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
      TThread.Synchronize(TThread.Current,
      procedure
      begin
        ShowMessage('Erro de exportação: ' + lExportErrorMessage);
      end);
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
        lFileStream.Free;
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
        lFileStream.Free;
      end;
    end;

    TThread.Synchronize(TThread.Current,
      procedure
      begin
        ShowMessage('Ok');
      end);
  end);
  lTask.Start;
end;

end.
