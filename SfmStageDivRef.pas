unit sfmStageDivRef;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzDlgBtn, ValEdit, Grids, TeeProcs, TeEngine, Chart, RzSpnEdt,
  ExtCtrls, RzPanel, StdCtrls, Mask, RzEdit, Series, math, RzButton,
  {added}
  Data, ClassStage, TDPointUtils, VProcess, BasicStructures;

type
  TfmStageDivRef = class(TForm)
    GroupBox5: TGroupBox;
    Editdm1: TRzEdit;
    Pnldm1: TRzPanel;
    Pnldm1overdmz: TRzPanel;
    Editdm1overdmz: TRzEdit;
    Editdmz: TRzEdit;
    Pnldmmid: TRzPanel;
    Editdmmid: TRzEdit;
    PnlCurveAdjParam: TRzPanel;
    PnlDivNum: TRzPanel;
    SpinEditCurveAdjParam: TRzSpinEdit;
    Pnldmz: TRzPanel;
    SpinnerDivNum: TRzSpinner;
    GraphDmCurve: TChart;
    GBoxAutoDiv: TGroupBox;
    StrGridEhtPre1: TStringGrid;
    VLEXaInput: TValueListEditor;
    SpinEditXaRange: TRzSpinEdit;
    GroupBox2: TGroupBox;
    StrGridEhtPre2: TStringGrid;
    VLEXaInput2: TValueListEditor;
    GroupBox4: TGroupBox;
    RzEditEhtbarPre: TRzEdit;
    RzPanelEhtbarPre: TRzPanel;
    RzPanelEhipPre: TRzPanel;
    RzEditEhipPre: TRzEdit;
    RzPanelEhtPPre: TRzPanel;
    RzEditEhtpPre: TRzEdit;
    RzPanelAlphaPre: TRzPanel;
    RzPanelZpre: TRzPanel;
    RzPanelKaPre: TRzPanel;
    RzEditZpre: TRzEdit;
    RzEditKaPre: TRzEdit;
    RzPanelAlphaCheckPre: TRzPanel;
    RzEditAlphaCheckPre: TRzEdit;
    RzEditAlphaPre: TRzEdit;
    RzPanelZPreDummy: TRzPanel;
    RzEditZPreDummy: TRzEdit;
    DBtnStageDiv: TRzDialogButtons;
    GroupBoxGoverningStageInput: TGroupBox;
    PnlEhtGS: TRzPanel;
    PnldmGS: TRzPanel;
    EdtDmGS: TRzEdit;
    EdtEhtGS: TRzEdit;
    PnlXaRange: TRzPanel;
    EdtyitaGS: TRzEdit;
    PnlYitaigsR: TRzPanel;
    EdtEhiGS: TRzEdit;
    PnlEhigsR: TRzPanel;
    CBoxAutoSetXaPre2: TCheckBox;
    CBoxLock: TCheckBox;
    BtnDefault: TRzButton;
    BtnClear: TRzButton;
    MemoStageDivRef: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure DBtnStageDivClickOk(Sender: TObject);
    procedure DBtnStageDivClickCancel(Sender: TObject);
    procedure SpinEditXaRangeChange(Sender: TObject);
    procedure SpinnerDivNumChange(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure DBtnStageDivClickHelp(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure DrawDynGrid(Grid : TStringGrid);
  private
    //input Params
  	EhtGS           : double;
  	dmGS            : double;
    yitaGS          : double;
    EhiGS            : double;
  	dm1             : double;
  	dm1overdmz      : double;
    CurveAdjParam   : double;
  	DivisionNum     : integer;
  	AdjParam        : double;
  	AlphaPre        : double;
  	KaPre           : double;
  	XaRange         : double;
    //? 
    IniDms      : TIniArr;
  	EhtpPre     : double;
    //global Results
    GSPostTDPoint : TTDPoint;
    arrXaPre1     : TDyArray;
    arrDmPre1     : TDyArray;
    arrEhtPre1    : TDyArray;
    //Important Results
    ZPre          : integer;
    //OutputGrid
  	DeltaH        : double;
  	arrXaPre2, arrEht1Pre2, arrEht2Pre2 : TDyArray;
    arrDmPre2     : TDyArray;
  	arrOrderPre2  : array of integer;
    procedure Refresh;
		procedure Ini;
    procedure D2V;
    procedure V2D;
    procedure SaveAndSend(const FileName: TFileName);
    function  GetGSPostTDPoint: TTDPoint;
		function  GetXaPre1Array : TDyArray;
    function  GetDmPre1Array: TDyArray;
    function  GetEhtPre1Array(arrdmPre1, arrXaPre1: TDyArray)  : TDyArray;
    function  GetZPre(arrEhtPre1 : TDyArray) : integer;
    procedure Biz;
    procedure DrawGraph(graph: TComponent);
    procedure DrawDynTable(table: TComponent);
    function  ThreeTDPointsInterpolation2(IniArr : TIniArr; DivNum:Integer): TDyArray;
  public

  end;

var
  fmStageDivRef: TfmStageDivRef;

implementation
	uses frmStageDiv, frmHRSys, fmSTFPD,
    ClassIniData, ClassGoverningStage, ClassHRSys, ClassStageDiv;
{$R *.dfm}
procedure TfmStageDivRef.Ini;
begin
	if aGoverningStage.GStype = SBGS then begin
	  EhtGS 	 := TSingleGoverningStage(aGoverningStage.GS).Eht;
    dmGS 	   := TSingleGoverningStage(aGoverningStage.GS).dm;
    yitaGS   := TSingleGoverningStage(aGoverningStage.GS).yitaI;
    EhiGS    := TSingleGoverningStage(aGoverningStage.GS).Ehi;
  end else if aGoverningStage.GStype = DBGS then begin
	  EhtGS 	 := TDoubleGoverningStage(aGoverningStage.GS).Eht;
    dmGS 	   := TDoubleGoverningStage(aGoverningStage.GS).dm;
    yitaGS   := TDoubleGoverningStage(aGoverningStage.GS).yitaI;
    EhiGS    := TDoubleGoverningStage(aGoverningStage.GS).Ehi;
  end else begin
	  EhtGS 	 := 0 ;
    dmGS 		 := 0 ;
    yitaGS   := 0 ;
    EhiGS    := 0 ;
  end;
	dm1     							:= 610	;
  dm1overdmz    				:= 0.75 ;
	DivisionNum           := 6;
  CurveAdjParam         := 0.03;
  AlphaPre              := 0.08;
  KaPre                 := 0.16;
  XaRange               := 0.486;
end;

procedure TfmStageDivRef.FormCreate(Sender: TObject);
var
	i : integer;
begin
{ClearAll}
 ClearAll(Self);
{Data}
	Ini;
{Visual}
	Self.SetBounds(formSTFPD.Width,0,Self.Width,Self.Height);
  GraphDmCurve.tag   := 0;
  VLEXaInput.tag     := 0;
  StrGridEhtPre1.tag := 0;
  CBoxAutoSetXaPre2.Checked := True;
  CBoxLock.Checked          := False;
  DBtnStageDiv.BtnOK.Caption     := 'Calculate';
  DBtnStageDiv.BtnHelp.Caption   := 'Exit';
  DBtnStageDiv.BtnCancel.Caption := 'Save';
  MemoStageDivRef.Clear;
{Data-Visual}
  D2V;
  DrawGraph(GraphDmCurve);
  DrawDynTable(VLEXaInput);
  DrawDynTable(StrGridEhtPre1);
end;

procedure TfmStageDivRef.Refresh;
begin
    DivisionNum := SpinnerDivNum.Value;
		XaRange     := SpinEditXaRange.Value;
end;

procedure TfmStageDivRef.DrawGraph(graph: TComponent);
begin
  //图整理
  	GraphDmCurve.Legend.Visible       := False;
		GraphDmCurve.View3D               := False;
  	GraphDmCurve.LeftAxis.Maximum     := 1500;
  	GraphDmCurve.LeftAxis.Minimum     := 200;
  	GraphDmCurve.BottomAxis.Automatic := True; //自动调整坐标轴大小
  	GraphDmCurve.AnimatedZoomSteps    := 1;
end;

procedure TfmStageDivRef.V2D;
begin
		EhtGS         	:=   StrToFloat(EdtEhtGS.Text 	     );
		dmGS            :=   StrToFloat(EdtdmGS.Text 		     );
    yitaGS          :=   StrToFloat(EdtyitaGS.Text 	     );
    EhiGS           :=   StrToFloat(EdtEhiGS.Text 	       );
		dm1           	:=   StrToFloat(Editdm1.Text 				 );
		dm1overdmz      :=   StrToFloat(Editdm1overdmz.Text	 );
    CurveAdjParam   :=   SpinEditCurveAdjParam.Value      ;
		DivisionNum     :=   SpinnerDivNum.Value              ;
		AlphaPre        :=   StrToFloat(RzEditAlphaPre.Text  );
		KaPre           :=   StrToFloat(RzEditKaPre.Text     );
		XaRange         :=   SpinEditXaRange.Value            ;
end;

procedure TfmStageDivRef.D2V;
begin
		EdtEhtGS.Text         	    := format('%.2f' , [EhtGS]);
		EdtdmGS.Text                := format('%.2f' , [dmGS]);
		EdtyitaGS.Text         	    := format('%.2f' , [yitaGS]);
		EdtEhiGS.Text                := format('%.2f' , [EhiGS]);
    Editdm1.Text                := format('%.2f' , [dm1]);
    Editdm1overdmz.Text         := format('%.2f' , [dm1overdmz]);
  	SpinEditCurveAdjParam.Value := CurveAdjParam;
    SpinnerDivNum.Value         := DivisionNum;
		RzEditAlphaPre.Text         := format('%.2f' , [AlphaPre]);
		RzEditKaPre.Text            := format('%.2f' , [KaPre]);
		SpinEditXaRange.Value       := XaRange;
end;

procedure TfmStageDivRef.SaveAndSend(const FileName: TFileName);
var
 	f: TextFile;
 	i, k: Integer;
begin
	V2D;
 	AssignFile(f, FileName);
 	Rewrite(f);

// Save Input params to a file
  Writeln(f, '[dm1]');
  Writeln(f, dm1);
  Writeln(f, '[dm1overdmz]');
  Writeln(f, dm1overdmz);
  Writeln(f, '[CurveAdjParam]');
  Writeln(f, CurveAdjParam);
  Writeln(f, '[DivisionNum]');
  Writeln(f, DivisionNum);
  Writeln(f, '[AlphaPre]');
  Writeln(f, AlphaPre);
  Writeln(f, '[KaPre]');
  Writeln(f, KaPre);
  Writeln(f, '[XaRange]');
  Writeln(f, XaRange);

// Save Output Params to a file
  Writeln(f, '[ZPre]');
  Writeln(f, ZPre);

// Save a TStringGrid to a file
  Writeln(f, '[StrGridEhtPre2]');
 	with StrGridEhtPre2 do begin
   // Write number of Columns/Rows
   	Writeln(f, RowCount);
   	Writeln(f, ColCount);
   // loop through cells
   	for k := 0 to RowCount - 1 do
     	for i := 0 to ColCount - 1 do
       	Writeln(F, Cells[i, k]);
 	end;
 	CloseFile(F);
  {改写成转置表格，方便读入时配合界面设计}
  //StrGridEhtPre2.Rows[1].Add('Text');
end;

procedure TfmStageDivRef.DrawDynTable(table: TComponent);
var
	i : integer;
  str: string;
begin
	Randomize;
	if table.Name = 'VLEXaInput' then begin
  	if VLEXaInput.tag = 0 then begin
  	  with VLEXaInput do begin
  	    VLEXaInput.Strings.Clear;
  	  	Options := Options + [goEditing];
  	 		for i := 0 to SpinnerDivNum.Value do begin
  	       InsertRow('xa[ '+ InttoStr(i+1) +' ]',FloatToStr(-Random(10)*0.001+Random(10)*0.001+SpinEditXaRange.Value),true);
  	    end;
  	    Height := DefaultRowHeight * (RowCount+1);
  	    tag := tag+1;
  	 	end;
  	 end else if VLEXaInput.tag > 0 then begin
     	with VLEXaInput do begin
  	    VLEXaInput.Strings.Clear;
  	  	Options := Options + [goEditing];
  	 		for i := 0 to SpinnerDivNum.Value do begin
  	       InsertRow('xa[ '+ InttoStr(i+1) +' ]',FloatToStr(-Random(10)*0.001+Random(10)*0.001+XaRange),true);
  	    end;
  	    Height := DefaultRowHeight * (RowCount+1);
  	    tag := tag+1;
  	 	end;
     end;
	end;
	if table.Name = 'StrGridEhtPre1' then begin
  	//画表格
  	 with StrGridEhtPre1 do begin
     	if tag = 0 then begin
  	  	Options := Options + [goColSizing];
  	    FixedCols := 0;
  	    FixedRows := 1;
  	  	RowCount := SpinnerDivNum.Value + 2;//fixed
  	    ColCount := 4;
  	    Width  := DefaultColWidth * (ColCount+1);
        Cells[0,0] := 'Num';
  	 		Cells[1,0] := 'dm';
  	 		Cells[2,0] := 'xa';
  	 		Cells[3,0] := 'Δht';
        tag := tag + 1;
      end else if tag > 0 then begin
        for i := RowCount downto 1 do begin
        	RowCount := RowCount-1;
        end;
        ClearAll(StrGridEhtPre1);
  	  	Options := Options + [goColSizing];
  	  	RowCount := DivisionNum + 2;//fixed
  	    ColCount := 4;
  	    Height := DefaultRowHeight * (RowCount+1);
  	    Width  := DefaultColWidth * (ColCount+1);
  	    FixedCols := 0;
  	    FixedRows := 1;
        Cells[0,0] := 'Num';
  	 		Cells[1,0] := 'dm';
  	 		Cells[2,0] := 'xa';
  	 		Cells[3,0] := 'Δht';
        tag := tag + 1;
      end;
  	 end;
  end;
	if table.Name = 'VLEXaInput2' then begin
  	if CBoxAutoSetXaPre2.Checked = True then begin
   		with VLEXaInput2 do begin
   		  Strings.Clear;
   		  Options := Options + [goEditing];
   		  for i := 0 to ZPre-1 do begin
   		    InsertRow('xa[ '+ InttoStr(i+1) +' ]',FloatToStr(-Random(10)*0.001+Random(10)*0.001+SpinEditXaRange.Value),true);
   		  end;
   		  Setfocus;
   		  tag := tag + 1; //no need for tag
      end;
    end else begin
   		with VLEXaInput2 do begin
   		  Strings.Clear;
   		  Options := Options + [goEditing];
   		  for i := 0 to ZPre-1 do begin
        	str := InputBox('输入Xa序列', '请输入Xa['+inttostr(i)+']', floattostr(-Random(10)*0.001+Random(10)*0.001+SpinEditXaRange.Value));
   		    InsertRow('xa[ '+ InttoStr(i+1) +' ]',str,true);
   		  end;
   		  Height := DefaultRowHeight * (RowCount+1);
   		  Setfocus;
   		  tag := tag + 1; //no need for tag
      end;
    end;
  end;
	if table.Name = 'StrGridEhtPre2' then begin
  	if StrGridEhtPre2.tag = 0 then begin
     	with StrGridEhtPre2 do begin
    		Options := Options + [goColSizing];
      	FixedCols := 0;
      	FixedRows := 1;
     		RowCount := ZPre + 1;//fixed
      	ColCount := 6;
      	Width  := DefaultColWidth * (ColCount+1);
        ScrollBars := ssVertical;
   			Cells[0,0] := 'Order';
      	Cells[1,0] := 'dm';
      	Cells[2,0] := 'xa';
      	Cells[3,0] := '(Δht)';
      	Cells[4,0] := 'ΔH';
      	Cells[5,0] := 'Δht';
      	tag := tag + 1;
     	end;
    end else if StrGridEhtPre2.tag > 0 then begin
    	with StrGridEhtPre2 do begin
        for i := RowCount downto 1 do begin
        	RowCount := RowCount-1;
        end;
        ClearAll(StrGridEhtPre2);
     		RowCount  := ZPre + 1;//fixed
      	ColCount  := 6;
      	Width     := DefaultColWidth * (ColCount+1);
    		Options   := Options + [goColSizing];
        ScrollBars := ssVertical;
      	FixedCols := 0;
      	FixedRows := 1;
   			Cells[0,0] := 'Order';
      	Cells[1,0] := 'dm';
      	Cells[2,0] := 'xa';
      	Cells[3,0] := '(Δht)';
      	Cells[4,0] := 'ΔH';
      	Cells[5,0] := 'Δht';
      	tag := tag + 1;
    		for i := 0 to ZPre-1 do begin
        	Cells[0,i+1] := IntToStr(arrOrderPre2[i]);
        	Cells[1,i+1] := format('%.2f',[arrdmPre2[i]]);
        	Cells[2,i+1] := format('%.3f',[arrXaPre2[i]]);
        	Cells[3,i+1] := format('%.2f',[arrEht1Pre2[i]]);
        	Cells[5,i+1] := format('%.2f',[arrEht2Pre2[i]]);
      	end;
      	Cells[4,1]   := format('%.2f',[DeltaH]);
      end;
    end;
  end;
end;

procedure TfmStageDivRef.SpinEditXaRangeChange(Sender: TObject);
begin
	Refresh;
  DrawDynTable(VLEXaInput);
end;

procedure TfmStageDivRef.SpinnerDivNumChange(Sender: TObject);
begin
	Refresh;
  DrawDynTable(VLEXaInput);
end;

function TfmStageDivRef.GetGSPostTDPoint : TTDPoint;
var
  EhigsR : double;
  yitaigsR : double;
	flag : integer;
  TDPoint2gsR : TTDPoint;
begin
  if aGoverningStage <> nil then begin
  	if aGoverningStage.GStype = SBGS then begin
    	Result := TSingleGoverningStage(aGoverningStage.GS).TDPoint3;//test aGoverningStage.GS.TDPoint3;
    end else if aGoverningStage.GStype = DBGS then begin
      Result := TDoubleGoverningStage(aGoverningStage.GS).TDPoint3;//test aGoverningStage.GS.TDPoint3;
    end else begin
      Result := MainTDPoint0a;
    end;
  end;
end;

function TfmStageDivRef.GetDmPre1Array : TDyArray;
var
	dmz, dmmid : double;
  DmCurveSerie : TLineSeries;
  i : integer;
begin
   //赋初始值
  	dmz 												:= dm1/dm1overdmz;
  	dmmid 											:= (dm1+dmz)/2*(1-CurveAdjParam);
    //显示
    Editdmz.Clear;
		Editdmz.Text    					:= FloatToStr(dmz);
    Editdmmid.Clear;
		Editdmmid.Text   					:= FloatToStr(dmmid);
		//三点画曲线
    DivisionNum    					  := SpinnerDivNum.Value;
    SetLength(Result,DivisionNum+1);
    //TDPointMid
  	IniDms[0] := dm1;    IniDms[1] := dmmid;     IniDms[2] := dmz;
  	Result  := ThreeTDPointsInterpolation2(IniDms, DivisionNum);
		//输出图形
    for i := 0 to GraphDmCurve.SeriesCount-1 do begin
      GraphDmCurve.Series[i].Clear;
    end;
    DmCurveSerie := TLineSeries.Create(GraphDmCurve);
    GraphDmCurve.AddSeries(DmCurveSerie);
    with DmCurveSerie do begin
      for i := 0 to DivisionNum do begin
      	Addxy(i,Result[i],' ',clBlue);
      end;
    end;
    GraphDmCurve.tag := GraphDmCurve.tag+1;
end;

function TfmStageDivRef.GetXaPre1Array : TDyArray;
var
	i : integer;
begin
	SetLength(Result , DivisionNum + 1);
  for i := 0 to DivisionNum do begin
		Result[i] :=  StrToFloat(VLEXaInput.Values[VLEXaInput.Keys[i+1]]);
  end;
end;

function TfmStageDivRef.GetEhtPre1Array(arrdmPre1, arrXaPre1: TDyArray) : TDyArray;
var
  i : integer;
begin
  SetLength(Result,DivisionNum+1);
  //自动赋值的表列
  for i := 0 to DivisionNum do begin
    Result[i]:=  power((pi*aIniData.BasicData.n*arrdmPre1[i]/1000)/60/arrXaPre1[i],2)/2000;
  end;
end;

function TfmStageDivRef.GetZPre(arrEhtPre1: TDyArray) : integer;
var
  i : integer;
  EhtBarPre : double;
  EhipPre : double; 
  ZPreDummy : double;
  AlphaCheckPre : double;
begin
    //预设计参数
    EhtBarPre := sum(arrEhtPre1)/(DivisionNum+1);

    EhipPre	:=  GSPostTDPoint.H - TDPointList[High(TDPointList)].H;
    EhtpPre :=  GSPostTDPoint.H - PSGetTDPoint(TDPointList[High(TDPointList)].P, GSPostTDPoint.S).H;

    ZPreDummy := (1 + AlphaPre) * EhtpPre / EhtBarPre;
    ZPre      := Round(ZPreDummy);
    Result    := ZPre;

    AlphaCheckPre := KaPre*(1-EhiPPre/EhtpPre)*EhtpPre/419*(ZPre-1)/ZPre;
    //显示
    RzEditEhtBarPre.Clear;
    RzEditEhtBarPre.Text := format('%.2f' , [EhtBarPre]);
    RzEditEhipPre.Clear;
    RzEditEhipPre.Text   := format('%.2f' , [EhipPre]);
    RzEditEhtpPre.Clear;
    RzEditEhtpPre.Text   := format('%.2f' , [EhtpPre]);
    RzEditZPreDummy.Clear;
    RzEditZPreDummy.Text := format('%.2f' , [ZPreDummy]);
    RzEditZPre.Clear;
    RzEditZPre.Text      := format('%d', [ZPre]);
    RzEditAlphaCheckPre.Clear;
    RzEditAlphaCheckPre.Text := format('%.2f' , [AlphaCheckPre]);
    //表格
    if CBoxLock.Checked = False then begin
    	DrawDynTable(VLEXaInput2);
    end;
end;

procedure TfmStageDivRef.Biz;
var 
	St, arrStagePostPre : array of TTDPoint;
  arrFlag : array of integer; 
  tmpdeltaH : double;
  i : integer;
begin
	V2D;

  GSPostTDPoint := GetGSPostTDPoint;
  arrXaPre1     := GetXaPre1Array;
  arrDmPre1     := GetdmPre1Array;
  arrEhtPre1    := GetEhtPre1Array(arrDmPre1, arrXaPre1);
  DrawDynGrid(StrGridEhtPre1);

  ZPre          := GetZPre(arrEhtPre1);

	if ZPre >= 2 then begin
	 	//动态建立表格
   	DrawDynTable(StrGridEhtPre2);

   	SetLength(arrOrderPre2, ZPre);
   	for i := 0 to ZPre - 1 do begin
   		arrOrderPre2[i] := i+1;
   	end;

   	SetLength(arrDmPre2, ZPre);
   	arrDmPre2  := ThreeTDPointsInterpolation2(IniDms, ZPre-1);

   	SetLength(arrXaPre2,ZPre);
   	for i := 0 to ZPre-1 do begin
   		arrXaPre2[i] := StrToFloat(VLEXaInput2.Values[VLEXaInput2.Keys[i+1]]);
   	end;
     
   	SetLength(arrEht1Pre2, ZPre);
   	for i := 0 to ZPre-1 do begin
      arrEht1Pre2[i] := power((pi*aIniData.BasicData.n * arrdmPre2[i]/1000)/60/arrXaPre2[i],2)/2000;
   	end;

   	DeltaH := EhtpPre *(1 + AlphaPre) - sum(arrEht1Pre2);

   	SetLength(arrEht2Pre2, ZPre);
   	for i := 0 to ZPre-1 do begin
   		arrEht2Pre2[i] := arrEht1Pre2[i] + DeltaH/ZPre;
   	end;
   
   	//输出显示
	 	DrawDynTable(StrGridEhtPre2);

   	//回查点在近似热力曲线哪里
   	//通过级后反查抽汽点
	 	SetLength(arrFlag, ZPre+1);
   	SetLength(arrStagePostPre, ZPre+1);
   	SetLength(St, ZPre);
   	arrStagePostPre[0] := GSPostTDPoint;
    arrFlag[0] := SeekTDPointPositionByP(GSPostTDPoint.P, TDPointList);
    MemoStageDivRef.Lines.Add('TDPoint Position on TDCurve:  '+Inttostr(arrFlag[0]));
   	for i := 0 to ZPre-1 do begin
   		St[i] := HSGetTDPoint((arrStagePostPre[i].H - arrEht2Pre2[i]) , arrStagePostPre[i].S);
   	 	arrFlag[i+1] := SeekTDPointPositionByP(St[i].P, TDPointList);
			arrStagePostPre[i+1] := TDPointList[arrFlag[i+1]];//可以用插值法做成更精确的返回值
      MemoStageDivRef.Lines.Add('TDPoint Position on TDCurve:  '+IntToStr(arrFlag[i+1]));
   	end;

    //焓降分配最后一级与预订排汽点不重合处理(迭代)
    if arrFlag[ZPre] < Length(TDPointList)-1 then begin
    	repeat
    			tmpdeltaH := TDPointList[arrFlag[ZPre]].H - TDPointList[High(TDPointList)].H;
    		  MemoStageDivRef.Lines.Add('多余焓降'+Floattostr(tmpdeltaH));
    			if tmpdeltaH > 0 then begin
   					for i := 0 to ZPre-1 do begin
   						arrEht2Pre2[i] := arrEht2Pre2[i] + tmpdeltaH/ZPre;//存在多余焓降则自动平均分配
   					end;
    		  	MemoStageDivRef.Lines.Add('多余焓降已自动处理');
    			end;
    			//重载输出表格
    			DrawDynTable(StrGridEhtPre2);
    			//新一轮值查点显示
    			MemoStageDivRef.Lines.Add('TDPoint Position on TDCurve:  '+Inttostr(arrFlag[0]));
   				for i := 0 to ZPre-1 do begin
   					St[i] := HSGetTDPoint((arrStagePostPre[i].H - arrEht2Pre2[i]) , arrStagePostPre[i].S);
   			 		arrFlag[i+1] := SeekTDPointPositionByP(St[i].P, TDPointList);
						arrStagePostPre[i+1] := TDPointList[arrFlag[i+1]];//可以用插值法做成更精确的返回值
    		  	MemoStageDivRef.Lines.Add('TDPoint Position on TDCurve:  '+IntToStr(arrFlag[i+1]));
    		  end;
    	until
    		arrFlag[ZPre] = Length(TDPointList)-1
   	end;

	end else
 		Showmessage('Check again!');//for safety concerns
end;

procedure TfmStageDivRef.DrawDynGrid(Grid : TStringGrid);
var
	i : integer;
begin
  if Grid = StrGridEhtPre1 then begin
  	with StrGridEhtPre1 do begin
  		for i := 0 to DivisionNum do begin
  			Cells[0,i+1] := format('%d' , [i+1]);
    		Cells[1,i+1] := format('%.2f' , [arrDmPre1[i]]);
    		Cells[2,i+1] := format('%.3f' , [arrXaPre1[i]]);
    		Cells[3,i+1] := format('%.2f' , [arrEhtPre1[i]]);
  		end;
    end;
  end;
end;

procedure TfmStageDivRef.DBtnStageDivClickCancel(Sender: TObject);
begin
	SaveAndSend('TextStageDivOut.txt');
end;

procedure TfmStageDivRef.DBtnStageDivClickOk(Sender: TObject);
begin
	Biz;
end;

function  TfmStageDivRef.ThreeTDPointsInterpolation2(IniArr : TIniArr; DivNum:Integer): TDyArray;
var
  i : integer;
begin
  SetLength( Result , DivNum + 1 );
  for i := 0 to DivNum do begin
  		Result[i] :=
    							IniArr[0] *
    							(i - DivNum/2)*
                  (i - DivNum)/
    							(0 - DivNum/2)/
                  (0 - DivNum)+
    							IniArr[1] *
    							(i - 0)*
                  (i - DivNum)/
    							(DivNum/2 - 0)/
                  (DivNum/2 - DivNum)+
    							IniArr[2] *
    							(i - 0)*
                  (i - DivNum/2)/
    							(DivNum - 0)/
                  (DivNum - DivNum/2);
  end;
end;

procedure TfmStageDivRef.btnDefaultClick(Sender: TObject);
begin
  ClearAll(Self);
	Ini;
  D2V;
end;

procedure TfmStageDivRef.DBtnStageDivClickHelp(Sender: TObject);
begin
	Close;
end;

procedure TfmStageDivRef.BtnClearClick(Sender: TObject);
begin
	ClearAll(Self);
end;


end.

