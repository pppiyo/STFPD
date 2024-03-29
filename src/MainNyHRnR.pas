unit MainNyHRnR;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ActnList, StdCtrls, RzEdit, RzSplit, RzPanel,
  RzDlgBtn, RzTabs, RzGroupBar, Buttons,
  FrmMainParams, FrmGoverningStage, FrmHRSys, FrmStageDiv, FrmCoupling, FrmStageCal,FrmSectionCal,
  Data;

type
  TFormMainNyHRnR = class(TForm)
    MainToolbar: TRzToolbar;
    SBtnDrawGraph: TSpeedButton;
    SBtnVTri: TSpeedButton;
    MainMenu: TRzGroupBar;
    RzGroupBasicDesign: TRzGroup;
    MainStatusBar: TRzStatusBar;
    MainMessageBox: TRzSizePanel;
    RzMemo1: TRzMemo;
    actListShow: TActionList;
    ActOutput: TAction;
    actMainParams: TAction;
    actGoverningStage: TAction;
    actHRSys: TAction;
    actStageDiv: TAction;
    actCoupling: TAction;
    actStageCal: TAction;
    ActCheckData: TAction;
    ActOptimize: TAction;
    actCancel: TAction;
    actDrawHSGraph: TAction;
    actDrawVTri: TAction;
    actSectionCal: TAction;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    MenuDrawHSGraph: TMenuItem;
    sMenuMainParams: TMenuItem;
    DrawHRSysOut: TMenuItem;
    DrawStageDivisionOut: TMenuItem;
    DrawStageCalOut: TMenuItem;
    actStageCal2: TAction;
    WorkArea: TRzPageControl;
    TabMainParams: TRzTabSheet;
    DBtnMainParams: TRzDialogButtons;
    TabGoverningStage: TRzTabSheet;
    DBtnGoverningStage: TRzDialogButtons;
    TabHRSys: TRzTabSheet;
    DBtnHRSys: TRzDialogButtons;
    TabStageDiv: TRzTabSheet;
    DBtnStageDiv: TRzDialogButtons;
    TabCoupling: TRzTabSheet;
    DBtnCoupling: TRzDialogButtons;
    TabStageCal: TRzTabSheet;
    DBtnStageCal: TRzDialogButtons;
    TabSectionCal: TRzTabSheet;
    DBtnSectionCal: TRzDialogButtons;
    RzTabSheet1: TRzTabSheet;
    TabStageCal2: TRzTabSheet;
    DBtnStageCal2: TRzDialogButtons;
    procedure FormShow(Sender: TObject);
    procedure actMainParamsExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actGoverningStageExecute(Sender: TObject);
    procedure actHRSysExecute(Sender: TObject);
    procedure actStageDivExecute(Sender: TObject);
    procedure actCouplingExecute(Sender: TObject);
    procedure actStageCalExecute(Sender: TObject);
    procedure actSectionCalExecute(Sender: TObject);
    procedure actStageCal2Execute(Sender: TObject);
  private
    { Private declarations }
        FfrmMainParams     : TframeMainParams;
        FfrmGoverningStage : TframeGoverningStage;
        FfrmHRSys          : TframeHRSys;
        FfrmStageDiv       : TframeStageDiv;
        FfrmCoupling       : TframeCoupling;
        FfrmStageCal       : TframeStageCal;
        FfrmStageCal2       : TframeStageCal;
        FfrmSectionCal     : TframeSectionCal;
        procedure Auto;
        procedure UpdateSelectedPage( Action: TAction );
  public
    { Public declarations }
  end;

var
  FormMainNyHRnR: TFormMainNyHRnR;

implementation

uses MainGraphNR;

{$R *.dfm}

procedure TFormMainNyHRnR.UpdateSelectedPage( Action: TAction );
begin
  actMainParams.Checked          := actMainParams     = Action;
  actGoverningStage.Checked      := actGoverningStage = Action;
  actHRSys.Checked      				 := actHRSys          = Action;
  actStageDiv.Checked            := actStageDiv       = Action;
  actCoupling.Checked       		 := actCoupling       = Action;
  actStageCal.Checked      			 := actStageCal       = Action;
  actStageCal2.Checked      		 := actStageCal       = Action;
  actSectionCal.Checked          := actSectionCal     = Action;
end;

procedure TFormMainNyHRnR.FormShow(Sender: TObject);
var
	i:integer;
begin
{Visual Ini}
  Self.Height := 771;
  Self.Width  := 1021;

	with WorkArea do begin
  	Visible := False;
  	for i:=0 to PageCount-1 do begin
	  	Pages[i].TabVisible := False;
		end;
  end;

  FfrmMainParams     := nil;
  FfrmGoverningStage := nil;
  FfrmHRSys          := nil;
  FfrmStageDiv       := nil;
  FfrmCoupling       := nil;
  FfrmStageCal       := nil;
  FfrmStageCal2      := nil;
  FfrmSectionCal     := nil;

  FormMainGraphNR := TFormMainGraphNR.Create(Self);
  RzGroupBasicDesign.Items[0].Caption := 'Main Parameters';
  RzGroupBasicDesign.Items[1].Caption := 'Governing Stage';
  RzGroupBasicDesign.Items[2].Caption := 'HR System';
  RzGroupBasicDesign.Items[3].Caption := 'Stage Division';
  RzGroupBasicDesign.Items[4].Caption := 'Coupling';
  RzGroupBasicDesign.Items[5].Caption := 'Stage Calculation';
  RzGroupBasicDesign.Items[6].Caption := 'Stage Calculation';
  RzGroupBasicDesign.Items[7].Caption := 'Final H-S Graph';//fm
  RzGroupBasicDesign.Items[8].Caption := 'Section Calculation';

  Data.aIniData        := nil;
  Data.aGoverningStage := nil;
  Data.aHRSys          := nil;
  Data.aHRSysWithDA    := nil;
  Data.aStageDiv       := nil;
  Data.aCoupling       := nil;
  Data.aStageCal       := nil;
  Data.aSectionCal     := nil;

  Auto;
end;

{Auto}
procedure TFormMainNyHRnR.Auto;
begin
  actMainParamsExecute(Self);
end;

procedure TFormMainNyHRnR.actMainParamsExecute(Sender: TObject);
begin
	WorkArea.Visible := True;
  try
		if FfrmMainParams = nil then begin
  		FfrmMainParams := TFrameMainParams.Create( nil );
      FfrmMainParams.Parent := TabMainParams;
      FfrmMainParams.Align  := alClient;
    end;
  finally
    	UpdateSelectedPage( actMainParams );
  		WorkArea.ActivePageIndex := actMainParams.Tag;
  		WorkArea.ActivePage.TabVisible := true;
  		DBtnMainParams.BtnCancel.Caption := 'Next';
  		DBtnMainParams.BtnHelp.Caption   := 'Back';
	end;
end;

procedure TFormMainNyHRnR.actGoverningStageExecute(Sender: TObject);
begin
  	try
			if FfrmGoverningStage = nil then begin
  			FfrmGoverningStage := TFrameGoverningStage.Create( nil );
  	    FfrmGoverningStage.Parent := TabGoverningStage;
  	    FfrmGoverningStage.Align  := alClient;
  	  end;
  	finally
  	  	UpdateSelectedPage( actGoverningStage );
  			WorkArea.ActivePageIndex := actGoverningStage.Tag;
  			WorkArea.ActivePage.TabVisible := true;
  			DBtnGoverningStage.BtnCancel.Caption := 'Next';
  			DBtnGoverningStage.BtnHelp.Caption   := 'Back';
		end;
end;

procedure TFormMainNyHRnR.actHRSysExecute(Sender: TObject);
begin
  	try
			if FfrmHRSys = nil then begin
  			FfrmHRSys := TFrameHRSys.Create( nil );
  	    FfrmHRSys.Parent := TabHRSys;
  	    FfrmHRSys.Align := alClient;
  	  end;
  	finally
  	  	UpdateSelectedPage( actHRSys );
  			WorkArea.ActivePageIndex := actHRSys.Tag;
  			WorkArea.ActivePage.TabVisible := true;
  			DBtnHRSys.BtnCancel.Caption := 'Next';
  			DBtnHRSys.BtnHelp.Caption   := 'Back';
		end; 
end;

procedure TFormMainNyHRnR.actStageDivExecute(Sender: TObject);
begin
  	try
			if FfrmStageDiv = nil then begin
  			FfrmStageDiv := TFrameStageDiv.Create( nil );
  	    FfrmStageDiv.Parent := TabStageDiv;
  	    FfrmStageDiv.Align := alClient;
  	  end;
  	finally
  	  	UpdateSelectedPage( actStageDiv );
  			WorkArea.ActivePageIndex := actStageDiv.Tag;
  			WorkArea.ActivePage.TabVisible := true;
  			DBtnStageDiv.BtnCancel.Caption := 'Next';
  			DBtnStageDiv.BtnHelp.Caption   := 'Back';
		end;
end;

procedure TFormMainNyHRnR.actCouplingExecute(Sender: TObject);
begin
  try
		if FfrmCoupling = nil then begin
  		FfrmCoupling := TFrameCoupling.Create( nil );
      FfrmCoupling.Parent := TabCoupling;
      FfrmCoupling.Align := alClient;
    end;
  finally
    	UpdateSelectedPage( actCoupling );
  		WorkArea.ActivePageIndex := actCoupling.Tag;
  		WorkArea.ActivePage.TabVisible := true;
  		DBtnCoupling.BtnCancel.Caption := 'Next';
  		DBtnCoupling.BtnHelp.Caption   := 'Back';
	end;
end;

procedure TFormMainNyHRnR.actStageCalExecute(Sender: TObject);
begin
  try
		if FfrmStageCal = nil then begin
  		FfrmStageCal := TFrameStageCal.Create( nil );
      FfrmStageCal.Parent := TabStageCal;
      FfrmStageCal.Align := alClient;
    end;
  finally
    	UpdateSelectedPage( actStageCal );
  		WorkArea.ActivePageIndex := actStageCal.Tag;
  		WorkArea.ActivePage.TabVisible := true;
  		DBtnStageCal.BtnCancel.Caption := 'Next';
  		DBtnStageCal.BtnHelp.Caption   := 'Back';
	end;
end;

procedure TFormMainNyHRnR.actStageCal2Execute(Sender: TObject);
begin
  try
		if FfrmStageCal2 = nil then begin
  		FfrmStageCal2 := TFrameStageCal.Create( nil );
      FfrmStageCal2.Parent := TabStageCal2;
      FfrmStageCal2.Align := alClient;
    end;
  finally
    	UpdateSelectedPage( actStageCal2 );
  		WorkArea.ActivePageIndex := actStageCal2.Tag;
  		WorkArea.ActivePage.TabVisible := true;
  		DBtnStageCal2.BtnCancel.Caption := 'Next';
  		DBtnStageCal2.BtnHelp.Caption   := 'Back';
	end;
end;

procedure TFormMainNyHRnR.actSectionCalExecute(Sender: TObject);
begin
  try
		if FfrmSectionCal = nil then begin
  		FfrmSectionCal := TFrameSectionCal.Create( nil );
      FfrmSectionCal.Parent := TabSectionCal;
      FfrmSectionCal.Align := alClient;
    end;
  finally
    	UpdateSelectedPage( actSectionCal );
  		WorkArea.ActivePageIndex := actSectionCal.Tag;
  		WorkArea.ActivePage.TabVisible := true;
  		//DBtnSectionCal.BtnCancel.Caption := 'Next';
  		DBtnSectionCal.BtnHelp.Caption   := 'Back';
	end;
end;

procedure TFormMainNyHRnR.actCancelExecute(Sender: TObject);
begin
	Close;
end;


end.
