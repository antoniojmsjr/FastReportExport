object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Exportar Fast Report'
  ClientHeight = 126
  ClientWidth = 244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 19
    Width = 24
    Height = 13
    Caption = 'Port:'
  end
  object btnStop: TBitBtn
    Left = 104
    Top = 50
    Width = 90
    Height = 25
    Caption = 'Stop'
    Enabled = False
    TabOrder = 0
    OnClick = btnStopClick
  end
  object btnStart: TBitBtn
    Left = 8
    Top = 50
    Width = 90
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = btnStartClick
  end
  object edtPort: TEdit
    Left = 38
    Top = 16
    Width = 156
    Height = 21
    NumbersOnly = True
    TabOrder = 2
    Text = '9000'
  end
  object btnBrowser: TButton
    Left = 8
    Top = 88
    Width = 90
    Height = 25
    Caption = 'Export'
    Enabled = False
    TabOrder = 3
    OnClick = btnBrowserClick
  end
end
