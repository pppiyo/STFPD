object FrameStageCal: TFrameStageCal
  Left = 0
  Top = 0
  Width = 992
  Height = 635
  TabOrder = 0
  object RzToolbar1: TRzToolbar
    Left = 909
    Top = 0
    Width = 83
    Height = 635
    Align = alRight
    AutoStyle = False
    BorderInner = fsBump
    BorderOuter = fsBump
    BorderSides = [sdTop, sdBottom]
    BorderWidth = 0
    TabOrder = 0
    ToolbarControls = (
      BtnRefresh
      BtnClearV
      BtnDefault
      BtnCalculate
      BtnDrawCurve
      BtnStageOpt
      BtnLoadSaved)
    object BtnRefresh: TButton
      Left = 4
      Top = 2
      Width = 75
      Height = 25
      Action = actRefresh
      TabOrder = 0
    end
    object BtnClearV: TButton
      Left = 4
      Top = 27
      Width = 75
      Height = 25
      Action = actClear
      Caption = 'Clear'
      TabOrder = 1
    end
    object BtnDefault: TButton
      Left = 4
      Top = 52
      Width = 75
      Height = 25
      Action = actDefault
      Caption = 'Default'
      TabOrder = 2
    end
    object BtnCalculate: TButton
      Left = 4
      Top = 77
      Width = 75
      Height = 25
      Cursor = crDrag
      Action = actCalculate
      Caption = 'Calculate'
      TabOrder = 3
    end
    object BtnDrawCurve: TButton
      Left = 4
      Top = 102
      Width = 75
      Height = 25
      Action = actDraw
      Caption = 'Draw'
      TabOrder = 4
    end
    object BtnStageOpt: TButton
      Left = 4
      Top = 127
      Width = 75
      Height = 25
      Action = actStageOpt
      TabOrder = 5
    end
    object BtnLoadSaved: TButton
      Left = 4
      Top = 152
      Width = 75
      Height = 25
      Caption = 'Load Saved'
      TabOrder = 6
      OnClick = BtnLoadSavedClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 225
    Height = 635
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 1
    object GBoxGSDesignInput: TGroupBox
      Left = 1
      Top = 1
      Width = 223
      Height = 288
      Align = alTop
      Caption = 'Government Stage Design Parameters'
      TabOrder = 0
      object StrGridGSDesignInput: TRzStringGrid
        Left = 2
        Top = 15
        Width = 219
        Height = 271
        Align = alClient
        TabOrder = 0
      end
    end
    object GBoxHRSys: TGroupBox
      Left = 1
      Top = 289
      Width = 223
      Height = 345
      Align = alClient
      Caption = 'Steam Extraction Information'
      TabOrder = 1
      object StrGridSteamExtraInfo: TRzStringGrid
        Left = 2
        Top = 15
        Width = 219
        Height = 328
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object GBoxPSDesignInput: TGroupBox
    Left = 225
    Top = 0
    Width = 684
    Height = 635
    Align = alClient
    Caption = 'Pressure Stage Design Parameters'
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 2
      Top = 15
      Width = 680
      Height = 194
      Align = alTop
      Caption = 'Automatic Inputs'
      TabOrder = 0
      object StrGridPSAutoInput: TRzStringGrid
        Left = 2
        Top = 15
        Width = 676
        Height = 177
        Align = alClient
        TabOrder = 0
      end
    end
    object GroupBox2: TGroupBox
      Left = 2
      Top = 209
      Width = 680
      Height = 351
      Align = alClient
      Caption = 'Manual Inputs'
      TabOrder = 1
      object StrGridPSManualInput: TRzStringGrid
        Left = 2
        Top = 15
        Width = 676
        Height = 334
        Align = alClient
        TabOrder = 0
        RowHeights = (
          18
          18
          18
          18
          18)
      end
      object StrGridPSManualInput2: TRzStringGrid
        Left = 2
        Top = 15
        Width = 676
        Height = 334
        Align = alClient
        TabOrder = 1
      end
    end
    object GroupBox3: TGroupBox
      Left = 2
      Top = 560
      Width = 680
      Height = 73
      Align = alBottom
      Caption = 'Automatic Settings'
      TabOrder = 2
      object StrGridPSAutoOutput: TRzStringGrid
        Left = 2
        Top = 15
        Width = 676
        Height = 56
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object ActionList1: TActionList
    Left = 392
    Top = 272
    object actDefault: TAction
      Caption = 'actDefault'
      OnExecute = actDefaultExecute
    end
    object actClear: TAction
      Caption = 'actClear'
      OnExecute = actClearExecute
    end
    object actCalculate: TAction
      Caption = 'actCalculate'
      OnExecute = actCalculateExecute
    end
    object actDraw: TAction
      Caption = 'actDraw'
      OnExecute = actDrawExecute
    end
    object actStageOpt: TAction
      Caption = 'Random Input'
      OnExecute = actStageOptExecute
    end
    object actGetPSStage2: TAction
      Caption = 'Alternative'
      OnExecute = actGetPSStage2Execute
    end
    object actRefresh: TAction
      Caption = 'Refresh'
      OnExecute = actRefreshExecute
    end
  end
end
