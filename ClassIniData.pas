unit ClassIniData;

interface
uses
	math,
  TDPointUtils, ClassPublicData;

type
	TBasic = class
		pr       : double;
   	pe       : double;
   	t0       : double;
   	tfw      : double;
   	pfp      : double;
   	N        : integer;
   	p0       : double;
   	bpc       : double;
   	tw1      : double;
   	pcp      : double;
   	DeltaDej : double;
   	Deltatej : double;
   	DeltaDl  : double;
   	DeltaDla : double;
    constructor Create;
  end;

type
	TAdjustment = Class
		Cok           : double;
		namda         : double;
		Cex           : double;
		yitari        : double;
		yitag         : double;
		yitaax        : double;
		yitabox       : double;
		expandm       : double;
		DeltaDoverD0  : double;
    constructor Create;
  end;

type
	TCurveShape = Class
    CurveMove     : double  	;
	  CurveDivNum   : Integer		;
    constructor Create;
  end;

{IniData}
type
	TIniData = class//关系着所有需要显示的数据
    tag : integer;
    //Input
  	BasicData      : TBasic;//约定：字段写成去T加Data
    AdjustmentData : TAdjustment;
    CurveShapeData : TCurveShape;
    //Calculateed phase1
    Ehtmac         : double;
    Ehimac         : double;
    IniTDPoints    : TIniTDPoints;
    //Calculateed phase2
    D0             : double;
    procedure GetIniTDPoints;//Calculateed phase1
    procedure GetD0auto;//Calculateed phase2
    procedure CheckData;
    Constructor Create(PublicData : TPublicData);
  end;
  //var aIniData    : TIniData;
implementation

Constructor TIniData.Create(PublicData : TPublicData);
begin
  tag := 0;
	BasicData      := TBasic.Create;
  BasicData.pr   := PublicData.Pr;
  BasicData.pe   := PublicData.Pe;
  BasicData.t0   := PublicData.t0;
  BasicData.p0   := PublicData.p0;
  BasicData.bpc  := PublicData.bpc;
  BasicData.N    := PublicData.N;
  AdjustmentData := TAdjustment.Create;
  CurveShapeData := TCurveShape.Create;
end;

procedure TIniData.GetIniTDPoints;
var
	Deltap0,Deltapc : double;
begin
		//Calculation
    Deltap0 		    := self.AdjustmentData.Cok * self.BasicData.p0;
    MainTDPoint0 	  := PTGetTDPoint(Self.BasicData.p0, Self.BasicData.t0);//Point0
		MainTDPoint0a.H := MainTDPoint0.H;
    MainTDPoint0a.P := MainTDPoint0.P - DeltaP0;
    MainTDPoint0a 	:= PHGetTDPoint(MainTDPoint0a.P, MainTDPoint0a.H);//POINT 0'

    MainTDPointC.P 	:= self.BasicData.bpc;
  	Deltapc 		    := self.AdjustmentData.namda * power(self.AdjustmentData.Cex/100,2) * self.BasicData.bpc;
    MainTDPointZ.P 	:= MainTDPointC.P + DeltaPc;

    MainTDPoint0at 	:= PSGetTDPoint(MainTDPointZ.P, MainTDPoint0a.S);// POINT 0't
    self.Ehtmac 	  := MainTDPoint0a.H - MainTDPoint0at.H;
  	self.Ehimac 	  := self.Ehtmac * self.AdjustmentData.yitari;
    MainTDPointZ 		:= PHGetTDPoint(MainTDPointZ.P, MainTDPoint0a.H - self.Ehimac);//POINTZ

    MainTDPointMid  := HSGetTDPoint((MainTDPoint0a.H+MainTDPointz.H)/2,(MainTDPoint0a.S+MainTDPointz.S)/2);
    //IniTDPoints
    Self.IniTDPoints[0] := MainTDPoint0a;
    Self.IniTDPoints[1] := PHGetTDPoint(MainTDPointMid.P , (MainTDPointMid.H - Self.CurveShapeData.CurveMove));//temp 后方纠正
    Self.IniTDPoints[2] := MainTDPointZ;
end;

procedure TIniData.GetD0Auto;
begin
    //D0
  	if Self.BasicData.N = 3000 then begin
  		Self.D0 := 3600* self.BasicData.pe * self.AdjustmentData.expandm /
      					(self.Ehtmac * self.AdjustmentData.yitari * self.AdjustmentData.yitag
                * self.AdjustmentData.yitaax) / (1 - self.AdjustmentData.DeltaDoverD0);
  	end else
  		Self.D0 := 3600* self.BasicData.pe * self.AdjustmentData.expandm /
      					(self.Ehtmac * self.AdjustmentData.yitari * self.AdjustmentData.yitag
                * self.AdjustmentData.yitaax * self.AdjustmentData.yitabox)
                / (1 - self.AdjustmentData.DeltaDoverD0);
    tag := 1;
end;

procedure TIniData.CheckData;
begin
;
end;

constructor TBasic.Create;{可以从其他途径导入初始值（借鉴版本TEST20）}
begin
	 pr       :=     1500     ;
	 pe       :=     1200     ;
	 t0       :=     370      ;
	 tfw      :=     153      ;
	 pfp      :=     6.3      ;
	 N        :=     7000     ;
	 p0       :=     3.5      ;
	 bpc      :=     0.006    ;
	 tw1      :=     20       ;
	 pcp      :=     1.2      ;
	 DeltaDej :=     500      ;
	 Deltatej :=     3        ;
	 DeltaDl  :=     900     ;
	 DeltaDla :=     200       ;
end;

constructor TAdjustment.Create;
begin
	 Cok           :=   0.04		;
	 namda         :=   0.1		;
	 Cex           :=   100 		;
	 yitari        :=   0.69		;
	 yitag         :=   0.970		;
	 yitaax        :=   0.98		;
	 yitabox       :=   0.960		;
	 expandm       :=   1.3		;
	 DeltaDoverD0  :=   0.031		;
end;

constructor TCurveShape.Create;
begin
	 CurveMove     :=   25		;
	 CurveDivNum   :=   50		;
end;

end.

