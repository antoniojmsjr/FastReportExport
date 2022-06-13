unit Horse.StaticFiles;

interface

uses

  System.Generics.Collections,
  System.Classes,
  System.SysUtils,
  Horse;

type

  THorseStaticFileCallback = class
  private
    FPathRoot: string;
    FDefaultFiles: TArray<string>;
  public
    class function New: THorseStaticFileCallback;
    function SetPathRoot(APathRoot: string): THorseStaticFileCallback;
    function SetDefaultFiles(ADefaultFiles: TArray<string>): THorseStaticFileCallback;
    procedure Callback(AHorseRequest: THorseRequest; AHorseResponse: THorseResponse; ANext: TProc);
  end;

  THorseStaticFileManager = class
  private
    FCallbackList: TObjectList<THorseStaticFileCallback>;
    class var FDefaultManager: THorseStaticFileManager;
    procedure SetCallbackList(const Value: TObjectList<THorseStaticFileCallback>);
  protected
    class function GetDefaultManager: THorseStaticFileManager; static;
  public
    constructor Create;
    destructor Destroy; override;
    property CallbackList: TObjectList<THorseStaticFileCallback> read FCallbackList write SetCallbackList;
    class destructor UnInitialize;
    class property DefaultManager: THorseStaticFileManager read GetDefaultManager;
  end;

function HorseStaticFile(APathRoot: string; const ADefaultFiles: TArray<string> = []): THorseCallback; overload;

implementation

uses
  System.IOUtils,
  System.Net.Mime;

function HorseStaticFile(APathRoot: string; const ADefaultFiles: TArray<string> = []): THorseCallback; overload;
var
  LHorseStaticFileCallback: THorseStaticFileCallback;
begin
  LHorseStaticFileCallback := THorseStaticFileCallback.Create;

  THorseStaticFileManager
    .DefaultManager
    .CallbackList
    .Add(LHorseStaticFileCallback);

  Result :=
    LHorseStaticFileCallback
    .SetPathRoot(APathRoot)
    .SetDefaultFiles(ADefaultFiles)
    .Callback;
end;

{ THorseStaticFileCallback }

procedure THorseStaticFileCallback.Callback(AHorseRequest: THorseRequest; AHorseResponse: THorseResponse; ANext: TProc);
var
  LFileStream: TFileStream;
  LNormalizeFileName: string;
  LType: string;
  LKind: TMimeTypes.TKind;
  I: Integer;
begin

  LNormalizeFileName := AHorseRequest.RawWebRequest.RawPathInfo.TrimLeft(['/']);

  LNormalizeFileName := LNormalizeFileName.Replace('/', TPath.DirectorySeparatorChar);

  LNormalizeFileName := TPath.Combine(FPathRoot, LNormalizeFileName);

   if (TDirectory.Exists(LNormalizeFileName)) or (ExtractFileName(LNormalizeFileName).IsEmpty) then
  begin
    for I := Low(FDefaultFiles) to High(FDefaultFiles) do
    begin
      if TFile.Exists(TPath.Combine(LNormalizeFileName, FDefaultFiles[I])) then
      begin
        LNormalizeFileName := TPath.Combine(LNormalizeFileName, FDefaultFiles[I]);
        Break;
      end;
    end;
  end;

  if TFile.Exists(LNormalizeFileName) then
  begin
    LFileStream := TFileStream.Create(LNormalizeFileName, fmShareDenyNone or fmOpenRead);
    AHorseResponse.RawWebResponse.ContentStream := LFileStream;
    TMimeTypes.Default.GetFileInfo(LNormalizeFileName, LType, LKind);
    AHorseResponse.RawWebResponse.ContentType := LType;
    AHorseResponse.RawWebResponse.StatusCode := 200;
    AHorseResponse.RawWebResponse.SendResponse;
    raise EHorseCallbackInterrupted.Create;
  end;

  ANext();
end;

class function THorseStaticFileCallback.New: THorseStaticFileCallback;
begin
  Result := THorseStaticFileCallback.Create;
end;

function THorseStaticFileCallback.SetPathRoot(APathRoot: string): THorseStaticFileCallback;
begin
  Result := Self;
  FPathRoot := APathRoot;
end;

function THorseStaticFileCallback.SetDefaultFiles(ADefaultFiles: TArray<string>): THorseStaticFileCallback;
begin
  Result := Self;
  FDefaultFiles := ADefaultFiles;
end;

{ THorseStaticFileManager }

constructor THorseStaticFileManager.Create;
begin
  FCallbackList := TObjectList<THorseStaticFileCallback>.Create(True);
end;

destructor THorseStaticFileManager.Destroy;
begin
  FCallbackList.Free;
  inherited;
end;

class function THorseStaticFileManager.GetDefaultManager: THorseStaticFileManager;
begin
  if FDefaultManager = nil then
    FDefaultManager := THorseStaticFileManager.Create;
  Result := FDefaultManager;
end;

procedure THorseStaticFileManager.SetCallbackList(const Value: TObjectList<THorseStaticFileCallback>);
begin
  FCallbackList := Value;
end;

class destructor THorseStaticFileManager.UnInitialize;
begin
  FreeAndNil(FDefaultManager);
end;

end.
