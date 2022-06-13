library ISAPI;

uses
  System.SysUtils, System.Classes, Horse, Horse.StaticFiles,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, frxClass, System.StrUtils,
  FRExport, FRExport.Interfaces, FRExport.Interfaces.Providers, FRExport.Types, //FRExport Classes
  Utils in '..\Utils\Utils.pas';

{$R *.res}

begin
  THorse.Use('/', HorseStaticFile(TUtils.PathApp, ['']));

  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Get('export',
    procedure(pReq: THorseRequest; pRes: THorseResponse; pNext: TProc)

    function GetFileName(const pFileName: string): string;
    var
      lUUID: TGuid;
    begin
      if (CreateGuid(lUUID) = S_OK) then
        Result := ReplaceStr(ReplaceStr(Format('%s-%s', [pFileName, GuidToString(lUUID)]), '{', ''), '}', '');
    end;

    var
      lFDConnection: TFDConnection;
      lQryCliente: TFDQuery;
      lError: string;
      lFRExportPDF: IFRExportPDF;
      lFRExportHTML: IFRExportHTML;
      lFRExportPNG: IFRExportPNG;
      lFileStream: TFileStream;
      lFileExportPDF: string;
      lFileExportHTML: string;
      lFileExportPNG: string;
    begin
      lFDConnection := nil;
      lQryCliente := nil;
      try
        lFDConnection := TFDConnection.Create(nil);
        lQryCliente := TFDQuery.Create(lFDConnection);
        lQryCliente.Connection := lFDConnection;

        //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
        if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
        begin
          pRes.Send('Erro de conexão: ' + lError).Status(500);
          Exit;
        end;

        //SELECT TABELA CLIENTE
        if not TUtils.QueryOpen(lQryCliente, 'SELECT * FROM CLIENTE', lError) then
        begin
          pRes.Send('Erro de consulta: ' + lError).Status(500);
          Exit;
        end;

        //EXPORT PDF/HTML/PNG

        //PROVIDER PDF
        lFRExportPDF := TFRExportProviderPDF.New;
        lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
        lFRExportPDF.frxPDF.Author := 'Antônio José Medeiros Schneider';
        lFRExportPDF.frxPDF.Creator := 'Antônio José Medeiros Schneider';

        //PROVIDER HTML
        lFRExportHTML := TFRExportProviderHTML.New;

        //PROVIDER PNG
        lFRExportPNG := TFRExportProviderPNG.New;

        //CLASSE DE EXPORTAÇÃO
        try
          TFRExport.New.
          DataSets.
            SetDataSet(lQryCliente, 'DataSetCliente').
          &End.
          Providers.
            SetProvider(lFRExportPDF).
            SetProvider(lFRExportHTML).
            SetProvider(lFRExportPNG).
          &End.
          Export.
            SetExceptionFastReport(True).
            SetFileReport(TUtils.PathAppFileReport).
            Report(procedure(pfrxReport: TfrxReport)
              var
                lfrxComponent: TfrxComponent;
                lfrxMemoView: TfrxMemoView absolute lfrxComponent;
              begin
                //CONFIGURAÇÃO DO COMPONENTE
                pfrxReport.ReportOptions.Author := 'Antônio José Medeiros Schneider';

                //PASSAGEM DE PARÂMETRO PARA O RELATÓRIO
                lfrxComponent := pfrxReport.FindObject('mmoProcess');
                if Assigned(lfrxComponent) then
                begin
                  lfrxMemoView.Memo.Clear;
                  lfrxMemoView.Memo.Text := 'ISAPI HORSE';
                end;
              end).
            Execute;
        except
          on E: Exception do
          begin
            if E is EFRExport then
              pRes.Send(E.ToString).Status(500)
            else
              pRes.Send(E.Message+' - '+E.QualifiedClassName).Status(500);
            Exit;
          end;
        end;

        //EXPORT
        Sleep(10);
        try
          //SALVAR PDF
          if Assigned(lFRExportPDF.Stream) then
          begin
            lFileStream := nil;
            try
              lFileExportPDF := Format('%s%s.%s', [TUtils.PathApp, GetFileName('Cliente'), 'pdf']);
              lFileStream := TFileStream.Create(lFileExportPDF, fmCreate);
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
              lFileExportHTML := Format('%s%s.%s', [TUtils.PathApp, GetFileName('Cliente'), 'html']);
              lFileStream := TFileStream.Create(lFileExportHTML, fmCreate);
              lFileStream.CopyFrom(lFRExportHTML.Stream, 0);
            finally
              lFileStream.Free;
            end;
          end;

          //SALVAR PNG
          if Assigned(lFRExportPNG.Stream) then
          begin
            lFileStream := nil;
            try
              lFileExportPNG := Format('%s%s.%s', [TUtils.PathApp, GetFileName('Cliente'), 'png']);
              lFileStream := TFileStream.Create(lFileExportPNG, fmCreate);
              lFileStream.CopyFrom(lFRExportPNG.Stream, 0);
            finally
              lFileStream.Free;
            end;
          end;
        except
          on E: Exception do
          begin
            pRes.Send('Export error: '+ E.Message).Status(500);
            Exit;
          end;
        end;

        pRes.
          Send(TUtils.GetHTML(pReq.RawWebRequest.Host+':'+pReq.RawWebRequest.ServerPort.ToString, lFileExportPDF, lFileExportHTML, lFileExportPNG)).
          ContentType('text/html; charset=utf-8').
          Status(200);
      finally
        lQryCliente.Close;
        lFDConnection.Free;
      end;
    end);

  THorse.Listen;
end.
