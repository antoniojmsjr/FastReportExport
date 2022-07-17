unit Data;

interface

uses
  FireDAC.Comp.Client, System.SysUtils;

type
  TData = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure QryEstadosBrasil(pFDConnection: TFDConnection; var pQuery: TFDQuery);
    class procedure QryMunicipioEstado(pFDConnection: TFDConnection; var pQuery: TFDQuery);
    class procedure QryMunicipioRegiao(pFDConnection: TFDConnection; var pQuery: TFDQuery);
    class procedure QryEstadoRegiao(pFDConnection: TFDConnection; var pQuery: TFDQuery);
    class procedure QryMunicipios(pFDConnection: TFDConnection; var pQuery: TFDQuery;
                                  const pEstadoID: Integer = 0);
  end;

implementation

uses
  Utils;

{ TData }

class procedure TData.QryEstadoRegiao(pFDConnection: TFDConnection; var pQuery: TFDQuery);
var
  lSQL: TStringBuilder;
  lError: string;
begin
  lSQL := nil;
  try
    pQuery := TFDQuery.Create(pFDConnection);
    pQuery.Connection := pFDConnection;

    lSQL := TStringBuilder.Create;
    lSQL.Append('SELECT');
    lSQL.Append('  TB2.ID, TB2.NOME, COUNT(1) AS ESTADO_QTD ');
    lSQL.Append('FROM');
    lSQL.Append('  ESTADO TB1 ');
    lSQL.Append('INNER JOIN');
    lSQL.Append('  REGIAO TB2 ');
    lSQL.Append('ON');
    lSQL.Append('  TB1.REGIAO_ID = TB2.ID ');
    lSQL.Append('GROUP BY');
    lSQL.Append('  TB2.ID, TB2.NOME');

    if not TUtils.QueryOpen(pQuery, lSQL.ToString, lError) then
      raise Exception.CreateFmt('Erro consulta - QryEstadoRegiao: %s', [lError]);
  finally
    lSQL.Free;
  end;
end;

class procedure TData.QryEstadosBrasil(pFDConnection: TFDConnection; var pQuery: TFDQuery);
var
  lSQL: TStringBuilder;
  lError: string;
begin
  lSQL := nil;
  try
    pQuery := TFDQuery.Create(pFDConnection);
    pQuery.Connection := pFDConnection;

    lSQL := TStringBuilder.Create;
    lSQL.Append('SELECT');
    lSQL.Append('  TB1.ID AS ESTADO_ID, TB1.NOME AS ESTADO_NOME,');
    lSQL.Append('  TB2.ID AS REGIAO_ID, TB2.NOME AS REGIAO_NOME ');
    lSQL.Append('FROM');
    lSQL.Append('  ESTADO TB1 ');
    lSQL.Append('INNER JOIN');
    lSQL.Append('  REGIAO TB2 ');
    lSQL.Append('ON');
    lSQL.Append('  TB1.REGIAO_ID = TB2.ID ');
    lSQL.Append('ORDER BY');
    lSQL.Append('  TB2.ID, TB1.NOME ASC');

    if not TUtils.QueryOpen(pQuery, lSQL.ToString, lError) then
      raise Exception.CreateFmt('Erro consulta - QryEstadosBrasil: %s', [lError]);
  finally
    lSQL.Free;
  end;
end;

class procedure TData.QryMunicipioEstado(pFDConnection: TFDConnection; var pQuery: TFDQuery);
var
  lSQL: TStringBuilder;
  lError: string;
begin
  lSQL := nil;
  try
    pQuery := TFDQuery.Create(pFDConnection);
    pQuery.Connection := pFDConnection;

    lSQL := TStringBuilder.Create;
    lSQL.Append('SELECT');
    lSQL.Append('  ESTADO_ID, ESTADO_NOME, COUNT(1) AS MUNICIPIO_QTD ');
    lSQL.Append('FROM');
    lSQL.Append('  VW_LOCALIDADES ');
    lSQL.Append('GROUP BY');
    lSQL.Append('  ESTADO_ID, ESTADO_NOME');

    if not TUtils.QueryOpen(pQuery, lSQL.ToString, lError) then
      raise Exception.CreateFmt('Erro consulta - QryMunicipioEstado: %s', [lError]);
  finally
    lSQL.Free;
  end;
end;

class procedure TData.QryMunicipioRegiao(pFDConnection: TFDConnection; var pQuery: TFDQuery);
var
  lSQL: TStringBuilder;
  lError: string;
begin
  lSQL := nil;
  try
    pQuery := TFDQuery.Create(pFDConnection);
    pQuery.Connection := pFDConnection;

    lSQL := TStringBuilder.Create;
    lSQL.Append('SELECT');
    lSQL.Append('  REGIAO_ID, REGIAO_NOME, COUNT(1) AS MUNICIPIO_QTD ');
    lSQL.Append('FROM');
    lSQL.Append('  VW_LOCALIDADES ');
    lSQL.Append('GROUP BY');
    lSQL.Append('  REGIAO_ID, REGIAO_NOME');

    if not TUtils.QueryOpen(pQuery, lSQL.ToString, lError) then
      raise Exception.CreateFmt('Erro consulta - QryMunicipioRegiao: %s', [lError]);
  finally
    lSQL.Free;
  end;
end;

class procedure TData.QryMunicipios(pFDConnection: TFDConnection;
  var pQuery: TFDQuery; const pEstadoID: Integer);
var
  lSQL: TStringBuilder;
  lError: string;
begin
  lSQL := nil;
  try
    pQuery := TFDQuery.Create(pFDConnection);
    pQuery.Connection := pFDConnection;

    lSQL := TStringBuilder.Create;
    lSQL.Append('SELECT');
    lSQL.Append('  MUNICIPIO_ID, MUNICIPIO_NOME, ');
    lSQL.Append('  ESTADO_ID, ESTADO_NOME, ');
    lSQL.Append('  REGIAO_ID, REGIAO_NOME ');
    lSQL.Append('FROM ');
    lSQL.Append('  VW_LOCALIDADES ');
    if (pEstadoID > 0) then
      lSQL.Append(Format('WHERE ESTADO_ID  = %d ', [pEstadoID]));
    lSQL.Append('ORDER BY');
    lSQL.Append('  REGIAO_ID, ESTADO_NOME, MUNICIPIO_NOME');

    if not TUtils.QueryOpen(pQuery, lSQL.ToString, lError) then
      raise Exception.CreateFmt('Erro consulta - QryMunicipios: %s', [lError]);
  finally
    lSQL.Free;
  end;
end;

end.
