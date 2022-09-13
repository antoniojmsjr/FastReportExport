unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  Vcl.Grids, Vcl.ValEdit;

type
  TfrmMain = class(TForm)
    pnlHeader: TPanel;
    edtURL: TEdit;
    lblURLTitle: TLabel;
    NetHTTPClient: TNetHTTPClient;
    NetHTTPRequest: TNetHTTPRequest;
    Bevel1: TBevel;
    btnRequest: TButton;
    vledtResponseHeaders: TValueListEditor;
    btnOpenFile: TButton;
    procedure btnRequestClick(Sender: TObject);
    procedure btnOpenFileClick(Sender: TObject);
  private
    { Private declarations }
    FPDFFile: string;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.IOUtils, Winapi.ShellAPI;

procedure OpenPDF(const pFile: TFileName; const pTypeForm: Integer = SW_NORMAL);
var
  lPdir: PChar;
begin
  GetMem(lPdir, 256);
  StrPCopy(lPdir, pFile);
  ShellExecute(0, nil, Pchar(pFile), nil, lPdir, pTypeForm);
  FreeMem(lPdir, 256);
end;

procedure TfrmMain.btnOpenFileClick(Sender: TObject);
begin
  OpenPDF(FPDFFile);
end;

procedure TfrmMain.btnRequestClick(Sender: TObject);
var
  lHTTPResponse: IHTTPResponse;
  lPDFStrem: TFileStream;
  lHeaderValue: TNameValuePair;
  lContentDisposition: string;
begin
  vledtResponseHeaders.Strings.Clear;

  lHTTPResponse := NetHTTPRequest.Client.Get(edtURL.Text);

  if (lHTTPResponse.StatusCode <> 200) then
    raise Exception.CreateFmt('%d - %s', [lHTTPResponse.StatusCode, lHTTPResponse.StatusText]);

  lHTTPResponse.ContentStream.Position := 0;
  if not Assigned(lHTTPResponse.ContentStream) then
    raise Exception.Create('Content response empty.');

  lContentDisposition := lHTTPResponse.HeaderValue['Content-Disposition'];
  lContentDisposition := StringReplace(lContentDisposition, '"', '', [rfReplaceAll]);
  FPDFFile := Trim(Copy(lContentDisposition, Pos('=', lContentDisposition)+1, Length(lContentDisposition)));

  if (FPDFFile = EmptyStr) then
    FPDFFile := ExtractFilePath(ParamStr(0)) + 'FastReportExport.pdf'
  else
    FPDFFile := ExtractFilePath(ParamStr(0)) + FPDFFile;

  lPDFStrem := TFileStream.Create(FPDFFile, fmCreate);
  try
    lPDFStrem.CopyFrom(lHTTPResponse.ContentStream, 0);
  finally
    lPDFStrem.Free;
  end;

  for lHeaderValue in lHTTPResponse.Headers do
    vledtResponseHeaders.InsertRow(lHeaderValue.Name, lHeaderValue.Value, True);
  vledtResponseHeaders.Refresh;

  if FileExists(FPDFFile) then
    ShowMessage(FPDFFile);
end;

end.
