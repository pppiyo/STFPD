object FrameMainParams: TFrameMainParams
  Left = 0
  Top = 0
  Width = 843
  Height = 556
  TabOrder = 0
  object RzToolbar1: TRzToolbar
    Left = 767
    Top = 0
    Width = 83
    Height = 540
    Align = alLeft
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
      BtnDrawCurve
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
    object BtnDrawCurve: TButton
      Left = 4
      Top = 77
      Width = 75
      Height = 25
      Action = actDraw
      TabOrder = 3
    end
    object BtnSave: TButton
      Left = 4
      Top = 102
      Width = 75
      Height = 25
      Action = actSave
      TabOrder = 4
    end
    object BtnLoadSaved: TButton
      Left = 4
      Top = 127
      Width = 75
      Height = 25
      Action = actLoadSaved
      TabOrder = 5
    end
  end
  object GBoxAdjustParams: TGroupBox
    Left = 201
    Top = 0
    Width = 280
    Height = 540
    Align = alLeft
    Caption = 'Adjustment Parameters'
    TabOrder = 1
    object PnlCok: TRzPanel
      Left = 12
      Top = 24
      Width = 141
      Height = 33
      BorderOuter = fsGroove
      Caption = 'Inlet steam throttling loss coefficient Cok'
      TabOrder = 0
    end
    object Pnlnamda: TRzPanel
      Left = 12
      Top = 66
      Width = 141
      Height = 31
      BorderOuter = fsGroove
      Caption = 'Exhaust pipe resistance coefficient '#955
      TabOrder = 1
    end
    object Pnlyitari: TRzPanel
      Left = 12
      Top = 148
      Width = 141
      Height = 29
      BorderOuter = fsGroove
      Caption = ' '#951'ri'
      TabOrder = 2
    end
    object Pnlyitag: TRzPanel
      Left = 12
      Top = 189
      Width = 141
      Height = 28
      BorderOuter = fsGroove
      Caption = ' '#951'g'
      TabOrder = 3
    end
    object Pnlyitaax: TRzPanel
      Left = 12
      Top = 224
      Width = 141
      Height = 25
      BorderOuter = fsGroove
      Caption = #951'ax'
      TabOrder = 4
    end
    object Pnlexpandm: TRzPanel
      Left = 12
      Top = 298
      Width = 141
      Height = 42
      BorderOuter = fsGroove
      Caption = 'Inlet steam flow enhancement coefficient considering bleeding m'
      TabOrder = 5
    end
    object PnlCex: TRzPanel
      Left = 12
      Top = 106
      Width = 141
      Height = 31
      BorderOuter = fsGroove
      Caption = 'Exhaust velocity Cex'
      TabOrder = 6
    end
    object Pnlyitabox: TRzPanel
      Left = 12
      Top = 256
      Width = 141
      Height = 33
      BorderOuter = fsGroove
      Caption = ' '#951'gearbox'
      TabOrder = 7
    end
    object PnldeltaDoverD0: TRzPanel
      Left = 12
      Top = 346
      Width = 141
      Height = 55
      BorderOuter = fsGroove
      Caption = 
        'Inlet Steam flow enhancement coefficient  considering shaft-pack' +
        'ing leakage '#916'D/D0'
      TabOrder = 8
    end
    object SpinEditCok: TRzSpinEdit
      Left = 167
      Top = 32
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 3
      Direction = sdLeftRight
      Increment = 0.001000000000000000
      IntegersOnly = False
      Max = 1.000000000000000000
      Orientation = orHorizontal
      Value = 0.030000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 9
    end
    object SpinEditnamda: TRzSpinEdit
      Left = 167
      Top = 72
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 3
      Direction = sdLeftRight
      Increment = 0.001000000000000000
      IntegersOnly = False
      Max = 1.000000000000000000
      Orientation = orHorizontal
      Value = 0.070000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 10
    end
    object SpinEditCex: TRzSpinEdit
      Left = 167
      Top = 113
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Direction = sdLeftRight
      Orientation = orHorizontal
      Value = 90.000000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 11
    end
    object SpinEdityitari: TRzSpinEdit
      Left = 167
      Top = 153
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 3
      Direction = sdLeftRight
      Increment = 0.001000000000000000
      IntegersOnly = False
      Max = 1.000000000000000000
      Orientation = orHorizontal
      Value = 0.600000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 12
    end
    object SpinEdityitag: TRzSpinEdit
      Left = 167
      Top = 193
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 2
      Direction = sdLeftRight
      Increment = 0.010000000000000000
      IntegersOnly = False
      Max = 1.000000000000000000
      Orientation = orHorizontal
      Value = 0.940000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 13
    end
    object SpinEdityitaax: TRzSpinEdit
      Left = 167
      Top = 226
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 2
      Direction = sdLeftRight
      Increment = 0.010000000000000000
      IntegersOnly = False
      Max = 1.000000000000000000
      Orientation = orHorizontal
      Value = 0.980000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 14
    end
    object SpinEdityitabox: TRzSpinEdit
      Left = 167
      Top = 266
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 2
      Direction = sdLeftRight
      Increment = 0.010000000000000000
      IntegersOnly = False
      Max = 1.000000000000000000
      Orientation = orHorizontal
      Value = 0.980000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 15
    end
    object SpinEditexpandm: TRzSpinEdit
      Left = 167
      Top = 306
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 3
      Direction = sdLeftRight
      Increment = 0.001000000000000000
      IntegersOnly = False
      Max = 1.500000000000000000
      Min = 1.000000000000000000
      Orientation = orHorizontal
      Value = 1.150000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 16
    end
    object SpinEditdeltaDoverD0: TRzSpinEdit
      Left = 167
      Top = 362
      Width = 97
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Decimals = 3
      Direction = sdLeftRight
      Increment = 0.001000000000000000
      IntegersOnly = False
      Max = 1.000000000000000000
      Orientation = orHorizontal
      Value = 0.031000000000000000
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 17
    end
    object EditD0: TRzEdit
      Left = 169
      Top = 490
      Width = 80
      Height = 21
      Color = clInfoBk
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 18
    end
    object PnlD0: TRzPanel
      Left = 10
      Top = 485
      Width = 87
      Height = 36
      BorderOuter = fsGroove
      Caption = 'Steam Flow Rate D0 (kg/h)'
      TabOrder = 19
    end
    object RGrpGetD0Auto: TRadioGroup
      Left = 10
      Top = 407
      Width = 103
      Height = 65
      Caption = 'D0  Acquisition'
      ItemIndex = 0
      Items.Strings = (
        'Auto'
        'Manual')
      TabOrder = 20
      OnClick = RGrpGetD0AutoClick
    end
  end
  object GBoxMainInput: TRzGroupBox
    Left = 0
    Top = 0
    Width = 201
    Height = 540
    Align = alLeft
    BorderOuter = fsGroove
    Caption = 'Input Parameters'
    TabOrder = 2
    object Editpr: TRzEdit
      Left = 109
      Top = 18
      Width = 80
      Height = 21
      Color = clInfoBk
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 0
    end
    object Editpe: TRzEdit
      Left = 109
      Top = 54
      Width = 80
      Height = 21
      Color = clInfoBk
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 1
    end
    object Edittfw: TRzEdit
      Left = 109
      Top = 127
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 2
    end
    object Editpfp: TRzEdit
      Left = 109
      Top = 163
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 3
    end
    object Editn: TRzEdit
      Left = 109
      Top = 199
      Width = 80
      Height = 21
      Color = clInfoBk
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 4
    end
    object Editp0: TRzEdit
      Left = 109
      Top = 235
      Width = 80
      Height = 21
      Color = clInfoBk
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 5
    end
    object Editbpc: TRzEdit
      Left = 109
      Top = 271
      Width = 80
      Height = 21
      Color = clInfoBk
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 6
    end
    object Edittw1: TRzEdit
      Left = 109
      Top = 308
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 7
    end
    object Editpcp: TRzEdit
      Left = 109
      Top = 344
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 8
    end
    object EditDeltaDej: TRzEdit
      Left = 109
      Top = 380
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 9
    end
    object EditDeltatej: TRzEdit
      Left = 109
      Top = 424
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 10
    end
    object EditDeltaDl: TRzEdit
      Left = 109
      Top = 468
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 11
    end
    object EditDeltaDa: TRzEdit
      Left = 109
      Top = 506
      Width = 80
      Height = 21
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 12
    end
    object PnlPr: TRzPanel
      Left = 11
      Top = 16
      Width = 87
      Height = 26
      BorderOuter = fsGroove
      Caption = 'pr'
      TabOrder = 13
    end
    object Pnlpe: TRzPanel
      Left = 11
      Top = 52
      Width = 87
      Height = 26
      BorderOuter = fsGroove
      Caption = 'pe'
      TabOrder = 14
    end
    object Pnltfw: TRzPanel
      Left = 11
      Top = 125
      Width = 87
      Height = 25
      BorderOuter = fsGroove
      Caption = 'tfw'
      TabOrder = 15
    end
    object Pnlpfp: TRzPanel
      Left = 11
      Top = 161
      Width = 87
      Height = 30
      BorderOuter = fsGroove
      Caption = 'pfp'
      TabOrder = 16
    end
    object Pnln: TRzPanel
      Left = 11
      Top = 197
      Width = 87
      Height = 25
      BorderOuter = fsGroove
      Caption = 'N'
      TabOrder = 17
    end
    object Pnlp0: TRzPanel
      Left = 11
      Top = 233
      Width = 87
      Height = 26
      BorderOuter = fsGroove
      Caption = 'p0'
      TabOrder = 18
    end
    object Pnlbpc: TRzPanel
      Left = 11
      Top = 269
      Width = 87
      Height = 26
      BorderOuter = fsGroove
      Caption = 'bpc'
      TabOrder = 19
    end
    object Pnltw1: TRzPanel
      Left = 11
      Top = 306
      Width = 87
      Height = 30
      BorderOuter = fsGroove
      Caption = 'tw1'
      TabOrder = 20
    end
    object Pnlpcp: TRzPanel
      Left = 11
      Top = 342
      Width = 87
      Height = 33
      BorderOuter = fsGroove
      Caption = 'pcp'
      TabOrder = 21
    end
    object PnlDeltaDej: TRzPanel
      Left = 11
      Top = 378
      Width = 87
      Height = 33
      BorderOuter = fsGroove
      Caption = #916'Dej'
      TabOrder = 22
    end
    object PnlDeltatej: TRzPanel
      Left = 11
      Top = 414
      Width = 87
      Height = 46
      BorderOuter = fsGroove
      Caption = #916'tej'
      TabOrder = 23
    end
    object PnlDeltaDl: TRzPanel
      Left = 11
      Top = 466
      Width = 87
      Height = 34
      BorderOuter = fsGroove
      Caption = #916'Dl'
      TabOrder = 24
    end
    object PnlDeltaDa: TRzPanel
      Left = 11
      Top = 503
      Width = 87
      Height = 33
      BorderOuter = fsGroove
      Caption = #916'Dl'#39
      TabOrder = 25
    end
    object Editt0: TRzEdit
      Left = 109
      Top = 90
      Width = 80
      Height = 21
      Color = clInfoBk
      ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 26
    end
    object Pnlt0: TRzPanel
      Left = 11
      Top = 88
      Width = 87
      Height = 26
      BorderOuter = fsGroove
      Caption = 't0'
      TabOrder = 27
    end
  end
  object GroupBox1: TGroupBox
    Left = 481
    Top = 0
    Width = 286
    Height = 540
    Align = alLeft
    Caption = 'Curve Settings'
    TabOrder = 3
    object GBoxHSGraphControl: TGroupBox
      Left = 2
      Top = 257
      Width = 282
      Height = 204
      Align = alTop
      Caption = 'H-S Graph Control'
      TabOrder = 0
      object SpinEditCurveMove: TRzSpinEdit
        Left = 152
        Top = 28
        Width = 97
        Height = 21
        AllowKeyEdit = True
        CheckRange = True
        Decimals = 1
        Direction = sdLeftRight
        Increment = 0.100000000000000000
        IntegersOnly = False
        Max = 25.000000000000000000
        Min = 10.000000000000000000
        Orientation = orHorizontal
        Value = 21.000000000000000000
        ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
        TabOrder = 0
      end
      object PnlCurveMove: TRzPanel
        Left = 12
        Top = 15
        Width = 125
        Height = 42
        BorderOuter = fsGroove
        Caption = 'Curve Shape Adjustment (kJ/kg)'
        TabOrder = 1
      end
      object NumEditCurveDivNum: TRzNumericEdit
        Left = 152
        Top = 76
        Width = 65
        Height = 21
        ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
        TabOrder = 2
        Value = 50.000000000000000000
        DisplayFormat = ',0;(,0)'
      end
      object PnlCurveDivNum: TRzPanel
        Left = 11
        Top = 65
        Width = 126
        Height = 40
        BorderOuter = fsGroove
        Caption = 'Number Of Elements For Curve Interpolation'
        TabOrder = 3
      end
      object RGrpShowTDPointList: TRadioGroup
        Left = 12
        Top = 120
        Width = 245
        Height = 73
        Caption = 'Show Interpolation Elements List'
        ItemIndex = 1
        Items.Strings = (
          'Yes'
          'No')
        TabOrder = 4
      end
    end
    object GroupBox2: TGroupBox
      Left = 2
      Top = 15
      Width = 282
      Height = 242
      Align = alTop
      Caption = 'Grid Initial Thermal Dynamic Points'
      TabOrder = 1
      object GridIniTDPoints: TStringGrid
        Left = 2
        Top = 15
        Width = 278
        Height = 225
        Align = alClient
        FixedCols = 0
        TabOrder = 0
      end
    end
  end
  object Timer1: TTimer
    Left = 352
    Top = 424
  end
  object ActionList1: TActionList
    Left = 392
    Top = 456
    object actSave: TAction
      Caption = 'Save'
      OnExecute = actSaveExecute
    end
    object actLoadSaved: TAction
      Caption = 'Load Saved'
      OnExecute = actLoadSavedExecute
    end
    object actDraw: TAction
      Caption = 'Draw'
      OnExecute = actDrawExecute
    end
  end
end
