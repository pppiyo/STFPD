object FormMainNyHRnR: TFormMainNyHRnR
  Left = 332
  Top = 170
  Width = 907
  Height = 632
  Caption = 'FormMainNyHRnR'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object MainToolbar: TRzToolbar
    Left = 0
    Top = 0
    Width = 899
    Height = 29
    BorderInner = fsNone
    BorderOuter = fsGroove
    BorderSides = [sdTop]
    BorderWidth = 0
    TabOrder = 0
    VisualStyle = vsGradient
    ToolbarControls = (
      SBtnDrawGraph
      SBtnVTri)
    object SBtnDrawGraph: TSpeedButton
      Left = 4
      Top = 3
      Width = 23
      Height = 22
      Action = actDrawHSGraph
      Caption = 'HS'
    end
    object SBtnVTri: TSpeedButton
      Left = 27
      Top = 3
      Width = 23
      Height = 22
      Action = actDrawVTri
      Caption = #916
    end
  end
  object MainMenu: TRzGroupBar
    Left = 0
    Top = 29
    Width = 161
    Height = 466
    GradientColorStart = clBtnFace
    GradientColorStop = clBtnShadow
    GroupBorderSize = 8
    VisualStyle = vsWinXP
    Color = clBtnShadow
    ParentColor = False
    TabOrder = 1
    object RzGroupBasicDesign: TRzGroup
      Items = <
        item
          Action = actMainParams
          Caption = 'Main Parameters'
        end
        item
          Action = actGoverningStage
          Caption = 'Governing Stage'
        end
        item
          Action = actHRSys
          Caption = 'HR System'
        end
        item
          Action = actStageDiv
          Caption = 'Stage Division'
        end
        item
          Action = actCoupling
          Caption = 'Coupling'
        end
        item
          Action = actStageCal
          Caption = 'Stage Calculation'
        end
        item
          Action = actDrawHSGraph
          Caption = 'Final HSGraph'
        end
        item
          Action = actSectionCal
          Caption = 'Section Calculation'
        end
        item
          Caption = 'Item9'
        end>
      Opened = True
      OpenedHeight = 207
      Caption = 'Basic Design'
      ParentColor = False
    end
  end
  object MainStatusBar: TRzStatusBar
    Left = 0
    Top = 495
    Width = 899
    Height = 19
    BorderInner = fsNone
    BorderOuter = fsNone
    BorderSides = [sdLeft, sdTop, sdRight, sdBottom]
    BorderWidth = 0
    TabOrder = 2
    VisualStyle = vsGradient
  end
  object MainMessageBox: TRzSizePanel
    Left = 0
    Top = 514
    Width = 899
    Height = 72
    Align = alBottom
    SizeBarWidth = 7
    TabOrder = 3
    object RzMemo1: TRzMemo
      Left = 0
      Top = 8
      Width = 899
      Height = 64
      Align = alClient
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 0
    end
  end
  object WorkArea: TRzPageControl
    Left = 161
    Top = 29
    Width = 738
    Height = 466
    ActivePage = TabStageCal2
    Align = alClient
    BoldCurrentTab = True
    ShowShadow = False
    TabIndex = 6
    TabOrder = 4
    FixedDimension = 19
    object TabMainParams: TRzTabSheet
      Caption = 'MainParams'
      object DBtnMainParams: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionCancel = actGoverningStage
        ActionHelp = actCancel
        CaptionOk = 'OK'
        CaptionCancel = 'actGoverningStage'
        CaptionHelp = 'actCancel'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
    end
    object TabGoverningStage: TRzTabSheet
      Tag = 1
      Caption = 'GoverningStage'
      object DBtnGoverningStage: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionCancel = actHRSys
        ActionHelp = actMainParams
        CaptionOk = 'OK'
        CaptionCancel = 'actHRSys'
        CaptionHelp = 'actMainParams'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
    end
    object TabHRSys: TRzTabSheet
      Caption = 'HRSys'
      object DBtnHRSys: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionCancel = actStageDiv
        ActionHelp = actGoverningStage
        CaptionOk = 'OK'
        CaptionCancel = 'actStageDiv'
        CaptionHelp = 'actGoverningStage'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
    end
    object TabStageDiv: TRzTabSheet
      Caption = 'StageDivison'
      object DBtnStageDiv: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionCancel = actCoupling
        ActionHelp = actHRSys
        CaptionOk = 'OK'
        CaptionCancel = 'actCoupling'
        CaptionHelp = 'actHRSys'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
    end
    object TabCoupling: TRzTabSheet
      Caption = 'Coupling'
      object DBtnCoupling: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionCancel = actStageCal
        ActionHelp = actStageDiv
        CaptionOk = 'OK'
        CaptionCancel = 'actStageCal'
        CaptionHelp = 'actStageDiv'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
    end
    object TabStageCal: TRzTabSheet
      Caption = 'StageCalculation'
      object DBtnStageCal: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionCancel = actStageCal2
        ActionHelp = actCoupling
        CaptionOk = 'OK'
        CaptionCancel = 'actStageCal2'
        CaptionHelp = 'actCoupling'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
    end
    object TabStageCal2: TRzTabSheet
      Tag = 6
      Caption = 'StageCalculation2'
      object DBtnStageCal2: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionCancel = actSectionCal
        ActionHelp = actStageCal
        CaptionOk = 'OK'
        CaptionCancel = 'actSectionCal'
        CaptionHelp = 'actStageCal'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
    end
    object TabSectionCal: TRzTabSheet
      Caption = 'SectionCalculation'
      object DBtnSectionCal: TRzDialogButtons
        Left = 0
        Top = 409
        Width = 736
        ActionHelp = actStageCal
        CaptionOk = 'OK'
        CaptionCancel = 'actSectionCal'
        CaptionHelp = 'actStageCal'
        HotTrack = True
        ModalResultOk = 1
        ModalResultCancel = 2
        ModalResultHelp = 0
        ShowOKButton = False
        ShowCancelButton = False
        ShowHelpButton = True
        WidthOk = 76
        WidthCancel = 76
        WidthHelp = 76
        TabOrder = 0
      end
      object RzTabSheet1: TRzTabSheet
        Caption = 'TabSheet1'
      end
    end
  end
  object actListShow: TActionList
    Left = 200
    Top = 56
    object ActOutput: TAction
      Category = 'Output'
      Caption = 'Output'
    end
    object actMainParams: TAction
      Category = 'BasicDesign'
      Caption = 'actMainParams'
      OnExecute = actMainParamsExecute
    end
    object actGoverningStage: TAction
      Tag = 1
      Category = 'BasicDesign'
      Caption = 'actGoverningStage'
      OnExecute = actGoverningStageExecute
    end
    object actHRSys: TAction
      Tag = 2
      Category = 'BasicDesign'
      Caption = 'actHRSys'
      OnExecute = actHRSysExecute
    end
    object actStageDiv: TAction
      Tag = 3
      Category = 'BasicDesign'
      Caption = 'actStageDiv'
      OnExecute = actStageDivExecute
    end
    object actCoupling: TAction
      Tag = 4
      Category = 'BasicDesign'
      Caption = 'actCoupling'
      OnExecute = actCouplingExecute
    end
    object actStageCal: TAction
      Tag = 5
      Category = 'BasicDesign'
      Caption = 'actStageCal'
      OnExecute = actStageCalExecute
    end
    object ActCheckData: TAction
      Category = 'Optimization'
      Caption = 'CheckData'
    end
    object ActOptimize: TAction
      Category = 'Optimization'
      Caption = 'Optimize'
    end
    object actCancel: TAction
      Category = 'Cancel'
      Caption = 'actCancel'
      OnExecute = actCancelExecute
    end
    object actDrawHSGraph: TAction
      Category = 'Draw'
      Caption = 'actDrawHSGraph'
    end
    object actDrawVTri: TAction
      Category = 'Draw'
      Caption = 'actDrawVTri'
    end
    object actStageCal2: TAction
      Tag = 6
      Category = 'BasicDesign'
      Caption = 'actStageCal2'
      OnExecute = actStageCal2Execute
    end
    object actSectionCal: TAction
      Tag = 7
      Category = 'BasicDesign'
      Caption = 'actSectionCal'
      OnExecute = actSectionCalExecute
    end
  end
  object Timer1: TTimer
    Left = 168
    Top = 56
  end
  object MainMenu1: TMainMenu
    AutoMerge = True
    BiDiMode = bdRightToLeftNoAlign
    OwnerDraw = True
    ParentBiDiMode = False
    Left = 168
    Top = 88
    object MenuDrawHSGraph: TMenuItem
      Caption = 'HSGraph'
      object sMenuMainParams: TMenuItem
        Caption = 'Initial Curve'
      end
      object DrawHRSysOut: TMenuItem
        Caption = 'HR System'
      end
      object DrawStageDivisionOut: TMenuItem
        Caption = 'Stage Division'
      end
      object DrawStageCalOut: TMenuItem
        Caption = 'Stage Calculation'
      end
    end
  end
end