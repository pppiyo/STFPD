object FrameHRSys: TFrameHRSys
  Left = 0
  Top = 0
  Width = 887
  Height = 572
  TabOrder = 0
  object RzToolbar1: TRzToolbar
    Left = 804
    Top = 0
    Width = 83
    Height = 572
    Align = alRight
    AutoStyle = False
    BorderInner = fsBump
    BorderOuter = fsBump
    BorderSides = [sdTop, sdBottom]
    BorderWidth = 0
    TabOrder = 0
    ToolbarControls = (
      BtnClearV
      BtnDefault
      BtnCalculate
      BtnDraw
      BtnSave
      BtnLoadSaved)
    object BtnClearV: TButton
      Left = 4
      Top = 2
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 0
      OnClick = BtnClearVClick
    end
    object BtnDefault: TButton
      Left = 4
      Top = 27
      Width = 75
      Height = 25
      Caption = 'Default'
      TabOrder = 1
      OnClick = BtnDefaultClick
    end
    object BtnCalculate: TButton
      Left = 4
      Top = 52
      Width = 75
      Height = 25
      Caption = 'Calculate'
      TabOrder = 2
      OnClick = BtnCalculateClick
    end
    object BtnDraw: TButton
      Left = 4
      Top = 77
      Width = 75
      Height = 25
      Caption = 'Draw'
      TabOrder = 3
      OnClick = BtnDrawClick
    end
    object BtnSave: TButton
      Left = 4
      Top = 102
      Width = 75
      Height = 25
      Caption = 'Save'
      TabOrder = 4
      OnClick = BtnSaveClick
    end
    object BtnLoadSaved: TButton
      Left = 4
      Top = 127
      Width = 75
      Height = 25
      Caption = 'Load Saved'
      TabOrder = 5
      OnClick = BtnLoadSavedClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 804
    Height = 572
    Align = alClient
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 802
      Height = 185
      Align = alTop
      TabOrder = 0
      object Image1: TImage
        Left = 114
        Top = 1
        Width = 687
        Height = 183
        Align = alClient
      end
      object GBoxBleed: TGroupBox
        Left = 1
        Top = 1
        Width = 113
        Height = 183
        Align = alLeft
        Caption = 'Extractions'
        TabOrder = 0
        object SpinnerZHR: TRzSpinner
          Left = 16
          Top = 48
          Max = 5
          Min = 1
          Value = 1
          OnChange = SpinnerZHRChange
          ParentColor = False
          TabOrder = 0
        end
        object PanelSteamExtraction: TPanel
          Left = 8
          Top = 18
          Width = 49
          Height = 25
          BevelOuter = bvNone
          Caption = 'Stage#'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object GBoxDA: TGroupBox
          Left = 8
          Top = 80
          Width = 97
          Height = 97
          Caption = 'Deaerator'
          TabOrder = 2
          object CBoxHasDA: TComboBox
            Left = 8
            Top = 20
            Width = 81
            Height = 21
            ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
            ItemHeight = 13
            ItemIndex = 0
            TabOrder = 0
            Text = 'Yes'
            Items.Strings = (
              'Yes'
              'No')
          end
          object LEditPeDA: TLabeledEdit
            Left = 8
            Top = 64
            Width = 81
            Height = 21
            EditLabel.Width = 41
            EditLabel.Height = 13
            EditLabel.Caption = 'Pressure'
            ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
            TabOrder = 1
            Text = '0.515'
          end
        end
      end
    end
    object GBoxHRSysInput: TGroupBox
      Left = 1
      Top = 186
      Width = 802
      Height = 192
      Align = alTop
      Caption = 'GBoxHRSysInput'
      TabOrder = 1
      object StrGridHRSysInput: TRzStringGrid
        Left = 2
        Top = 15
        Width = 798
        Height = 175
        Align = alClient
        TabOrder = 0
        RowHeights = (
          18
          18
          18
          18
          18)
      end
    end
    object GBoxHRSysOutput: TGroupBox
      Left = 1
      Top = 378
      Width = 802
      Height = 193
      Align = alClient
      Caption = 'GBoxHRSysOutput'
      TabOrder = 2
      object StrGridHRSysOutput: TRzStringGrid
        Left = 2
        Top = 15
        Width = 798
        Height = 176
        Align = alClient
        TabOrder = 0
      end
    end
  end
end
