unit FrmStageCal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Grids, StdCtrls, ExtCtrls, RzPanel,

  Data, TDPointUtils, VProcess, sfmStageCalResult, MainGraphNR,
  ClassIniData, ClassGoverningStage, ClassHRSys, ClassHRSysWithDA, ClassStageDiv, ClassCoupling,
  ClassStageCal, ClassStage, RzGrids;

type
	TArrStageCal = array of TStageCal;
type
  TFrameStageCal = class(TFrame)
    RzToolbar1: TRzToolbar;
    BtnRefresh: TButton;
    BtnClearV: TButton;
    BtnDefault: TButton;
    BtnCalculate: TButton;
    BtnDrawCurve: TButton;
    BtnStageOpt: TButton;
    Panel1: TPanel;
    GBoxGSDesignInput: TGroupBox;
    StrGridGSDesignInput: TRzStringGrid;
    GBoxHRSys: TGroupBox;
    StrGridSteamExtraInfo: TRzStringGrid;
    GBoxPSDesignInput: TGroupBox;
    GroupBox1: TGroupBox;
    StrGridPSAutoInput: TRzStringGrid;
    GroupBox2: TGroupBox;
    StrGridPSManualInput: TRzStringGrid;
    StrGridPSManualInput2: TRzStringGrid;
    GroupBox3: TGroupBox;
    StrGridPSAutoOutput: TRzStringGrid;
    ActionList1: TActionList;
    actDefault: TAction;
    actClear: TAction;
    actCalculate: TAction;
    actDraw: TAction;
    actStageOpt: TAction;
    actGetPSStage2: TAction;
    actRefresh: TAction;
    BtnLoadSaved: TButton;
    procedure AfterConstruction;override;
    procedure actDefaultExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actCalculateExecute(Sender: TObject);
    procedure actDrawExecute(Sender: TObject);
    procedure actGetPSStage2Execute(Sender: TObject);
    procedure actStageOptExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure BtnLoadSavedClick(Sender: TObject);
  private
    { Private declarations }
  	ArrSample : TArrStageCal;
    ArrProperResults : TArrStageCal;
    OptimumResult : TStageCal;
		function Filter(paramArrSample: TArrStageCal): TArrStageCal;
		function FindOptimum(paramArrProperResults: TArrStageCal): TStageCal;
  	{Data}
    procedure Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSys:THRSys;StageDiv:TStageDiv;Coupling:TCoupling);overload;
    procedure Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSysWithDA:THRSysWithDA;StageDiv:TStageDiv;Coupling:TCoupling);overload;
    procedure Calculate(StageCal:TStageCal);
    {Visual}
    procedure DrawDynGrid(Grid:TStringGrid;StageCal:TStageCal);
    {Data & Visual}
    procedure D2V(param:TStageCal);
    procedure V2D(param:TStageCal);
    procedure D2V2(param:TStageCal);
    procedure V2D2(param:TStageCal);
    procedure LoadSaved(const FileName: TFileName);
    procedure SaveStageCalInput(const FileName: TFileName);//特制函数
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrameStageCal.Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSys:THRSys;StageDiv:TStageDiv;Coupling:TCoupling);
var
	i,j : integer;
begin
  if aStageCal = nil then begin
  	aStageCal := TStagecal.Create(IniData,GoverningStage,HRSys,StageDiv,Coupling);
  end else begin
  	FreeAndNil(aStageCal);
  	aStageCal := TStagecal.Create(IniData,GoverningStage,HRSys,StageDiv,Coupling);
  end;
  //计算
  if GoverningStage.GSType = SBGS then begin
    //上级值传递
    aStageCal.Stages.Add(TSingleGoverningStage(GoverningStage.GS));
    //压力级第一级初始化
    aStageCal.Stages.Add(TPressureStage.Create(aStageCal.arrN[0],
    				aStageCal.arrG[0],aStageCal.arrdn[0],aStageCal.arrdb[0],
            aStageCal.arrEht[0],aStageCal.arrxa[0],0.2, 10.5, 0.3, 2,
            180, 0.25, 15, 1.5, 0.3, 4,
            0, 1, TSingleGoverningStage(aStageCal.Stages.Items[0]).C2,
            TSingleGoverningStage(aStageCal.Stages.Items[0]).TDPoint3));
  	//压力级第一级计算
  	TPressureStage(aStageCal.Stages.Items[1]).GetPressureStage;
  	//剩余压力级的计算
  	for i := 2 to aStageCal.Z-1 do begin
  		aStageCal.Stages.Add(TPressureStage.Create(
  	  				aStageCal.arrN[i-1],aStageCal.arrG[i-1],aStageCal.arrdn[i-1],
              aStageCal.arrdb[i-1],aStageCal.arrEht[i-1],aStageCal.arrxa[i-1],
              0.2, TPressureStage(aStageCal.Stages.Items[i-1]).alpha1+0.5,
              0.3, 2, 180, 0.25, 15, 1.5, 0.3, 4,
  	          TPressureStage(aStageCal.Stages.Items[i-1]).Miu1, 1,
  	          TPressureStage(aStageCal.Stages.Items[i-1]).C2,
  	          TPressureStage(aStageCal.Stages.Items[i-1]).TDPoint3));
  	  TPressureStage(aStageCal.Stages.Items[i]).GetPressureStage;
  	end;
  end else if  GoverningStage.GSType = DBGS then begin
    //上级值传递
    aStageCal.Stages.Add(TDoubleGoverningStage(GoverningStage.GS));
    //压力级第一级初始化
    aStageCal.Stages.Add(TPressureStage.Create(
    				aStageCal.arrN[0],aStageCal.arrG[0],aStageCal.arrdn[0],aStageCal.arrdb[0],
            aStageCal.arrEht[0],aStageCal.arrxa[0],0.02, 10.5, 1, 2,
            180, 0.25, 15, 1.5, 0.3, 4,
            0, 1, TDoubleGoverningStage(aStageCal.Stages.Items[0]).C2,
            TDoubleGoverningStage(aStageCal.Stages.Items[0]).TDPoint3));
  	//压力级第一级计算
  	TPressureStage(aStageCal.Stages.Items[1]).GetPressureStage;
  	//剩余压力级的计算
  	for i := 2 to aStageCal.Z-1 do begin
  		aStageCal.Stages.Add(TPressureStage.Create(
  	  				aStageCal.arrN[i-1],aStageCal.arrG[i-1],aStageCal.arrdn[i-1],
              aStageCal.arrdb[i-1],aStageCal.arrEht[i-1],aStageCal.arrxa[i-1],
              0.2, TPressureStage(aStageCal.Stages.Items[i-1]).alpha1+0.5,
              1, 2, 180, 0.25, 15, 1.5, 0.3, 4,
  	          TPressureStage(aStageCal.Stages.Items[i-1]).Miu1, 1,
  	          TPressureStage(aStageCal.Stages.Items[i-1]).C2,
  	          TPressureStage(aStageCal.Stages.Items[i-1]).TDPoint3));
  	  TPressureStage(aStageCal.Stages.Items[i]).GetPressureStage;
  	end;
  end;
end;

procedure TFrameStageCal.Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSysWithDA:THRSysWithDA;StageDiv:TStageDiv;Coupling:TCoupling);
var
	i,j : integer;
begin
  	if aStageCal = nil then begin
  		aStageCal := TStagecal.Create(IniData,GoverningStage,HRSysWithDA,StageDiv,Coupling);
  	end else begin
  		FreeAndNil(aStageCal);
  		aStageCal := TStagecal.Create(IniData,GoverningStage,HRSysWithDA,StageDiv,Coupling);
  	end;
  	//计算
  	if GoverningStage.GSType = SBGS then begin
  	  //上级值传递
  	  aStageCal.Stages.Add(TSingleGoverningStage(GoverningStage.GS));
  	  //压力级第一级初始化
  	  aStageCal.Stages.Add(TPressureStage.Create(aStageCal.arrN[0],
  	  				aStageCal.arrG[0],aStageCal.arrdn[0],aStageCal.arrdb[0],
  	          aStageCal.arrEht[0],aStageCal.arrxa[0],0.02, 10.5, 0.3, 2,
  	          180, 0.25, 15, 1.5, 0.3, 4,
  	          0, 1, TSingleGoverningStage(aStageCal.Stages.Items[0]).C2,
  	          TSingleGoverningStage(aStageCal.Stages.Items[0]).TDPoint3));
  		//压力级第一级计算
  		TPressureStage(aStageCal.Stages.Items[1]).GetPressureStage;
  		//剩余压力级的计算
  		for i := 2 to aStageCal.Z-1 do begin
  			aStageCal.Stages.Add(TPressureStage.Create(
  		  				aStageCal.arrN[i-1],aStageCal.arrG[i-1],aStageCal.arrdn[i-1],
  	            aStageCal.arrdb[i-1],aStageCal.arrEht[i-1],aStageCal.arrxa[i-1],
  	            0.02, TPressureStage(aStageCal.Stages.Items[i-1]).alpha1+0.5,
  	            0.3, 2, 180, 0.25, 15, 1.5, 0.3, 4,
  		          TPressureStage(aStageCal.Stages.Items[i-1]).Miu1, 1,
  		          TPressureStage(aStageCal.Stages.Items[i-1]).C2,
  		          TPressureStage(aStageCal.Stages.Items[i-1]).TDPoint3));
  		  TPressureStage(aStageCal.Stages.Items[i]).GetPressureStage;
  		end;
  	end else if  GoverningStage.GSType = DBGS then begin
  	  //上级值传递
  	  aStageCal.Stages.Add(TDoubleGoverningStage(GoverningStage.GS));
  	  //压力级第一级初始化
  	  aStageCal.Stages.Add(TPressureStage.Create(
  	  				aStageCal.arrN[0],aStageCal.arrG[0],aStageCal.arrdn[0],aStageCal.arrdb[0],
  	          aStageCal.arrEht[0],aStageCal.arrxa[0],0.02, 10.5, 1, 2,
  	          180, 0.25, 15, 1.5, 0.3, 4,
  	          0, 1, TDoubleGoverningStage(aStageCal.Stages.Items[0]).C2,
  	          TDoubleGoverningStage(aStageCal.Stages.Items[0]).TDPoint3));
  		//压力级第一级计算
  		TPressureStage(aStageCal.Stages.Items[1]).GetPressureStage;
  		//剩余压力级的计算
  		for i := 2 to aStageCal.Z-1 do begin
  			aStageCal.Stages.Add(TPressureStage.Create(
  		  				aStageCal.arrN[i-1],aStageCal.arrG[i-1],aStageCal.arrdn[i-1],
  	            aStageCal.arrdb[i-1],aStageCal.arrEht[i-1],aStageCal.arrxa[i-1],
  	            0.02, TPressureStage(aStageCal.Stages.Items[i-1]).alpha1+0.5,
  	            1, 2, 180, 0.25, 15, 1.5, 0.3, 4,
  		          TPressureStage(aStageCal.Stages.Items[i-1]).Miu1, 1,
  		          TPressureStage(aStageCal.Stages.Items[i-1]).C2,
  		          TPressureStage(aStageCal.Stages.Items[i-1]).TDPoint3));
  		  TPressureStage(aStageCal.Stages.Items[i]).GetPressureStage;
  		end;
  	end;
end;

procedure TframeStageCal.AfterConstruction;
begin
  inherited;
		if ((aHRSys<>nil) and (aCoupling.tag=1)) then begin
  		StrGridPSManualInput2.Visible := False;
  		{Data}
  		Ini(aIniData,aGoverningStage,aHRSys,aStageDiv,aCoupling);
			{Visual}
  		DrawDynGrid(StrGridGSDesignInput,aStageCal);
  		DrawDynGrid(StrGridSteamExtraInfo,aStageCal);
  		DrawDynGrid(StrGridPSAutoInput,aStageCal);
  		DrawDynGrid(StrGridPSManualInput,aStageCal);
  		DrawDynGrid(StrGridPSAutoOutput,aStageCal);
  		{Visual & Data}
  		D2V(aStageCal);
  	  BtnCalculate.Enabled := True;
  	end else if ((aHRSysWithDA.tag=1) and (aCoupling.tag=1)) then begin
  		StrGridPSManualInput2.Visible := False;
  		{Data}
  		Ini(aIniData,aGoverningStage,aHRSysWithDA,aStageDiv,aCoupling);
			{Visual}
  		DrawDynGrid(StrGridGSDesignInput,aStageCal);
  		DrawDynGrid(StrGridSteamExtraInfo,aStageCal);
  		DrawDynGrid(StrGridPSAutoInput,aStageCal);
  		DrawDynGrid(StrGridPSManualInput,aStageCal);
  		DrawDynGrid(StrGridPSAutoOutput,aStageCal);
  		{Visual & Data}
  		D2V(aStageCal);
  	  BtnCalculate.Enabled := True;
    end else begin
  		Showmessage('Previous phases not finished yet, Please return!');
  	end;
end;

procedure TframeStageCal.actDefaultExecute(Sender: TObject);
begin
	StrGridPSManualInput2.Hide;
  StrGridPSManualInput.Visible := True;
	if ((aHRSys<>nil) and (aCoupling.tag=1)) then begin
  	{Data}
  	Ini(aIniData,aGoverningStage,aHRSys,aStageDiv,aCoupling);
		{Visual}
  	DrawDynGrid(StrGridGSDesignInput,aStageCal);
  	DrawDynGrid(StrGridSteamExtraInfo,aStageCal);
  	DrawDynGrid(StrGridPSAutoInput,aStageCal);
  	DrawDynGrid(StrGridPSManualInput,aStageCal);
  	DrawDynGrid(StrGridPSAutoOutput,aStageCal);
  	{Visual & Data}
  	D2V(aStageCal);
    BtnCalculate.Enabled := True;
	end else if ((aHRSysWithDA<>nil) and (aCoupling.tag=1)) then begin
  	{Data}
  	Ini(aIniData,aGoverningStage,aHRSysWithDA,aStageDiv,aCoupling);
		{Visual}
  	DrawDynGrid(StrGridGSDesignInput,aStageCal);
  	DrawDynGrid(StrGridSteamExtraInfo,aStageCal);
  	DrawDynGrid(StrGridPSAutoInput,aStageCal);
  	DrawDynGrid(StrGridPSManualInput,aStageCal);
  	DrawDynGrid(StrGridPSAutoOutput,aStageCal);
  	{Visual & Data}
  	D2V(aStageCal);
    BtnCalculate.Enabled := True;
    BtnRefresh.Enabled   := True;
  end else begin
  	Showmessage('Previous phases not finished yet, Please return!');
    BtnCalculate.Enabled := False;
  end;
end;

procedure TframeStageCal.actClearExecute(Sender: TObject);
begin
	ClearAll(Self);
  BtnRefresh.Enabled := False;
  BtnCalculate.Enabled := False;
end;

procedure TframeStageCal.actCalculateExecute(Sender: TObject);
var
	i : integer;
begin
  V2D(aStageCal);
  Calculate(aStageCal);
  try
	  if FormStageCalResult = nil then begin
  	  FormStageCalResult := TFormStageCalResult.Create(Self);
    end else begin
      FreeAndNil(FormStageCalResult);
      FormStageCalResult := TFormStageCalResult.Create(Self);
    end;
  finally
    FormStageCalResult.SetBounds(840,0,420,610);
    FormStageCalResult.Show;
	end;
  aStageCal.Iteration;
end;

procedure TframeStageCal.Calculate(StageCal:TStageCal);
var
	i : integer;
begin
  	if (StageCal.FGoverningStage.GSType = SBGS) then begin
  	  //剩余压力级的计算
  	  for i := 0 to StageCal.Z-2 do begin
  	    TPressureStage(StageCal.Stages.Items[i+1]).GetPressureStage;
  	  end;
  	end else if (StageCal.FGoverningStage.GSType = DBGS) then begin
  	  //剩余压力级的计算
  	  for i := 0 to StageCal.Z-2 do begin
  	    TPressureStage(StageCal.Stages.Items[i+1]).GetPressureStage;
  	  end;
    end;

  	StageCal.GetYitari;
  	StageCal.GetSumPi;
end;

//!
//Data-Visual
procedure TframeStageCal.D2V(param:TStageCal);
var
	i : integer;
begin
	if param <> nil then begin
  	if (param.FGoverningStage.GSType = SBGS) then begin
  		with StrGridGSDesignInput do begin 
        Cells[1,1] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).Eht);
        Cells[1,2] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).dm);
    		Cells[1,3] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).OmegaM);
      	Cells[1,4] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).alpha1);
      	Cells[1,5] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).e);
      	Cells[1,6] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).BladeHeightDelta);
      	Cells[1,7] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).Zm);
    	end;
    end else if (param.FGoverningStage.GSType = DBGS) then begin
  		with StrGridGSDesignInput do begin
        Cells[1,1] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).Eht);
        Cells[1,2] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).dm);
    		Cells[1,3] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Omegab);
        Cells[1,4] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Omegag);
        Cells[1,5] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Omegaba);
      	Cells[1,6] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).alpha1);
      	Cells[1,7] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).e);
      	Cells[1,8] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).BladeHeightDelta);
        Cells[1,9] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Zm);
    	end;       
    end;
		for i := 1 to (param.Stages.Count-1) do begin
    	with StrGridPSAutoInput do begin
    		Cells[i+1,1]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).G]);
    		Cells[i+1,2]  := format('%d',[TPressureStage(param.Stages.Items[i]).N]);
      	Cells[i+1,3]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).Eht]);
      	Cells[i+1,4]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).dn]);
      	Cells[i+1,5]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).db]);
      	Cells[i+1,6]  := format('%.3f',[TPressureStage(param.Stages.Items[i]).xa]);
      end;
      with StrGridPSManualInput do begin
      	Cells[i+1,1]  := Floattostr(TPressureStage(param.Stages.Items[i]).Omegam);
        Cells[i+1,2]  := Floattostr(TPressureStage(param.Stages.Items[i]).alpha1);
        Cells[i+1,3]  := Floattostr(TPressureStage(param.Stages.Items[i]).e);
    		Cells[i+1,4] := Floattostr(TPressureStage(param.Stages.Items[i]).BladeHeightdelta);
      	Cells[i+1,5] := Floattostr(TPressureStage(param.Stages.Items[i]).dp);
      	Cells[i+1,6] := Floattostr(TPressureStage(param.Stages.Items[i]).deltalp);
      	Cells[i+1,7] := Floattostr(TPressureStage(param.Stages.Items[i]).zp);
      	Cells[i+1,8] := Floattostr(TPressureStage(param.Stages.Items[i]).deltalz);
      	Cells[i+1,9] := Floattostr(TPressureStage(param.Stages.Items[i]).deltaS);
        Cells[i+1,10] := Floattostr(TPressureStage(param.Stages.Items[i]).Zm);
     end;
    	with StrGridPSAutoOutput do begin
    		Cells[i+1,1]  := Floattostr(TPressureStage(param.Stages.Items[i]).Miu1);
      end;
    end;
  end else
  	Showmessage('Not Initialized yet!');
end;

procedure TframeStageCal.V2D(param:TStageCal);
var
	i : integer;
begin
	if param <> nil then begin
		for i := 1 to (param.Stages.Count-1) do begin
    	with StrGridPSAutoInput do begin
				TPressureStage(param.Stages.Items[i]).G    := StrToFloat(Cells[i+1,1]);
				TPressureStage(param.Stages.Items[i]).N    := StrToInt(Cells[i+1,2]);
        TPressureStage(param.Stages.Items[i]).Eht  := StrToFloat(Cells[i+1,3]);
				TPressureStage(param.Stages.Items[i]).dn   := StrToFloat(Cells[i+1,4]);
				TPressureStage(param.Stages.Items[i]).db   := StrToFloat(Cells[i+1,5]);
				TPressureStage(param.Stages.Items[i]).xa   := StrToFloat(Cells[i+1,6]);
      end;
      with StrGridPSManualInput do begin
				TPressureStage(param.Stages.Items[i]).Omegam             := StrToFloat(Cells[i+1,1] );
				TPressureStage(param.Stages.Items[i]).alpha1             := StrToFloat(Cells[i+1,2] );
				TPressureStage(param.Stages.Items[i]).e                  := StrToFloat(Cells[i+1,3] );
				TPressureStage(param.Stages.Items[i]).BladeHeightdelta   := StrToFloat(Cells[i+1,4] );
				TPressureStage(param.Stages.Items[i]).dp                 := StrToFloat(Cells[i+1,5] );
				TPressureStage(param.Stages.Items[i]).deltalp            := StrToFloat(Cells[i+1,6] );
				TPressureStage(param.Stages.Items[i]).zp                 := StrToFloat(Cells[i+1,7] );
				TPressureStage(param.Stages.Items[i]).deltalz            := StrToFloat(Cells[i+1,8] );
				TPressureStage(param.Stages.Items[i]).DeltaS             := StrToFloat(Cells[i+1,9] );
        TPressureStage(param.Stages.Items[i]).Zm                 := StrToFloat(Cells[i+1,10] );
     	end;
    	with StrGridPSAutoOutput do begin
    		TPressureStage(param.Stages.Items[i]).Miu1  := StrToFloat(Cells[i+1,1]);
      end;
    end;
  end else
  	Showmessage('Not Initialized yet!');
end;

//Data Visual
procedure TframeStageCal.DrawDynGrid(Grid:TStringGrid;StageCal:TStageCal);
var
	i : integer;
const
  GSColTitles : array[0..2] of string = ('Item','Value','Unit');
  GSRowTitlesDB : array[0..8] of string = ('Δht','dm','Ωb1','Ωg','Ωb2','α1','e','Δ','Zm');
  GSRowUnitsDB  : array[0..8] of string = ('kJ/kg','mm','-','-','-','°','-','mm','-');
  GSRowTitlesSB : array[0..6] of string = ('Δht','dm','Ωb','α1','e','Δ','Zm');
  GSRowUnitsSB  : array[0..6] of string = ('kJ/kg','mm','-','°','-','mm','-');
  HSColTitles : array[0..3] of string = ('Item','Stage','ΔGe','Unit');
  arrPSAutoInputTitle: array[0..5] of string = ('G', 'n', 'Eht', 'dn', 'db', 'xa');
  arrPSAutoInputUnit: array[0..5] of string = ('kg/s', 'r/min', 'kJ/kg', 'mm', 'mm', '-');
  arrPSManualInputTitle: array[0..9] of string = ('Ωm', 'α1','e', 'Δ','dp', 'δp', 'zp', 'δz', 'ΔS','Zm');
  arrPSManualInputUnit: array[0..9] of string = ('-', '°','-', 'mm','mm', 'mm', '-', 'mm', 'mm','-');
  arrPSAutoOutputTitle: array[0..0] of string = ('Miu');
  arrPSAutoOutputUnit: array[0..0] of string = ('-');
begin
	if (StageCal <> nil) then begin  ///////////
  	if Grid.Name = 'StrGridGSDesignInput' then begin
  		if StageCal.FGoverningStage.GSType = SBGS then begin
  			with Grid do begin
  				FixedCols := 1;
  			  FixedRows := 1;
  			  RowCount  := 8;
  			  ColCount  := 3;
  	      options := options + [goEditing];
  	  	  //第一列显示（PHSTX）
  				for i := 1 to RowCount-1 do begin
  	 				Cells[0,i] := GSRowTitlesSB[i-1];
  	        Cells[2,i] := GSRowUnitsSB[i-1];
  	 			end;
  	  	  //第一行显示（12345..）
  	  	  for i := 0 to ColCount-1 do begin
  			      Cells[i,0] := GSColTitles[i];
  			  end;
  	    end;
  	  end else if StageCal.FGoverningStage.GSType = DBGS then begin
  			with Grid do begin
  				FixedCols := 1;
  			  FixedRows := 1;
  			  RowCount  := 10;
  			  ColCount  := 3;
  	      options := options + [goEditing];
  	  	  //第一列显示（PHSTX）
  				for i := 1 to RowCount-1 do begin
  	 				Cells[0,i] := GSRowTitlesDB[i-1];
  	        Cells[2,i] := GSRowUnitsDB[i-1];
  	 			end;
  	  	  //第一行显示（12345..）
  	  	  for i := 0 to ColCount-1 do begin
  			      Cells[i,0] := GSColTitles[i];
  			  end;
  	    end;
  	  end;
  	end;
  	if Grid.Name = 'StrGridSteamExtraInfo' then begin
  		with Grid do begin
  			FixedCols := 1;
  			FixedRows := 1;
  	    if StageCal.FHRSysWithDA <> nil then begin
  				RowCount  := StageCal.FHRSysWithDA.ZHR+1;
  			  ColCount  := 4;
  	  	  //第一列显示
  			  for i := 1 to RowCount-1 do begin
  	 			  Cells[0,i] := IntToStr(i);
  	        Cells[1,i] := FloatToStr(StageCal.FCoupling.DDArrPosList[i-1,1]);
  	        Cells[2,i] := Format('%.2f',[StageCal.FHRSysWithDA.arrHROutput[i-1].DeltaDe]);
            Cells[3,i] := 'kg/h';
          end;
    	  	//第一行显示
    	  	for i := 0 to ColCount-1 do begin
  	  	    Cells[i,0] := HSColTitles[i];
  		  	end;
  		  end else if StageCal.FHRSys <> nil then begin
  				RowCount  := StageCal.FHRSys.ZHR+1;
  			  ColCount  := 4;
  	  	  //第一列显示
  			  for i := 1 to RowCount-1 do begin
  	 			  Cells[0,i] := IntToStr(i);
  	        Cells[1,i] := FloatToStr(StageCal.FCoupling.DDArrPosList[i-1,1]);
  	        Cells[2,i] := Format('%.2f',[StageCal.FHRSys.arrHROutput[i-1].DeltaDe]);
          end;
  	      Cells[3,i] := 'kg/h';
    	  	//第一行显示
    	  	for i := 0 to ColCount-1 do begin
  	  	    Cells[i,0] := HSColTitles[i];
  		  	end;
  		  end;
      end;
  	end;
  	if Grid.Name = 'StrGridPSAutoInput' then begin
  		with Grid do begin
        ScrollBars := ssBoth;
  	  	RowCount := 7;
        ColCount := StageCal.FStageDiv.Z+2;//除开调节级，但加上了显示单位的Col
  	  	Width := (ColCount+1)*DefaultColWidth;
  	  	Height := (RowCount+1)*DefaultRowHeight;
  			for i := 0 to RowCount-1 do begin
  	      Cells[0,i+1] := arrPSAutoInputTitle[i];
  	      Cells[1,i+1] := arrPSAutoInputUnit[i];
  	  	end;
  	    Cells[0,0] := 'Item';
  	    Cells[1,0] := 'Unit';
  	  	for i := 2 to StageCal.FStageDiv.Z+1 do begin
  	    	Cells[i,0] := inttostr(i-1);
  	  	end;
  		end;
  	end;
  	if Grid.Name = 'StrGridPSManualInput' then begin
  		with Grid do begin
        ScrollBars := ssBoth;
  	  	RowCount := 11;
        ColCount := StageCal.FStageDiv.Z+2;//除开调节级，但加上了显示单位的Col
  			Options := Options + [goEditing];
  	  	Width := (ColCount+1)*DefaultColWidth;
  	  	Height := (RowCount+1)*DefaultRowHeight;
  	    Cells[0,0] := 'Item';
  	    Cells[1,0] := 'Unit';
        for i := 2 to StageCal.FStageDiv.Z+1 do begin
          Cells[i,0] := inttostr(i-1);
        end;
  			for i := 1 to RowCount-1 do begin
  	      Cells[0,i] := arrPSManualInputTitle[i-1];
  	      Cells[1,i] := arrPSManualInputUnit[i-1];
  	  	end;
  		end;
  	end;
  	if Grid.Name = 'StrGridPSAutoOutput' then begin
  		with Grid do begin
        ScrollBars := ssBoth;
  	  	RowCount := 2;
        ColCount := StageCal.FStageDiv.Z+2;//除开调节级，但加上了显示单位的Col
        Options := Options + [goEditing];
  	  	Width := (ColCount+1)*DefaultColWidth;
  	  	Height := (RowCount+1)*DefaultRowHeight;
  	    Cells[0,0] := 'Item';
  	    Cells[1,0] := 'Unit';
  	  	for i := 2 to StageCal.FStageDiv.Z+1 do begin
  	    	Cells[i,0] := inttostr(i-1);
  	  	end;
  			for i := 1 to RowCount-1 do begin
  	      Cells[0,i] := arrPSAutoOutputTitle[i-1];
  	      Cells[1,i] := arrPSAutoOutputUnit[i-1];
  	  	end;
  		end;
  	end;
	end;
end;

procedure TframeStageCal.actDrawExecute(Sender: TObject);
begin
  FormMainGraphNR.DrawStageCalOut(aStageCal.Stages);
  FormMainGraphNR.Show;
end;

function TframeStageCal.Filter(paramArrSample: TArrStageCal): TArrStageCal;
var
	i,j,tmpN : integer;
  flag : integer;
  tmparrflag, tmpFlagQualifiedIndex : array of integer;
begin
	flag := 1;
	tmpN := Length(paramArrSample);
  SetLength(tmpFlagQualifiedIndex,tmpN);
  SetLength(tmparrflag,tmpN);
	//ln as filter
  	for i := 0 to tmpN-1 do begin
  		for j := 0 to paramArrSample[i].Z-2 do begin
    		if TPressureStage(paramArrSample[i].Stages.Items[j]).lb <= TPressureStage(paramArrSample[i].Stages.Items[j+1]).lb then begin
        	flag := 1 * flag;
        end else begin
        	flag := 0;
        end;
    	end;
      if flag = 1 then begin
      	tmpFlagQualifiedIndex[i] := 1;//00111000
      end;
  	end;
    flag := 0;
    for i := 0 to tmpN-1 do begin
    	if tmpFlagQualifiedIndex[i] = 1 then begin
        Inc(flag);
        tmparrflag[i] := i;
      end;
    end;
    SetLength(Result,flag);
    for i := 0 to flag-1 do begin
    	Result[i] := paramArrSample[tmparrflag[i]];
    end;
end;

function TframeStageCal.FindOptimum(paramArrProperResults: TArrStageCal): TStageCal;
var
	i : integer;
begin
	//对比函数

end;

procedure TframeStageCal.actStageOptExecute(Sender: TObject);
var
	i : integer;
	tmpStr1 : String;
  tmpSampleNum : integer;
begin
	//弹出对话框
	tmpStr1 := InputBox('Sample Number', 'Please input a number for sample collection', Inttostr(20));
  tmpSampleNum := StrToInt(tmpStr1);
  SetLength(ArrSample , tmpSampleNum);
  for i := 0 to tmpSampleNum-1 do begin 
		ArrSample[i] := aStageCal;
    ArrSample[i].SolutionGenerator;
    D2V(ArrSample[i]);	//...
    Calculate(ArrSample[i]);
  end;
  ArrProperResults := Filter(ArrSample);
  OptimumResult := FindOptimum(ArrProperResults);
  SaveStageCalInput('TextStageCalInput.txt');
end;

procedure TframeStageCal.actGetPSStage2Execute(Sender: TObject);
var
	i : integer;
const
  arrPSManualInput2Title: array[0..9] of string = ('Ωm', 'α1','ln', 'Δ','dp', 'δp', 'zp', 'δz', 'ΔS','Zm');
  arrPSManualInput2Unit : array[0..9] of string = ('-', '°','mm', 'mm','mm', 'mm', '-', 'mm', 'mm','-');
begin
//Grid
	StrGridPSManualInput.Hide;
  with StrGridPSManualInput2 do begin
  	Visible := True;
    ScrollBars := ssBoth;
  	RowCount := 11;
    if aStageDiv <> nil then begin
  		ColCount := aStageDiv.Z+2;//除开调节级，但加上了显示单位的Col
    end;
  	Options := Options + [goEditing];
  	Width := (ColCount+1)*DefaultColWidth;
  	Height := (RowCount+1)*DefaultRowHeight;
    Cells[0,0] := 'Item';
    Cells[1,0] := 'Unit';
    if aStageDiv <> nil then begin
  		for i := 2 to aStageDiv.Z+1 do begin
      	Cells[i,0] := inttostr(i-1);
  		end;
    end;
  	for i := 1 to RowCount-1 do begin
      Cells[0,i] := arrPSManualInput2Title[i-1];
      Cells[1,i] := arrPSManualInput2Unit[i-1];
  	end;
  end;
//      
end;

procedure TframeStageCal.V2D2(param:TStageCal);
var
	i : integer;
begin
	if param <> nil then begin
 {
  	if (aGoverningStage.GSType = SBGS) then begin
  		with StrGridGSDesignInput do begin
				TSingleGoverningStage(param.Stages.Items[0]).OmegaM    		    := StrToFloat(Cells[1,3]);
				TSingleGoverningStage(param.Stages.Items[0]).alpha1      	    := StrToFloat(Cells[1,4]);
				TSingleGoverningStage(param.Stages.Items[0]).e      	 					:= StrToFloat(Cells[1,5]);
				TSingleGoverningStage(param.Stages.Items[0]).BladeHeightDelta  := StrToFloat(Cells[1,6]);
        TSingleGoverningStage(param.Stages.Items[0]).Zm                := StrToFloat(Cells[1,7]);
    	end;
    end else if (aGoverningStage.GSType = DBGS) then begin
  		with StrGridGSDesignInput do begin
				TDoubleGoverningStage(param.Stages.Items[0]).Omegab    		     := StrToFloat(Cells[1,3]);
				TDoubleGoverningStage(param.Stages.Items[0]).Omegag             := StrToFloat(Cells[1,4]);
				TDoubleGoverningStage(param.Stages.Items[0]).Omegaba            := StrToFloat(Cells[1,5]);
				TDoubleGoverningStage(param.Stages.Items[0]).alpha1      	     := StrToFloat(Cells[1,6]);
				TDoubleGoverningStage(param.Stages.Items[0]).e      	           := StrToFloat(Cells[1,7]);
				TDoubleGoverningStage(param.Stages.Items[0]).BladeHeightDelta   := StrToFloat(Cells[1,8]);
        TDoubleGoverningStage(param.Stages.Items[0]).Zm                  := StrToFloat(Cells[1,9]);
    	end;
    end;
 }
		for i := 1 to (param.Stages.Count-1) do begin
    {
    	with StrGridPSAutoInput do begin
				TPressureStage(param.Stages.Items[i]).G    := StrToFloat(Cells[i+1,1]);
				TPressureStage(param.Stages.Items[i]).N    := StrToInt(Cells[i+1,2]);
        TPressureStage(param.Stages.Items[i]).Eht  := StrToFloat(Cells[i+1,3]);
				TPressureStage(param.Stages.Items[i]).dn   := StrToFloat(Cells[i+1,4]);
				TPressureStage(param.Stages.Items[i]).db   := StrToFloat(Cells[i+1,5]);
				TPressureStage(param.Stages.Items[i]).xa   := StrToFloat(Cells[i+1,6]);
      end;
    }
      with StrGridPSManualInput do begin
				TPressureStage(param.Stages.Items[i]).Omegam             := StrToFloat(Cells[i+1,1] );
				TPressureStage(param.Stages.Items[i]).alpha1             := StrToFloat(Cells[i+1,2] );
				TPressureStage(param.Stages.Items[i]).ln                  := StrToFloat(Cells[i+1,3] );
				TPressureStage(param.Stages.Items[i]).BladeHeightdelta   := StrToFloat(Cells[i+1,4] );
				TPressureStage(param.Stages.Items[i]).dp                 := StrToFloat(Cells[i+1,5] );
				TPressureStage(param.Stages.Items[i]).deltalp            := StrToFloat(Cells[i+1,6] );
				TPressureStage(param.Stages.Items[i]).zp                 := StrToFloat(Cells[i+1,7] );
				TPressureStage(param.Stages.Items[i]).deltalz            := StrToFloat(Cells[i+1,8] );
				TPressureStage(param.Stages.Items[i]).DeltaS             := StrToFloat(Cells[i+1,9] );
        TPressureStage(param.Stages.Items[i]).Zm                 := StrToFloat(Cells[i+1,10] );
     	end;
    	with StrGridPSAutoOutput do begin
    		TPressureStage(param.Stages.Items[i]).Miu1  := StrToFloat(Cells[i+1,1]);
      end;
    end;
  end else
  	Showmessage('Not Initialized yet!');
end;

procedure TframeStageCal.D2V2(param:TStageCal);
var
	i : integer;
begin
	if param <> nil then begin
  	if (aGoverningStage.GSType = SBGS) then begin
  		with StrGridGSDesignInput do begin 
        Cells[1,1] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).Eht);
        Cells[1,2] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).dm);
    		Cells[1,3] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).OmegaM);
      	Cells[1,4] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).alpha1);
      	Cells[1,5] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).ln);
      	Cells[1,6] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).BladeHeightDelta);
      	Cells[1,7] := Floattostr(TSingleGoverningStage(param.Stages.Items[0]).Zm);
    	end;
    end else if (aGoverningStage.GSType = DBGS) then begin
  		with StrGridGSDesignInput do begin
        Cells[1,1] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).Eht);
        Cells[1,2] := FloatToStr(TSingleGoverningStage(param.Stages.Items[0]).dm);
    		Cells[1,3] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Omegab);
        Cells[1,4] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Omegag);
        Cells[1,5] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Omegaba);
      	Cells[1,6] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).alpha1);
      	Cells[1,7] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).ln);
      	Cells[1,8] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).BladeHeightDelta);
        Cells[1,9] := Floattostr(TDoubleGoverningStage(param.Stages.Items[0]).Zm);
    	end;       
    end;
		for i := 1 to (param.Stages.Count-1) do begin
    	with StrGridPSAutoInput do begin
    		Cells[i+1,1]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).G]);
    		Cells[i+1,2]  := format('%d',[TPressureStage(param.Stages.Items[i]).N]);
      	Cells[i+1,3]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).Eht]);
      	Cells[i+1,4]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).dn]);
      	Cells[i+1,5]  := format('%.2f',[TPressureStage(param.Stages.Items[i]).db]);
      	Cells[i+1,6]  := format('%.3f',[TPressureStage(param.Stages.Items[i]).xa]);
      end;
      with StrGridPSManualInput do begin
      	Cells[i+1,1]  := Floattostr(TPressureStage(param.Stages.Items[i]).Omegam);
        Cells[i+1,2]  := Floattostr(TPressureStage(param.Stages.Items[i]).alpha1);
        Cells[i+1,3]  := Floattostr(TPressureStage(param.Stages.Items[i]).ln);
    		Cells[i+1,4] := Floattostr(TPressureStage(param.Stages.Items[i]).BladeHeightdelta);
      	Cells[i+1,5] := Floattostr(TPressureStage(param.Stages.Items[i]).dp);
      	Cells[i+1,6] := Floattostr(TPressureStage(param.Stages.Items[i]).deltalp);
      	Cells[i+1,7] := Floattostr(TPressureStage(param.Stages.Items[i]).zp);
      	Cells[i+1,8] := Floattostr(TPressureStage(param.Stages.Items[i]).deltalz);
      	Cells[i+1,9] := Floattostr(TPressureStage(param.Stages.Items[i]).deltaS);
        Cells[i+1,10] := Floattostr(TPressureStage(param.Stages.Items[i]).Zm);
     end;
    	with StrGridPSAutoOutput do begin
    		Cells[i+1,1]  := Floattostr(TPressureStage(param.Stages.Items[i]).Miu1);
      end;
    end;
  end else
  	Showmessage('Not Initialized yet!');
end;

procedure TFrameStageCal.actRefreshExecute(Sender: TObject);
begin
  actCalculate.Execute;
  actDraw.Execute;
end;

procedure TFrameStageCal.LoadSaved(const FileName: TFileName);
var
 f: TextFile;
 iTmp, i, k, tmpZ : Integer;
 dTmp : double;
 strTmp: String;
begin
 	AssignFile(f, FileName);
 	Reset(f);
	While not eof(f) do begin
  	Readln(f, strTmp);
    if LowerCase(StrTmp) = LowerCase('[Z]') then begin
    	Readln(f, iTmp);
      tmpZ := iTmp;
    	Continue;
    end;
    if StrTmp = '[StrGridPSManualInput]' then begin
    	with StrGridPSManualInput do begin
      	Readln(f, iTmp);
        RowCount := iTmp;
   			Readln(f, iTmp);
        ColCount := iTmp;
   			for i := 0 to RowCount - 1 do begin
     			for k := 0 to ColCount - 1 do begin
       			Readln(f, strTmp);
       			Cells[k, i] := strTmp;
          end;
        end;
     	end;
   	end;
    if StrTmp = '[StrGridPSAutoOutput]' then begin
    	with StrGridPSAutoOutput do begin
      	Readln(f, iTmp);
       	RowCount := iTmp;
   			Readln(f, iTmp);
   			ColCount := iTmp;
   			for i := 0 to RowCount - 1 do begin
     			for k := 0 to ColCount - 1 do begin
       			Readln(f, strTmp);
       			Cells[k, i] := strTmp;
          end;
        end;
     	end;
   	end;
  end;
  CloseFile(f);
end;

procedure  TframeStageCal.SaveStageCalInput(const FileName: TFileName);
var
 f: TextFile;
 iTmp, i, k: Integer;
 dTmp : double;
 strTmp: String;
 tmpZPre : integer;
 tmpRange : integer;
begin
  tmpZPre := 0;
 	AssignFile(f, FileName);
 	Rewrite(f);

	// Save Output Params to a file
  Writeln(f, '[Z]');
  Writeln(f, aStageDiv.Z);

	// Save a TStringGrid to a file
  Writeln(f, '[StrGridPSManualInput]');
 	with StrGridPSManualInput do begin
   // Write number of Columns/Rows
   	Writeln(f, RowCount);
   	Writeln(f, ColCount);
   // loop through cells
   	for k := 0 to RowCount - 1 do
     	for i := 0 to ColCount - 1 do
       	Writeln(F, Cells[i, k]);
 	end;

  Writeln(f, '[StrGridPSAutoOutput]');
 	with StrGridPSAutoOutput do begin
   // Write number of Columns/Rows
   	Writeln(f, RowCount);
   	Writeln(f, ColCount);
   // loop through cells
   	for k := 0 to RowCount - 1 do
     	for i := 0 to ColCount - 1 do
       	Writeln(F, Cells[i, k]);
 	end;   
 	CloseFile(F);
end;

procedure TFrameStageCal.BtnLoadSavedClick(Sender: TObject);
begin
	LoadSaved('TextStageCalInput.txt');
end;

end.
