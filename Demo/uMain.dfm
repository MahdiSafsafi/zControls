object Main: TMain
  Left = 0
  Top = 0
  Caption = 'zObjectInspector Demo'
  ClientHeight = 425
  ClientWidth = 773
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object zObjectInspector1: TzObjectInspector
    Left = 0
    Top = 41
    Width = 273
    Height = 384
    Align = alLeft
    Text = 'zObjectInspector1'
    Color = clWhite
    BorderStyle = bsSingle
    Component = zObjectInspector1
    TabOrder = 0
    AllowSearch = True
    AutoCompleteText = True
    DefaultCategoryName = 'Miscellaneous'
    ShowGutter = True
    GutterColor = clCream
    GutterEdgeColor = clGray
    NameColor = clBtnText
    ValueColor = clNavy
    NonDefaultValueColor = clNavy
    BoldNonDefaultValue = True
    HighlightColor = 14737632
    ReferencesColor = clMaroon
    SubPropertiesColor = clGreen
    ShowHeader = False
    ShowGridLines = False
    GridColor = clBlack
    SplitterColor = clGray
    FixedSplitter = False
    ReadOnly = False
    TrackChange = False
    GutterWidth = 12
    ShowItemHint = True
    SortByCategory = False
    HeaderPropText = 'Property'
    HeaderValueText = 'Value'
    OnBeforeAddItem = zObjectInspector1BeforeAddItem
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 773
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 14
      Width = 68
      Height = 13
      Caption = 'Peek Control :'
    end
    object ObjsCombo: TComboBox
      Left = 98
      Top = 11
      Width = 145
      Height = 21
      TabOrder = 0
      Text = 'ObjsCombo'
      OnChange = ObjsComboChange
    end
    object CheckBox2: TCheckBox
      Left = 257
      Top = 13
      Width = 97
      Height = 17
      Caption = 'Include Event'
      TabOrder = 1
      OnClick = CheckBox2Click
    end
    object BtnMultiComponents: TButton
      Left = 376
      Top = 9
      Width = 161
      Height = 25
      Caption = 'Multi Components'
      TabOrder = 2
      OnClick = BtnMultiComponentsClick
    end
  end
  object Panel2: TPanel
    Left = 273
    Top = 41
    Width = 500
    Height = 384
    Align = alClient
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 1
      Top = 42
      Width = 498
      Height = 341
      Align = alClient
      Caption = 'Controls :'
      TabOrder = 0
      object SpeedButton1: TSpeedButton
        Left = 16
        Top = 83
        Width = 121
        Height = 22
        CustomHint = BalloonHint1
        Caption = 'SpeedButton 1'
      end
      object SpeedButton2: TSpeedButton
        Left = 16
        Top = 111
        Width = 121
        Height = 22
        Caption = 'SpeedButton 2'
      end
      object Image1: TImage
        Left = 161
        Top = 120
        Width = 105
        Height = 105
      end
      object Label3: TLabel
        Left = 24
        Top = 240
        Width = 31
        Height = 13
        Caption = 'Label3'
      end
      object LabeledEdit1: TLabeledEdit
        Left = 16
        Top = 56
        Width = 121
        Height = 21
        EditLabel.Width = 61
        EditLabel.Height = 13
        EditLabel.Caption = 'LabeledEdit1'
        TabOrder = 0
      end
      object CheckBox1: TCheckBox
        Left = 16
        Top = 142
        Width = 97
        Height = 17
        Caption = 'CheckBox1'
        TabOrder = 1
      end
      object RadioButton1: TRadioButton
        Left = 16
        Top = 176
        Width = 113
        Height = 17
        Caption = 'RadioButton1'
        TabOrder = 2
      end
      object Memo1: TMemo
        Left = 272
        Top = 40
        Width = 185
        Height = 89
        Lines.Strings = (
          'Memo1')
        TabOrder = 3
      end
      object ListBox1: TListBox
        Left = 272
        Top = 160
        Width = 185
        Height = 97
        ItemHeight = 13
        TabOrder = 4
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 498
      Height = 41
      Align = alTop
      Caption = 'Panel3'
      ShowCaption = False
      TabOrder = 1
      object Label2: TLabel
        Left = 19
        Top = 17
        Width = 31
        Height = 13
        Caption = 'Style :'
      end
      object StylesCombo: TComboBox
        Left = 64
        Top = 12
        Width = 145
        Height = 21
        TabOrder = 0
        Text = 'StylesCombo'
        OnChange = StylesComboChange
      end
    end
  end
  object BalloonHint1: TBalloonHint
    Left = 384
    Top = 216
  end
end
