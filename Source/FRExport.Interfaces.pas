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
unit FRExport.Interfaces;

interface

uses
  System.Classes, Data.DB, frxClass, frxDBSet, FRExport.Types,
  FRExport.Interfaces.Providers;

type
  IFRExportExecute = interface;
  IFRExportDataSets = interface;
  IFRExportProviders = interface;

  IFRExport = interface
    ['{BB3644C1-048D-4730-949A-9A1083E3AA72}']
    function GetFRExportExecute: IFRExportExecute;
    function GetExportDataSets: IFRExportDataSets;
    function GetExportProviders: IFRExportProviders;

    property DataSets: IFRExportDataSets read GetExportDataSets;
    property Providers: IFRExportProviders read GetExportProviders;
    property Export: IFRExportExecute read GetFRExportExecute;
  end;

  IFRExportDataSets = interface
    ['{9A66A228-A834-4273-8F42-F825FE508F87}']
    function GetEnd: IFRExport;
    function SetDataSet(DataSet: TDataSet; const UserName: string): IFRExportDataSets; overload;
    function SetDataSet(DataSet: TfrxDBDataset): IFRExportDataSets; overload;

    property &End: IFRExport read GetEnd;
  end;

  IFRExportProviders = interface
    ['{543D70DA-CFFB-413A-B29D-940BC4B8399A}']
    function GetEnd: IFRExport;
    function SetProvider(Provider: IFRExportProvider): IFRExportProviders;

    property &End: IFRExport read GetEnd;
  end;

  IFRExportExecute = interface
    ['{50125DEF-BE3B-4FD2-9819-A5D4849663F9}']
    function SetExceptionFastReport(const Value: Boolean): IFRExportExecute;
    function SetFileReport(const FileName: string): IFRExportExecute; overload;
    function SetFileReport(FileStream: TStream): IFRExportExecute; overload;
    function Report(const CallbackReport: TFRExportReportCallback): IFRExportExecute;
    procedure Execute;
  end;

implementation

end.
