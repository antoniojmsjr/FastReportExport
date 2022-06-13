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
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids;

type
  TfrmMain = class(TForm)
    frxReport: TfrxReport;
    qryCliente: TFDQuery;
    conFastReportExport: TFDConnection;
    dsCliente: TDataSource;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Button2: TButton;
    btnExportar: TButton;
    ckbExportThread: TCheckBox;
    procedure btnExportarClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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

  //PROVIDER PNG
  lFRExportPNG := TFRExportProviderPNG.New;
  lFRExportPNG.frxPNG.JPEGQuality := 100;

  //CLASSE DE EXPORTAÇÃO
  try
    TFRExport.New.
      DataSets.
        SetDataSet(qryCliente, 'DataSetCliente').
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
              lfrxMemoView.Memo.Text := 'VCL';
            end;
          end).
        Execute; //EXECUTA O PROCESSO DE EXPORTAÇÃO DO RELATÓRIO
  except
    on E: Exception do
    begin
      if E is EFRExport then
        ShowMessage(E.ToString)
      else
        ShowMessage(E.Message);
      Exit;
    end;
  end;

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
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  conFastReportExport.Open();

  qryCliente.Close;
  qryCliente.Open();

  btnExportar.Enabled := True;
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
    lFRExportPDF.frxPDF.Subject := 'Cliente - Delphi';
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
          SetDataSet(qryCliente, 'DataSetCliente').
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
              lfrxMemoView.Memo.Text := 'VCL';
            end;
          end).
          Execute;
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
        ShowMessage(lExportErrorMessage);
      end);
      Exit;
    end;

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
  end);
  lTask.Start;
end;

end.
