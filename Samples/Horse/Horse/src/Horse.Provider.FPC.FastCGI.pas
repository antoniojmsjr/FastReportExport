unit Horse.Provider.FPC.FastCGI;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

{$IF DEFINED(FPC) AND DEFINED(HORSE_FCGI)}
uses SysUtils, Classes, fpFCGI, httpdefs, fpHTTP, Horse.Provider.Abstract, Horse.Constants, Horse.Proc;

type
  THorseProvider<T: class> = class(THorseProviderAbstract<T>)
  private
    class var FPort: Integer;
    class var FHost: string;
    class var FRunning: Boolean;
    class var FFastCGIApplication: TFCGIApplication;
    class function GetDefaultFastCGIApplication: TFCGIApplication;
    class function FastCGIApplicationIsNil: Boolean;
    class procedure SetPort(const AValue: Integer); static;
    class procedure SetHost(const AValue: string); static;
    class function GetPort: Integer; static;
    class function GetDefaultPort: Integer; static;
    class function GetDefaultHost: string; static;
    class function GetHost: string; static;
    class procedure InternalListen; virtual;
    class procedure DoGetModule(Sender: TObject; ARequest: TRequest; var ModuleClass: TCustomHTTPModuleClass);
  public
    class property Host: string read GetHost write SetHost;
    class property Port: Integer read GetPort write SetPort;
    class procedure Listen; overload; override;
    class procedure Listen(const APort: Integer; const AHost: string = '0.0.0.0'; const ACallback: TProc<T> = nil); reintroduce; overload; static;
    class procedure Listen(const APort: Integer; const ACallback: TProc<T>); reintroduce; overload; static;
    class procedure Listen(const AHost: string; const ACallback: TProc<T> = nil); reintroduce; overload; static;
    class procedure Listen(const ACallback: TProc<T>); reintroduce; overload; static;
  end;
{$ENDIF}

implementation

{$IF DEFINED(FPC) AND DEFINED(HORSE_FCGI)}
uses Horse.WebModule;

class function THorseProvider<T>.GetDefaultFastCGIApplication: TFCGIApplication;
begin
  if FastCGIApplicationIsNil then
    FFastCGIApplication := Application;
  Result := FFastCGIApplication;
end;

class function THorseProvider<T>.FastCGIApplicationIsNil: Boolean;
begin
  Result := FFastCGIApplication = nil;
end;

class function THorseProvider<T>.GetDefaultHost: string;
begin
  Result := DEFAULT_HOST;
end;

class function THorseProvider<T>.GetDefaultPort: Integer;
begin
  Result := -1;
end;

class function THorseProvider<T>.GetHost: string;
begin
  Result := FHost;
end;

class function THorseProvider<T>.GetPort: Integer;
begin
  Result := FPort;
end;

class procedure THorseProvider<T>.InternalListen;
var
  LFastCGIApplication: TFCGIApplication;
begin
  inherited;
  if FHost.IsEmpty then
    FHost := GetDefaultHost;
  LFastCGIApplication := GetDefaultFastCGIApplication;
  LFastCGIApplication.AllowDefaultModule := True;
  LFastCGIApplication.OnGetModule := DoGetModule;
  LFastCGIApplication.Port := FPort;
  LFastCGIApplication.LegacyRouting := True;
  LFastCGIApplication.Address := FHost;
  LFastCGIApplication.Initialize;
  FRunning := True;
  DoOnListen;
  LFastCGIApplication.Run;
end;

class procedure THorseProvider<T>.DoGetModule(Sender: TObject; ARequest: TRequest; var ModuleClass: TCustomHTTPModuleClass);
begin
  ModuleClass := THorseWebModule;
end;

class procedure THorseProvider<T>.Listen;
begin
  InternalListen;;
end;

class procedure THorseProvider<T>.Listen(const APort: Integer; const AHost: string; const ACallback: TProc<T>);
begin
  SetPort(APort);
  SetHost(AHost);
  SetOnListen(ACallback);
  InternalListen;
end;

class procedure THorseProvider<T>.Listen(const AHost: string; const ACallback: TProc<T>);
begin
  Listen(FPort, AHost, ACallback);
end;

class procedure THorseProvider<T>.Listen(const ACallback: TProc<T>);
begin
  Listen(FPort, FHost, ACallback);
end;

class procedure THorseProvider<T>.Listen(const APort: Integer; const ACallback: TProc<T>);
begin
  Listen(APort, FHost, ACallback);
end;

class procedure THorseProvider<T>.SetHost(const AValue: string);
begin
  FHost := AValue;
end;

class procedure THorseProvider<T>.SetPort(const AValue: Integer);
begin
  FPort := AValue;
end;
{$ENDIF}

end.
