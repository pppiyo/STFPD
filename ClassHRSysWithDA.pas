unit ClassHRSysWithDA;

interface
uses ClassHRSys, ClassIniData, ClassGoverningStage, TDPointUtils, GE, Dialogs, Sysutils, math;

{HRSysWithDA}
type
	THRSysWithDA = Class(THRSys)
		PeDA  : double;
    ZHR   : integer;
  private
  	//�ϼ�����
    FIniData : TIniData;
    FGoverningStage : TGoverningStage;
    //��������
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
    //��������
    FDAPosition  : integer;
    FDATDPointOutletWater : TTDPoint;
    //����
    function  GetDlaPosition : integer;
    procedure SetDlaPosition(Value: integer);
  	procedure GetDfw;
    procedure GetfwOutTDPoint;
    procedure GetcwInTDPoint;
    procedure GetOriarrDeltaHfw;
    procedure GetarrDeltaHfw;
    procedure GetNumHasDrainIn;
    procedure GetHl;
    //����
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
  Self.cwInTDPoint := PTGetTDPoint(FIniData.BasicData.pcp, TDPointC.T+FIniData.BasicData.deltatej);//�о����ˮ�£���
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
  //ֻ�г�����
  if Self.ZHR = 1 then begin //������λ��ֻ��Ϊ0//ע�⣺������+��ˮ�õ�ģ��
    //������
    FarrTDPointExtraction[0] := arrNewTDPointExtraction[0];//�����ò�ֵ�����ɸ���ȷ�ķ���ֵ
    Self.arrHROutput[0].PTDPointExtraction := @FarrTDPointExtraction[0];//ָ��
    ///����ƽ�����
		//�������Dg, Dcw
    if Self.DAPosition = Self.DlaPosition then begin
    	Gausselimination(1.0, 1.0, Self.Dfw - Self.DeltaDla,
    	FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    	Self.Dfw * FarrTDPointDrain[0].H - Self.DeltaDla * hl);
    	//���ݷ��̽�
    	Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    	Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
    end else begin
    	{to do : ���©�����յ������������}
    end;
    if Self.DAPosition <> Self.DlaPosition then begin
    	Gausselimination(1.0, 1.0, Self.Dfw,
    	FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    	Self.Dfw * FarrTDPointDrain[0].H);
    	//���ݷ��̽�
    	Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    	Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
    end;//���©�����յ�λ�û��п�����������
	end;

  if Self.ZHR > 1 then begin

  	if Self.FDAPosition = 0 then begin
    	//������
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i] := arrNewTDPointExtraction[i];
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//ָ��
    	end;
      ///����ƽ�����
      FDeEquivalentDrain := 0;//��ʼ����ֵ
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
  	    end else begin //arrHR[i].HasDrainIn = True ����ˮ�𼶻���
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
	  	//�ⷽ�̻��DA��Dg
    	if FDAPosition > 0 then begin
  	  	if (DlaPosition<>FDAPosition) then begin //ֻ��Ϊ��������������©���������©��
  	  	   Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
				   //���ݷ��̽�
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				end else begin //��DlaPosition = DAPosition��
					 Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain- DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //���ݷ��̽�
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				end;
      end else begin
  	  	if (DlaPosition<>FDAPosition) then begin //ֻ��Ϊ��������������©���������©��
  	  	   Gausselimination(1.0, 1.0, Dfw,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H);
				   //���ݷ��̽�
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				end else begin //��DlaPosition = DAPosition��
					 Gausselimination(1.0, 1.0, Dfw - DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //���ݷ��̽�
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
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
    	//������
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i] := arrNewTDPointExtraction[i];
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//ָ��
    	end;
  	  ///����ƽ�����
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
	  //�ⷽ�̻��DA��Dg
  	  if (DlaPosition<>FDAPosition) then begin
  	     Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
			   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
			   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
			   //���ݷ��̽�
			   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
			   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
			end else begin //��DlaPosition = DAPosition��
				 Gausselimination(1.0, 1.0, Dfw - DeltaDla,
				 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - DeltaDla * Hl);
				 //���ݷ��̽�
				 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
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
	//����Զ�����DeltaHfwChange�Ƿ�Ϊ0
  tmpSum := 0;
	for i := 0 to ZHR-1 do begin
  	tmpSum := tmpSum + Self.arrChange[i];
  end;
	if tmpSum<> 0 then Showmessage('Error : Sum of DivChange must be zero!');
  //����Զ�����DeltaHfwChange�Ƿ�Խ��
  for i := 0 to ZHR-1 do begin
  	if Self.arrChange[i] > Self.DivRange then
    	Showmessage('Error : Change Value Must be below  '+Floattostr(Self.DivRange));
  end;
  //����������ʽ�µļ���������
  for i := 0 to Self.ZHR-1 do begin
  	if Self.arrHRInput[i].IsSurface = False then begin
  		if not ((Self.arrHRInput[i].Yitah=100) and (Self.arrHRInput[i].Deltalt = 0)) then
				Showmessage('Warning : Please Press OK Button!');
  	end;
  end;
  //������������
  Count := 0;
  for i := 0 to Self.ZHR-1 do begin
  	if Self.arrHRInput[i].IsSurface = False then begin
    	Count := Count + 1;
  	end;
  end;
  if Count > 1 then Showmessage('Error : Only One Deaerator is allowed');
  //������©���ֶ����ø���
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
  	Self.arrHRInput[Floor(Self.ZHR/2)].HasDlaIn := True;		//�Զ�������������������Ƿ�����ϼ���ˮ������ HasDrainIn
  	Showmessage('Automatically Set Steam Leakage Reclaim Position!');
	end;
	for i := 0 to (Self.ZHR - 1) do begin
		Self.arrHROutput[i].HasDrainIn := True;
	end;
  Self.arrHROutput[0].HasDrainIn := False;
  Self.arrHROutput[Self.DAPosition+1].HasDrainIn := False;//����ÿ�εĵ�һ��������������Ķ�����ˮ���룬����������
//���ó���message�Ͳ��ܼ�������
end;

//THRSysWithDA
constructor THRSysWithDA.Create(ZHR:integer; PeDA:double; IniData:TIniData; GoverningStage:TGoverningStage);
var
	i : integer;
begin
	//�����ϼ�����
  FIniData        := IniData;
  FGoverningStage := GoverningStage;
  //��������
  Self.ZHR := ZHR;
  Self.PeDA := PeDA;
	GetfwOutTDPoint;
  GetcwInTDPoint;
  Self.DivRange := 10;
  Self.DAPosition := (Ceil(Self.ZHR / 2)-1);//��ʾ��DA��űȸ�ֵ��һ
  SetLength(Self.arrDeltaHfw, Self.ZHR);
  SetLength(Self.arrChange, Self.ZHR); //�Զ���ֵ��Change��Ŀ�Ȼ�������Ŀ��һ�����һ����Ϊƽ��
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
  //�ر������Ƿ�����ϼ���ˮ������ HasDrainIn
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
	if (Self.ZHR >= 3) and (Self.FDAPosition < Self.ZHR-1) then begin//������С��2�Ҽ������������һ��
  	Self.arrHROutput[FDAPosition+1].HasDrainIn := False;
  end;//����ÿ�εĵ�һ��������,����Ķ�����ˮ����
  }
  Self.FDlaPosition := -1;//��ʼ�����©��λ�ã�-1��ʾĬ�Ϸ�����������
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

  //ֻ�г�����
  if Self.ZHR = 1 then begin //������λ��ֻ��Ϊ0//ע�⣺������+��ˮ�õ�ģ��

    	///�ĸ�������
  		//����������������
    	FarrTDPointOutletWater[0] := PLGetTDPoint(Self.PeDA); //��ˮ��ǰ��
    	Self.arrHROutput[0].PTDPointOutletWater := @FarrTDPointOutletWater[0];//ָ��
    	//���������������
  		FarrTDPointInletWater[0] := self.cwInTDPoint;
  		Self.arrHROutput[0].PTDPointInletWater  := @FarrTDPointInletWater[0];//ָ��
    	//��ˮ//ֻ�г����������������ˮ����ˮ���ڳ���������
    	FarrTDPointDrain[0] := FarrTDPointOutletWater[0];
    	Self.arrHROutput[0].PTDPointDrain := @FarrTDPointDrain[0];//ָ��
    	//������
    	FarrTDPointExtraction[0].P  :=  FarrTDPointDrain[0].P/(1 - Self.arrHRInput[0].DeltaPeOverPe/100);
    	SetLength(arrFlag, 1);
    	arrFlag[0] := SeekTDPointPositionByP(FarrTDPointExtraction[0].P, TDPointList);//�������������Ϸ��������
    	FarrTDPointExtraction[0] := TDPointList[arrFlag[0]];//�����ò�ֵ�����ɸ���ȷ�ķ���ֵ
    	Self.arrHROutput[0].PTDPointExtraction := @FarrTDPointExtraction[0];//ָ��
    	///����ƽ�����
    	//���øü��������ĸ�ˮ��
    	Self.arrHROutput[0].Dfw := Self.Dfw;
    	//���øü��Ƿ����ϼ���ˮ
    	Self.arrHROutput[0].HasDrainIn := False;
			//�������Dg, Dcw
    	if Self.DAPosition = Self.DlaPosition then begin
    		Gausselimination(1.0, 1.0, Self.Dfw - Self.DeltaDla,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H - Self.DeltaDla * self.Hl);
    		//���ݷ��̽�
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
    	end else begin
    		{to do : ���©�����յ������������}
    		Gausselimination(1.0, 1.0, Self.Dfw,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H);
    		//���ݷ��̽�
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
    	end;

  {ZHR>1}
	end else if Self.ZHR > 1 then begin

    	{�ĸ�������}
  		//����������������
      FarrTDPointOutletWater[0] := Self.fwOutTDPoint;
		  for i:= 0 to (Self.ZHR - 2) do begin
        FarrTDPointOutletWater[i+1].H := FarrTDPointOutletWater[i].H - Self.arrHRInput[i].DeltaHWater;
		  end;
		  for i := 0 to (Self.FDAPosition - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pfp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
  	  FDATDPointOutletWater := PLGetTDPoint(Self.PeDA);//## //����������ĳ��� ������������ѹ���¶�Ӧ�ı���Һ��  Ҳ�Ǹ�ˮ����ڵĵ㣩
      FarrTDPointOutletWater[FDAPosition] := FDATDPointOutletWater;
		  for i:= (Self.FDAPosition + 1) to (Self.ZHR - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pcp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
		  for i:= 0 to (Self.ZHR-1) do begin
    	  Self.arrHROutput[i].PTDPointOutletWater := @FarrTDPointOutletWater[i];//ָ��
      end;
    	//���������������
  		for i:= 0 to (Self.ZHR-2) do begin//##
  			FarrTDPointInletWater[i] := FarrTDPointOutletWater[i+1];
  		end;
   		FarrTDPointInletWater[Self.ZHR-1] := Self.cwInTDPoint;//ע��ˮ��
			for i:= 0 to (Self.ZHR-1) do begin
    		Self.arrHROutput[i].PTDPointInletWater := @FarrTDPointInletWater[i];//ָ��
    	end;
  		//��ˮ
  		for i := 0 to (Self.ZHR-1) do begin
  			FarrTDPointDrain[i].T := FarrTDPointOutletWater[i].T + Self.arrHRInput[i].Deltalt;
    		FarrTDPointDrain[i]   := TLGetTDPoint(FarrTDPointDrain[i].T);
    	  Self.arrHROutput[i].PTDPointDrain := @FarrTDPointDrain[i];//ָ��
			end;
    	//������
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i].P  :=  FarrTDPointDrain[i].P/(1 - Self.arrHRInput[i].DeltaPeOverPe/100);
    	end;
    	for i := 0 to (Self.ZHR-1) do begin
    		SetLength(arrFlag, Self.ZHR);
    		arrFlag[i] := SeekTDPointPositionByP(FarrTDPointExtraction[i].P, TDPointList);//�������������Ϸ��������
    		FarrTDPointExtraction[i] := TDPointList[arrFlag[i]];//�����ò�ֵ�����ɸ���ȷ�ķ���ֵ
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//ָ��
    	end;
      {����ƽ�����׼����}
  	  //���øü��������ĸ�ˮ��
  	  for i := 0 to (Self.ZHR - 1) do begin
  	  	if i <= Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := Self.Dfw;
  	    end else if i > Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := 0;
  	    end;
  	  end;
  	  //����������������
			for i := 0 to (ZHR - 1) do begin
				arrHROutput[i].DeltaHSteam := arrHROutput[i].PTDPointExtraction^.H - arrHROutput[i].PTDPointDrain^.H;
			end;
			//�Զ�������������������Ƿ�����ϼ���ˮ������ HasDrainIn
			for i := 0 to (Self.ZHR - 1) do begin
				Self.arrHROutput[i].HasDrainIn := True; //##
			end; //ȫ����Ϊfalse
      Self.arrHROutput[0].HasDrainIn := False;
      Self.arrHROutput[FDAPosition+1].HasDrainIn := False;//����ÿ�εĵ�һ��������������Ķ�����ˮ���룬����������
  	  //De & Drain
  	  SetLength(FDeEquivalentDla ,1);
  	  j := 0;
      FDeEquivalentDrain := 0;//��ʼ����ֵ

    	{DAPosition = 0}
  		if Self.FDAPosition = 0 then begin
    	  {DlaPos = FDAPosition}
    	  if Self.FDlaPosition = FDAPosition then begin
  		  	  Gausselimination(1.0, 1.0, Dfw - self.DeltaDla,
					  arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					  Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - self.Hl * self.DeltaDla);
					  //���ݷ��̽�
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///��ʼ�������������ƽ�����
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
					  //���ݷ��̽�
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///��ʼ�������������ƽ�����
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
  		    end else begin //arrHR[i].HasDrainIn = True ����ˮ�𼶻���
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
	  		//�ⷽ�̻��DA��Dg
  		  if (DlaPosition<>FDAPosition) then begin //ֻ��Ϊ��������������©���������©��
  		     Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
				   //���ݷ��̽�
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				end else begin //��DlaPosition = DAPosition��
					 Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain- DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //���ݷ��̽�
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
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

  //ֻ�г�����
  if Self.ZHR = 1 then begin //������λ��ֻ��Ϊ0//ע�⣺������+��ˮ�õ�ģ��

    	///�ĸ�������
  		//����������������
    	FarrTDPointOutletWater[0] := PLGetTDPoint(Self.PeDA); //��ˮ��ǰ��
    	Self.arrHROutput[0].PTDPointOutletWater := @FarrTDPointOutletWater[0];//ָ��
    	//���������������
  		FarrTDPointInletWater[0] := self.cwInTDPoint;
  		Self.arrHROutput[0].PTDPointInletWater  := @FarrTDPointInletWater[0];//ָ��
    	//��ˮ//ֻ�г����������������ˮ����ˮ���ڳ���������
    	FarrTDPointDrain[0] := FarrTDPointOutletWater[0];
    	Self.arrHROutput[0].PTDPointDrain := @FarrTDPointDrain[0];//ָ��
    	//������
    	FarrTDPointExtraction[0].P  :=  FarrTDPointDrain[0].P/(1 - Self.arrHRInput[0].DeltaPeOverPe/100);
    	SetLength(arrFlag, 1);
    	arrFlag[0] := SeekTDPointPositionByP(FarrTDPointExtraction[0].P, TDPointList);//�������������Ϸ��������
    	FarrTDPointExtraction[0] := TDPointList[arrFlag[0]];//�����ò�ֵ�����ɸ���ȷ�ķ���ֵ
    	Self.arrHROutput[0].PTDPointExtraction := @FarrTDPointExtraction[0];//ָ��
    	///����ƽ�����
    	//���øü��������ĸ�ˮ��
    	Self.arrHROutput[0].Dfw := Self.Dfw;
    	//���øü��Ƿ����ϼ���ˮ
    	Self.arrHROutput[0].HasDrainIn := False;
			//�������Dg, Dcw
    	if Self.DAPosition = Self.DlaPosition then begin
    		Gausselimination(1.0, 1.0, Self.Dfw - Self.DeltaDla,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H - Self.DeltaDla * self.Hl);
    		//���ݷ��̽�
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
    	end else begin
    		{to do : ���©�����յ������������}
    		Gausselimination(1.0, 1.0, Self.Dfw,
    		FarrTDPointExtraction[0].H, FarrTDPointInletWater[0].H,
    		Self.Dfw * FarrTDPointDrain[0].H);
    		//���ݷ��̽�
    		Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
    	end;

  {ZHR>1}
	end else if Self.ZHR > 1 then begin

    	{�ĸ�������}
  		//����������������
      FarrTDPointOutletWater[0] := Self.fwOutTDPoint;
		  for i:= 0 to (Self.ZHR - 2) do begin
        FarrTDPointOutletWater[i+1].H := FarrTDPointOutletWater[i].H - Self.arrHRInput[i].DeltaHWater;
		  end;
		  for i := 0 to (Self.FDAPosition - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pfp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
  	  FDATDPointOutletWater := PLGetTDPoint(Self.PeDA);//## //����������ĳ��� ������������ѹ���¶�Ӧ�ı���Һ��  Ҳ�Ǹ�ˮ����ڵĵ㣩
      FarrTDPointOutletWater[FDAPosition] := FDATDPointOutletWater;
		  for i:= (Self.FDAPosition + 1) to (Self.ZHR - 1) do begin
  		  FarrTDPointOutletWater[i] := PHGetTDPoint(FIniData.BasicData.pcp, FarrTDPointOutletWater[i].H);
		  end;//SPECIALLY FOR DAPOSITION = 0!
		  for i:= 0 to (Self.ZHR-1) do begin
    	  Self.arrHROutput[i].PTDPointOutletWater := @FarrTDPointOutletWater[i];//ָ��
      end;
    	//���������������
  		for i:= 0 to (Self.ZHR-2) do begin//##
  			FarrTDPointInletWater[i] := FarrTDPointOutletWater[i+1];
  		end;
   		FarrTDPointInletWater[Self.ZHR-1] := Self.cwInTDPoint;//ע��ˮ��
			for i:= 0 to (Self.ZHR-1) do begin
    		Self.arrHROutput[i].PTDPointInletWater := @FarrTDPointInletWater[i];//ָ��
    	end;
  		//��ˮ
  		for i := 0 to (Self.ZHR-1) do begin
  			FarrTDPointDrain[i].T := FarrTDPointOutletWater[i].T + Self.arrHRInput[i].Deltalt;
    		FarrTDPointDrain[i]   := TLGetTDPoint(FarrTDPointDrain[i].T);
    	  Self.arrHROutput[i].PTDPointDrain := @FarrTDPointDrain[i];//ָ��
			end;
    	//������
    	for i := 0 to (Self.ZHR-1) do begin
    		FarrTDPointExtraction[i].P  :=  FarrTDPointDrain[i].P/(1 - Self.arrHRInput[i].DeltaPeOverPe/100);
    	end;
    	for i := 0 to (Self.ZHR-1) do begin
    		SetLength(arrFlag, Self.ZHR);
    		arrFlag[i] := SeekTDPointPositionByP(FarrTDPointExtraction[i].P, TDPointList);//�������������Ϸ��������
    		FarrTDPointExtraction[i] := TDPointList[arrFlag[i]];//�����ò�ֵ�����ɸ���ȷ�ķ���ֵ
    	  Self.arrHROutput[i].PTDPointExtraction := @FarrTDPointExtraction[i];//ָ��
    	end;
      {����ƽ�����׼����}
  	  //���øü��������ĸ�ˮ��
  	  for i := 0 to (Self.ZHR - 1) do begin
  	  	if i <= Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := Self.Dfw;
  	    end else if i > Self.FDAPosition then begin
  	    	Self.arrHROutput[i].Dfw := 0;
  	    end;
  	  end;
  	  //����������������
			for i := 0 to (ZHR - 1) do begin
				arrHROutput[i].DeltaHSteam := arrHROutput[i].PTDPointExtraction^.H - arrHROutput[i].PTDPointDrain^.H;
			end;
			//�Զ�������������������Ƿ�����ϼ���ˮ������ HasDrainIn
			for i := 0 to (Self.ZHR - 1) do begin
				Self.arrHROutput[i].HasDrainIn := True; //##
			end; //ȫ����Ϊfalse
      Self.arrHROutput[0].HasDrainIn := False;
      Self.arrHROutput[FDAPosition+1].HasDrainIn := False;//����ÿ�εĵ�һ��������������Ķ�����ˮ���룬����������
  	  //De & Drain
  	  SetLength(FDeEquivalentDla ,1);
  	  j := 0;
      FDeEquivalentDrain := 0;//��ʼ����ֵ

    	{DAPosition = 0}
  		if Self.FDAPosition = 0 then begin
    	  {DlaPos = FDAPosition}
    	  if Self.FDlaPosition = FDAPosition then begin
  		  	  Gausselimination(1.0, 1.0, Dfw - self.DeltaDla,
					  arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					  Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - self.Hl * self.DeltaDla);
					  //���ݷ��̽�
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///��ʼ�������������ƽ�����
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
					  //���ݷ��̽�
    		    Self.arrHROutput[0].DeltaDe := Gausseliminationxx;
    		    Self.arrHROutput[0].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				    //Dcw
				    for i := 0 to (ZHR - 1) do begin
					    if i < FDAPosition then begin
						    arrHROutput[i].Dcw := 0;
					    end else if i > FDAPosition then begin
						    arrHROutput[i].Dcw := arrHROutput[FDAPosition].Dcw;
					    end;
				    end;
    	      ///��ʼ�������������ƽ�����
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
  		    end else begin //arrHR[i].HasDrainIn = True ����ˮ�𼶻���
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
	  		//�ⷽ�̻��DA��Dg
  		  if (DlaPosition<>FDAPosition) then begin //ֻ��Ϊ��������������©���������©��
  		     Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain,
				   arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
				   Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H);
				   //���ݷ��̽�
				   arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
				   arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
				end else begin //��DlaPosition = DAPosition��
					 Gausselimination(1.0, 1.0, Dfw - arrHROutput[FDAPosition-1].Drain- DeltaDla,
					 arrHROutput[FDAPosition].PTDPointExtraction^.H, arrHROutput[FDAPosition].PTDPointInletWater^.H,
					 Dfw * arrHROutput[FDAPosition].PTDPointDrain^.H - arrHROutput[FDAPosition-1].Drain * arrHROutput[FDAPosition-1].PTDPointDrain^.H - DeltaDla * Self.Hl);
					 //���ݷ��̽�
					 arrHROutput[FDAPosition].DeltaDe := Gausseliminationxx;
					 arrHROutput[FDAPosition].Dcw     := Gausseliminationyy;//�ⷽ�̽���
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


function GetDeEquivalent(D, h, hdrain, DeltaHSteam : double): double;//��һ����ˮ������һ����ˮ����ɵ�����ֵ
begin
  	Result := D * (h - hdrain) / DeltaHSteam;
end;

function GetStandardDeltaDe(Din,DeltaHWater,DeltaHSteam,yitah : double) : double;
begin
	Result := Din * DeltaHWater/(DeltaHSteam * yitah/100);
end;
end.
