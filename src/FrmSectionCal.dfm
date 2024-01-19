object FrameSectionCal: TFrameSectionCal
  Left = 0
  Top = 0
  Width = 875
  Height = 482
  TabOrder = 0
  object GBoxHRBalance: TGroupBox
    Left = 0
    Top = 0
    Width = 217
    Height = 482
    Align = alLeft
    Caption = 'Section Calculation'
    TabOrder = 0
    object StrGridSectionCal: TRzStringGrid
      Left = 2
      Top = 15
      Width = 213
      Height = 465
      Align = alClient
      TabOrder = 0
    end
  end
  object GBoxFinalIndex: TGroupBox
    Left = 217
    Top = 0
    Width = 216
    Height = 482
    Align = alLeft
    Caption = 'Final Index'
    TabOrder = 1
    object StrGridFinalIndex: TRzStringGrid
      Left = 2
      Top = 15
      Width = 212
      Height = 465
      Align = alClient
      TabOrder = 0
    end
  end
  object RzToolbar1: TRzToolbar
    Left = 792
    Top = 0
    Width = 83
    Height = 482
    Align = alRight
    AutoStyle = False
    BorderInner = fsBump
    BorderOuter = fsBump
    BorderSides = [sdTop, sdBottom]
    BorderWidth = 0
    TabOrder = 2
    ToolbarControls = (
      BtnClear
      BtnRefresh
      BtnIteration
      BtnCheck)
    object BtnClear: TButton
      Left = 4
      Top = 2
      Width = 75
      Height = 25
      Action = actClear
      TabOrder = 0
    end
    object BtnRefresh: TButton
      Left = 4
      Top = 27
      Width = 75
      Height = 25
      Action = actRefresh
      TabOrder = 1
    end
    object BtnIteration: TButton
      Left = 4
      Top = 52
      Width = 75
      Height = 25
      Action = actIteration
      TabOrder = 2
    end
    object BtnCheck: TButton
      Left = 4
      Top = 77
      Width = 75
      Height = 25
      Action = actCheck
      TabOrder = 3
    end
  end
  object ActionList1: TActionList
    Left = 392
    Top = 272
    object actRefresh: TAction
      Caption = 'Refresh'
      OnExecute = actRefreshExecute
    end
    object actClear: TAction
      Caption = 'Clear'
      OnExecute = actClearExecute
    end
    object actCalculate: TAction
      Caption = 'Calculate'
    end
    object actCheck: TAction
      Caption = 'Check'
      OnExecute = actCheckExecute
    end
    object actIteration: TAction
      Caption = 'Iteration'
      OnExecute = actIterationExecute
    end
  end
end
