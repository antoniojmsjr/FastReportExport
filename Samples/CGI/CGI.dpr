program CGI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  Horse,
  Horse.StaticFiles,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  frxClass,
  System.StrUtils,
  FRExport,
  FRExport.Interfaces,
  FRExport.Interfaces.Providers,
  FRExport.Types,
  Utils in '..\Utils\Utils.pas',
  Data in '..\Utils\Data.pas';

begin
  THorse.Use('/', HorseStaticFile(TUtils.PathApp, ['']));

  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Get('export/:estadoid',
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
      lQryEstadosBrasil: TFDQuery;
      lQryMunicipioEstado: TFDQuery;
      lQryMunicipioRegiao: TFDQuery;
      lQryEstadoRegiao: TFDQuery;
      lQryMunicipios: TFDQuery;
      lFRExportPDF: IFRExportPDF;
      lFileStream: TFileStream;
      lError: string;
      lFileExportPDF: string;
      lFiltro: Integer;
    begin
      lFiltro := pReq.Params.Field('estadoid').AsInteger;
      lFDConnection := nil;
      try
        lFDConnection := TFDConnection.Create(nil);

        //CONEX�O COM O BANCO DE DADOS DE EXEMPLO
        if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
        begin
          pRes.Send('Erro de conex�o: ' + lError).Status(500);
          Exit;
        end;

        //CONSULTA BANCO DE DADOS
        try
          TData.QryEstadosBrasil(lFDConnection, lQryEstadosBrasil);
          TData.QryMunicipioEstado(lFDConnection, lQryMunicipioEstado);
          TData.QryMunicipioRegiao(lFDConnection, lQryMunicipioRegiao);
          TData.QryEstadoRegiao(lFDConnection, lQryEstadoRegiao);
          TData.QryMunicipios(lFDConnection, lQryMunicipios, lFiltro);
        except
          on E: Exception do
          begin
            pRes.Send(E.Message).Status(500);
            Exit;
          end;
        end;

        //EXPORT

        //PROVIDER PDF
        lFRExportPDF := TFRExportProviderPDF.New;
        lFRExportPDF.frxPDF.Subject := 'Samples Fast Report Export';
        lFRExportPDF.frxPDF.Author := 'Ant�nio Jos� Medeiros Schneider';
        lFRExportPDF.frxPDF.Creator := 'Ant�nio Jos� Medeiros Schneider';

        //CLASSE DE EXPORTA��O
        try
          TFRExport.New.
          DataSets.
            SetDataSet(lQryEstadosBrasil, 'EstadosBrasil').
            SetDataSet(lQryMunicipioEstado, 'MunicipioEstado').
            SetDataSet(lQryMunicipioRegiao, 'MunicipioRegiao').
            SetDataSet(lQryEstadoRegiao, 'EstadoRegiao').
            SetDataSet(lQryMunicipios, 'Municipios').
          &End.
          Providers.
            SetProvider(lFRExportPDF).
          &End.
          Export.
            SetExceptionFastReport(True).
            SetFileReport(TUtils.PathAppFileReport). //LOCAL DO RELAT�RIO *.fr3
            Report(procedure(pfrxReport: TfrxReport) //CONFIGURA��O DO COMPONENTE DE RELAT�RIO DO FAST REPORT
            var
              lfrxComponent: TfrxComponent;
              lfrxMemoView: TfrxMemoView absolute lfrxComponent;
            begin
              //CONFIGURA��O DO COMPONENTE
              pfrxReport.ReportOptions.Author := 'Ant�nio Jos� Medeiros Schneider';

              //PASSAGEM DE PAR�METRO PARA O RELAT�RIO
              lfrxComponent := pfrxReport.FindObject('mmoProcess');
              if Assigned(lfrxComponent) then
              begin
                lfrxMemoView.Memo.Clear;
                lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['CGI HORSE']);
              end;
            end).
            Execute; //PROCESSAMENTO DO RELAT�RIO
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
        Sleep(1);
        try

          //SALVAR PDF
          if Assigned(lFRExportPDF.Stream) then
          begin
            lFileStream := nil;
            try
              lFileExportPDF := Format('%s%s.%s', [TUtils.PathApp, GetFileName('LocalidadesIBGE'), 'pdf']);
              lFileStream := TFileStream.Create(lFileExportPDF, fmCreate);
              lFileStream.CopyFrom(lFRExportPDF.Stream, 0);

              //ENVIO DO ARQUIVO
              pRes.SendFile(lFRExportPDF.Stream, 'LocalidadesIBGE.pdf', 'application/pdf');
            finally
              FreeAndNil(lFileStream);
            end;
          end;

        except
          on E: Exception do
          begin
            pRes.Send('Export error: '+ E.Message).Status(500);
            Exit;
          end;
        end;

      finally
        lFDConnection.Free;
      end;
    end);

  THorse.Listen;
end.
