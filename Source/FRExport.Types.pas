{******************************************************************************}
{                                                                              }
{           FRExport                                                           }
{                                                                              }
{           Copyright (C) Antônio José Medeiros Schneider Júnior               }
{                                                                              }
{           https://github.com/antoniojmsjr/FastReportExport                   }
{                                                                              }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit FRExport.Types;

interface

uses
  frxClass, System.Classes, System.SysUtils;

type
  TFRExportReportCallback = reference to procedure(frxReport: TfrxReport);

  EFRExport = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
    FMessage: string;
  public
    { public declarations }
  end;

  EFRExportFileReport = class(EFRExport)
  private
    { private declarations }
    FFileName: string;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pFileName: string; const pMessage: string);
    function ToString: string; override;
    property FileName: string read FFileName;
  end;

  EFRExportProvider = class(EFRExport)
  private
    { private declarations }
    FProvider: string;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pProvider: string; const pMessage: string);
    function ToString: string; override;
    property Provider: string read FProvider;
  end;

  EFRExportPrepareReport = class(EFRExport)
  private
    { private declarations }
    FMessages: TStrings;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pMessages: TStrings);
    destructor Destroy; override;
    function ToString: string; override;
    property Messages: TStrings read FMessages;
  end;

implementation

{$REGION 'EFRExportProvider'}
constructor EFRExportProvider.Create(const pProvider: string;
  const pMessage: string);
begin
  inherited Create('See ToString.');
  FProvider := pProvider;
  FMessage := pMessage;
end;

function EFRExportProvider.ToString: string;
begin
  Result := EmptyStr;
  Result := Concat(Result, 'Export Providers', sLineBreak, sLineBreak);
  Result := Concat(Result, 'Provider: ', FProvider, sLineBreak);
  Result := Concat(Result, 'Message: ', FMessage);
end;
{$ENDREGION}

{$REGION 'EFRExportPrepareReport'}
constructor EFRExportPrepareReport.Create(const pMessages: TStrings);
begin
  inherited Create('See ToString.');

  FMessages := TStringList.Create;
  FMessages.AddStrings(pMessages);
end;

destructor EFRExportPrepareReport.Destroy;
begin
  FMessages.Free;
  inherited Destroy;
end;

function EFRExportPrepareReport.ToString: string;
var
  I: Integer;
begin
  Result := EmptyStr;
  Result := Concat(Result, 'Prepare Report', sLineBreak, sLineBreak);
  for I := 0 to Pred(FMessages.Count) do
    Result := Concat(Result, '* ', FMessages.Strings[I], sLineBreak);
end;
{$ENDREGION}

{$REGION 'EFRExportFileReport'}
constructor EFRExportFileReport.Create(const pFileName: string;
  const pMessage: string);
begin
  inherited Create('See ToString.');
  FFileName := pFileName;
  FMessage := pMessage;
end;

function EFRExportFileReport.ToString: string;
begin
  Result := EmptyStr;
  Result := Concat(Result, 'Export File', sLineBreak, sLineBreak);
  Result := Concat(Result, 'File: ', FFileName, sLineBreak);
  Result := Concat(Result, 'Message: ', FMessage);
end;
{$ENDREGION}

end.
