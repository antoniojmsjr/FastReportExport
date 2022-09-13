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
  frxExportCSV, frxExportRTF, frxExportXLS, frxExportXLSX, frxExportDOCX;

type

  IFRExportProvider = interface
    ['{801C408B-8B7F-4288-AE41-42E836F0EACD}']
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

  IFRExportXLS = interface(IFRExportProvider)
    ['{C57D4C26-656B-4159-A229-B0B795BD14D8}']
    function GetfrxXLS: TfrxXLSExport;

    property frxXLS: TfrxXLSExport read GetfrxXLS;
  end;

  IFRExportXLSX = interface(IFRExportProvider)
    ['{E1185657-BDD7-4F28-836B-4CEB764D5D26}']
    function GetfrxXLSX: TfrxXLSXExport;

    property frxXLSX: TfrxXLSXExport read GetfrxXLSX;
  end;

  IFRExportDOCX = interface(IFRExportProvider)
    ['{F05403B5-6E5C-4088-AE62-81F3DA8A986D}']
    function GetfrxDOCX: TfrxDOCXExport;

    property frxDOCX: TfrxDOCXExport read GetfrxDOCX;
  end;

  IFRExportBMP = interface(IFRExportProvider)
    ['{2DE25CD1-ADB0-4EB4-A355-25BE4EFC816F}']
    function GetfrxBMP: TfrxBMPExport;

    property frxBMP: TfrxBMPExport read GetfrxBMP;
  end;

  IFRExportJPEG = interface(IFRExportProvider)
    ['{1F1DD580-6C83-499F-861D-8BCCC8DB3198}']
    function GetfrxJPEG: TfrxJPEGExport;

    property frxJPEG: TfrxJPEGExport read GetfrxJPEG;
  end;

implementation

end.
