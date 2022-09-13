object frmMain: TfrmMain
  Left = 0
  Top = 0
  ActiveControl = btnRequest
  Caption = 'Client request Fast Report Export'
  ClientHeight = 361
  ClientWidth = 459
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 475
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 60
    Width = 459
    Height = 5
    Align = alTop
    Shape = bsTopLine
    ExplicitWidth = 531
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 459
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlHeader'
    ShowCaption = False
    TabOrder = 0
    object lblURLTitle: TLabel
      Left = 10
      Top = 10
      Width = 19
      Height = 13
      Caption = 'URL'
    end
    object edtURL: TEdit
      Left = 10
      Top = 29
      Width = 300
      Height = 21
      TabOrder = 0
      Text = 'http://localhost:9000/export/43'
    end
    object btnRequest: TButton
      Left = 322
      Top = 27
      Width = 130
      Height = 25
      Caption = 'Request'
      TabOrder = 1
      OnClick = btnRequestClick
    end
  end
  object vledtResponseHeaders: TValueListEditor
    Left = 0
    Top = 65
    Width = 459
    Height = 266
    Align = alClient
    BorderStyle = bsNone
    KeyOptions = [keyEdit]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goRowSelect, goThumbTracking]
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitHeight = 366
    ColWidths = (
      197
      260)
  end
  object btnOpenFile: TButton
    Left = 0
    Top = 331
    Width = 459
    Height = 30
    Align = alBottom
    Caption = 'Open File'
    TabOrder = 2
    OnClick = btnOpenFileClick
    ExplicitTop = 431
  end
  object NetHTTPClient: TNetHTTPClient
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    HandleRedirects = True
    AllowCookies = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 144
  end
  object NetHTTPRequest: TNetHTTPRequest
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    Client = NetHTTPClient
    Left = 208
  end
end
