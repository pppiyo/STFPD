unit ClassStageCal;

interface
uses
	SysUtils, Classes, math, Dialogs, TDPointUtils, BasicStructureS,
  ClassIniData, ClassGoverningStage, ClassHRSys, ClassHRSysWithDA, ClassStageDiv, ClassCoupling,
  ClassStage, UpriseDataGenerator, VProcess;

{StageCal}
type
	TStageCal = Class
  	Z : integer;
		Stages : TList;
    yitari : double;
    SumPi  : double;
  	arrn: array of integer;//仅含压力级
  	arrG, arrDm, arrdn, arrdb, arrEht, arrxa : array of double;//仅含压力级
  	arrGDummy : array of double;//仅含压力级
    FfinalCurveTDPoints : array of TTDPoint;
  private
  	procedure ReviseMiu1;
    procedure GetOptimumE;
    procedure GetOptimumAlpha1;
    procedure GetOptimumOmegam;
  public
    tag : integer;
    FIniData        : TIniData;
    FGoverningStage : TGoverningStage;
    FHRSys          : THRSys;
    FHRSysWithDA    : THRSysWithDA;
    FStageDiv       : TStageDiv;
    FCoupling       : TCoupling;
  	constructor Create(IniData:TIniData; GoverningStage:TGoverningStage; HRSys:THRSys; StageDiv:TStageDiv; Coupling:TCoupling);Overload;
  	constructor Create(IniData:TIniData; GoverningStage:TGoverningStage; HRSysWithDA:THRSysWithDA; StageDiv:TStageDiv; Coupling:TCoupling);Overload;
    procedure GetYitari;
    procedure GetSumPi;
    procedure GetNewTDProcessCurve;
    procedure SolutionGenerator;
    procedure Iteration;
  end;

implementation

//TStageCal
Constructor TStageCal.Create(IniData:TIniData;GoverningStage:TGoverningStage;
                              HRSys:THRSys;StageDiv:TStageDiv;Coupling:TCoupling);
var
	i,j : integer;
begin
  tag := 0;
  //赋初始值
  FIniData        := IniData;
  FGoverningStage := GoverningStage;
  FHRSys          := HRSys;
  FStageDiv       := StageDiv;
  FCoupling       := Coupling;
	Self.Z := Coupling.Z;  //修正Coupling.Z;
  Self.Stages := TList.Create;
  Self.yitari := 0;
  Self.SumPi := 0;
  //压力级初始化(前提条件)
  SetLength(arrGDummy, HRSys.ZHR+1);
  arrGDummy[0] := (IniData.D0 - IniData.BasicData.DeltaDl)/3600;//压力级第一级流量
  for i := 1 to HRSys.ZHR do begin
  	arrGDummy[i] := arrGDummy[i-1] - HRSys.arrHROutput[i-1].DeltaDe/3600;
  end;
  SetLength(arrG, StageDiv.Z); //压力级
  for j := 0 to Length(arrG)-1 do begin//只用作计数
  	if j <= (Coupling.DDArrPosList[0,1]-1) then begin
    	arrG[j] := arrGDummy[0];
      Continue;
    end;
    for i := 0 to HRSys.ZHR-2 do begin
    	if ((j > (Coupling.DDArrPosList[i,1]-1)) and (j <= (Coupling.DDArrPosList[i+1,1]-1))) then begin
      	arrG[j] := arrGDummy[i+1];
      end;
    end;
    if j > (Coupling.DDArrPosList[HRSys.ZHR-1,1]-1) then begin
    	arrG[j] := arrGDummy[HRSys.ZHR];
      Continue;
    end;
  end;
  SetLength(arrn, StageDiv.Z);
  SetLength(arrDm,StageDiv.Z);
  SetLength(arrdn,StageDiv.Z);
  SetLength(arrdb,StageDiv.Z);
  SetLength(arrEht,StageDiv.Z);
  SetLength(arrxa,StageDiv.Z);
  for i := 0 to StageDiv.Z-1 do begin
  	arrN[i]  := IniData.BasicData.N;
  	arrDm[i] := StageDiv.arrDm[i];
  	arrdn[i] := StageDiv.arrDm[i];
  	arrdb[i] := StageDiv.arrDm[i]+1;
  	arrEht[i]:= StageDiv.arrEht[i];
  	arrxa[i] := StageDiv.arrxa[i];
  end;
end;

Constructor TStageCal.Create(IniData:TIniData;GoverningStage:TGoverningStage;
                              HRSysWithDA:THRSysWithDA;StageDiv:TStageDiv;Coupling:TCoupling);
var
	i,j : integer;
begin
  tag := 0;
  //赋初始值
  FIniData        := IniData;
  FGoverningStage := GoverningStage;
  FHRSysWithDA    := HRSysWithDA;
  FStageDiv       := StageDiv;
  FCoupling       := Coupling;
	Self.Z := Coupling.Z; //修正Coupling.Z;
  Self.Stages := TList.Create;
  Self.yitari := 0;
  Self.SumPi := 0;
    //压力级初始化(前提条件)
  	SetLength(arrGDummy, HRSysWithDA.ZHR+1);
  	arrGDummy[0] := (IniData.D0 - IniData.BasicData.DeltaDl)/3600;//压力级第一级流量
  	for i := 1 to HRSysWithDA.ZHR do begin
  		arrGDummy[i] := arrGDummy[i-1] - HRSysWithDA.arrHROutput[i-1].DeltaDe/3600;
  	end;
  	SetLength(arrG, StageDiv.Z); //压力级
  	for j := 0 to Length(arrG)-1 do begin//只用作计数
  		if j <= (Coupling.DDArrPosList[0,1]-1) then begin
  	  	arrG[j] := arrGDummy[0];
        Continue;
      end;
  	  for i := 0 to HRSysWithDA.ZHR-2 do begin
  	  	if ((j > (Coupling.DDArrPosList[i,1]-1)) and (j <= (Coupling.DDArrPosList[i+1,1]-1))) then begin
  	    	arrG[j] := arrGDummy[i+1];
  	    end;
  	  end;
  	  if j > (Coupling.DDArrPosList[HRSysWithDA.ZHR-1,1]-1) then begin
  	  	arrG[j] := arrGDummy[HRSysWithDA.ZHR];
        Continue;
      end;
  	end;
  	SetLength(arrn, StageDiv.Z);
  	SetLength(arrDm,StageDiv.Z);
  	SetLength(arrdn,StageDiv.Z);
  	SetLength(arrdb,StageDiv.Z);
  	SetLength(arrEht,StageDiv.Z);
  	SetLength(arrxa,StageDiv.Z);
  	for i := 0 to StageDiv.Z-1 do begin
  		arrN[i]  := IniData.BasicData.N;
  		arrDm[i] := StageDiv.arrDm[i];
  		arrdn[i] := StageDiv.arrDm[i];
  		arrdb[i] := StageDiv.arrDm[i]+1;
  		arrEht[i]:= StageDiv.arrEht[i];
  		arrxa[i] := StageDiv.arrxa[i];
  	end;
end;

procedure TStageCal.GetNewTDProcessCurve;
var
	i : integer;
begin
  SetLength(FfinalCurveTDPoints, Self.Stages.Count);
  if FGoverningStage.GSType = SBGS then begin  //单列调节级
    FfinalCurveTDPoints[0] := TSingleGoverningStage(Self.Stages.Items[0]).TDPoint2;
  end else if FGoverningStage.GSType = DBGS  then begin
    FfinalCurveTDPoints[0] := TDoubleGoverningStage(Self.Stages.Items[0]).TDPoint2;
  end;
	for i := 1 to Self.Stages.Count-1 do begin
  	FfinalCurveTDPoints[i] := TPressureStage(Self.Stages.Items[i]).TDPoint2;
  end;
end;

procedure TStageCal.GetYitari;
var
	i : integer;
begin
	if Self.Stages <> nil then begin
  	Self.yitari := (MainTDPoint0a.H - TPressureStage(Self.Stages.Items[Self.Stages.Count-1]).TDPoint2.H) /
  	(MainTDPoint0a.H - PSGetTDPoint(MainTDPointZ.P, MainTDPoint0a.S).H);
  end else
  	Showmessage('Not initialized yet!');
  tag := 1;
end;

procedure TStageCal.GetSumPi;
var
	i : integer;
  tmparrPin : array of double;
begin
	Setlength(tmparrPin,Self.Z);
	if Self.Stages <> nil then begin
  	if FGoverningStage.GSType = SBGS then begin  //单列调节级
    	tmparrPin[0] := TSingleGoverningStage(Self.Stages.Items[0]).Pin;
  		for i := 1 to Self.Stages.Count-1 do begin
  			tmparrPin[i] := TPressureStage(Self.Stages.Items[i]).Pin;
    	end;
    end else if FGoverningStage.GSType = DBGS then begin //双列调节级
    	tmparrPin[0] := TDoubleGoverningStage(Self.Stages.Items[0]).Pin;
  		for i := 1 to Self.Stages.Count-1 do begin
  			tmparrPin[i] := TPressureStage(Self.Stages.Items[i]).Pin;
    	end;
    end;
    Self.SumPi := Sum(tmpArrPin);
  end else
  	Showmessage('Not initialized yet!');
end;

procedure TStageCal.ReviseMiu1;
var
	i : integer;
  tmpMiu1e,tmpMiu1G,tmpMiu1db : TDyArray;
begin
	  SetLength(tmpMiu1e,self.Z-2);//除开第一级和最后一级
	  SetLength(tmpMiu1G,self.Z-2);//除开第一级和最后一级
	  SetLength(tmpMiu1db,self.Z-2);//除开第一级和最后一级
	  for i := 0 to Self.Z-3 do begin
	  	if ((TPressureStage(Self.Stages.Items[i+1]).e = 1) and (TPressureStage(Self.Stages.Items[i+2]).e = 1)) then begin
	    	tmpMiu1e[i] := 1;
	    end else begin
	      tmpMiu1e[i] := 0;
	    end;
	  	if (TPressureStage(Self.Stages.Items[i+1]).G = TPressureStage(Self.Stages.Items[i+2]).G) then begin
	    	tmpMiu1G[i] := 1;
	    end else begin
	      tmpMiu1G[i] := 0.5;
	    end;
	  	if (TPressureStage(Self.Stages.Items[i+2]).db / TPressureStage(Self.Stages.Items[i+1]).db <=1.5) then begin
	    	tmpMiu1db[i] := 1;
	    end else begin
	      tmpMiu1db[i] := 0.5;
	    end;
	  end;
	  for i := 0 to Self.Z-3 do begin
	  	if (tmpMiu1e[i] = 1) and (tmpMiu1G[i] = 1) and (tmpMiu1db[i] = 1) then begin //1 1 1
	    	TPressureStage(Self.Stages.Items[i+1]).Miu1 := 1;
      end else if (tmpMiu1e[i] = 1) and (tmpMiu1G[i] = 1) and (tmpMiu1db[i] = 0.5) then begin //1 1 0.5
	    	TPressureStage(Self.Stages.Items[i+1]).Miu1 := 0.5;
	    end else if (tmpMiu1e[i] = 1) and (tmpMiu1G[i] = 0.5) and (tmpMiu1db[i] = 1) then begin //1 0.5 1
	    	TPressureStage(Self.Stages.Items[i+1]).Miu1 := 0.5;
	    end else if (tmpMiu1e[i] = 1) and (tmpMiu1G[i] = 0.5) and (tmpMiu1db[i] = 0.5) then begin //1 0.5 0.5
	    	TPressureStage(Self.Stages.Items[i+1]).Miu1 := 0.5;
	    end else if tmpMiu1e[i] = 0 then begin //0
	    	TPressureStage(Self.Stages.Items[i+1]).Miu1 := 0;
      end;
	  end;
    TPressureStage(Self.Stages.Items[Self.Z-1]).Miu1 := 0;
end;

procedure TStageCal.GetOptimumE;
var
	i : integer;
  tmparrx : TDyArray;
  tmpNumEequ1 : integer;
begin
	Randomize;
  	tmpNumEequ1 := Random(Self.Z-1);//随机设置e=1的个数
    tmparrx := GetUpriseDataArray(Self.Z -1 - tmpNumEequ1, 0.3 , 1);//生成非1的递增e序列
    for i := 0 to Self.Z-2 do begin
    	if i <= Length(tmparrx)-1 then begin
	    	TPressureStage(Self.Stages.Items[i+1]).e := tmparrx[i];
      end else begin
     		TPressureStage(Self.Stages.Items[i+1]).e := 1;
      end;
    end;
end;

procedure TStageCal.GetOptimumAlpha1;
var
	i : integer;
  tmparrx : TDyArray;
begin
  	tmparrx := GetUpriseDataArray(Self.Z - 1, 10.5, 14); //TC-1A ~ TC-3A Series  //10.5 , 22
  	for i := 0 to Self.Z-2 do begin
  		TPressureStage(Self.Stages.Items[i+1]).Alpha1 := tmparrx[i];
    end;
end;

procedure TStageCal.GetOptimumOmegam;
var
	i : integer;
  tmparrx : TDyArray;
begin
  	tmparrx := GetUpriseDataArray(Self.Z-1, 0.08 , 0.5); //TC-1A ~ TC-3A Series
  	for i := 0 to Self.Z-2 do begin
  		TPressureStage(Self.Stages.Items[i+1]).OmegaM := tmparrx[i];
  	end;
end;

procedure TStageCal.SolutionGenerator;
var
	i : integer;
begin
	ReviseMiu1;    //在外层套一个循环，在后方加入ln变化趋势和效率计算结果的筛选
  GetOptimumE;
  GetOptimumAlpha1;
  GetOptimumOmegam;
end;

procedure TStageCal.Iteration; //withDA
var
  i, j : integer;
  tmparrPostStageEx : TTDPointList;
  tmparrNewHRSysOut : TTDPointList;
begin
	if FHRSysWithDA <> nil then begin
  	SetLength(tmparrPostStageEx, FHRSysWithDA.ZHR);
  	SetLength(tmparrNewHRSysOut, FHRSysWithDA.ZHR);
  	for i := 0 to FHRSysWithDA.ZHR-1 do begin
  		tmparrPostStageEx[i] := TPressureStage(self.Stages.Items[FCoupling.DDArrPosList[i,1]]).TDPoint3;
    	tmparrNewHRSysOut[i] := FHRSysWithDA.arrHROutput[i].PTDPointExtraction^;
  	end;
  	if tmparrNewHRSysOut <> tmparrPostStageEx then begin
  		AddMessage('Need Iteration', 'MessageBox.txt');
    	SetLength(FHRSysWithDA.arrNewTDPointExtraction, FHRSysWithDA.ZHR);
    	for i := 0 to FHRSysWithDA.ZHR-1 do begin
      	FHRSysWithDA.arrNewTDPointExtraction[i] := tmparrPostStageEx[i];
    	end;
    	FHRSysWithDA.GetNewDeltaDe;{再加入级迭代类的一系列算法}
  	end;
  end else begin
  	SetLength(tmparrPostStageEx, FHRSys.ZHR);
  	SetLength(tmparrNewHRSysOut, FHRSys.ZHR);
  	for i := 0 to FHRSys.ZHR-1 do begin
  		tmparrPostStageEx[i] := TPressureStage(self.Stages.Items[FCoupling.DDArrPosList[i,1]]).TDPoint3;
    	tmparrNewHRSysOut[i] := FHRSys.arrHROutput[i].PTDPointExtraction^;
  	end;
  	if tmparrNewHRSysOut <> tmparrPostStageEx then begin
  		AddMessage('Need Iteration', 'MessageBox.txt');
    	SetLength(FHRSys.arrNewTDPointExtraction, FHRSys.ZHR);
    	for i := 0 to FHRSys.ZHR-1 do begin
      	FHRSys.arrNewTDPointExtraction[i] := tmparrPostStageEx[i];
    	end;
    	FHRSys.GetNewDeltaDe;{再加入级迭代类的一系列算法}
    end;
  end;
end;


end.

