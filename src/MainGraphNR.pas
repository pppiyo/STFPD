unit MainGraphNR;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Series, TeEngine, ExtCtrls, TeeProcs, Chart,
  TDPointUtils, ClassGoverningStage, ClassStage, ClassHRSys, ClassHRSysWithDA, ClassStageDiv,
  ClassCoupling, Data;


type
  TFormMainGraphNR = class(TForm)
    HSGraph: TChart;
    Series1: TPointSeries;
    Series2: TLineSeries;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FCurveDivNum : integer;
    Ftag : integer;
    FSePointIniMain        : TPointSeries;
  	FSeLineIniCurve        : TLineSeries;
    FSePointCurveGSRevise  : TPointSeries;
    FSeLineCurveGSRevise   : TLineSeries;
    FSeLineHRSysRange      : TLineSeries;
    FSePointHRSysOut       : TPointSeries;
    FSePointStageDivOut    : TPointSeries;
		FSePointNewStageDivOut : TPointSeries;
		FSePointNewHRSysOut    : TPointSeries;
    FSePointStageCalOut    : TPointSeries;
    FSeLineStageCalOut     : TLineSeries;
    FSeLineNewIni          : TLineSeries;
  public
    { Public declarations }
    procedure DrawIniCurve(IniTDPoints:TIniTDPoints ; CurveDivNum:integer);
    procedure DrawCurveGSRevise(param:TGoverningStage);
    procedure DrawHRSysOut(param : THRSys);
    procedure DrawStageDivOut(param : TStageDiv);
    procedure DrawCouplingOut(param : TCoupling);
    procedure DrawStageCalOut(param : TList);
  end;

var
  FormMainGraphNR: TFormMainGraphNR;

implementation
uses fmSTFPD, MainNyHRnR;

{$R *.dfm}

procedure TFormMainGraphNR.FormCreate(Sender: TObject);
begin
   Self.Caption := 'HS Graph';
   Self.Height := 582;
   Self.SetBounds(0, FormSTFPD.Height, FormSTFPD.Width, Self.Height);
   Ftag := 0;
end;

procedure TFormMainGraphNR.DrawIniCurve(IniTDPoints:TIniTDPoints ; CurveDivNum:integer);
var
	i : integer;
begin
	Self.FCurveDivNum := CurveDivNum;
  if Self.FSeLineIniCurve = nil then begin
   	Self.FSeLineIniCurve := TLineSeries.Create(Self.HSGraph);
    Self.FSeLineIniCurve.ParentChart := Self.HSGraph;
  end else begin
  	Self.FSeLineIniCurve.Clear;
  end;
	ThreeTDPointsInterpolation(IniTDPoints,CurveDivNum);
  FSeLineIniCurve.Marks.Visible := False;
  //画热力过程曲线
  for i := 0 to CurveDivNum do begin
 		Self.FSeLineIniCurve.Addxy(TDPointList[i].S,TDPointList[i].H,'',clblue);
  end;
  Self.HSGraph.BottomAxis.Automatic := True;
  Self.HSGraph.LeftAxis.Automatic   := True;
end;

procedure TFormMainGraphNR.DrawCurveGSRevise(param:TGoverningStage);
var
	i : integer;
begin
  //自定义分点（复用用户在界面1中的操作数值）
  //显示上清除原曲线
  if FSeLineIniCurve <> nil then begin
  	Self.FSeLineIniCurve.Clear;//显示上取代 Inicurve, 因而隐藏该curve
  end;
  //创建新曲线
  if Self.FSeLineCurveGSRevise = nil then begin
   	Self.FSeLineCurveGSRevise := TLineSeries.Create(Self.HSGraph);
    Self.FSeLineCurveGSRevise.ParentChart := Self.HSGraph;
  end else begin
  	Self.FSeLineCurveGSRevise.Clear;
  end;
  //创建新点
  if Self.FSePointCurveGSRevise = nil then begin
   	Self.FSePointCurveGSRevise := TPointSeries.Create(Self.HSGraph);
    Self.FSePointCurveGSRevise.ParentChart := Self.HSGraph;
  end else begin
  	Self.FSePointCurveGSRevise.Clear;
  end;        
  FSeLineCurveGSRevise.Marks.Visible := False;
  //画热力过程曲线
  if param.GStype = DBGS then begin
  	//加上调节级的6个点
  	Self.FSePointCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint0.S,TDoubleGoverningStage(param.GS).TDPoint0.H,'',clblue);
  	Self.FSePointCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint1.S,TDoubleGoverningStage(param.GS).TDPoint1.H,'',clblue);
  	Self.FSePointCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint2.S,TDoubleGoverningStage(param.GS).TDPoint2.H,'',clblue);
  	Self.FSePointCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint1a.S,TDoubleGoverningStage(param.GS).TDPoint1a.H,'',clblue);
  	Self.FSePointCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint2a.S,TDoubleGoverningStage(param.GS).TDPoint2a.H,'',clblue);
    Self.FSePointCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint3.S,TDoubleGoverningStage(param.GS).TDPoint3.H,'',clblue);
  	//加上调节级的6个点连成的线
  	Self.FSeLineCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint0.S,TDoubleGoverningStage(param.GS).TDPoint0.H,'',clblue);
  	Self.FSeLineCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint1.S,TDoubleGoverningStage(param.GS).TDPoint1.H,'',clblue);
  	Self.FSeLineCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint2.S,TDoubleGoverningStage(param.GS).TDPoint2.H,'',clblue);
  	Self.FSeLineCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint1a.S,TDoubleGoverningStage(param.GS).TDPoint1a.H,'',clblue);
  	Self.FSeLineCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint2a.S,TDoubleGoverningStage(param.GS).TDPoint2a.H,'',clblue);
    Self.FSeLineCurveGSRevise.Addxy(TDoubleGoverningStage(param.GS).TDPoint3.S,TDoubleGoverningStage(param.GS).TDPoint3.H,'',clblue);
  end else if param.GStype = SBGS then begin
  	//加上调节级的4个点
  	Self.FSePointCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint0.S,TSingleGoverningStage(param.GS).TDPoint0.H,'',clblue);
  	Self.FSePointCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint1.S,TSingleGoverningStage(param.GS).TDPoint1.H,'',clblue);
  	Self.FSePointCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint2.S,TSingleGoverningStage(param.GS).TDPoint2.H,'',clblue);
  	Self.FSePointCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint3.S,TSingleGoverningStage(param.GS).TDPoint3.H,'',clblue);
  	//加上调节级的4个点连成的线
  	Self.FSeLineCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint0.S,TSingleGoverningStage(param.GS).TDPoint0.H,'',clblue);
  	Self.FSeLineCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint1.S,TSingleGoverningStage(param.GS).TDPoint1.H,'',clblue);
  	Self.FSeLineCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint2.S,TSingleGoverningStage(param.GS).TDPoint2.H,'',clblue);
  	Self.FSeLineCurveGSRevise.Addxy(TSingleGoverningStage(param.GS).TDPoint3.S,TSingleGoverningStage(param.GS).TDPoint3.H,'',clblue);
  end;
  for i := 0 to FCurveDivNum do begin
  	Self.FSeLineCurveGSRevise.Addxy(TDPointList[i].S,TDPointList[i].H,'',clblue);
  end;
end;

procedure TFormMainGraphNR.DrawHRSysOut(param : THRSys);
var
	i : integer;
begin
  if Self.FSePointHRSysOut <> nil then
    FreeAndNil(Self.FSePointHRSysOut);

  Self.FSePointHRSysOut := TPointSeries.Create(Self.HSGraph);
  Self.FSePointHRSysOut.ParentChart := Self.HSGraph;

  FSePointHRSysOut.Pointer.Style := psCircle;
  FSePointHRSysOut.Marks.Visible := True;
  FSePointHRSysOut.Marks.BackColor := clRed;

  if (param is THRSysWithDA) then begin
	  for i := 0 to THRSysWithDA(param).ZHR - 1 do begin
		  FSePointHRSysOut.Addxy((param as THRSysWithDA).arrHROutput[i].PTDPointExtraction^.S , (param as THRSysWithDA).arrHROutput[i].PTDPointExtraction^.H,'TDPointExtraction ['+IntToStr(i)+']'+'.P='+Format('%.4f',[(param as THRSysWithDA).arrHROutput[i].PTDPointExtraction^.P]),clred);
    end;
  end else begin
	  for i := 0 to param.ZHR - 1 do begin
		  FSePointHRSysOut.Addxy(param.arrHROutput[i].PTDPointExtraction^.S , param.arrHROutput[i].PTDPointExtraction^.H,'TDPointExtraction ['+IntToStr(i)+']'+'.P='+Format('%.4f',[param.arrHROutput[i].PTDPointExtraction^.P]),clred);
    end;
  end;
end;

procedure TFormMainGraphNR.DrawStageDivOut(param : TStageDiv);
var
	i : integer;
  arrflag : array of integer;
const
  ArrColor : array[0..4] of TColor = (clred, clBlue, clLime, clGreen, clPurple );
begin
  if Self.FSePointStageDivOut <> nil then
    FreeAndNil(Self.FSePointStageDivOut);

  Self.FSePointStageDivOut := TPointSeries.Create(Self.HSGraph);
  Self.FSePointStageDivOut.ParentChart := Self.HSGraph;
  FSePointStageDivOut.Pointer.Style := psCircle;
  FSePointStageDivOut.Marks.Visible := True;
  FSePointStageDivOut.Marks.Style := smsLabel;
  FSePointStageDivOut.Marks.BackColor := clyellow;
	for i := 0 to param.Z-1 do begin
	  FSePointStageDivOut.Addxy(param.arrPostStageTDPoint[i].S, param.arrPostStageTDPoint[i].H,'Post Stage ['+IntToStr(i)+']',clYellow);
  end;
end;

procedure TFormMainGraphNR.DrawCouplingOut(param : TCoupling);
var
	i : integer;
  arrflag : array of integer;
const
  ArrColor : array[0..4] of TColor = (clred, clBlue, clLime, clGreen, clPurple );
begin
  if ((param.Choice = 0) or (param.Choice = 2)) then begin
	  if param.arrNewStageDivOutTDPoint <> nil then begin
	  //new stage div out
	    if Self.FSePointNewStageDivOut <> nil then
	      FreeAndNil(Self.FSePointNewStageDivOut);
	    Self.FSePointNewStageDivOut := TPointSeries.Create(Self.HSGraph);
	    Self.FSePointNewStageDivOut.ParentChart := Self.HSGraph;
	    FSePointNewStageDivOut.Pointer.Style := psDiamond;
	    FSePointNewStageDivOut.Marks.Visible := True;
	    FSePointNewStageDivOut.Marks.Style := smsLabel;
	    FSePointNewStageDivOut.Marks.BackColor := clyellow;
		  for i := 0 to param.Z - 1 do begin
		    FSePointNewStageDivOut.Addxy(param.arrNewStageDivOutTDPoint[i].S, param.arrNewStageDivOutTDPoint[i].H,'New Post Stage ['+IntToStr(i)+']',clYellow);
	    end;
	  end;
  end else if ((param.Choice = 1) or (param.Choice = 2)) then begin
	  if (param.arrNewHRSysOutTDPoint <> nil) or (param.arrNewHRSysWithDAOutTDPoint <> nil) then begin
	  //new HRSys out
	    if Self.FSePointNewHRSysOut <> nil then
	      FreeAndNil(Self.FSePointNewHRSysOut);
	    Self.FSePointNewHRSysOut := TPointSeries.Create(Self.HSGraph);
	    Self.FSePointNewHRSysOut.ParentChart := Self.HSGraph;
	    FSePointNewHRSysOut.Pointer.Style := psDiamond;
	    FSePointNewHRSysOut.Marks.Visible := True;
	    FSePointNewHRSysOut.Marks.Style := smsLabel;
	    FSePointNewHRSysOut.Marks.BackColor := clred;
      if param.arrHRSysWithDAOutTDPoint = nil then begin
		    for i := 0 to param.ZHR - 1 do begin
		      FSePointNewHRSysOut.Addxy(param.arrNewHRSysOutTDPoint[i].S, param.arrNewHRSysOutTDPoint[i].H,'New ExtractionPoint['+IntToStr(i)+']',clRed);
	      end;
      end else begin
		    for i := 0 to param.ZHR - 1 do begin
		      FSePointNewHRSysOut.Addxy(param.arrNewHRSysWithDAOutTDPoint[i].S, param.arrNewHRSysWithDAOutTDPoint[i].H,'New ExtractionPoint['+IntToStr(i)+']',clRed);
	      end;
      end;
    end;
  end; 
end;

procedure TFormMainGraphNR.DrawStageCalOut(param : TList);
var
	i : integer;
  arrflag : array of integer;
const
  ArrColor : array[0..4] of TColor = (clred, clBlue, clLime, clGreen, clPurple );
begin
	//Point
  if Self.FSePointStageCalOut <> nil then
    FreeAndNil(Self.FSePointStageCalOut);

  Self.FSePointStageCalOut := TPointSeries.Create(Self.HSGraph);
  Self.FSePointStageCalOut.ParentChart := Self.HSGraph;
  FSePointStageCalOut.Pointer.Style := psCircle;
  FSePointStageCalOut.Marks.Visible := True;
  FSePointStageCalOut.Marks.Style := smsLabel;
  FSePointStageCalOut.Marks.BackColor := clLime;
  if (aGoverningStage.GSType = SBGS) then begin
  	FSePointStageCalOut.Addxy(TSingleGoverningStage(param.items[0]).TDPoint0.S, TSingleGoverningStage(param.items[0]).TDPoint0.H,'PostStage_P0['+IntToStr(i)+']',clLime);
  	FSePointStageCalOut.Addxy(TSingleGoverningStage(param.items[0]).TDPoint1.S, TSingleGoverningStage(param.items[0]).TDPoint1.H,'PostStage_P1['+IntToStr(i)+']',clLime);
  	FSePointStageCalOut.Addxy(TSingleGoverningStage(param.items[0]).TDPoint2.S, TSingleGoverningStage(param.items[0]).TDPoint2.H,'PostStage_P2['+IntToStr(i)+']',clLime);
		for i := 1 to param.Count - 1 do begin
  		FSePointStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint0.S, TSingleGoverningStage(param.items[i]).TDPoint0.H,'PostStage_P0['+IntToStr(i)+']',clLime);
  		FSePointStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint1.S, TSingleGoverningStage(param.items[i]).TDPoint1.H,'PostStage_P1['+IntToStr(i)+']',clLime);
  		FSePointStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint2.S, TSingleGoverningStage(param.items[i]).TDPoint2.H,'PostStage_P2['+IntToStr(i)+']',clLime);
		end;
  end else if (aGoverningStage.GSType = DBGS) then begin
  	FSePointStageCalOut.Addxy(TDoubleGoverningStage(param.items[0]).TDPoint0.S, TSingleGoverningStage(param.items[0]).TDPoint0.H,'PostStage_P0['+IntToStr(i)+']',clLime);
  	FSePointStageCalOut.Addxy(TDoubleGoverningStage(param.items[0]).TDPoint1.S, TSingleGoverningStage(param.items[0]).TDPoint1.H,'PostStage_P1['+IntToStr(i)+']',clLime);
  	FSePointStageCalOut.Addxy(TDoubleGoverningStage(param.items[0]).TDPoint2.S, TSingleGoverningStage(param.items[0]).TDPoint2.H,'PostStage_P2['+IntToStr(i)+']',clLime);
		for i := 1 to param.Count - 1 do begin
  		FSePointStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint0.S, TSingleGoverningStage(param.items[i]).TDPoint0.H,'PostStage_P0['+IntToStr(i)+']',clLime);
  		FSePointStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint1.S, TSingleGoverningStage(param.items[i]).TDPoint1.H,'PostStage_P1['+IntToStr(i)+']',clLime);
  		FSePointStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint2.S, TSingleGoverningStage(param.items[i]).TDPoint2.H,'PostStage_P2['+IntToStr(i)+']',clLime);
		end;
  end;

  //Line
  if Self.FSeLineStageCalOut <> nil then
  	FreeAndNil(Self.FSeLineStageCalOut);
    
  Self.FSeLineStageCalOut := TLineSeries.Create(Self.HSGraph);
  Self.FSeLineStageCalOut.ParentChart := Self.HSGraph;
  FSeLineStageCalOut.Pointer.Style := psCircle;
  FSeLineStageCalOut.Marks.Visible := False;
  FSeLineStageCalOut.Marks.Style := smsLabel;
  FSeLineStageCalOut.Marks.BackColor := clgreen;
  if (aGoverningStage.GSType = SBGS) then begin
  	FSeLineStageCalOut.Addxy(TSingleGoverningStage(param.items[0]).TDPoint0.S, TSingleGoverningStage(param.items[0]).TDPoint0.H,'',clgreen);
  	FSeLineStageCalOut.Addxy(TSingleGoverningStage(param.items[0]).TDPoint1.S, TSingleGoverningStage(param.items[0]).TDPoint1.H,'',clgreen);
  	FSeLineStageCalOut.Addxy(TSingleGoverningStage(param.items[0]).TDPoint2.S, TSingleGoverningStage(param.items[0]).TDPoint2.H,'',clgreen);
		for i := 1 to param.Count - 1 do begin
  		FSeLineStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint0.S, TSingleGoverningStage(param.items[i]).TDPoint0.H,'',clgreen);
  		FSeLineStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint1.S, TSingleGoverningStage(param.items[i]).TDPoint1.H,'',clgreen);
  		FSeLineStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint2.S, TSingleGoverningStage(param.items[i]).TDPoint2.H,'',clgreen);
		end;
  end else if (aGoverningStage.GSType = DBGS) then begin
  	FSeLineStageCalOut.Addxy(TDoubleGoverningStage(param.items[0]).TDPoint0.S, TSingleGoverningStage(param.items[0]).TDPoint0.H,'',clgreen);
  	FSeLineStageCalOut.Addxy(TDoubleGoverningStage(param.items[0]).TDPoint1.S, TSingleGoverningStage(param.items[0]).TDPoint1.H,'',clgreen);
  	FSeLineStageCalOut.Addxy(TDoubleGoverningStage(param.items[0]).TDPoint2.S, TSingleGoverningStage(param.items[0]).TDPoint2.H,'',clgreen);
		for i := 1 to param.Count - 1 do begin
  		FSeLineStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint0.S, TSingleGoverningStage(param.items[i]).TDPoint0.H,'',clgreen);
  		FSeLineStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint1.S, TSingleGoverningStage(param.items[i]).TDPoint1.H,'',clgreen);
  		FSeLineStageCalOut.Addxy(TPressureStage(param.items[i]).TDPoint2.S, TSingleGoverningStage(param.items[i]).TDPoint2.H,'',clgreen);
		end;
  end;
end;



end.
