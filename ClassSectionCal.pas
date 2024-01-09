unit ClassSectionCal;

interface
uses
	SysUtils, Classes, math, Dialogs, TDPointUtils, BasicStructures,
  ClassIniData, ClassGoverningStage, ClassHRSys, ClassHRSysWithDA,
  ClassStageDiv, ClassCoupling, ClassStageCal,
  ClassStage;

{SectionCal}
type
	TSectionCal = Class
  	ZHRB : integer;
  	arrDHRB :TDyArray;
    arrPHRB :TDyArray;
  	PiHRB   : double;
  	PaHRB   : double;
    PeHRB   : double;
    dHRB    : double;
    daHRB   : double;
    qHRB    : double;
    YitaElHRB : double;
    yitari  : double;
    Pin     : double;
    Pa      : double;
    Pe      : double;
  private
		FiniData        : TIniData;
    FGoverningStage : TGoverningStage;
    FHRSys          : THRSys;
    FHRSysWithDA    : THRSysWithDA;
    FStageDiv       : TStageDiv;
    FCoupling       : TCoupling;
    FStageCal       : TStageCal;  
  public
    Constructor Create(iniData:TIniData;
    GoverningStage:TGoverningStage; HRSys:THRSys; StageDiv:TStageDiv;
    Coupling:TCoupling; StageCal:TStageCal);overload;
    Constructor Create(iniData:TIniData;
    GoverningStage:TGoverningStage; HRSysWithDA:THRSysWithDA; StageDiv:TStageDiv;
    Coupling:TCoupling; StageCal:TStageCal);overload;
    procedure GetarrDHRB;
    procedure GetarrPHRB;
    procedure GetPiHRB;
    procedure GetPaHRB;
    procedure GetPeHRB;
    procedure GetPa;
    procedure GetPe;
    procedure GetdHRB;
    procedure GetdaHRB;
    procedure GetqHRB;
    procedure GetYitaElHRB;
    procedure Check;
  end;

implementation

//TSectionCal
Constructor TSectionCal.Create(iniData:TIniData;
    GoverningStage:TGoverningStage; HRSys:THRSys;
    StageDiv:TStageDiv; Coupling:TCoupling; StageCal:TStageCal);
begin
	FiniData        := nil;
  FGoverningStage := nil;
  FHRSys          := nil;
  FHRSyswithDA    := nil;
  FStageDiv       := nil;
  FCoupling       := nil;
  FStageCal       := nil;
	FiniData        := IniData;
  FGoverningStage := GoverningStage;
  FHRSys          := HRSys;
  FStageDiv       := StageDiv;
  FCoupling       := Coupling;
  FStageCal       := StageCal;
 	Self.ZHRB := FCoupling.ZHR + 2 ;
  SetLength(arrDHRB,ZHRB);
  SetLength(arrPHRB,ZHRB);
  Self.yitari := FStageCal.yitari;
  Self.Pin := FStageCal.SumPi;
end;

Constructor TSectionCal.Create(iniData:TIniData;
    GoverningStage:TGoverningStage; HRSysWithDA:THRSysWithDA; StageDiv:TStageDiv;
    Coupling:TCoupling; StageCal:TStageCal);
begin
	FiniData        := nil;
  FGoverningStage := nil;
  FHRSys          := nil;
  FHRSyswithDA    := nil;
  FStageDiv       := nil;
  FCoupling       := nil;
  FStageCal       := nil;
	FiniData        := IniData;
  FGoverningStage := GoverningStage;
  FHRSysWithDA    := HRSysWithDA;
  FStageDiv       := StageDiv;
  FCoupling       := Coupling;
  FStageCal       := StageCal;
 	Self.ZHRB := FCoupling.ZHR + 2 ;
  SetLength(arrDHRB,ZHRB);
  SetLength(arrPHRB,ZHRB);
  Self.yitari := FStageCal.yitari;
  Self.Pin := FStageCal.SumPi;
end;

procedure TSectionCal.GetPa;
begin
	Pa := Pin * FIniData.AdjustmentData.yitaax;
end;

procedure TSectionCal.GetPe;
begin
  if FIniData.BasicData.N = 3000 then begin
  	Pe := Pa * FIniData.AdjustmentData.yitag;
  end else if FIniData.BasicData.N > 3000 then begin
  	Pe := Pa * FIniData.AdjustmentData.yitag * FIniData.AdjustmentData.yitabox;
  end;
end;

procedure TSectionCal.GetarrDHRB;
var
	i : integer;
begin
  if FHRSys <> nil then begin
		if ZHRB = 2 then begin
			arrDHRB[0] := FIniData.D0; //调节级
  		arrDHRB[1] := arrDHRB[0] - FIniData.BasicData.DeltaDl; //压力级第一级组
  	end else if ZHRB > 2 then begin
			arrDHRB[0] := FIniData.D0; //调节级
  		arrDHRB[1] := arrDHRB[0] - FIniData.BasicData.DeltaDl; //压力级第一级组
			for i := 2 to ZHRB-1 do begin
				arrDHRB[i] := arrDHRB[i-1] - FHRSys.arrHROutput[i-2].DeltaDe;
  		end;
  	end;
  end else if  FHRSysWithDA <> nil then begin
		if ZHRB = 2 then begin
			arrDHRB[0] := FIniData.D0; //调节级
  		arrDHRB[1] := arrDHRB[0] - FIniData.BasicData.DeltaDl; //压力级第一级组
  	end else if ZHRB > 2 then begin
			arrDHRB[0] := FIniData.D0; //调节级
  		arrDHRB[1] := arrDHRB[0] - FIniData.BasicData.DeltaDl; //压力级第一级组
			for i := 2 to ZHRB-1 do begin
				arrDHRB[i] := arrDHRB[i-1] - FHRSysWithDA.arrHROutput[i-2].DeltaDe;
  		end;
  	end;
  end;
end;

procedure TSectionCal.GetarrPHRB;
var
	i : integer;
begin
  if FHRSys <> nil then begin
	  if FGoverningStage.GSType = SBGS then begin
	  	if ZHRB = 2 then begin//无抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSys.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSys.Hl - MainTDPointZ.H)/3600;
	  	end else if ZHRB = 3 then begin//只有一段抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSys.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSys.Hl - FHRSys.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
	      arrPHRB[2] := arrDHRB[2]*(FHRSys.arrHROutput[0].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end else if ZHRB > 3 then begin //抽汽>=1
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSys.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSys.Hl - FHRSys.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
				for i := 2 to ZHRB-2 do begin
					arrPHRB[i] := arrDHRB[i]*(FHRSys.arrHROutput[i-1].PTDPointExtraction^.H-FHRSys.arrHROutput[i].PTDPointExtraction^.H)/3600;
	  		end;
	      arrPHRB[ZHRB-1] := arrDHRB[ZHRB-1]*(FHRSys.arrHROutput[ZHRB-3].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end;
	  end else if FGoverningStage.GSType = DBGS then begin
	  	if ZHRB = 2 then begin//无抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSys.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSys.Hl - MainTDPointZ.H)/3600;
	  	end else if ZHRB = 3 then begin//只有一段抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSys.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSys.Hl - FHRSys.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
	      arrPHRB[2] := arrDHRB[2]*(FHRSys.arrHROutput[0].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end else if ZHRB > 3 then begin //抽汽>=1
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSys.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSys.Hl - FHRSys.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
				for i := 2 to ZHRB-2 do begin
					arrPHRB[i] := arrDHRB[i]*(FHRSys.arrHROutput[i-1].PTDPointExtraction^.H-FHRSys.arrHROutput[i].PTDPointExtraction^.H)/3600;
	  		end;
	      arrPHRB[ZHRB-1] := arrDHRB[ZHRB-1]*(FHRSys.arrHROutput[ZHRB-3].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end;
	 	end;
  end else if  FHRSysWithDA <> nil then begin
	  if FGoverningStage.GSType = SBGS then begin
	  	if ZHRB = 2 then begin//无抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSysWithDA.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSysWithDA.Hl - MainTDPointZ.H)/3600;
	  	end else if ZHRB = 3 then begin//只有一段抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSysWithDA.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSysWithDA.Hl - FHRSysWithDA.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
	      arrPHRB[2] := arrDHRB[2]*(FHRSysWithDA.arrHROutput[0].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end else if ZHRB > 3 then begin //抽汽>=1
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSysWithDA.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSysWithDA.Hl - FHRSysWithDA.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
				for i := 2 to ZHRB-2 do begin
					arrPHRB[i] := arrDHRB[i]*(FHRSysWithDA.arrHROutput[i-1].PTDPointExtraction^.H-FHRSysWithDA.arrHROutput[i].PTDPointExtraction^.H)/3600;
	  		end;
	      arrPHRB[ZHRB-1] := arrDHRB[ZHRB-1]*(FHRSysWithDA.arrHROutput[ZHRB-3].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end;
	  end else if FGoverningStage.GSType = DBGS then begin
	  	if ZHRB = 2 then begin//无抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSysWithDA.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSysWithDA.Hl - MainTDPointZ.H)/3600;
	  	end else if ZHRB = 3 then begin//只有一段抽汽
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSysWithDA.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSysWithDA.Hl - FHRSysWithDA.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
	      arrPHRB[2] := arrDHRB[2]*(FHRSysWithDA.arrHROutput[0].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end else if ZHRB > 3 then begin //抽汽>=1
				arrPHRB[0] := FIniData.D0*(MainTDPoint0a.H - FHRSysWithDA.Hl)/3600; //调节级
	  		arrPHRB[1] := arrDHRB[1]*(FHRSysWithDA.Hl - FHRSysWithDA.arrHROutput[0].PTDPointExtraction^.H)/3600; //压力级第一级组
				for i := 2 to ZHRB-2 do begin
					arrPHRB[i] := arrDHRB[i]*(FHRSysWithDA.arrHROutput[i-2].PTDPointExtraction^.H-FHRSysWithDA.arrHROutput[i-1].PTDPointExtraction^.H)/3600;
	  		end;
	      arrPHRB[ZHRB-1] := arrDHRB[ZHRB-1]*(FHRSysWithDA.arrHROutput[ZHRB-3].PTDPointExtraction^.H - MainTDPointZ.H)/3600;
	    end;
	 	end;
  end;
end;

procedure TSectionCal.GetPiHRB;
begin
	PiHRB := Sum(arrPHRB);
end;

procedure TSectionCal.GetPaHRB;
begin
	PaHRB := PiHRB * FIniData.AdjustmentData.yitaax;
end;

procedure TSectionCal.GetPeHRB;
begin
  if FIniData.BasicData.N = 3000 then begin
  	PeHRB := PaHRB * FIniData.AdjustmentData.yitag;
  end else if FIniData.BasicData.N > 3000 then begin
  	PeHRB := PaHRB * FIniData.AdjustmentData.yitag * FIniData.AdjustmentData.yitabox;
  end;
end;

procedure TSectionCal.GetdHRB;
begin
	dHRB := FIniData.D0 / PeHRB;
end;

procedure TSectionCal.GetdaHRB;
begin
	daHRB := FIniData.D0/(FIniData.D0*(MainTDPoint0a.H-MainTDPointZ.H)/3600-(PiHRB-PaHRB))/FIniData.AdjustmentData.yitag;
end;

procedure TSectionCal.GetqHRB;
begin
  if FHRSys <> nil then begin
    qHRB  := dHRB * (MainTDPoint0a.H - FHRSys.fwOutTDPoint.H);
  end else if FHRSysWithDA <> nil then begin
    qHRB  := dHRB * (MainTDPoint0a.H - FHRSysWithDA.fwOutTDPoint.H);
  end;
end;

procedure TSectionCal.GetYitaElHRB;
begin
	YitaElHRB := 3600 / qHRB;
end;

procedure TSectionCal.Check;
begin
	if abs((Self.Pe - FIniData.BasicData.pe) / FIniData.BasicData.pe) > 0.03 then begin
     Showmessage('Pi check failed!');
  end else begin
     Showmessage('Pi is qualified!');
  end;
	if abs((Self.yitari - FIniData.AdjustmentData.yitari) / FIniData.AdjustmentData.yitari) > 0.03 then begin
     Showmessage('ηi check failed!');
  end else begin
     Showmessage('ηi is qualified!');
  end;
end;


end.

