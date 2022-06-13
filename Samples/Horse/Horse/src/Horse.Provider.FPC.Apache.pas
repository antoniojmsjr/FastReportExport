unit Horse.Provider.FPC.Apache;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

{$IF DEFINED(HORSE_APACHE) AND DEFINED(FPC)}
uses
{$IFDEF unix}
  cthreads,
{$ENDIF}
  fphttp, httpdefs, httpd24, fpApache24, custapache24, SysUtils, Classes, Horse.Provider.Abstract,
  Horse.Constants, Horse.Proc;

type
  THorseProvider<T: class> = class(THorseProviderAbstract<T>)
  private
    class var FApacheApplication: TCustomApacheApplication;
    class var FHandlerName: string;
    class var FModuleName: string;
    class var FDefaultModule: pmodule;
    class function GetDefaultApacheApplication: TCustomApacheApplication;
    class function ApacheApplicationIsNil: Boolean;
    class procedure InternalListen; virtual;
    class procedure SetHandlerName(const AValue: string); static;
    class function GetHandlerName: string; static;
    class procedure SetModuleName(const AValue: string); static;
    class function GetModuleName: string; static;
    class procedure SetDefaultModule(const AValue: pmodule); static;
    class function GetDefaultModule: pmodule; static;
    class procedure DoGetModule(Sender: TObject; ARequest: TRequest; var pmoduleClass: TCustomHTTPModuleClass);
  public
    class property HandlerName: string read GetHandlerName write SetHandlerName;
    class property ModuleName: string read GetModuleName write SetModuleName;
    class property DefaultModule: pmodule read GetDefaultModule write SetDefaultModule;
    class procedure Listen; overload; override;
    class procedure Listen(const ACallback: TProc<T>); reintroduce; overload; static;
  end;
{$ENDIF}

implementation

{$IF DEFINED(HORSE_APACHE) AND DEFINED(FPC)}
uses Horse.WebModule;

class function THorseProvider<T>.GetDefaultApacheApplication: TCustomApacheApplication;
begin
  if ApacheApplicationIsNil then
    FApacheApplication := Application;
  Result := FApacheApplication;
end;

class function THorseProvider<T>.GetDefaultModule: pmodule;
begin
  Result := FDefaultModule;
end;

class function THorseProvider<T>.GetHandlerName: string;
begin
  Result := FHandlerName;
end;

class procedure THorseProvider<T>.SetModuleName(const AValue: string);
begin
  FModuleName := AValue;
end;

class function THorseProvider<T>.GetModuleName: string;
begin
  Result:= FModuleName;
end;

class function THorseProvider<T>.ApacheApplicationIsNil: Boolean;
begin
  Result := FApacheApplication = nil;
end;

class procedure THorseProvider<T>.InternalListen;
var
  LApacheApplication: TCustomApacheApplication;
begin
  inherited;
  LApacheApplication := GetDefaultApacheApplication;
  LApacheApplication.ModuleName := FModuleName;
  LApacheApplication.HandlerName := FHandlerName;
  LApacheApplication.SetModuleRecord(FDefaultModule^);
  LApacheApplication.AllowDefaultModule := True;
  LApacheApplication.OnGetModule := DoGetModule;
  LApacheApplication.LegacyRouting := True;
  DoOnListen;
  LApacheApplication.Initialize;
end;

class procedure THorseProvider<T>.DoGetModule(Sender: TObject; ARequest: TRequest; var pmoduleClass: TCustomHTTPModuleClass);
begin
  pmoduleClass := THorseWebModule;
end;

class procedure THorseProvider<T>.SetDefaultModule(const AValue: pmodule);
begin
  FDefaultModule := AValue;
end;

class procedure THorseProvider<T>.SetHandlerName(const AValue: string);
begin
  FHandlerName := AValue;
end;

class procedure THorseProvider<T>.Listen;
begin
  InternalListen;
end;

class procedure THorseProvider<T>.Listen(const ACallback: TProc<T>);
begin
  SetOnListen(ACallback);
  InternalListen;
end;
{$ENDIF}

end.
