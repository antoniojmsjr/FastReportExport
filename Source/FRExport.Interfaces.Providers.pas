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
unit FRExport.Interfaces.Providers;

interface

uses
  System.Classes, frxClass, frxExportPDF, frxExportHTML, frxExportImage,
  frxExportCSV, frxExportRTF;

type

  IFRExportProvider = interface
    ['{8270560F-760C-4618-B14A-D5A583DBE218}']
    function GetfrxCustomExportFilter: TfrxCustomExportFilter;
    function GetName: string;
    function GetStream: TStream;

    property Stream: TStream read GetStream;
    property Name: string read GetName;
  end;

  IFRExportPDF = interface(IFRExportProvider)
    ['{B706F9B7-371C-4B77-86E7-921CAFAEFABA}']
    function GetfrxPDF: TfrxPDFExport;

    property frxPDF: TfrxPDFExport read GetfrxPDF;
  end;

  IFRExportHTML = interface(IFRExportProvider)
    ['{227479C3-5BDF-458A-AE20-8340E54820C7}']
    function GetfrxHTML: TfrxHTMLExport;

    property frxHTML: TfrxHTMLExport read GetfrxHTML;
  end;

  IFRExportPNG = interface(IFRExportProvider)
    ['{275CE260-3C9E-4ECB-A31C-E5103AE5E4C5}']
    function GetfrxPNG: TfrxPNGExport;

    property frxPNG: TfrxPNGExport read GetfrxPNG;
  end;

  IFRExportCSV = interface(IFRExportProvider)
    ['{54A9E434-16E6-49B5-86D9-6E157FBE810B}']
    function GetfrxCSV: TfrxCSVExport;

    property frxCSV: TfrxCSVExport read GetfrxCSV;
  end;

  IFRExportRTF = interface(IFRExportProvider)
    ['{831B3B9F-9F50-4FF2-9F5F-0F37F115A4D5}']
    function GetfrxRTF: TfrxRTFExport;

    property frxRTF: TfrxRTFExport read GetfrxRTF;
  end;

implementation

end.
