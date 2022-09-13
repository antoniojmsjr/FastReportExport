![Maintained YES](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square&color=important)
![Memory Leak Verified YES](https://img.shields.io/badge/Memory%20Leak%20Verified%3F-yes-green.svg?style=flat-square&color=important)
![Release](https://img.shields.io/github/v/release/antoniojmsjr/FastReportExport?label=Latest%20release&style=flat-square&color=important)
![Stars](https://img.shields.io/github/stars/antoniojmsjr/FastReportExport.svg?style=flat-square)
![Forks](https://img.shields.io/github/forks/antoniojmsjr/FastReportExport.svg?style=flat-square)
![Issues](https://img.shields.io/github/issues/antoniojmsjr/FastReportExport.svg?style=flat-square&color=blue)</br>
![Compatibility](https://img.shields.io/badge/Compatibility-VCL,%20Firemonkey,%20DataSnap,%20Horse,%20RDW,%20RADServer-3db36a?style=flat-square)
![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE7%20and%20above-3db36a?style=flat-square)
![Fastreport Supported Versions](https://img.shields.io/badge/Fast%20Report%20Supported%20Versions-5.1.5%20and%20above-3db36a?style=flat-square)

# FastReportExport

**FastReportExport** é uma biblioteca para exportação de relatórios com [Fast Report](https://www.fast-report.com) para ambientes **multithreading** e não **GUI(Graphical User Interface)**.

Implementado na linguagem Delphi, utiliza o conceito de [fluent interface](https://en.wikipedia.org/wiki/Fluent_interface) para guiar no uso da biblioteca, desenvolvido para exportar relatórios nos formatos PDF, HTML, PNG, entre outros, conforme a necessidade.

**Ambientes**

* Windows Forms
* Windows Console
* Windows Service
* IIS ISAPI[(Horse)](https://github.com/HashLoad/horse)
* IIS CGI[(Horse)](https://github.com/HashLoad/horse)

## ⭕ Pré-requisito

Para utilizar o **FastReportExport** é necessário a instalação do componente [Fast Report](https://www.fast-report.com).

## ⚙️ Instalação Automatizada

Utilizando o [**Boss**](https://github.com/HashLoad/boss/releases/latest) (Dependency manager for Delphi) é possível instalar a biblioteca de forma automática.

```
boss install github.com/antoniojmsjr/FastReportExport
```

## ⚙️ Instalação Manual

Se você optar por instalar manualmente, basta adicionar as seguintes pastas ao seu projeto, em *Project > Options > Delphi Compiler > Target > All Configurations > Search path*

```
..\FastReportExport\Source
```

## 🧬 Provedores de Exportação

**Providers** é uma interface utilizada pela biblioteca para exportação dos relatórios que disponibiliza a classe **TfrxCustomExportFilter** para configuração, e pode ser extendida para implementação de outros formatos de arquivo.

| Arquivo | Provedor | TfrxCustomExportFilter |
|---|---|---|
| PDF | IFRExportPDF | TfrxPDFExport |
| HTML | IFRExportHTML | TfrxHTMLExport |
| PNG | IFRExportPNG | TfrxPNGExport |
| BMP | IFRExportBMP | TfrxBMPExport |
| JPEG | IFRExportJPEG | TfrxJPEGExport |
| CSV | IFRExportCSV | TfrxCSVExport |
| RTF | IFRExportRTF | TfrxRTFExport |
| XLS | IFRExportXLS | TfrxXLSExport |
| XLSX | IFRExportXLSX | TfrxXLSXExport |
| DOCX | IFRExportDOCX | TfrxDOCXExport |

**Exemplo**

```delphi
var
  lFRExportPDF: IFRExportPDF;
  lFRExportHTML: IFRExportHTML;
  lFRExportPNG: IFRExportPNG;
begin

  //PROVIDER PDF
  lFRExportPDF := TFRExportProviderPDF.New;
  lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
  lFRExportPDF.frxPDF.Author := 'Antônio José Medeiros Schneider';

  //PROVIDER HTML
  lFRExportHTML := TFRExportProviderHTML.New;

  //PROVIDER PNG
  lFRExportPNG := TFRExportProviderPNG.New;
  lFRExportPNG.frxPNG.JPEGQuality := 100;

end;
```

## 🧬 DataSet de Exportação

**DataSets** é uma interface utilizada pela biblioteca para comunicação com o banco de dados através dos componentes:

| Classe | Componente |
|---|---|
| TDataSet | Nativo |
| TfrxDBDataset | Fast Report |

## ⚡️ Uso da biblioteca

Para exemplificar o uso do biblioteca foi utilizado os dados da **[API de localidades do IBGE](https://servicodados.ibge.gov.br/api/docs/localidades)** para geração e exportação do relatório.

Arquivo de exemplo da exportação: [LocalidadesIBGE.pdf](https://github.com/antoniojmsjr/FastReportExport/files/9128761/LocalidadesIBGE.pdf)

Os exemplos estão disponíveis na pasta do projeto:

```
..\FastReportExport\Samples
```

**Banco de dados de exemplo**

* Firebird: 2.5.7 [Donwload](http://sourceforge.net/projects/firebird/files/firebird-win32/2.5.7-Release/Firebird-2.5.7.27050_0_Win32.exe/download)
* Arquivo BD:
```
..\FastReportExport\Samples\DB
```

**Relatório de exemplo**

```
..\FastReportExport\Samples\Report
```
**Exemplo**

```delphi
uses FRExport, FRExport.Types, FRExport.Interfaces.Providers;
```
```delphi
var
  lFRExportPDF: IFRExportPDF;
  lFRExportHTML: IFRExportHTML;
  lFRExportPNG: IFRExportPNG;
  lFileStream: TFileStream;
  lFileExport: string;
begin

  //PROVIDER PDF
  lFRExportPDF := TFRExportProviderPDF.New;
  lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
  lFRExportPDF.frxPDF.Author := 'Antônio José Medeiros Schneider';

  //PROVIDER HTML
  lFRExportHTML := TFRExportProviderHTML.New;

  //PROVIDER PNG
  lFRExportPNG := TFRExportProviderPNG.New;
  lFRExportPNG.frxPNG.JPEGQuality := 100;

  //CLASSE DE EXPORTAÇÃO
  try
    TFRExport.New.
      DataSets.
        SetDataSet(qryEstadosBrasil, 'EstadosBrasil').
        SetDataSet(frxdbMunicipioEstado).
        SetDataSet(frxdbMunicipioRegiao).
        SetDataSet(qryEstadoRegiao, 'EstadoRegiao').
        SetDataSet(qryMunicipios, 'Municipios').
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
              lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['VCL']);
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
      lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.pdf']);
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
      lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.html']);
      lFileStream := TFileStream.Create(lFileExport, fmCreate);
      lFileStream.CopyFrom(lFRExportHTML.Stream, 0);
    finally
      FreeAndNil(lFileStream);
    end;
  end;

  //SALVAR PNG
  if Assigned(lFRExportPNG.Stream) then
  begin
    lFileStream := nil;
    try
      lFileExport := Format('%s%s', [TUtils.PathApp, 'LocalidadesIBGE.png']);
      lFileStream := TFileStream.Create(lFileExport, fmCreate);
      lFileStream.CopyFrom(lFRExportPNG.Stream, 0);
    finally
      FreeAndNil(lFileStream);
    end;
  end;
end;
```

**Exemplo compilado**

* VCL
* VCL [(Horse)](https://github.com/HashLoad/horse)

Download: [Demo.zip](https://github.com/antoniojmsjr/FastReportExport/files/9128777/Demo.zip)

**Teste de desempenho para aplicações web usando [JMeter](https://jmeter.apache.org/):**

```
..\FastReportExport\Samples\JMeter
```


https://user-images.githubusercontent.com/20980984/173268272-dc81f411-b2e5-4030-8c56-c461527f2ebc.mp4



## ⚠️ Licença
`FastReportExport` is free and open-source software licensed under the [![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://github.com/antoniojmsjr/Horse-IPGeoLocation/blob/master/LICENSE)
