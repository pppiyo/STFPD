object FrameCoupling: TFrameCoupling
  Left = 0
  Top = 0
  Width = 900
  Height = 571
  TabOrder = 0
  object RzToolbar1: TRzToolbar
    Left = 817
    Top = 0
    Width = 83
    Height = 571
    Align = alRight
    AutoStyle = False
    BorderInner = fsBump
    BorderOuter = fsBump
    BorderSides = [sdTop, sdBottom]
    BorderWidth = 0
    TabOrder = 0
    ToolbarControls = (
      BtnRefresh
      BtnDefault
      BtnConfirmBase
      BtnAutoRevise
      BtnDrawHSGraph)
    object BtnRefresh: TButton
      Left = 4
      Top = 2
      Width = 75
      Height = 25
      Action = actRefresh
      TabOrder = 0
    end
    object BtnDefault: TButton
      Left = 4
      Top = 27
      Width = 75
      Height = 25
      Action = actDefault
      TabOrder = 1
    end
    object BtnConfirmBase: TButton
      Left = 4
      Top = 52
      Width = 75
      Height = 25
      Action = actChooseAdjBase
      Caption = 'Confirm Base'
      TabOrder = 2
    end
    object BtnAutoRevise: TButton
      Left = 4
      Top = 77
      Width = 75
      Height = 25
      Action = actAutoRevise
      Caption = 'Calculate'
      TabOrder = 3
    end
    object BtnDrawHSGraph: TButton
      Left = 4
      Top = 102
      Width = 75
      Height = 25
      Action = actDrawCouplingOut
      TabOrder = 4
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 817
    Height = 571
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object GBoxHRSysOut: TGroupBox
      Left = 1
      Top = 1
      Width = 815
      Height = 200
      Align = alTop
      Caption = 'Enthalpy Drop Division Result (Heat Regeneration System)'
      TabOrder = 0
      object StrGridHRSysOutTDPoint: TStringGrid
        Left = 2
        Top = 15
        Width = 811
        Height = 183
        Align = alClient
        RowCount = 6
        TabOrder = 0
      end
      object StrGridNewHRSysOutTDPoint: TStringGrid
        Left = 2
        Top = 15
        Width = 811
        Height = 183
        Align = alClient
        RowCount = 6
        TabOrder = 1
      end
    end
    object GBoxStageDivOut: TGroupBox
      Left = 1
      Top = 201
      Width = 815
      Height = 200
      Align = alTop
      Caption = 'Enthalpy Drop Division Result (Stage)'
      TabOrder = 1
      object StrGridStageDivOutTDPoint: TStringGrid
        Left = 2
        Top = 15
        Width = 811
        Height = 183
        Align = alClient
        RowCount = 6
        TabOrder = 0
      end
      object StrGridNewStageDivOutTDPoint: TStringGrid
        Left = 2
        Top = 15
        Width = 811
        Height = 183
        Align = alClient
        RowCount = 6
        TabOrder = 1
      end
    end
    object RGrpAdjBase: TRadioGroup
      Left = 1
      Top = 401
      Width = 168
      Height = 169
      Align = alLeft
      Caption = 'Adjustment Base'
      Items.Strings = (
        'Heat Regeneration System'
        'Stage Division'
        'Both')
      TabOrder = 2
    end
    object GBoxSuggestion: TGroupBox
      Left = 169
      Top = 401
      Width = 647
      Height = 169
      Align = alClient
      Caption = 'Division Adjustment Suggestions'
      TabOrder = 3
      object MemoDivChangeSug: TMemo
        Left = 2
        Top = 15
        Width = 643
        Height = 152
        Align = alClient
        ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
        TabOrder = 0
      end
    end
  end
  object ActionList1: TActionList
    Left = 352
    Top = 256
    object actChooseAdjBase: TAction
      Caption = 'ChooseAdjBase'
      OnExecute = actChooseAdjBaseExecute
    end
    object actRefresh: TAction
      Caption = 'Refresh'
      OnExecute = actRefreshExecute
    end
    object actDrawCouplingOut: TAction
      Caption = 'Draw'
      OnExecute = actDrawCouplingOutExecute
    end
    object actDefault: TAction
      Caption = 'Default'
      OnExecute = actDefaultExecute
    end
    object actAutoRevise: TAction
      Caption = 'Auto'
      OnExecute = actAutoReviseExecute
    end
  end
end
