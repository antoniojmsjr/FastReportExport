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
unit FRExport;

interface

uses
  frxClass, FRExport.Interfaces, FRExport.Core;

type

  TFRExport = class(TFRExportCustom)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function New: IFRExport;
  end;

  TFRExportProviderPDF = class(TFRExportProviderPDFCustom);
  TFRExportProviderHTML = class(TFRExportProviderHTMLCustom);
  TFRExportProviderPNG = class(TFRExportProviderPNGCustom);
  TFRExportProviderCSV = class(TFRExportProviderCSVCustom);
  TFRExportProviderRTF = class(TFRExportProviderRTFCustom);

implementation

{ TFRExport }

class function TFRExport.New: IFRExport;
begin
  Result := Self.Create;
end;

end.
