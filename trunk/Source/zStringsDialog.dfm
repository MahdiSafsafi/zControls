object StringsDialog: TStringsDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'String List Editor'
  ClientHeight = 344
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    457
    344)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 441
    Height = 297
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    DesignSize = (
      441
      297)
    object LblLines: TLabel
      Left = 7
      Top = 13
      Width = 37
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = 'LblLines'
    end
    object pMemo: TMemo
      Left = 6
      Top = 31
      Width = 427
      Height = 262
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Lines.Strings = (
        'Memo1')
      ScrollBars = ssBoth
      TabOrder = 0
      OnChange = pMemoChange
    end
  end
  object BtnOk: TButton
    Left = 252
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    TabOrder = 1
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 352
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = BtnCancelClick
  end
end
