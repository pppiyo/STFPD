unit ClassCoupling;

interface
uses
	SysUtils, Classes, math, Dialogs,
  TDPointUtils, BasicStructures,
  ClassIniData, ClassGoverningStage, ClassHRSys, ClassStageDiv, ClassHRSysWithDA;

{Coupling}
type
  TCoupling = Class
    DDArrPosList : array of array of integer;// Col1:HRSys; Col2:StageDiv
  	arrHRSysOutTDPoint    : TTDPointList;
  	arrHRSysWithDAOutTDPoint    : TTDPointList;
    arrStageDivOutTDPoint : TTDPointList;
  private
  	//上级参数
    FIniData        : TIniData;
    FGoverningStage : TGoverningStage;
    FHRSys          : THRSys;
    FHRSysWithDA    : THRSysWithDA;
    FStageDiv       : TStageDiv;
    //本级参数
    FZ : integer;
    FZHR : integer;
    FarrflagStageDiv : TDyIntArray;
    FarrflagHRSysWithDA    : TDyIntArray;
    FarrflagHRSys    : TDyIntArray;
    procedure FindMatch;
  public
    tag : integer;
    Choice : integer;
    arrNewStageDivEht        : TDyArray; //based on HRSys/Both
  	arrNewStageDivOutTDPoint : TTDPointList;//based on HRSys
    arrNewHRSysOutTDPoint    : TTDPointList;//based on StageDiv
    arrNewHRSysWithDAOutTDPoint    : TTDPointList;//based on StageDiv
    Constructor Create(IniData:TIniData; GoverningStage:TGoverningStage; HRSys:THRSys; StageDiv:TStageDiv);overload;
    Constructor Create(IniData:TIniData; GoverningStage:TGoverningStage; HRSysWithDA:THRSysWithDA; StageDiv:TStageDiv);overload;
    property  Z : integer read FZ write FZ;
		property  ZHR: integer read FZHR write FZHR;
    procedure CheckOriData;
    procedure CoupleByStageDivSuggestions;
    procedure CoupleByHRSysSuggestions;
    procedure CoupleByBothSuggestions;
    procedure CoupleByBoth;
    procedure CoupleByHRSys;
    procedure CoupleByStageDiv;
  end;

implementation

//TCoupling
Constructor TCoupling.Create(IniData:TIniData; GoverningStage:TGoverningStage; HRSysWithDA:THRSysWithDA; StageDiv:TStageDiv);
var
  i : integer;
begin
  tag := 0;
	//上级参数
  FIniData        := IniData;
  FGoverningStage := GoverningStage;
  FHRSysWithDA    := HRSysWithDA;
  FStageDiv       := StageDiv;
  //本级参数
	if ((HRSysWithDA <> nil) and (StageDiv <> nil)) then begin
  	FZHR := HRSysWithDA.ZHR;
  	Setlength(arrHRSysWithDAOutTDPoint, FZHR);
  	for i := 0 to FZHR-1 do begin
  	  arrHRSysWithDAOutTDPoint[i] := HRSysWithDA.arrHROutput[i].PTDPointExtraction^;
  	end;
  	FZ := 1+StageDiv.Z;
  	Setlength(arrStageDivOutTDPoint, FZ);
    arrStageDivOutTDPoint[0]   :=  GoverningStage.GS.TDPoint3;
  	for i := 1 to FZ-1 do begin
  	  arrStageDivOutTDPoint[i] := StageDiv.arrPostStageTDPoint[i-1];
  	end;
	end;
end;

Constructor TCoupling.Create(IniData:TIniData; GoverningStage:TGoverningStage; HRSys:THRSys; StageDiv:TStageDiv);
var
  i : integer;
begin
  tag := 0;
	//上级参数
  FIniData        := IniData;
  FGoverningStage := GoverningStage;
  FHRSys          := HRSys;
  FStageDiv       := StageDiv;
  //本级参数
	if ((HRSys<> nil) and (StageDiv <> nil)) then begin
  	FZHR := HRSys.ZHR;
  	Setlength(arrHRSysOutTDPoint, FZHR);
  	for i := 0 to FZHR-1 do begin
  	  arrHRSysOutTDPoint[i] := HRSys.arrHROutput[i].PTDPointExtraction^;
  	end; 
  	FZ := 1+StageDiv.Z;
  	Setlength(arrStageDivOutTDPoint, FZ);
  	for i := 0 to FZ-1 do begin
  	  arrStageDivOutTDPoint[i] := StageDiv.arrPostStageTDPoint[i];
  	end;
	end;
end;

procedure TCoupling.CoupleByStageDivSuggestions;
var
  i,j: integer;
begin
  if (FHRSys <> nil) then begin
		//Self.FindMatch;
  	if Self.FZHR <= 1 then begin
  	  Showmessage('Invalid Choice Since ZHR <= 1');
  	end else begin
			//change arrflagHRSys based on arrflagStageDiv
  	  for i := 0 to FZHR-1 do begin
  	    for j := 0 to FZ-1 do begin
  	      if i = DDArrPosList[i,0] then begin
  	    		FarrflagHRSys[i] := FarrflagStageDiv[DDArrPosList[i,1]];
  	      end;
  	    end;
  	  end;
  	  //find point in Inicurve
  	  SetLength(arrNewHRSysOutTDPoint, FZHR);
  	  for i := 0 to FZHR-1 do begin
  	  	arrNewHRSysOutTDPoint[i] := TDPointList[FarrflagHRSys[i]];
  	  end;
  	end;

  end else begin

  	if Self.FZHR <= 1 then begin
  	  Showmessage('Invalid Choice Since ZHR <= 1');
  	end else begin
			//change arrflagHRSys based on arrflagStageDiv
  	  for i := 0 to FZHR-1 do begin
  	    for j := 0 to FZ-1 do begin
  	      if i = DDArrPosList[i,0] then begin
  	    		FarrflagHRSysWithDA[i] := FarrflagStageDiv[DDArrPosList[i,1]];
  	      end;
  	    end;
  	  end;
  	  //find point in Inicurve
  	  SetLength(arrNewHRSysWithDAOutTDPoint, FZHR);
  	  for i := 0 to FZHR-1 do begin
  	  	arrNewHRSysWithDAOutTDPoint[i] := TDPointList[FarrflagHRSysWithDA[i]];
  	  end;
  	end;

  end;
end;

procedure TCoupling.CheckOriData;
var
  i,j,tmpFlag : integer;
begin
  if (FHRSys <> nil) then begin
		Self.FindMatch;
  	SetLength(arrNewHRSysOutTDPoint, FZHR);
  	for j := 0 to FZHR-1 do begin
  		arrNewHRSysOutTDPoint[j] := TDPointList[FarrflagHRSys[j]];
  	end;
  	SetLength(arrNewStageDivOutTDPoint, FZ);
  	for j := 0 to FZ-1 do begin
  	  arrNewStageDivOutTDPoint[j] := TDPointList[FarrflagStageDiv[j]];
  	end;
		tmpFlag := 0;
		for i := 0 to FZHR-1 do begin
  	  if (Self.FarrflagStageDiv[DDArrPosList[i,1]] = Self.FarrflagHRSys[DDArrPosList[i,0]]) then
  	  	Inc(tmpFlag);
  	end;
  	if (tmpFlag = FZHR) then begin
  		Showmessage('No need for Coupling!');
  	end else begin
  		Showmessage('Need Coupling, please choose a method!');
  	end;

  end else begin

		Self.FindMatch;
  	SetLength(arrNewHRSysWithDAOutTDPoint, FZHR);
  	for j := 0 to FZHR-1 do begin
  		arrNewHRSysWithDAOutTDPoint[j] := TDPointList[FarrflagHRSysWithDA[j]];
  	end;
  	SetLength(arrNewStageDivOutTDPoint, FZ);
  	for j := 0 to FZ-1 do begin
  	  arrNewStageDivOutTDPoint[j] := TDPointList[FarrflagStageDiv[j]];
  	end;
		tmpFlag := 0;
		for i := 0 to FZHR-1 do begin
  	  if (Self.FarrflagStageDiv[DDArrPosList[i,1]] = Self.FarrflagHRSysWithDA[DDArrPosList[i,0]]) then
  	  	Inc(tmpFlag);
  	end;
  	if (tmpFlag = FZHR) then begin
  		Showmessage('No need for Coupling!');
  	end else begin
  		Showmessage('Need Coupling, please choose a method!');
  	end;

  end;
end;

procedure TCoupling.CoupleByStageDiv;
var
  i,j,tmpFlag : integer;
  tmparrNewPea, tmparrNewtea, tmparrNewtfw2, tmparrNewhfw2, tmparrNewDeltaHfw : array of double;
begin

  if (FHRSys <> nil) then begin

  	if  FHRSys.ZHR > 1 then begin
			SetLength(tmparrNewPea, FHRSys.ZHR);
			SetLength(tmparrNewtea, FHRSys.ZHR);
			SetLength(tmparrNewtfw2, FHRSys.ZHR);
			SetLength(tmparrNewhfw2, FHRSys.ZHR);
			SetLength(tmparrNewDeltaHfw, FHRSys.ZHR);
  		for i := 0 to FHRSys.ZHR -1 do begin
	  		tmparrNewPea[i] := arrNewHRSysOutTDPoint[i].P * (1 - FHRSys.arrHRInput[i].DeltaPeOverPe/100);
    	  tmparrNewtea[i] := PLGetTDPoint(tmparrNewPea[i]).T;
    	  tmparrNewtfw2[i] := tmparrNewtea[i] - FHRSys.arrHRInput[i].Deltalt;
    	  tmparrNewhfw2[i] := PTGetTDPoint(FIniData.BasicData.pcp, tmparrNewtfw2[i]).H;
    	end;       	//arrNewHRSysWithDAOutTDPoint[j]
  		for i := 0 to FHRSys.ZHR - 2 do begin
    	  tmparrNewDeltaHfw[i] := tmparrNewhfw2[i+1] - tmparrNewhfw2[i];
    	  FHRSys.arrDeltaHfw[i] := tmparrNewDeltaHfw[i];
    	end;
    	FHRSys.GetNewarrHROutput;
      Self.CoupleByHRSysSuggestions;
    	Self.CoupleByHRSys;
    	Choice := 1;
   	end;

  end else if (FHRSysWithDA <> nil) then begin

		if  FHRSysWithDA.ZHR > 1 then begin
			SetLength(tmparrNewPea, FHRSysWithDA.ZHR);
			SetLength(tmparrNewtea, FHRSysWithDA.ZHR);
			SetLength(tmparrNewtfw2, FHRSysWithDA.ZHR);
			SetLength(tmparrNewhfw2, FHRSysWithDA.ZHR);
			SetLength(tmparrNewDeltaHfw, FHRSysWithDA.ZHR);

  		for i := 0 to FHRSysWithDA.ZHR -1 do begin
	  		tmparrNewPea[i] := arrNewHRSysWithDAOutTDPoint[i].P * (1 - FHRSysWithDA.arrHRInput[i].DeltaPeOverPe/100);
    	end;        
    	for i := 0 to FHRSysWithDA.DAPosition - 1 do begin
    	  tmparrNewtea[i] := PLGetTDPoint(tmparrNewPea[i]).T;
    	  tmparrNewtfw2[i] := tmparrNewtea[i] - FHRSysWithDA.arrHRInput[i].Deltalt;
    	end;
			tmparrNewtea[FHRSysWithDA.DAPosition]  := PLGetTDPoint(tmparrNewPea[FHRSysWithDA.DAPosition]).T;
      tmparrNewtfw2[FHRSysWithDA.DAPosition] := tmparrNewtea[FHRSysWithDA.DAPosition] - FHRSysWithDA.arrHRInput[FHRSysWithDA.DAPosition].Deltalt;
    	for i := FHRSysWithDA.DAPosition + 1 to FHRSysWithDA.ZHR -1 do begin
    	  tmparrNewtea[i] := PLGetTDPoint(tmparrNewPea[i]).T;
    	  tmparrNewtfw2[i] := tmparrNewtea[i] - FHRSysWithDA.arrHRInput[i].Deltalt;
    	end;

    	for i := 0 to FHRSysWithDA.DAPosition - 1 do begin
    	  tmparrNewhfw2[i] := PTGetTDPoint(FIniData.BasicData.pfp, tmparrNewtfw2[i]).H;
    	end;
    	tmparrNewhfw2[FHRSysWithDA.DAPosition] := PTGetTDPoint(FIniData.BasicData.pfp, tmparrNewtfw2[FHRSysWithDA.DAPosition]).H;
    	for i := FHRSysWithDA.DAPosition + 1 to FHRSysWithDA.ZHR -1 do begin
    	  tmparrNewhfw2[i] := PTGetTDPoint(FIniData.BasicData.pcp, tmparrNewtfw2[i]).H;
    	end;
      tmparrNewDeltaHfw[0] := FHRSysWithDA.fwOutTDPoint.H - tmparrNewhfw2[0];
  		for i := 1 to FHRSysWithDA.ZHR - 1 do begin
    	  tmparrNewDeltaHfw[i] := tmparrNewhfw2[i] - tmparrNewhfw2[i-1];
    	  FHRSysWithDA.arrDeltaHfw[i] := tmparrNewDeltaHfw[i];
    	end;
    	FHRSysWithDA.GetNewarrHROutput;
      self.CoupleByHRSysSuggestions;
    	Self.CoupleByHRSys;
    	Choice := 1;
    end;
    
  end;
  {
    	tmpflag := 0;
    	j := 0;
    	while j <= 200 do begin
    		FHRSysWithDA.GeneratearrChange;
				FHRSysWithDA.GetarrHROutput;
    		for i := 0 to FZHR-2 do begin
    			if ((FHRSysWithDA.arrHROutput[i].PTDPointExtraction^.P - arrNewHRSysWithDAOutTDPoint[i].P)
    	    		/ arrNewHRSysWithDAOutTDPoint[i].P) < 0.02 then begin
    	    	Inc(tmpflagHR);
    	    end;
    	  end;
    	  if tmpflagHR = FZHR-1 then begin
    	    showmessage('Solution found!');
    	    Showmessage(inttostr(j));
    	  	Break
    	  end else
    	  	Continue;
  		end;
    	if tmpflag = 0 then Showmessage('Please Change Range!');  }
  tag := 1;
end;

procedure TCoupling.CoupleByHRSysSuggestions;
var
  i,j : integer;
begin
  if (FHRSys <> nil) then begin
			//change arrflagStageDiv based on arrflagHRSys
    	for i := 0 to FZ-1 do begin
    	  for j := 0 to FZHR-1 do begin
    	    if i = DDArrPosList[j,1] then begin
    	  		FarrflagStageDiv[i] := FarrflagHRSys[DDArrPosList[j,0]];
    	    end;
    	  end;
    	end;
    	//find point in Inicurve
    	SetLength(arrNewStageDivOutTDPoint, FZ);
    	for i := Low(FarrflagStageDiv) to High(FarrflagStageDiv) do begin
    		arrNewStageDivOutTDPoint[i] := TDPointList[FarrflagStageDiv[i]];
    	end;
    	//Set arrStageDivChangeSug//相当于更新StageDiv
    	SetLength(arrNewStageDivEht, FZ);
    	arrNewStageDivEht := FStageDiv.GetEhtfromPostPoint(arrNewStageDivOutTDPoint);
  end else begin
			//change arrflagStageDiv based on arrflagHRSys
    	for i := 0 to FZ-1 do begin
    	  for j := 0 to FZHR-1 do begin
    	    if i = DDArrPosList[j,1] then begin
    	  		FarrflagStageDiv[i] := FarrflagHRSysWithDA[DDArrPosList[j,0]];
    	    end;
    	  end;
    	end;
    	//find point in Inicurve
    	SetLength(arrNewStageDivOutTDPoint, FZ);
    	for i := Low(FarrflagStageDiv) to High(FarrflagStageDiv) do begin
    		arrNewStageDivOutTDPoint[i] := TDPointList[FarrflagStageDiv[i]];
    	end;
    	//Set arrStageDivChangeSug//相当于更新StageDiv
    	SetLength(arrNewStageDivEht, FZ);
    	arrNewStageDivEht := FStageDiv.GetEhtfromPostPoint(arrNewStageDivOutTDPoint);
  end;
end;

procedure TCoupling.CoupleByHRSys;
var
  i,j : integer;
begin
    	//直接修改StageDiv
    	for i := 0 to (FZ-2) do begin
    		FStageDiv.arrEht[i] := arrNewStageDivEht[i];
    	end;
			for i := 0 to FZ-2 do begin
  			FStageDiv.arrxa[i] := Sqrt(power(PI,2) * power(FStageDiv.arrdm[i]/1000,2) * power(FIniData.BasicData.N,2) / FStageDiv.arrEht[i] / power(60,2) / 2000);
  		end;
    	Choice := 0;
  tag := 1;
end;

procedure TCoupling.CoupleByBothSuggestions;
var
  i,j,tmpFlag : integer;
  tmpSum : double;
  tmparrFlagBetween : array of integer;
begin
  if (FHRSys <> nil) then begin
		//Self.FindMatch;
  	if Self.FZHR <= 1 then begin
  	  Showmessage('Invalid Choice Since ZHR <= 1');
  	end else begin
			//随机生成中间点号，并传给两方备选点号
  	  SetLength(tmparrFlagBetween, FZHR);
  	  Randomize;
  	  for i := 0 to FZHR-1 do begin
  	  	tmparrFlagBetween[i] := Random(abs(FarrflagStageDiv[DDArrPosList[i,1]] - FarrflagStageDiv[DDArrPosList[i,0]]));
  	  end;
  	  for i := 0 to FZ-1 do begin
  	    for j := 0 to FZHR-1 do begin
  	      if i = DDArrPosList[j,1] then begin
  	    		FarrflagStageDiv[i] := tmparrFlagBetween[j] +
  	        Min(FarrflagStageDiv[DDArrPosList[j,1]],FarrflagStageDiv[DDArrPosList[j,0]]);
  	      end;
  	    end;
  	  end;
  	  for i := 0 to FZHR-1 do begin
  	    for j := 0 to FZ-1 do begin
  	      if i = DDArrPosList[i,0] then begin
  	    		FarrflagHRSys[i] := tmparrFlagBetween[i] +
  	        Min(FarrflagStageDiv[DDArrPosList[i,1]],FarrflagStageDiv[DDArrPosList[i,0]]);
  	      end;
  	    end;
  	  end;
  	  //通过双方备选点号获得相应的热力点
  	  SetLength(arrNewStageDivOutTDPoint, FZ);
  	  for i := Low(FarrflagStageDiv) to High(FarrflagStageDiv) do begin
  	  	arrNewStageDivOutTDPoint[i] := TDPointList[FarrflagStageDiv[i]];
  	  end;
  	  SetLength(arrNewHRSysOutTDPoint, FZHR);
  	  for i := 0 to FZHR-1 do begin
  	  	arrNewHRSysOutTDPoint[i] := TDPointList[FarrflagHRSys[i]];
  	  end;
  	end;

  end else begin

		//Self.FindMatch;
  	if Self.FZHR <= 1 then begin
  	  Showmessage('Invalid Choice Since ZHR <= 1');
  	end else begin
			//随机生成中间点号，并传给两方备选点号
  	  SetLength(tmparrFlagBetween, FZHR);
  	  Randomize;
  	  for i := 0 to FZHR-1 do begin
  	  	tmparrFlagBetween[i] := Random(abs(FarrflagStageDiv[DDArrPosList[i,1]] - FarrflagStageDiv[DDArrPosList[i,0]]));
  	  end;
  	  for i := 0 to FZ-1 do begin
  	    for j := 0 to FZHR-1 do begin
  	      if i = DDArrPosList[j,1] then begin
  	    		FarrflagStageDiv[i] := tmparrFlagBetween[j] +
  	        Min(FarrflagStageDiv[DDArrPosList[j,1]],FarrflagStageDiv[DDArrPosList[j,0]]);
  	      end;
  	    end;
  	  end;
  	  for i := 0 to FZHR-1 do begin
  	    for j := 0 to FZ-1 do begin
  	      if i = DDArrPosList[i,0] then begin
  	    		FarrflagHRSysWithDA[i] := tmparrFlagBetween[i] +
  	        Min(FarrflagStageDiv[DDArrPosList[i,1]],FarrflagStageDiv[DDArrPosList[i,0]]);
  	      end;
  	    end;
  	  end;
  	  //通过双方备选点号获得相应的热力点
  	  SetLength(arrNewStageDivOutTDPoint, FZ);
  	  for i := Low(FarrflagStageDiv) to High(FarrflagStageDiv) do begin
  	  	arrNewStageDivOutTDPoint[i] := TDPointList[FarrflagStageDiv[i]];
  	  end;
  	  SetLength(arrNewHRSysWithDAOutTDPoint, FZHR);
  	  for i := 0 to FZHR-1 do begin
  	  	arrNewHRSysWithDAOutTDPoint[i] := TDPointList[FarrflagHRSysWithDA[i]];
  	  end;
  	end;
  end;
end;

procedure TCoupling.CoupleByBoth;
var
  i,j,tmpFlag : integer;
  tmpflagHR : TDyIntArray;
  tmparrNewPea, tmparrNewtea, tmparrNewtfw2, tmparrNewhfw2, tmparrNewDeltaHfw : array of double;
begin
  if (FHRSys <> nil) then begin
    //通过新热力点反算双方分配
    //通过新热力点反算级焓降分配
    SetLength(arrNewStageDivEht, FZ);
    arrNewStageDivEht := FStageDiv.GetEhtfromPostPoint(arrNewStageDivOutTDPoint);
  	//通过新热力点反算回热系统
  	if  FHRSys.ZHR > 1 then begin
			SetLength(tmparrNewPea, FHRSys.ZHR);
			SetLength(tmparrNewtea, FHRSys.ZHR);
			SetLength(tmparrNewtfw2, FHRSys.ZHR);
			SetLength(tmparrNewhfw2, FHRSys.ZHR);
			SetLength(tmparrNewDeltaHfw, FHRSys.ZHR);
  		for i := 0 to FHRSys.ZHR -1 do begin
	  		tmparrNewPea[i] := arrNewHRSysOutTDPoint[i].P * (1 - FHRSys.arrHRInput[i].DeltaPeOverPe/100);
    	  tmparrNewtea[i] := PLGetTDPoint(tmparrNewPea[i]).T;
    	  tmparrNewtfw2[i] := tmparrNewtea[i] - FHRSys.arrHRInput[i].Deltalt;
    	  tmparrNewhfw2[i] := PTGetTDPoint(FIniData.BasicData.pcp, tmparrNewtfw2[i]).H;
    	end;       	//arrNewHRSysWithDAOutTDPoint[j]
  		for i := 0 to FHRSys.ZHR - 2 do begin
    	  tmparrNewDeltaHfw[i] := tmparrNewhfw2[i+1] - tmparrNewhfw2[i];
    	  FHRSys.arrDeltaHfw[i] := tmparrNewDeltaHfw[i];
    	end;
    	FHRSys.GetNewarrHROutput;
      Self.CoupleByHRSysSuggestions;
    	Self.CoupleByHRSys;
    	Choice := 1;
   	end;
    Self.CoupleByHRSys;
    Choice := 2;
    	//通过新热力点反算级焓降分配
    	//FHRSys.GeneratearrChange;
      {
    	SetLength(tmpflagHR, FZHR);
    	tmpflag := 0;
    	j := 0;
    	while j <= 200 do begin
    		FHRSys.GeneratearrChange;
//  	  FHRSys.CheckDataValidity;
				FHRSys.GetarrHROutput;
    		for i := 0 to FZHR-1 do begin
    			if ((FHRSys.arrHROutput[i].PTDPointExtraction^.P - arrNewHRSysOutTDPoint[i].P)
    	    		/ arrNewHRSysOutTDPoint[i].P) < 0.02 then begin
    	    	tmpflagHR[i] := 1;
    	    end;
    	  end;
    		for i := 0 to FZHR-1 do begin
    	  	tmpflag := tmpflag + tmpflagHR[i];
    	  end;
    	  if tmpflag = FZHR then begin
    	    showmessage('Solution found!');
    	    Showmessage(inttostr(j));
    	  	Break
    	  end else
    	  	Continue;
  		end;
    	if tmpflag = 0 then showmessage('Please Change Range!');
			//分段，提示SubDivNumber（两者间距（以点为单位）），接受后再次提示输入确定重合点; }

  end else begin 
  
    //通过新热力点反算双方分配
    //通过新热力点反算级焓降分配
    SetLength(arrNewStageDivEht, FZ);
    arrNewStageDivEht := FStageDiv.GetEhtfromPostPoint(arrNewStageDivOutTDPoint);
    //通过新热力点反算回热系统
		if  FHRSysWithDA.ZHR > 1 then begin
			SetLength(tmparrNewPea, FHRSysWithDA.ZHR);
			SetLength(tmparrNewtea, FHRSysWithDA.ZHR);
			SetLength(tmparrNewtfw2, FHRSysWithDA.ZHR);
			SetLength(tmparrNewhfw2, FHRSysWithDA.ZHR);
			SetLength(tmparrNewDeltaHfw, FHRSysWithDA.ZHR);

  		for i := 0 to FHRSysWithDA.ZHR -1 do begin
	  		tmparrNewPea[i] := arrNewHRSysWithDAOutTDPoint[i].P * (1 - FHRSysWithDA.arrHRInput[i].DeltaPeOverPe/100);
    	end;        
    	for i := 0 to FHRSysWithDA.DAPosition - 1 do begin
    	  tmparrNewtea[i] := PLGetTDPoint(tmparrNewPea[i]).T;
    	  tmparrNewtfw2[i] := tmparrNewtea[i] - FHRSysWithDA.arrHRInput[i].Deltalt;
    	end;
			tmparrNewtea[FHRSysWithDA.DAPosition]  := PLGetTDPoint(tmparrNewPea[FHRSysWithDA.DAPosition]).T;
      tmparrNewtfw2[FHRSysWithDA.DAPosition] := tmparrNewtea[FHRSysWithDA.DAPosition] - FHRSysWithDA.arrHRInput[FHRSysWithDA.DAPosition].Deltalt;
    	for i := FHRSysWithDA.DAPosition + 1 to FHRSysWithDA.ZHR -1 do begin
    	  tmparrNewtea[i] := PLGetTDPoint(tmparrNewPea[i]).T;
    	  tmparrNewtfw2[i] := tmparrNewtea[i] - FHRSysWithDA.arrHRInput[i].Deltalt;
    	end;

    	for i := 0 to FHRSysWithDA.DAPosition - 1 do begin
    	  tmparrNewhfw2[i] := PTGetTDPoint(FIniData.BasicData.pfp, tmparrNewtfw2[i]).H;
    	end;
    	tmparrNewhfw2[FHRSysWithDA.DAPosition] := PTGetTDPoint(FIniData.BasicData.pfp, tmparrNewtfw2[FHRSysWithDA.DAPosition]).H;
    	for i := FHRSysWithDA.DAPosition + 1 to FHRSysWithDA.ZHR -1 do begin
    	  tmparrNewhfw2[i] := PTGetTDPoint(FIniData.BasicData.pcp, tmparrNewtfw2[i]).H;
    	end;
      tmparrNewDeltaHfw[0] := FHRSysWithDA.fwOutTDPoint.H - tmparrNewhfw2[0];
  		for i := 1 to FHRSysWithDA.ZHR - 1 do begin
    	  tmparrNewDeltaHfw[i] := tmparrNewhfw2[i] - tmparrNewhfw2[i-1];
    	  FHRSysWithDA.arrDeltaHfw[i] := tmparrNewDeltaHfw[i];
    	end;
    	FHRSysWithDA.GetNewarrHROutput;
      self.CoupleByHRSysSuggestions;
    	Self.CoupleByHRSys;
    	Choice := 1;
    end;
    Self.CoupleByHRSys;
    Choice := 2;
    	//通过新热力点反算级焓降分配
    	//FHRSys.GeneratearrChange;
      {
    	SetLength(tmpflagHR, FZHR);
    	tmpflag := 0;
    	j := 0;
    	while j <= 200 do begin
    		FHRSys.GeneratearrChange;
//  	  FHRSys.CheckDataValidity;
				FHRSysWithDA.GetarrHROutput;
    		for i := 0 to FZHR-1 do begin
    			if ((FHRSysWithDA.arrHROutput[i].PTDPointExtraction^.P - arrNewHRSysWithDAOutTDPoint[i].P)
    	    		/ arrNewHRSysWithDAOutTDPoint[i].P) < 0.02 then begin
    	    	tmpflagHR[i] := 1;
    	    end;
    	  end;
    		for i := 0 to FZHR-1 do begin
    	  	tmpflag := tmpflag + tmpflagHR[i];
    	  end;
    	  if tmpflag = FZHR then begin
    	    showmessage('Solution found!');
    	    Showmessage(inttostr(j));
    	  	Break
    	  end else
    	  	Continue;
  		end;
    	if tmpflag = 0 then showmessage('Please Change Range!');
			//分段，提示SubDivNumber（两者间距（以点为单位）），接受后再次提示输入确定重合点; }
  end;
  tag := 1;
end;

procedure TCoupling.FindMatch;
var
  i,j,tmpFlag : integer;
  //tmparrFlagHRSys, tmparrFlagStageDiv : array of integer;
  tmparrNewHRSysOutTDPoint : array of TTDPoint;
  tmpSum : double;
begin
  if (FHRSys <> nil) then begin
  	//find positions
  	SetLength(FarrFlagHRSys, FZHR);
  	for i := 0 to FZHR-1 do begin
  	  FarrFlagHRSys[i] := SeekTDPointPositionByH(arrHRSysOutTDPoint[i].H, TDPointList);
  	end;
  	SetLength(FarrFlagStageDiv, FZ);
  	for i := 0 to FZ-1 do begin
  	  FarrFlagStageDiv[i] := SeekTDPointPositionByH(arrStageDivOutTDPoint[i].H, TDPointList);
  	end;
  	//find closest TDPoint;
  	SetLength(DDArrPosList,FZHR,2);
  	for i := 0 to FZHR-1 do begin
  	  for j := 0 to FZ-2 do begin
  			if ((FarrFlagStageDiv[j] <= FarrFlagHRSys[i]) and (FarrFlagStageDiv[j+1] >= FarrFlagHRSys[i])) then begin
  	  		if ((FarrFlagHRSys[i] - FarrFlagStageDiv[j]) <= (FarrFlagStageDiv[j+1] - FarrFlagHRSys[i])) then begin
  	        DDArrPosList[i,0]:= i;
  	        DDArrPosList[i,1]:= j;
  	        Continue;
  	  	  end else if ((FarrFlagHRSys[i] - FarrFlagStageDiv[j]) > (FarrFlagStageDiv[j+1] - FarrFlagHRSys[i])) then begin
  	  	    DDArrPosList[i,0]:= i;
  	        DDArrPosList[i,1]:= j+1;
  	        Continue;
  	  	  end else begin
  	  	    Showmessage('Please revise division number of the initial curve！！');
  	  		end;
  	    end;
  	  end;
  	end;
    tag := 1;

  end else begin
  
  	//find positions
  	SetLength(FarrFlagHRSysWithDA, FZHR);
  	for i := 0 to FZHR-1 do begin
  	  FarrFlagHRSysWithDA[i] := SeekTDPointPositionByH(arrHRSysWithDAOutTDPoint[i].H, TDPointList);
  	end;
  	SetLength(FarrFlagStageDiv, FZ);
  	for i := 0 to FZ-1 do begin
  	  FarrFlagStageDiv[i] := SeekTDPointPositionByH(arrStageDivOutTDPoint[i].H, TDPointList);
  	end;
  	//find closest TDPoint;
  	SetLength(DDArrPosList,FZHR,2);
  	for i := 0 to FZHR-1 do begin
  	  for j := 0 to FZ-2 do begin
  			if ((FarrFlagStageDiv[j] <= FarrFlagHRSysWithDA[i]) and (FarrFlagStageDiv[j+1] >= FarrFlagHRSysWithDA[i])) then begin
  	  		if ((FarrFlagHRSysWithDA[i] - FarrFlagStageDiv[j]) <= (FarrFlagStageDiv[j+1] - FarrFlagHRSysWithDA[i])) then begin
  	        DDArrPosList[i,0]:= i;
  	        DDArrPosList[i,1]:= j;
  	        Continue;
  	  	  end else if ((FarrFlagHRSysWithDA[i] - FarrFlagStageDiv[j]) > (FarrFlagStageDiv[j+1] - FarrFlagHRSysWithDA[i])) then begin
  	  	    DDArrPosList[i,0]:= i;
  	        DDArrPosList[i,1]:= j+1;
  	        Continue;
  	  	  end else begin
  	  	    Showmessage('Please revise division number of the initial curve！！');
  	  		end;
  	    end;
  	  end;
  	end;
    tag := 1;
  end;
end;

end.

