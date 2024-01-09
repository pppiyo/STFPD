unit FrmSectionCal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Grids, RzGrids, ActnList, StdCtrls, ExtCtrls, RzPanel,
  ClassSectionCal, Data, VProcess, ClassIteration, ClassIniData, ClassGoverningStage,
  ClassHRSys, ClassHRSysWithDA, ClassStageDiv, ClassCoupling, ClassStageCal;

type
  TFrameSectionCal = class(TFrame)
    GBoxHRBalance: TGroupBox;
    GBoxFinalIndex: TGroupBox;
    RzToolbar1: TRzToolbar;
    BtnClear: TButton;
    BtnRefresh: TButton;
    BtnIteration: TButton;
    BtnCheck: TButton;
    ActionList1: TActionList;
    actRefresh: TAction;
    actClear: TAction;
    actCalculate: TAction;
    actCheck: TAction;
    actIteration: TAction;
    StrGridSectionCal: TRzStringGrid;
    StrGridFinalIndex: TRzStringGrid;
    procedure AfterConstruction; override;
    procedure actRefreshExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actCheckExecute(Sender: TObject);
    procedure actIterationExecute(Sender: TObject);
  private
    { Private declarations }
  	{Visual}
		procedure DrawGrid(param:TSectionCal; Grid:TStringGrid);
    {Data}
    procedure Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSys:THRSys;StageDiv:TStageDiv;Coupling:TCoupling;StageCal:TStageCal);overload;
    procedure Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSysWithDA:THRSysWithDA;StageDiv:TStageDiv;Coupling:TCoupling;StageCal:TStageCal);overload;
    procedure Calculate;
    procedure Check(param : TSectionCal);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TframeSectionCal.AfterConstruction;
begin
  inherited;
  {Data}
  if aHRSys <> nil then begin
    Ini(ainiData,aGoverningStage,aHRSys,aStageDiv,aCoupling,aStageCal);
  end else if aHRSysWithDA <> nil then begin
    Ini(ainiData,aGoverningStage,aHRSysWithDA,aStageDiv,aCoupling,aStageCal);
  end;
  Calculate;
  {Visual}
  DrawGrid(aSectionCal, StrGridSectionCal);
  DrawGrid(aSectionCal, StrGridFinalIndex);
end;

procedure TframeSectionCal.Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSys:THRSys;StageDiv:TStageDiv;Coupling:TCoupling;StageCal:TStageCal);
begin
  if (aStageCal.tag = 1) then begin
	  if aSectionCal = nil then begin
  	  aSectionCal := TSectionCal.Create(iniData,GoverningStage,HRSys,StageDiv,Coupling,StageCal);
    end else begin
      FreeAndNil(aSectionCal);
      aSectionCal := TSectionCal.Create(iniData,GoverningStage,HRSys,StageDiv,Coupling,StageCal);
    end;
  end else begin
    Showmessage('Please finish the last procedure!');
  end;
end;

procedure TframeSectionCal.Ini(IniData:TIniData;GoverningStage:TGoverningStage;
          HRSysWithDA:THRSysWithDA;StageDiv:TStageDiv;Coupling:TCoupling;StageCal:TStageCal);
begin
  if (aStageCal.tag = 1) then begin
	  if aSectionCal = nil then begin
  	  aSectionCal := TSectionCal.Create(iniData,GoverningStage,HRSysWithDA,StageDiv,Coupling,StageCal);
    end else begin
      FreeAndNil(aSectionCal);
      aSectionCal := TSectionCal.Create(iniData,GoverningStage,HRSysWithDA,StageDiv,Coupling,StageCal);
    end;
  end else begin
    Showmessage('Please finish the last procedure!');
  end;
end;


procedure TframeSectionCal.Calculate;
begin
	if aSectionCal <> nil then begin
    aSectionCal.GetarrDHRB;
    aSectionCal.GetarrPHRB;
    aSectionCal.GetPiHRB;
    aSectionCal.GetPaHRB;
    aSectionCal.GetPeHRB;
    aSectionCal.GetdHRB;
    aSectionCal.GetdaHRB;
    aSectionCal.GetqHRB;
    aSectionCal.GetPa;
    aSectionCal.GetPe;
    aSectionCal.GetYitaElHRB;
  end;
end;

procedure TframeSectionCal.Check(param : TSectionCal);
begin
	param.Check;
end;

procedure TframeSectionCal.DrawGrid(param:TSectionCal; Grid:TStringGrid);
const
  SecCalColTitles    : array[0..2] of string = ('Item','Value','Unit');
  FinalIndexColTitles: array[0..2] of string = ('Item','Value','Unit');
  FinalIndexRowTitles: array[0..8] of string = ('Item','Pi','Pa','d','d¡¯','q','¦Çel','Pe','¦Çri');
var
	i : integer;
begin
	if Grid = StrGridSectionCal then begin
  	with Grid do begin
    	ColCount := 3;
      RowCount := 2 * param.ZHRB+1;
      for i := 0 to ColCount-1 do begin
      	Cells[i,0] := SecCalColTitles[i];
      end;
      for i := 1 to param.ZHRB do begin
      	Cells[0,i] := 'D['+Inttostr(i-1)+']';
        Cells[1,i] := format('%.2f',[param.arrDHRB[i-1]]);
        Cells[2,i] := 'kg/s';
      end;
      for i := param.ZHRB+1 to RowCount-1 do begin
        Cells[0,i] := 'P['+IntToStr(i-param.ZHRB-1)+']';
        Cells[1,i] := format('%.2f',[param.arrPHRB[i-param.ZHRB-1]]);
        Cells[2,i] := 'kW';
      end;
    end;
  end;
  if Grid = StrGridFinalIndex then begin
  	with Grid do begin
    	ColCount := 3;
      RowCount := 9;
      for i := 0 to RowCount-1 do begin
      	Cells[0,i] := FinalIndexRowTitles[i];
      end;
      for i := 0 to ColCount-1 do begin
      	Cells[i,0] := FinalIndexColTitles[i];
      end;
      Cells[1,1] := format('%.2f',[param.Pin]);
      Cells[1,2] := format('%.2f',[param.Pa]);
      Cells[1,3] := format('%.2f',[param.dHRB]);
      Cells[1,4] := format('%.2f',[param.daHRB]);
      Cells[1,5] := format('%.2f',[param.qHRB]);
      Cells[1,6] := format('%.2f',[param.YitaElHRB]);
      Cells[1,7] := format('%.2f',[param.Pe]);
      Cells[1,8] := format('%.2f',[param.yitari]);
      Cells[2,1] := 'kW';
      Cells[2,2] := 'kW';
      Cells[2,3] := 'kg/(kWh)';
      Cells[2,4] := 'kg/(kWh)';
      Cells[2,5] := 'kJ/(kWh)';
      Cells[2,6] := '-';
      Cells[2,7] := 'kW';
      Cells[2,8] := '-';
    end;
  end;
end;


procedure TFrameSectionCal.actRefreshExecute(Sender: TObject);
begin
  {Data}
  if aHRSys <> nil then begin
    Ini(ainiData,aGoverningStage,aHRSys,aStageDiv,aCoupling,aStageCal);
  end else if aHRSysWithDA <> nil then begin
    Ini(ainiData,aGoverningStage,aHRSysWithDA,aStageDiv,aCoupling,aStageCal);
  end;
  Calculate;
  {Visual}
  DrawGrid(aSectionCal, StrGridSectionCal);
  DrawGrid(aSectionCal, StrGridFinalIndex);
end;

procedure TFrameSectionCal.actClearExecute(Sender: TObject);
begin
	  ClearAll(Self);
end;

procedure TFrameSectionCal.actCheckExecute(Sender: TObject);
begin
	  Check(aSectionCal);
end;

procedure TFrameSectionCal.actIterationExecute(Sender: TObject);
begin
  if aHRSys <> nil then begin
	  if aIteration = nil then begin
      aIteration := TIteration.Create(aIniData,aGoverningStage,aHRSys,aStageDiv,aCoupling,aStageCal,aSectionCal);
    end else begin
  	  FreeAndNil(aIteration);
      aIteration := TIteration.Create(aIniData,aGoverningStage,aHRSys,aStageDiv,aCoupling,aStageCal,aSectionCal);
    end;
  end else if aHRSysWithDA <> nil then begin
	  if aIteration = nil then begin
      aIteration := TIteration.Create(aIniData,aGoverningStage,aHRSysWithDA,aStageDiv,aCoupling,aStageCal,aSectionCal);
    end else begin
  	  FreeAndNil(aIteration);
      aIteration := TIteration.Create(aIniData,aGoverningStage,aHRSysWithDA,aStageDiv,aCoupling,aStageCal,aSectionCal);
    end;
  end;
end;

end.

