object GraphicDialog: TGraphicDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Icon Editor'
  ClientHeight = 286
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object BtnSave: TButton
    Left = 272
    Top = 253
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 0
    OnClick = BtnSaveClick
  end
  object BtnCancel: TButton
    Left = 176
    Top = 253
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object BtnLoad: TButton
    Left = 47
    Top = 253
    Width = 99
    Height = 25
    Caption = 'Load...'
    TabOrder = 2
    OnClick = BtnLoadClick
  end
  object Panel1: TPanel
    Left = 2
    Top = 6
    Width = 370
    Height = 241
    BevelInner = bvLowered
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 3
    object Image1: TImage
      Left = 9
      Top = 8
      Width = 351
      Height = 225
      Center = True
    end
  end
  object opd: TOpenDialog
    Left = 168
    Top = 128
  end
end
