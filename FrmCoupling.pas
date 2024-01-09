unit FrmCoupling;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ActnList, StdCtrls, ExtCtrls, Grids, RzPanel,
  ClassCoupling, Data;

type
  TFrameCoupling = class(TFrame)
    RzToolbar1: TRzToolbar;
    BtnRefresh: TButton;
    BtnDefault: TButton;
    BtnConfirmBase: TButton;
    BtnAutoRevise: TButton;
    BtnDrawHSGraph: TButton;
    Panel1: TPanel;
    GBoxHRSysOut: TGroupBox;
    StrGridHRSysOutTDPoint: TStringGrid;
    GBoxStageDivOut: TGroupBox;
    StrGridStageDivOutTDPoint: TStringGrid;
    RGrpAdjBase: TRadioGroup;
    GBoxSuggestion: TGroupBox;
    MemoDivChangeSug: TMemo;
    ActionList1: TActionList;
    actChooseAdjBase: TAction;
    actRefresh: TAction;
    actDrawCouplingOut: TAction;
    actDefault: TAction;
    actAutoRevise: TAction;
    StrGridNewHRSysOutTDPoint: TStringGrid;
    StrGridNewStageDivOutTDPoint: TStringGrid;
    procedure AfterConstruction; override;
    procedure actChooseAdjBaseExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actDrawCouplingOutExecute(Sender: TObject);
    procedure actDefaultExecute(Sender: TObject);
    procedure actAutoReviseExecute(Sender: TObject);
  private
    { Visual }
    procedure DrawDynGrid(param: TCoupling; Grid: TStringGrid);
    { Data }
    procedure Ini;
  end;

implementation

uses MainGraphNR;

{$R *.dfm}

procedure TFrameCoupling.Ini;
begin
  if aStageDiv.tag = 1 then begin
  	if aHRSys <> nil then begin
  	  if aCoupling = nil then begin
  		  aCoupling := TCoupling.Create(aIniData, aGoverningStage, aHRSys, aStageDiv);
  	    aCoupling.CheckOriData;
  	  end else begin
  		  FreeAndNil(aCoupling);
  		  aCoupling := TCoupling.Create(aIniData, aGoverningStage, aHRSys, aStageDiv);
  	    aCoupling.CheckOriData;
  	  end;
  	end else if aHRSysWithDA <> nil then begin
  	  if aCoupling = nil then begin
  		  aCoupling := TCoupling.Create(aIniData, aGoverningStage, aHRSysWithDA, aStageDiv);
  	    aCoupling.CheckOriData;
  	  end else begin
  		  FreeAndNil(aCoupling);
  		  aCoupling := TCoupling.Create(aIniData, aGoverningStage, aHRSysWithDA, aStageDiv);
  	    aCoupling.CheckOriData;
  	  end;
    end;
  end else begin
    Showmessage('Last step not finished yet!');
  end;
end;

procedure TFrameCoupling.AfterConstruction;
begin
  inherited;
  {Data}
  Ini;
  {Visual}
  BtnDrawHSGraph.Enabled := False;
  BtnAutoRevise.Enabled  := False;
  RGrpAdjBase.ItemIndex := -1;
  MemoDivChangeSug.Lines.Clear;
  DrawDynGrid(aCoupling, StrGridHRSysOutTDPoint);
  DrawDynGrid(aCoupling, StrGridStageDivOutTDPoint);
end;

procedure TFrameCoupling.DrawDynGrid(param: TCoupling; Grid: TStringGrid);
var
	i : integer;
const
  ItemColTitles    : array[0..4] of string = ('P','H','S','T','X');
begin
  if Grid.Name = 'StrGridHRSysOutTDPoint' then begin
  	with Grid do begin
      Visible := True;
      StrGridNewHRSysOutTDPoint.Hide;
      BringToFront;
  		FixedCols := 1;
  	  FixedRows := 0;
  	  RowCount  := 6;
  	  ColCount  := param.ZHR + 1;
      //第一列显示（PHSTX）
      Cells[0,0] := 'ZHR';
  		for i := 1 to RowCount-1 do begin
   			Cells[0,i] := ItemColTitles[i-1];          
   		end;
      //第一行显示（12345..）
      for i := 1 to ColCount-1 do begin
  	      Cells[i,0] := IntToStr(i);
  	  end;
      //按列填入热力点信息
      for i := 1 to ColCount-1 do begin
        if param.arrHRSysOutTDPoint <> nil then begin
          Cells[i,1] := format('%.3f',[param.arrHRSysOutTDPoint[i-1].P]);
          Cells[i,2] := format('%.2f',[param.arrHRSysOutTDPoint[i-1].H]);
          Cells[i,3] := format('%.2f',[param.arrHRSysOutTDPoint[i-1].S]);
          Cells[i,4] := format('%.2f',[param.arrHRSysOutTDPoint[i-1].T]);
          Cells[i,5] := format('%.2f',[param.arrHRSysOutTDPoint[i-1].X]);
        end else begin
          Cells[i,1] := format('%.3f',[param.arrHRSysWithDAOutTDPoint[i-1].P]);
          Cells[i,2] := format('%.2f',[param.arrHRSysWithDAOutTDPoint[i-1].H]);
          Cells[i,3] := format('%.2f',[param.arrHRSysWithDAOutTDPoint[i-1].S]);
          Cells[i,4] := format('%.2f',[param.arrHRSysWithDAOutTDPoint[i-1].T]);
          Cells[i,5] := format('%.2f',[param.arrHRSysWithDAOutTDPoint[i-1].X]);
        end;
      end;
  	end;
  end;
  if Grid.Name = 'StrGridNewHRSysOutTDPoint' then begin
  	with StrGridHRSysOutTDPoint do begin//刷新列表
      Visible := True;
      StrGridNewHRSysOutTDPoint.Hide;
      BringToFront;
  		FixedCols := 1;
  	  FixedRows := 0;
  	  RowCount  := 6;
  	  ColCount  := param.ZHR + 1;
      //第一列显示（PHSTX）
      Cells[0,0] := 'ZHR';
  		for i := 1 to RowCount-1 do begin
   			Cells[0,i] := ItemColTitles[i-1];          
   		end;
      //第一行显示（12345..）
      for i := 1 to ColCount-1 do begin
  	      Cells[i,0] := IntToStr(i);
  	  end;
      //按列填入热力点信息
      for i := 1 to ColCount-1 do begin
        if param.arrHRSysOutTDPoint <> nil then begin
          Cells[i,1] := format('%.3f',[param.arrNewHRSysOutTDPoint[i-1].P]);
          Cells[i,2] := format('%.2f',[param.arrNewHRSysOutTDPoint[i-1].H]);
          Cells[i,3] := format('%.2f',[param.arrNewHRSysOutTDPoint[i-1].S]);
          Cells[i,4] := format('%.2f',[param.arrNewHRSysOutTDPoint[i-1].T]);
          Cells[i,5] := format('%.2f',[param.arrNewHRSysOutTDPoint[i-1].X]);
        end else begin
          Cells[i,1] := format('%.3f',[param.arrNewHRSysWithDAOutTDPoint[i-1].P]);
          Cells[i,2] := format('%.2f',[param.arrNewHRSysWithDAOutTDPoint[i-1].H]);
          Cells[i,3] := format('%.2f',[param.arrNewHRSysWithDAOutTDPoint[i-1].S]);
          Cells[i,4] := format('%.2f',[param.arrNewHRSysWithDAOutTDPoint[i-1].T]);
          Cells[i,5] := format('%.2f',[param.arrNewHRSysWithDAOutTDPoint[i-1].X]);
        end;
      end;
  	end;
  end;
  if Grid.Name = 'StrGridStageDivOutTDPoint' then begin
  	with Grid do begin
      Visible := True;
      BringToFront;
  		FixedCols := 1;
  	  FixedRows := 1;
  	  RowCount  := 6;
  	  ColCount  := param.Z + 1;
      //第一列显示（PHSTX）
      Cells[0,0] := 'Z';
  		for i := 1 to RowCount-1 do begin
   			Cells[0,i] := ItemColTitles[i-1];
   		end;
      //第一行显示（12345..）
      for i := 1 to ColCount-1 do begin
  	    Cells[i,0] := IntToStr(i);
  	  end;
      for i := 1 to ColCount-1 do begin
        Cells[i,1] := format('%.3f',[param.arrStageDivOutTDPoint[i-1].P]);
        Cells[i,2] := format('%.2f',[param.arrStageDivOutTDPoint[i-1].H]);
        Cells[i,3] := format('%.2f',[param.arrStageDivOutTDPoint[i-1].S]);
        Cells[i,4] := format('%.2f',[param.arrStageDivOutTDPoint[i-1].T]);
        Cells[i,5] := format('%.2f',[param.arrStageDivOutTDPoint[i-1].X]);
      end;
  	end;
  end;
  if Grid.Name = 'StrGridNewStageDivOutTDPoint' then begin
  	with StrGridStageDivOutTDPoint do begin
      //StrGridStageDivOutTDPoint.Destroy;
      //StrGridStageDivOutTDPoint.Create(Self);
      Visible := True;
      BringToFront;
  		FixedCols := 1;
  	  FixedRows := 1;
  	  RowCount  := 6;
  	  ColCount  := param.Z + 1;
      //第一列显示（PHSTX）
      Cells[0,0] := 'Z';
  		for i := 1 to RowCount-1 do begin
   			Cells[0,i] := ItemColTitles[i-1];
   		end;
      //第一行显示（12345..）
      for i := 1 to ColCount-1 do begin
  	    Cells[i,0] := IntToStr(i);
  	  end;
      for i := 1 to ColCount-1 do begin
        Cells[i,1] := format('%.3f',[param.arrNewStageDivOutTDPoint[i-1].P]);
        Cells[i,2] := format('%.2f',[param.arrNewStageDivOutTDPoint[i-1].H]);
        Cells[i,3] := format('%.2f',[param.arrNewStageDivOutTDPoint[i-1].S]);
        Cells[i,4] := format('%.2f',[param.arrNewStageDivOutTDPoint[i-1].T]);
        Cells[i,5] := format('%.2f',[param.arrNewStageDivOutTDPoint[i-1].X]);
      end;
  	end;
  end;
end;

procedure TFrameCoupling.actChooseAdjBaseExecute(Sender: TObject);
var
  i : integer;
begin
	if RGrpAdjBase.ItemIndex = -1 then begin
  	Showmessage('Please Choose A Coupling Method!');
  end else if RGrpAdjBase.ItemIndex = 0 then begin
    aCoupling.CoupleByHRSysSuggestions;
    //DrawDynGrid(aCoupling, StrGridNewStageDivOutTDPoint);
    MemoDivChangeSug.Lines.Clear;
    MemoDivChangeSug.Lines.add('Revise Suggestions Based On Maintaining Heat Regeneration System Generated, See Graph');
    BtnDrawHSGraph.Enabled := True;
  	BtnAutoRevise.Enabled  := True;
  end else if RGrpAdjBase.ItemIndex = 1 then begin
    aCoupling.CoupleByStageDivSuggestions;
    DrawDynGrid(aCoupling, StrGridNewHRSysOutTDPoint);
    MemoDivChangeSug.Lines.Clear;
    MemoDivChangeSug.Lines.add('Revise Suggestions Based On Maintaining Stage Distribution System Generated, See Graph');
    BtnDrawHSGraph.Enabled := True;
  	BtnAutoRevise.Enabled  := True;   
  end else if RGrpAdjBase.ItemIndex = 2 then begin
    aCoupling.CoupleByBothSuggestions;
    DrawDynGrid(aCoupling, StrGridNewHRSysOutTDPoint);
    DrawDynGrid(aCoupling, StrGridNewStageDivOutTDPoint);
    MemoDivChangeSug.Lines.Clear;
    MemoDivChangeSug.Lines.add('Revise Suggestions Based On Coupling Both Systems Generated, See Graph');
    BtnDrawHSGraph.Enabled := True;
  	BtnAutoRevise.Enabled  := True;
  end;
end;

procedure TFrameCoupling.actRefreshExecute(Sender: TObject);
begin
  inherited;
  {Data}
  Ini;
  {Visual}
  BtnDrawHSGraph.Enabled := False;
  BtnAutoRevise.Enabled  := False;
  RGrpAdjBase.ItemIndex := -1;
  MemoDivChangeSug.Lines.Clear;
  DrawDynGrid(aCoupling, StrGridHRSysOutTDPoint);
  DrawDynGrid(aCoupling, StrGridStageDivOutTDPoint);
  {undo graphic}
  //需要重新做graph，**撤销对astageDiv的更改**
end;

procedure TFrameCoupling.actDrawCouplingOutExecute(Sender: TObject);
begin
  FormMainGraphNR.DrawCouplingOut(aCoupling);
  FormMainGraphNR.Show;
end;

procedure TFrameCoupling.actDefaultExecute(Sender: TObject);
begin
	RGrpAdjBase.ItemIndex := 0;
  BtnDrawHSGraph.Enabled := True;
  BtnAutoRevise.Enabled  := True;
end;

procedure TFrameCoupling.actAutoReviseExecute(Sender: TObject);
begin
  if RGrpAdjBase.ItemIndex = 0 then begin
    aCoupling.CoupleByHRSys;
    MemoDivChangeSug.Lines.add('Done Coupling By Fixed HR System.');
    //actDrawCouplingOut.Execute;     //show graph automatically
  end else if RGrpAdjBase.ItemIndex = 1 then begin
    aCoupling.CoupleByStageDiv;
    MemoDivChangeSug.Lines.add('Done Coupling By Fixed Stage Distribution System.');
    //actDrawCouplingOut.Execute;    //show graph automatically
  end else if RGrpAdjBase.ItemIndex = 2 then begin
  {  aCoupling.CoupleByBoth;
    MemoDivChangeSug.Lines.add('Done Coupling By Both Systems.');
    //actDrawCouplingOut.Execute;    //show graph automatically   }
  end;
end;

end.
