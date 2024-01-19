unit ClassHRSysWithDA;

interface
uses ClassHRSys, ClassIniData, ClassGoverningStage, TDPointUtils, GE, Dialogs, Sysutils, math;

{HRSysWithDA}
type
	THRSysWithDA = Class(THRSys)
		PeDA  : double;
    ZHR   : integer;
  private
  	//上级参数
    FIniData : TIniData;
    FGoverningStage : TGoverningStage;
    //本级参数
    FarrTDPointOutletWater : array of TTDPoint;
    FarrTDPointInletWater  : array of TTDPoint;
    FarrTDPointDrain       : array of TTDPoint;
    FarrTDPointExtraction  : array of TTDPoint;
  	FDlaPosition : integer;
    FDeEquivalentDla : array of double;
    FDeEquivalentDrain : double;
    FOriarrDeltaHfw : array of double;
    FarrDeltaHfw : array of double;
    FNumHasDrainIn : integer;
    //新增参数
    FDAPosition  : integer;
    FDATDPointOutletWater : TTDPoint;
    //本级
    function  GetDlaPosition : integer;
    procedure SetDlaPosition(Value: integer);
  	procedure GetDfw;
    procedure GetfwOutTDPoint;
    procedure GetcwInTDPoint;
    procedure GetOriarrDeltaHfw;
    procedure GetarrDeltaHfw;
    procedure GetNumHasDrainIn;
    procedure GetHl;
    //新增
    function  GetDAPosition : integer;
    procedure SetDAPosition(Value: integer);
  public
    tag : integer;
  	property DAPosition : integer read GetDAPosition write SetDAPosition;
    procedure SetDefault;//override;
    procedure GetarrHROutput;//override;
    procedure CheckDataValidity;//override;
    procedure GetNewDeltaDe;//override;
    procedure GetNewarrHROutput;
  	Constructor Create(ZHR:integer; PeDA:double; IniData:TIniData; GoverningStage:TGoverningStage);//override;
	end;

  function GetDeEquivalent(D, h, hdrain, DeltaHSteam : double): double;
	function GetStandardDeltaDe(Din,DeltaHWater,DeltaHSteam,yitah : double) : double;

implementation

procedure THRSysWithDA.SetDlaPosition(Value: integer);
begin
	if Value < Self.ZHR then FDlaPosition := Value;
end;

function THRSysWithDA.GetDlaPosition : integer;
begin
	Result := FDlAPosition;
end;

procedure THRSysWithDA.GetDfw;
var
	tmpD0, tmpDeltaDl, tmpDeltaDla, tmpDeltaDej : double;
begin
  tmpD0 := FIniData.D0;
  tmpDeltaDl  := FIniData.BasicData.DeltaDl;
  tmpDeltaDla := FIniData.BasicData.DeltaDla;
  tmpDeltaDej := FIniData.BasicData.DeltaDej;
	Self.Dfw := tmpD0 - tmpDeltaDl + tmpDeltaDla + tmpDeltaDej;
end;

procedure THRSysWithDA.GetfwOutTDPoint;
begin
	Self.fwOutTDPoint := PTGetTDPoint(FIniData.BasicData.pfp, FIniData.BasicData.tfw);
end;

procedure THRSysWithDA.GetcwInTDPoint;
var
  TDPointC : TTDPoint;
begin
  TDPointC := PLGetTDPoint(FIniData.BasicData.bpc);
  Self.cwInTDPoint := PTGetTDPoint(FIniData.BasicData.pcp, TDPointC.T+FIniData.BasicData.deltatej);//研究入口水温！！
end;

procedure THRSysWithDA.GetOriarrDeltaHfw;
var
	i : integer;
begin
  SetLength(Self.FOriarrDeltaHfw, Self.ZHR);
  for i := 0 to Self.ZHR-1 do
		FOriarrDeltaHfw[i] := (fwOutTDPoint.H - cwInTDPoint.H)/Self.ZHR;
end;

procedure THRSysWithDA.GetarrDeltaHfw;
var
	i : integer;
begin
  SetLength(Self.FarrDeltaHfw, Self.ZHR);
  for i := 0 to Self.ZHR-1 do
		FarrDeltaHfw[i] := FOriarrDeltaHfw[i] * (1+arrChange[i]/100);
end;

procedure THRSysWithDA.GetNumHasDrainIn;
var
	i : integer;
begin
  FNumHasDrainIn := 0;
	for i := 0 to Self.ZHR-1 do begin
  	if Self.arrHRInput[i].HasDlaIn = True then begin
    	Inc(FNumHasDrainIn);
  	end;
  end;
end;

procedure THRSysWithDA.GetHl;
begin
	if FGoverningStage <> nil then begin
		Self.Hl := FGoverningStage.Hl;
  end else
  	Self.Hl := MainTDPoint0a.H;
end;

procedure THRSysWithDA.SetDefault;
var
	i : integer;
  tmpSum : double;
begin
  GenerateArrChange;
  GetarrDeltaHfw;
  for i := 0 to ZHR-1 do begin
  	arrDeltaHfw[i] := FarrDeltaHfw[i];
  end;
  for i := 0 to Self.ZHR-1 do begin
  	if i = Self.DAPosition then begin
  		Self.arrHRInput[i].IsSurface     := False;
  		Self.arrHRInput[i].Yitah         := 100;
  		Self.arrHRInput[i].Deltalt       := 0;
  		Self.arrHRInput[i].DeltaPeOverPe := Random(15)+5;
  		Self.arrHRInput[i].DeltaHWater   := arrDeltaHfw[i];//revise later(override)
  		Self.arrHRInput[i].Change        := arrChange[i];
  		Self.arrHRInput[i].HasDlaIn      := False;
    end else begin
  		Self.arrHRInput[i].IsSurface := True;
  		Self.arrHRInput[i].Yitah   := 98;
    	Self.arrHRInput[i].Deltalt := 3;
    	Self.arrHRInput[i].DeltaPeOverPe := 5;
    	Self.arrHRInput[i].DeltaHWater := arrDeltaHfw[i];//revise later(override)
    	Self.arrHRInput[i].Change  := arrChange[i];
    	Self.arrHRInput[i].HasDlaIn   := False;
    end;
  end;
end;

procedure THRSysWithDA.GetNewDeltaDe;
var
	i,j : integer;
begin
  //只有除氧器
  if Self.ZHR = 1 then begin //除氧器位置只能为0//注意：除氧器+给水泵的模型
    //抽汽点
    FarrTDPointExtraction[0] := arrNewTDPointExtraction[0];//可以用插值法做成更精确的返回值
    Self.arrHROutput[0].PTDPointExtraction := @FarrTDPointExtraction[0];//指针
    ///回热平衡计算
		//联立求解Dg, Dcw
    if Self.DAPosition = Self.DlaPosition then begin
    	Gausselimination(1.0, 1.0, Self.Dfw - Self.DeltaDla,
    	FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    	Self.Dfw * FarrTDPointDrain[0].H - Self.DeltaDla * hl);
    	//传递方程解
    	Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    	Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
    end else begin
    	{to do : 轴封漏气回收到凝汽器的情况}
    end;
    if Self.DAPosition <> Self.DlaPosition then begin
    	Gausselimination(1.0, 1.0, Self.Dfw,
    	FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    	Self.Dfw * FarrTDPointDrain[0].H);
    	//传递方程解
    	Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    	Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
    end;//轴封漏气回收的位置还有可能是凝汽器
	end;

  if Self.ZHR > 1 then begin

  	if Self.FDAPosition = 0 then begin
    	//抽汽点
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i] := arrNewTDPointExtraction[i];
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//指针
    	end;
      ///回热平衡计算
      FDeEquivalentDrain := 0;//初始化该值
  	  for i := 0 to FDAPosition-1 do begin
  	  	if arrHROutput[i].HasDrainIn = False then begin
				   if arrHRInput[i].HasDlaIn = False then begin
				   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					 		arrHROutput[i].Drain   :=  arrHROutput[i].DeltaDe;
				   end else begin
				    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				   	 	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
				   end;
  	    end else begin //arrHR[i].HasDrainIn = True 有疏水逐级回流
				   if arrHRInput[i].HasDlaIn = False then begin
           		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
				   end else begin
				   		FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				   	  arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				     	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
				     	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
				   end;
				   j := j + 1;
  	  	end;
  	  end;
	  	//解方程获得DA的Dg
    	if FDAPosition > 0 then begin
  	  	if (DlaPosition<>FDAPosition) then begin //只分为两种情况，有轴封漏气和无轴封漏气
  	  	   Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
				   //传递方程解
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end else begin //（DlaPosition = DAPosition）
					 Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain- DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //传递方程解
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end;
      end else begin
  	  	if (DlaPosition<>FDAPosition) then begin //只分为两种情况，有轴封漏气和无轴封漏气
  	  	   Gausselimination(1.0, 1.0, Dfw,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H);
				   //传递方程解
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end else begin //（DlaPosition = DAPosition）
					 Gausselimination(1.0, 1.0, Dfw - DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //传递方程解
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end;
      end;
			//Dcw
			for i := 0 to (ZHR - 1) do begin
				if i < FDAPosition then begin
					arrHROutput[i].Dcw := 0;
				end else if i > FDAPosition then begin
					arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
				end;
			end;
			for i := FDAPosition+1 to ZHR-1 do begin
				if arrHROutput[i].HasDrainIn = False then begin
			  	if arrHRInput[i].HasDlaIn = False then begin
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe;
  	      end else begin
			    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
			    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
			    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
			   	end;
  	   	end else begin
  	    	if arrHRInput[i].HasDlaIn = False then begin
			   		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
			    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
			    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
			  	end else begin
			    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
			    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
			    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
  	      end;
  	      j := j + 1;
  	    end;
			end;
    end;

    if Self.FDAPosition > 0 then begin
    	//抽汽点
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i] := arrNewTDPointExtraction[i];
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//指针
    	end;
  	  ///回热平衡计算
  	  FDeEquivalentDrain := 0;
  	  for i := 0 to FDAPosition-1 do begin
  	  	if arrHROutput[i].HasDrainIn = False then begin
				   if arrHRInput[i].HasDlaIn = False then begin
				   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					 		arrHROutput[i].Drain   :=  arrHROutput[i].DeltaDe;
				   end else begin
				    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, MainTDPoint0.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				   	 	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
				   end;
  	    end else begin //arrHR[i].HasDrainIn = True
				   if arrHRInput[i].HasDlaIn = False then begin
				   		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				   	 	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				     	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
				     	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
				   end else begin
				   		FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, MainTDPoint0.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				   	  arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				     	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
				     	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
				   end;
				   j := j + 1;
  	  	end;
  	  end;
	  //解方程获得DA的Dg
  	  if (DlaPosition<>FDAPosition) then begin
  	     Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
			   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
			   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
			   //传递方程解
			   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
			   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
			end else begin //（DlaPosition = DAPosition）
				 Gausselimination(1.0, 1.0, Dfw - DeltaDla,
				 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - DeltaDla * Hl);
				 //传递方程解
				 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
			end;
			//Dcw
			for i := 0 to (ZHR - 1) do begin
				if i < FDAPosition then begin
					arrHROutput[i].Dcw := 0;
				end else if i > FDAPosition then begin
					arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
				end;
			end;
			for i := FDAPosition+1 to ZHR-1 do begin
				if arrHROutput[i].HasDrainIn = False then begin
			  	if arrHRInput[i].HasDlaIn = False then begin
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe;
  	      end else begin
			    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
			    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
			    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
			   	end;
  	   	end else begin
  	    	if arrHRInput[i].HasDlaIn = False then begin
			   		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
			    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
			    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
			  	end else begin
			    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
			    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
			    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
			    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
  	      end;
  	      j := j + 1;
  	    end;
			end;
    end;
	end;
end;

procedure THRSysWithDA.CheckDataValidity;
var
	i : integer;
  tmpSum : double;
  Count : integer;
begin
	//检查自定义后的DeltaHfwChange是否为0
  tmpSum := 0;
	for i := 0 to ZHR-1 do begin
  	tmpSum := tmpSum + Self.arrChange[i];
  end;
	if tmpSum<> 0 then Showmessage('Error : Sum of DivChange must be zero!');
  //检查自定义后的DeltaHfwChange是否越界
  for i := 0 to ZHR-1 do begin
  	if Self.arrChange[i] > Self.DivRange then
    	Showmessage('Error : Change Value Must be below  '+Floattostr(Self.DivRange));
  end;
  //检查除氧器形式下的加热器参数
  for i := 0 to Self.ZHR-1 do begin
  	if Self.arrHRInput[i].IsSurface = False then begin
  		if not ((Self.arrHRInput[i].Yitah=100) and (Self.arrHRInput[i].Deltalt = 0)) then
				Showmessage('Warning : Please Press OK Button!');
  	end;
  end;
  //检查除氧器个数
  Count := 0;
  for i := 0 to Self.ZHR-1 do begin
  	if Self.arrHRInput[i].IsSurface = False then begin
    	Count := Count + 1;
  	end;
  end;
  if Count > 1 then Showmessage('Error : Only One Deaerator is allowed');
  //检查轴封漏气手动设置个数
  Count := 0;
  for i := 0 to Self.ZHR-1 do begin
  	if Self.arrHRInput[i].HasDlaIn = True then begin
    	Inc(Count);
  	end;
  end;
  if Count > 1 then begin
  	Showmessage('Error : Only One DlaIn is allowed');
  	for i := 0 to Self.ZHR-1 do begin
  		Self.arrHRInput[i].HasDlaIn := False;
  	end;
  	Self.arrHRInput[Floor(Self.ZHR/2)].HasDlaIn := True;		//自动修正输入参数：设置是否包含上级疏水的属性 HasDrainIn
  	Showmessage('Automatically Set Steam Leakage Reclaim Position!');
	end;
	for i := 0 to (Self.ZHR - 1) do begin
		Self.arrHROutput[i].HasDrainIn := True;
	end;
  Self.arrHROutput[0].HasDrainIn := False;
  Self.arrHROutput[Self.DAPosition+1].HasDrainIn := False;//除开每段的第一个加热器，其余的都有疏水流入，包括除氧器
//设置成有message就不能继续计算
end;

//THRSysWithDA
constructor THRSysWithDA.Create(ZHR:integer; PeDA:double; IniData:TIniData; GoverningStage:TGoverningStage);
var
	i : integer;
begin
	//导入上级参数
  FIniData        := IniData;
  FGoverningStage := GoverningStage;
  //本级参数
  Self.ZHR := ZHR;
  Self.PeDA := PeDA;
	GetfwOutTDPoint;
  GetcwInTDPoint;
  Self.DivRange := 10;
  Self.DAPosition := (Ceil(Self.ZHR / 2)-1);//显示的DA序号比该值大一
  SetLength(Self.arrDeltaHfw, Self.ZHR);
  SetLength(Self.arrChange, Self.ZHR); //自动赋值的Change数目比回热器数目少一：最后一个作为平衡
  SetLength(Self.arrHRInput, Self.ZHR);
  SetLength(Self.arrHROutput, Self.ZHR);
 	Randomize;
  GetOriarrDeltaHfw;
  for i := 0 to Self.ZHR-1 do begin
  	if i= Self.DAPosition then begin
  		Self.arrHRInput[i].IsSurface     := False;
  		Self.arrHRInput[i].Yitah         := 100;
  		Self.arrHRInput[i].Deltalt       := 0;
  		Self.arrHRInput[i].DeltaPeOverPe := Random(15)+5;
  		Self.arrHRInput[i].DeltaHWater   := FOriarrDeltaHfw[i];//revise later(override)
  		Self.arrHRInput[i].Change        := arrChange[i];
  		Self.arrHRInput[i].HasDlaIn      := False;
    end else begin
  		Self.arrHRInput[i].IsSurface := True;
  		Self.arrHRInput[i].Yitah   := 98;
    	Self.arrHRInput[i].Deltalt := 3;
    	Self.arrHRInput[i].DeltaPeOverPe := 5;
    	Self.arrHRInput[i].DeltaHWater := FOriarrDeltaHfw[i];//revise later(override)
    	Self.arrHRInput[i].Change  := arrChange[i];
    	Self.arrHRInput[i].HasDlaIn   := False;
    end;
  end;
  //特别设置是否包含上级疏水的属性 HasDrainIn
  for i := 0 to Self.ZHR-1 do begin
  	Self.arrHROutput[i].PTDPointOutletWater := nil;
  	Self.arrHROutput[i].PTDPointInletWater  := nil;
    Self.arrHROutput[i].PTDPointDrain       := nil;
    Self.arrHROutput[i].PTDPointExtraction  := nil;
    Self.arrHROutput[i].DeltaHSteam         := 0;
    Self.arrHROutput[i].Dfw                 := 0;
    Self.arrHROutput[i].HasDrainIn          := True;
    Self.arrHROutput[i].Drain               := 0;
    Self.arrHROutput[i].Dcw                 := 0;
    Self.arrHROutput[i].DeltaDe             := 0;
  end;
  {
	Self.arrHROutput[0].HasDrainIn := False;
	if (Self.ZHR >= 3) and (Self.FDAPosition < Self.ZHR-1) then begin//级数不小于2且加热器不是最后一个
  	Self.arrHROutput[FDAPosition+1].HasDrainIn := False;
  end;//除开每段的第一个加热器,其余的都有疏水流入
  }
  Self.FDlaPosition := -1;//初始化轴封漏气位置（-1表示默认放入凝汽器）
end;

procedure THRSysWithDA.SetDAPosition(Value: integer);
begin
	if Value < Self.ZHR then FDAPosition := Value;
end;

function THRSysWithDA.GetDAPosition : integer;
begin
	Result := FDAPosition;
end;

procedure THRSysWithDA.GetNewarrHROutput;
var
	i,j,Count : integer;
  arrFlag : array of Integer;
  tmpSumDeltaHfwBeforeDA    : double;
begin
  tag := 1;
  GetNumHasDrainIn;
	GetDfw;
	GetfwOutTDPoint;
  GetcwInTDPoint;
  Self.GetHl;

  SetLength(FarrTDPointOutletWater, Self.ZHR);
  SetLength(FarrTDPointInletWater, Self.ZHR);
  SetLength(FarrTDPointDrain, Self.ZHR);
  SetLength(FarrTDPointExtraction, Self.ZHR);

  //只有除氧器
  if Self.ZHR = 1 then begin //除氧器位置只能为0//注意：除氧器+给水泵的模型

    	///四个点设置
  		//除氧器出口热力点
    	FarrTDPointOutletWater[0] := PLGetTDPoint(Self.PeDA); //给水泵前点
    	Self.arrHROutput[0].PTDPointOutletWater := @FarrTDPointOutletWater[0];//指针
    	//除氧器入口热力点
  		FarrTDPointInletWater[0] := self.cwInTDPoint;
  		Self.arrHROutput[0].PTDPointInletWater  := @FarrTDPointInletWater[0];//指针
    	//疏水//只有除氧器的情况下无疏水或疏水等于出口热力点
    	FarrTDPointDrain[0] := FarrTDPointOutletWater[0];
    	Self.arrHROutput[0].PTDPointDrain := @FarrTDPointDrain[0];//指针
    	//抽汽点
    	FarrTDPointExtraction[0].P  :=  FarrTDPointDrain[0].P/(1 - Self.arrHRInput[0].DeltaPeOverPe/100);
    	SetLength(arrFlag, 1);
    	arrFlag[0] := SeekTDPointPositionByP(FarrTDPointExtraction[0].P, TDPointList);//热力过程曲线上反查抽汽点
    	FarrTDPointExtraction[0] := TDPointList[arrFlag[0]];//可以用插值法做成更精确的返回值
    	Self.arrHROutput[0].PTDPointExtraction := @FarrTDPointExtraction[0];//指针
    	///回热平衡计算
    	//设置该级回热器的给水量
    	Self.arrHROutput[0].Dfw := Self.Dfw;
    	//设置该级是否含有上级疏水
    	Self.arrHROutput[0].HasDrainIn := False;
			//联立求解Dg, Dcw
    	if Self.DAPosition = Self.DlaPosition then begin
    		Gausselimination(1.0, 1.0, Self.Dfw - Self.DeltaDla,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H - Self.DeltaDla * self.Hl);
    		//传递方程解
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
    	end else begin
    		{to do : 轴封漏气回收到凝汽器的情况}
    		Gausselimination(1.0, 1.0, Self.Dfw,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H);
    		//传递方程解
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
    	end;

  {ZHR>1}
	end else if Self.ZHR > 1 then begin

    	{四个点设置}
  		//除氧器出口热力点
      FarrTDPointOutletWater[0] := Self.fwOutTDPoint;
		  for i:= 0 to (Self.ZHR - 2) do begin
        FarrTDPointOutletWater[i+1].H := FarrTDPointOutletWater[i].H - Self.arrHRInput[i].DeltaHWater;
		  end;
		  for i := 0 to (Self.FDAPosition - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pfp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
  	  FDATDPointOutletWater := PLGetTDPoint(Self.PeDA);//## //除氧器自身的出口 （除氧器工作压力下对应的饱和液体  也是给水泵入口的点）
      FarrTDPointOutletWater[FDAPosition] := FDATDPointOutletWater;
		  for i:= (Self.FDAPosition + 1) to (Self.ZHR - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pcp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
		  for i:= 0 to (Self.ZHR-1) do begin
    	  Self.arrHROutput[i].PTDPointOutletWater := @FarrTDPointOutletWater[i];//指针
      end;
    	//回热器入口热力点
  		for i:= 0 to (Self.ZHR-2) do begin//##
  			FarrTDPointInletWater[i] := FarrTDPointOutletWater[i+1];
  		end;
   		FarrTDPointInletWater[Self.ZHR-1] := Self.cwInTDPoint;//注意水泵
			for i:= 0 to (Self.ZHR-1) do begin
    		Self.arrHROutput[i].PTDPointInletWater := @FarrTDPointInletWater[i];//指针
    	end;
  		//疏水
  		for i := 0 to (Self.ZHR-1) do begin
  			FarrTDPointDrain[i].T := FarrTDPointOutletWater[i].T + Self.arrHRInput[i].Deltalt;
    		FarrTDPointDrain[i]   := TLGetTDPoint(FarrTDPointDrain[i].T);
    	  Self.arrHROutput[i].PTDPointDrain := @FarrTDPointDrain[i];//指针
			end;
    	//抽汽点
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i].P  :=  FarrTDPointDrain[i].P/(1 - Self.arrHRInput[i].DeltaPeOverPe/100);
    	end;
    	for i := 0 to (Self.ZHR-1) do begin
    		SetLength(arrFlag, Self.ZHR);
    		arrFlag[i] := SeekTDPointPositionByP(FarrTDPointExtraction[i].P, TDPointList);//热力过程曲线上反查抽汽点
    		FarrTDPointExtraction[i] := TDPointList[arrFlag[i]];//可以用插值法做成更精确的返回值
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//指针
    	end;
      {回热平衡计算准备量}
  	  //设置该级回热器的给水量
  	  for i := 0 to (Self.ZHR - 1) do begin
  	  	if i <= Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := Self.Dfw;
  	    end else if i > Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := 0;
  	    end;
  	  end;
  	  //辅助参数蒸汽焓升
			for i := 0 to (ZHR - 1) do begin
				arrHROutput[i].DeltaHSteam := arrHROutput[i].PTDPointExtraction^.H - arrHROutput[i].PTDPointDrain^.H;
			end;
			//自动修正输入参数：设置是否包含上级疏水的属性 HasDrainIn
			for i := 0 to (Self.ZHR - 1) do begin
				Self.arrHROutput[i].HasDrainIn := True; //##
			end; //全部设为false
      Self.arrHROutput[0].HasDrainIn := False;
      Self.arrHROutput[FDAPosition+1].HasDrainIn := False;//除开每段的第一个加热器，其余的都有疏水流入，包括除氧器
  	  //De & Drain
  	  SetLength(FDeEquivalentDla ,1);
  	  j := 0;
      FDeEquivalentDrain := 0;//初始化该值

    	{DAPosition = 0}
  		if Self.FDAPosition = 0 then begin
    	  {DlaPos = FDAPosition}
    	  if Self.FDlaPosition = FDAPosition then begin
  		  	  Gausselimination(1.0, 1.0, Dfw - self.DeltaDla,
					  arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					  Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - self.Hl * self.DeltaDla);
					  //传递方程解
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///开始后面加热器的热平衡计算
    	      arrHROutput[1].DeltaDe := GetStandardDeltaDe(arrHROutput[1].Dcw, arrHRInput[1].DeltaHWater, arrHROutput[1].DeltaHSteam, arrHRInput[1].yitah);
    	      for i := 2 to ZHR-1 do begin
    	       		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
					    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
    	      end;
    	  {DlaPos <> FDAPosition}
    	  end else if Self.FDlaPosition <> FDAPosition then begin
  		  	  Gausselimination(1.0, 1.0, Dfw,
					  arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					  Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H);
					  //传递方程解
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///开始后面加热器的热平衡计算
						for i := FDAPosition+1 to ZHR-1 do begin
							if arrHROutput[i].HasDrainIn = False then begin
						  	if arrHRInput[i].HasDlaIn = False then begin
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
									arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe;
  		  		    end else begin
						    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
						    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
						   	end;
  		  		 	end else begin
  		  		  	if arrHRInput[i].HasDlaIn = False then begin
						   		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
						    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
						  	end else begin
						    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
						    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
  		  		    end;
  		  		    j := j + 1;
  		  		  end;
						end;
        end;

    	{DAPosition > 0}
    	end else if Self.FDAPosition > 0 then begin
    	
  		  for i := 0 to FDAPosition-1 do begin
  		  	if arrHROutput[i].HasDrainIn = False then begin
					   if arrHRInput[i].HasDlaIn = False then begin
					   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						 		arrHROutput[i].Drain   :=  arrHROutput[i].DeltaDe;
					   end else begin
					    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   	 	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
					    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
					   end;
  		    end else begin //arrHR[i].HasDrainIn = True 有疏水逐级回流
					   if arrHRInput[i].HasDlaIn = False then begin
    	       		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
					    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
					   end else begin
					   		FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   	  arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					     	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
					     	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
					   end;
					   j := j + 1;
  		  	end;
  		  end;
	  		//解方程获得DA的Dg
  		  if (DlaPosition<>FDAPosition) then begin //只分为两种情况，有轴封漏气和无轴封漏气
  		     Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
				   //传递方程解
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end else begin //（DlaPosition = DAPosition）
					 Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain- DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //传递方程解
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end;
				//Dcw
				for i := 0 to (ZHR - 1) do begin
					if i < FDAPosition then begin
						arrHROutput[i].Dcw := 0;
					end else if i > FDAPosition then begin
						arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					end;
				end;
				for i := FDAPosition+1 to ZHR-1 do begin
					if arrHROutput[i].HasDrainIn = False then begin
				  	if arrHRInput[i].HasDlaIn = False then begin
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
							arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe;
  		      end else begin
				    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
				   	end;
  		   	end else begin
  		    	if arrHRInput[i].HasDlaIn = False then begin
				   		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
				  	end else begin
				    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
  		      end;
  		      j := j + 1;
  		    end;
				end;
    	end;
    end;
end;

procedure THRSysWithDA.GetarrHROutput;
var
	i,j,Count : integer;
  arrFlag : array of Integer;
  tmpSumDeltaHfwBeforeDA    : double;
begin
  tag := 1;
  GetNumHasDrainIn;
	GetDfw;
	GetfwOutTDPoint;
  GetcwInTDPoint;
	//Set arrDeltaHfw
  GetOriarrDeltaHfw;
  GetarrDeltaHfw;
  for i := 0 to ZHR-1 do begin
  	arrDeltaHfw[i] := FarrDeltaHfw[i];
  end;
  Self.GetHl;

  SetLength(FarrTDPointOutletWater, Self.ZHR);
  SetLength(FarrTDPointInletWater, Self.ZHR);
  SetLength(FarrTDPointDrain, Self.ZHR);
  SetLength(FarrTDPointExtraction, Self.ZHR);

  //只有除氧器
  if Self.ZHR = 1 then begin //除氧器位置只能为0//注意：除氧器+给水泵的模型

    	///四个点设置
  		//除氧器出口热力点
    	FarrTDPointOutletWater[0] := PLGetTDPoint(Self.PeDA); //给水泵前点
    	Self.arrHROutput[0].PTDPointOutletWater := @FarrTDPointOutletWater[0];//指针
    	//除氧器入口热力点
  		FarrTDPointInletWater[0] := self.cwInTDPoint;
  		Self.arrHROutput[0].PTDPointInletWater  := @FarrTDPointInletWater[0];//指针
    	//疏水//只有除氧器的情况下无疏水或疏水等于出口热力点
    	FarrTDPointDrain[0] := FarrTDPointOutletWater[0];
    	Self.arrHROutput[0].PTDPointDrain := @FarrTDPointDrain[0];//指针
    	//抽汽点
    	FarrTDPointExtraction[0].P  :=  FarrTDPointDrain[0].P/(1 - Self.arrHRInput[0].DeltaPeOverPe/100);
    	SetLength(arrFlag, 1);
    	arrFlag[0] := SeekTDPointPositionByP(FarrTDPointExtraction[0].P, TDPointList);//热力过程曲线上反查抽汽点
    	FarrTDPointExtraction[0] := TDPointList[arrFlag[0]];//可以用插值法做成更精确的返回值
    	Self.arrHROutput[0].PTDPointExtraction := @FarrTDPointExtraction[0];//指针
    	///回热平衡计算
    	//设置该级回热器的给水量
    	Self.arrHROutput[0].Dfw := Self.Dfw;
    	//设置该级是否含有上级疏水
    	Self.arrHROutput[0].HasDrainIn := False;
			//联立求解Dg, Dcw
    	if Self.DAPosition = Self.DlaPosition then begin
    		Gausselimination(1.0, 1.0, Self.Dfw - Self.DeltaDla,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H - Self.DeltaDla * self.Hl);
    		//传递方程解
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
    	end else begin
    		{to do : 轴封漏气回收到凝汽器的情况}
    		Gausselimination(1.0, 1.0, Self.Dfw,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H);
    		//传递方程解
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
    	end;

  {ZHR>1}
	end else if Self.ZHR > 1 then begin

    	{四个点设置}
  		//除氧器出口热力点
      FarrTDPointOutletWater[0] := Self.fwOutTDPoint;
		  for i:= 0 to (Self.ZHR - 2) do begin
        FarrTDPointOutletWater[i+1].H := FarrTDPointOutletWater[i].H - Self.arrHRInput[i].DeltaHWater;
		  end;
		  for i := 0 to (Self.FDAPosition - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pfp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
  	  FDATDPointOutletWater := PLGetTDPoint(Self.PeDA);//## //除氧器自身的出口 （除氧器工作压力下对应的饱和液体  也是给水泵入口的点）
      FarrTDPointOutletWater[FDAPosition] := FDATDPointOutletWater;
		  for i:= (Self.FDAPosition + 1) to (Self.ZHR - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pcp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
		  for i:= 0 to (Self.ZHR-1) do begin
    	  Self.arrHROutput[i].PTDPointOutletWater := @FarrTDPointOutletWater[i];//指针
      end;
    	//回热器入口热力点
  		for i:= 0 to (Self.ZHR-2) do begin//##
  			FarrTDPointInletWater[i] := FarrTDPointOutletWater[i+1];
  		end;
   		FarrTDPointInletWater[Self.ZHR-1] := Self.cwInTDPoint;//注意水泵
			for i:= 0 to (Self.ZHR-1) do begin
    		Self.arrHROutput[i].PTDPointInletWater := @FarrTDPointInletWater[i];//指针
    	end;
  		//疏水
  		for i := 0 to (Self.ZHR-1) do begin
  			FarrTDPointDrain[i].T := FarrTDPointOutletWater[i].T + Self.arrHRInput[i].Deltalt;
    		FarrTDPointDrain[i]   := TLGetTDPoint(FarrTDPointDrain[i].T);
    	  Self.arrHROutput[i].PTDPointDrain := @FarrTDPointDrain[i];//指针
			end;
    	//抽汽点
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i].P  :=  FarrTDPointDrain[i].P/(1 - Self.arrHRInput[i].DeltaPeOverPe/100);
    	end;
    	for i := 0 to (Self.ZHR-1) do begin
    		SetLength(arrFlag, Self.ZHR);
    		arrFlag[i] := SeekTDPointPositionByP(FarrTDPointExtraction[i].P, TDPointList);//热力过程曲线上反查抽汽点
    		FarrTDPointExtraction[i] := TDPointList[arrFlag[i]];//可以用插值法做成更精确的返回值
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//指针
    	end;
      {回热平衡计算准备量}
  	  //设置该级回热器的给水量
  	  for i := 0 to (Self.ZHR - 1) do begin
  	  	if i <= Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := Self.Dfw;
  	    end else if i > Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := 0;
  	    end;
  	  end;
  	  //辅助参数蒸汽焓升
			for i := 0 to (ZHR - 1) do begin
				arrHROutput[i].DeltaHSteam := arrHROutput[i].PTDPointExtraction^.H - arrHROutput[i].PTDPointDrain^.H;
			end;
			//自动修正输入参数：设置是否包含上级疏水的属性 HasDrainIn
			for i := 0 to (Self.ZHR - 1) do begin
				Self.arrHROutput[i].HasDrainIn := True; //##
			end; //全部设为false
      Self.arrHROutput[0].HasDrainIn := False;
      Self.arrHROutput[FDAPosition+1].HasDrainIn := False;//除开每段的第一个加热器，其余的都有疏水流入，包括除氧器
  	  //De & Drain
  	  SetLength(FDeEquivalentDla ,1);
  	  j := 0;
      FDeEquivalentDrain := 0;//初始化该值

    	{DAPosition = 0}
  		if Self.FDAPosition = 0 then begin
    	  {DlaPos = FDAPosition}
    	  if Self.FDlaPosition = FDAPosition then begin
  		  	  Gausselimination(1.0, 1.0, Dfw - self.DeltaDla,
					  arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					  Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - self.Hl * self.DeltaDla);
					  //传递方程解
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///开始后面加热器的热平衡计算
    	      arrHROutput[1].DeltaDe := GetStandardDeltaDe(arrHROutput[1].Dcw, arrHRInput[1].DeltaHWater, arrHROutput[1].DeltaHSteam, arrHRInput[1].yitah);
    	      for i := 2 to ZHR-1 do begin
    	       		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
					    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
    	      end;
    	  {DlaPos <> FDAPosition}
    	  end else if Self.FDlaPosition <> FDAPosition then begin
  		  	  Gausselimination(1.0, 1.0, Dfw,
					  arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					  Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H);
					  //传递方程解
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//解方程结束
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///开始后面加热器的热平衡计算
						for i := FDAPosition+1 to ZHR-1 do begin
							if arrHROutput[i].HasDrainIn = False then begin
						  	if arrHRInput[i].HasDlaIn = False then begin
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
									arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe;
  		  		    end else begin
						    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
						    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
						   	end;
  		  		 	end else begin
  		  		  	if arrHRInput[i].HasDlaIn = False then begin
						   		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
						    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
						  	end else begin
						    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
						    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
						    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
  		  		    end;
  		  		    j := j + 1;
  		  		  end;
						end;
        end;

    	{DAPosition > 0}
    	end else if Self.FDAPosition > 0 then begin
    	
  		  for i := 0 to FDAPosition-1 do begin
  		  	if arrHROutput[i].HasDrainIn = False then begin
					   if arrHRInput[i].HasDlaIn = False then begin
					   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
						 		arrHROutput[i].Drain   :=  arrHROutput[i].DeltaDe;
					   end else begin
					    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   	 	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
					    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
					   end;
  		    end else begin //arrHR[i].HasDrainIn = True 有疏水逐级回流
					   if arrHRInput[i].HasDlaIn = False then begin
    	       		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   		arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
					    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
					   end else begin
					   		FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
					   	  arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dfw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
					     	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
					     	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
					   end;
					   j := j + 1;
  		  	end;
  		  end;
	  		//解方程获得DA的Dg
  		  if (DlaPosition<>FDAPosition) then begin //只分为两种情况，有轴封漏气和无轴封漏气
  		     Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
				   //传递方程解
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end else begin //（DlaPosition = DAPosition）
					 Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain- DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //传递方程解
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//解方程结束
				end;
				//Dcw
				for i := 0 to (ZHR - 1) do begin
					if i < FDAPosition then begin
						arrHROutput[i].Dcw := 0;
					end else if i > FDAPosition then begin
						arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					end;
				end;
				for i := FDAPosition+1 to ZHR-1 do begin
					if arrHROutput[i].HasDrainIn = False then begin
				  	if arrHRInput[i].HasDlaIn = False then begin
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
							arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe;
  		      end else begin
				    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0];
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + DeltaDla;
				   	end;
  		   	end else begin
  		    	if arrHRInput[i].HasDlaIn = False then begin
				   		FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDrain;
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain;
				  	end else begin
				    	FDeEquivalentDla[0] := GetDeEquivalent(DeltaDla, Self.Hl, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	FDeEquivalentDrain := GetDeEquivalent(arrHROutput[i-1].Drain, arrHROutput[i-1].PTDPointDrain^.H, arrHROutput[i].PTDPointDrain^.H, arrHROutput[i].DeltaHSteam);
				    	arrHROutput[i].DeltaDe := GetStandardDeltaDe(arrHROutput[i].Dcw, arrHRInput[i].DeltaHWater, arrHROutput[i].DeltaHSteam, arrHRInput[i].yitah);
				    	arrHROutput[i].DeltaDe := arrHROutput[i].DeltaDe - FDeEquivalentDla[0] - FDeEquivalentDrain;
				    	arrHROutput[i].Drain :=  arrHROutput[i].DeltaDe + arrHROutput[i-1].Drain + DeltaDla;
  		      end;
  		      j := j + 1;
  		    end;
				end;
    	end;
    end;
end;


function GetDeEquivalent(D, h, hdrain, DeltaHSteam : double): double;//上一级疏水流入下一级疏水折算成的流量值
begin
  	Result := D * (h - hdrain) / DeltaHSteam;
end;

function GetStandardDeltaDe(Din,DeltaHWater,DeltaHSteam,yitah : double) : double;
begin
	Result := Din * DeltaHWater/(DeltaHSteam * yitah/100);
end;
end.
