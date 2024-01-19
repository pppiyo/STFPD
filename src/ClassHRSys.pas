unit ClassHRSys;

interface
uses
	SysUtils, Classes, math, Dialogs, TDPointUtils,
  ClassIniData, ClassGoverningStage, GE;

type
  THRInput = Record
  	IsSurface     : Boolean;
		Yitah         : double;
		Deltalt       : double;
		DeltaPeOverPe : double;
    DeltaHWater   : double;
    Change        : double;
    HasDlaIn      : Boolean;///���©�����յ�λ�û��п�����������
  end;

type
	THROutput = Record
		PTDPointOutletWater  : PTDPoint;
		PTDPointInletWater   : PTDPoint;
		PTDPointDrain        : PTDPoint;
		PTDPointExtraction   : PTDPoint;
		DeltaHSteam          : double;
		Dfw                  : double;
    HasDrainIn           : Boolean;
    Drain                : double;
    Dcw                  : double;
		DeltaDe              : double;
  end;

type
  TarrHRInput = array of THRInput;

type
  TarrHROutput = array of THROutput;

{HRSystem}
type
	THRSys = Class
    tag : integer;
    ZHR         : integer;//�ϼ�����ֱ�����
    Dfw         : double;//�ϼ�����ֱ�����
    DeltaDla    : double;//�ϼ�����ֱ�����
    fwOutTDPoint: TTDPoint;//�ϼ�����ֱ�����
    cwInTDPoint : TTDPoint;//�ϼ�����ֱ�����
    Hl          : double;
  	arrHRInput  : TarrHRInput;
    DivRange    : integer;
    arrDeltaHfw : array of double; //Լ����D2V��������ֵ�Ӵ�����������������飬V2D����ʱ������
    arrChange   : array of Double;//Լ����D2V��������ֵ�Ӵ�����������������飬V2D����ʱ������
    arrHROutput : TarrHROutput;
  private
  	//�ϼ�����
    FIniData        : TIniData;
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
    function  GetDlaPosition : integer;
    procedure SetDlaPosition(Value: integer);
  	procedure GetDfw;
    procedure GetfwOutTDPoint;
    procedure GetcwInTDPoint;
    procedure GetOriarrDeltaHfw;
    procedure GetarrDeltaHfw;
    procedure GetNumHasDrainIn;
    procedure GetHl;
  public
  	arrNewTDPointExtraction : array of TTDPoint;
    property  DlaPosition : integer read GetDlaPosition write SetDlaPosition;
    procedure SetDefault;//dynamic;
    procedure GetarrHROutput;
    procedure GenerateArrChange;
    procedure GetNewDeltaDe;
    procedure GetNewarrHROutput;
  	Constructor Create(ZHR:Integer; IniData:TIniData; GoverningStage:TGoverningStage);
end;

implementation
uses MainNyHRnR;

procedure THRSys.GetNewDeltaDe;
var
	i,j : integer;
begin

end;

procedure THRSys.GetarrHROutput;
var
	i,j,Count : integer;
  arrFlag : array of Integer;
begin
  tag := 1;

end;

procedure THRSys.GetNewarrHROutput;
var
	i,j,Count : integer;
  arrFlag : array of Integer;
begin
  tag := 1;

end;

//HRSys
procedure THRSys.GetHl;
begin
	if FGoverningStage <> nil then begin
		Self.Hl := FGoverningStage.Hl;
  end else
  	Self.Hl := MainTDPoint0a.H;
end;

constructor THRSys.Create(ZHR:integer; IniData:TIniData; GoverningStage:TGoverningStage);
var
	i : integer;
  tmpSum : integer;
begin
	//�ϼ���������
  tag := 0;
  FIniData        := IniData;
  FGoverningStage := GoverningStage;
  //��������
  Self.ZHR := ZHR;
	GetfwOutTDPoint;
  GetcwInTDPoint;
  Self.DivRange := 10;
  SetLength(Self.arrDeltaHfw, Self.ZHR);
  SetLength(Self.arrChange, Self.ZHR); //�Զ���ֵ��Change��Ŀ�Ȼ�������Ŀ��һ�����һ����Ϊƽ��
  SetLength(Self.arrHRInput, Self.ZHR);
  SetLength(Self.arrHROutput, Self.ZHR);
 	Randomize;
  GetOriarrDeltaHfw;
  for i := 0 to Self.ZHR-1 do begin
  	Self.arrHRInput[i].IsSurface     := True;
  	Self.arrHRInput[i].Yitah         := 98;
    Self.arrHRInput[i].Deltalt       := 3;
    Self.arrHRInput[i].DeltaPeOverPe := 5;
    Self.arrHRInput[i].DeltaHWater   := FOriarrDeltaHfw[i];//revise later(override)
    Self.arrHRInput[i].Change        := arrChange[i];
    Self.arrHRInput[i].HasDlaIn      := False;
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
  if ZHR > 0 then begin
    Self.arrHROutput[0].HasDrainIn := False;//����ÿ�εĵ�һ��������������Ķ�����ˮ
  end;
end;

procedure THRSys.GenerateArrChange;
var
	i : integer;
  tmpSum : double;
begin
//Set arrChange
 	Randomize;
  tmpSum := 0;
  if Self.ZHR > 1 then begin
  	for i := 0 to ZHR-2 do begin
    	arrChange[i] := Self.DivRange - 2 * Random(Self.DivRange);
    	tmpSum := tmpSum + arrChange[i];
  	end;
  	arrChange[ZHR-1] := - tmpSum;
  end else
  	arrChange[0] := 0;
end;

procedure THRSys.SetDefault;
var
	i : integer;
begin
	GenerateArrChange;
  GetarrDeltaHfw;
  for i := 0 to ZHR-1 do begin
  	arrDeltaHfw[i] := FarrDeltaHfw[i];
  end;
  for i := 0 to Self.ZHR-1 do begin
  	Self.arrHRInput[i].IsSurface := True;
  	Self.arrHRInput[i].Yitah   := 98;
    Self.arrHRInput[i].Deltalt := 3;
    Self.arrHRInput[i].DeltaPeOverPe := 5;
    Self.arrHRInput[i].DeltaHWater := arrDeltaHfw[i];//revise later(override)
    Self.arrHRInput[i].Change  := arrChange[i];
    Self.arrHRInput[i].HasDlaIn   := False;
  end;
end;

procedure THRSys.SetDlaPosition(Value: integer);
begin
	if Value < Self.ZHR then FDlaPosition := Value;
end;

function THRSys.GetDlaPosition : integer;
begin
	Result := FDlAPosition;
end;

procedure THRSys.GetDfw;
var
	tmpD0, tmpDeltaDl, tmpDeltaDla : double;
begin
  tmpD0 := FIniData.D0;
  tmpDeltaDl  := FIniData.BasicData.DeltaDl;
  tmpDeltaDla := FIniData.BasicData.DeltaDla;
	Self.Dfw := tmpD0 - tmpDeltaDl + tmpDeltaDla;
end;

procedure THRSys.GetfwOutTDPoint;
begin
	Self.fwOutTDPoint := PTGetTDPoint(FIniData.BasicData.pfp, FIniData.BasicData.tfw);
end;

procedure THRSys.GetcwInTDPoint;
var
  TDPointC : TTDPoint;
begin
  TDPointC := PLGetTDPoint(FIniData.BasicData.bpc);
  Self.cwInTDPoint := PTGetTDPoint(FIniData.BasicData.pcp, TDPointC.T+FIniData.BasicData.deltatej);//�о����ˮ�£���
end;

procedure THRSys.GetOriarrDeltaHfw;
var
	i : integer;
begin
  SetLength(Self.FOriarrDeltaHfw, Self.ZHR);
  for i := 0 to Self.ZHR-1 do
		FOriarrDeltaHfw[i] := (fwOutTDPoint.H - cwInTDPoint.H)/Self.ZHR;
end;

procedure THRSys.GetarrDeltaHfw;
var
	i : integer;
begin
  SetLength(Self.FarrDeltaHfw, Self.ZHR);
  for i := 0 to Self.ZHR-1 do
		FarrDeltaHfw[i] := FOriarrDeltaHfw[i] * (1+arrChange[i]/100);
end;

procedure THRSys.GetNumHasDrainIn;
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

end.

