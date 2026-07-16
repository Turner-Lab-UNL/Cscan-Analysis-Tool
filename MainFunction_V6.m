
function MainFunction_V6
close all
clear all

figures_all =  findobj('type','figure');
num_figures = length(figures_all);
if num_figures~=0
    return
end

global SelectRegionCount
global NumPlots

global Waves
global Draw
global ScanSettings
global NumberOldLocations
global xCorrSettings

global CurrentFolder
global GateInfo
global GateOld

global SaveString
global ax_A_Vector
global ax_C_Vector
global ax_F_Vector

global RefWaves 
global RefScanSettings 
global CurrentFolderRef
% mfilename
filename=mfilename('fullpath');
[filepath] = fileparts(filename);

addpath(fullfile(filepath,'AdditionalFcns'));
addpath(fullfile(filepath,'Alignment'));
addpath(fullfile(filepath,'ClassTypes'));
addpath(fullfile(filepath,'CrosshairFcns'));
addpath(fullfile(filepath,'DrawShapes'));
addpath(fullfile(filepath,'KeepArrayFcns'));
addpath(fullfile(filepath,'ObtainAndSave'));
addpath(fullfile(filepath,'Settings'));
addpath(fullfile(filepath,'PanelsAndGUI'));
addpath(fullfile(filepath,'VarianceLocationsFcns'));
addpath(fullfile(filepath,'VelocityAndThickness'));
addpath(fullfile(filepath,'Attenuation'));

ProgramName='C-Scan Plot Interface';

%% Initialize Basic Gate Settings
GateInfo.g1=Gate(); % This is a handle class
GateInfo.g2=Gate();
GateInfo.g3=Gate();
GateInfo.g4=Gate();
High=[nan nan nan,nan,nan];
Low=[nan nan nan,nan,nan];

GateOld.g1=Gate(); % Needed to Check if Gates have been updated
GateOld.g2=Gate();
GateOld.g3=Gate();
GateOld.g4=Gate();
GeneralGateFill(GateOld.g1);
GeneralGateFill(GateOld.g2);
GeneralGateFill(GateOld.g3);
GeneralGateFill(GateOld.g4);
GateInfo.g1.High=High;
GateInfo.g2.High=High;
GateInfo.g3.High=High;
GateInfo.g4.High=High;
GateInfo.g1.Low=Low;
GateInfo.g2.Low=Low;
GateInfo.g3.Low=Low;
GateInfo.g4.Low=Low;
GateInfo.CurrentGate=Gate();
GateInfo.CurrentGate.Low=Low;
GateInfo.CurrentGate.High=High;


%% Generate other Class objects needed for Program
ScanSettings=ScanParameters();
Waves=WaveMatrices();
xCorrSettings=CrossCorParameters();

RefScanSettings=ScanParameters();
RefWaves=WaveMatrices();
CurrentFolderRef=pwd;

SelectRegionCount=1;
GateInfo.CurrentGate.MouseClick=0;
CurrentFolder=pwd;

Draw.SelectedIndecies=[];
Draw.NameArray=[];
Draw.KeepArray=[];
Draw.SubtractArray=[];
Draw.NumPlots=0;

SaveString.String ='''xCorrSettings'', ''GateInfo'',''ScanSettings'',''Waves'',''Draw''';
SaveString.ScanSettings=1;
SaveString.Waves=1;
SaveString.XCorr=1;
SaveString.Gates=1;
SaveString.Draw=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigWidth=950;
FigHight=425;
f = figure('Visible','off','Position',[0,0,FigWidth,FigHight],'Units','normalized','MenuBar','none');
f.NumberTitle='off';
f.SizeChangedFcn=@ResizeFunction;
f.CloseRequestFcn={@CloseFig,ProgramName,filepath};
f.DockControls='off';
f.ToolBar='Figure';

hFileMenu = uimenu(f, 'Text', 'File','Tag','figMenuFile');
hAllMenuItems = allchild(hFileMenu);
delete(hAllMenuItems)
hLoadMenu = uimenu('Label','Load Data', 'Parent',hFileMenu);
hLoadRefMenu = uimenu('Label','Load Reference Data', 'Parent',hFileMenu);
hSaveMenu = uimenu('Label','Save Data', 'Parent',hFileMenu);

delete(findall(f,'tag','Annotation.InsertLegend'));
delete(findall(f,'tag','Annotation.InsertColorbar'));
delete(findall(f,'tag','DataManager.Linking'));
delete(findall(f,'tag','Standard.PrintFigure'));
delete(findall(f,'tag','Standard.SaveFigure'));
delete(findall(f,'tag','Standard.FileOpen'));
delete(findall(f,'tag','Standard.NewFigure'));
delete(findall(f,'tag','Standard.OpenInspector'));
hEdit=findall(f,'tag','Standard.EditPlot');
hEdit.ClickedCallback='CurserCallback(gcbf)';
toolbar=hEdit.Parent;

addToolbarExplorationButtons(f)
delete(findall(f,'tag','Exploration.Brushing'));



hFunctionsMenu = uimenu(f,'Text','Functions','Tag','figMenuFunctions');
hGateSettings = uimenu(hFunctionsMenu,'Text','GateSettings','Callback',@GateSettings_Callback);
hXCorr = uimenu(hFunctionsMenu,'Text','Waveform Alignment','Callback',@CrossCorr_Callback);
hWaveSpeed = uimenu(hFunctionsMenu,'Text','Wavespeed','Callback',@Wavespeed_Callback);
hAttenuation = uimenu(hFunctionsMenu,'Text','Attenuation','Callback',@Attenuation_Callback);
hSettings = uimenu(hFunctionsMenu,'Text','Settings','Callback',@SetSettings_Callback);

% hRecentMenu = uimenu('Label','Recent Data', 'Parent',hFileMenu);

hInsertMenu = uimenu(f,'Text','Insert','Tag','figMenuInsert');
uimenu(hInsertMenu,'Text','C-Graph','Callback',{@InsertC});
uimenu(hInsertMenu,'Text','A-Graph','Callback',{@InsertA});
uimenu(hInsertMenu,'Text','Spectrum','Callback',{@InsertFreq});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumPlots=0;
NumberOldLocations=0;

ButtonWidth=90;
ButtonHigth=25;
DropDownWidth=100;
Displacment=0;
RightPanel=.785;
SelectHight = .93;
FigInsertHeight=.995;


MessageBox = uicontrol('Style','text',...
    'String','Message Box','HorizontalAlignment','left','Position',[FigWidth-DropDownWidth*2-...
    Displacment,1,DropDownWidth*2,ButtonHigth*2],'background',[0.6 0.6 0.6],'Units','normalized','Tag','MessageBox');

FileNameBox = uicontrol('Style','text','String','File Name',...
    'HorizontalAlignment','left','Units','normalized',...
    'Position',[.005,.005,.765,.04],'background',[0.8 0.8 0.8]);

RefFileNameBox = uicontrol('Style','text','String','Reference File Name',...
    'HorizontalAlignment','left','Units','normalized',...
    'Position',[.005,.045,.765,.04],'background',[0.8 0.8 0.8]);

MessageBox.HitTest='off';
FileNameBox.HitTest='off';
RefFileNameBox.HitTest='off';

%% Create A and C Scan Panels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[AScanAxes,APanel]=CreateAScanPannel(f);
APanel.Position=[.39, .05+.4725, .38, .945/2];
ax_A_Vector{1}=AScanAxes;

[FreqAxes,FreqPanel]=CreateFreqPannel(f);
FreqPanel.Position=[.39, .05, .38, .945/2];
ax_F_Vector{1}=FreqAxes;

[CScanAxes,CPanel]=CreateCScanPannel(f);
CPanel.Position=[.005, .05, .38, .945];
ax_C_Vector{1}=CScanAxes;
%
% [CScanAxes,CPanel]=CreateCScanPannel(f);
% CPanel.Position=[.01, .05, .38, .945];
% ax_C_Vector{1}=CScanAxes;


%% Variance Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[DrawPanel,~,~,~,~,~,~ ]=CreateDrawPanel(f,ax_C_Vector,RightPanel,FigInsertHeight);


%% Load and Save Data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(hLoadMenu, 'Callback',{@SelectData_Callback,FileNameBox,MessageBox,ax_C_Vector,ax_A_Vector});
set(hLoadRefMenu, 'Callback',{@LoadReferenceData_Callback,RefFileNameBox,MessageBox});
set(hSaveMenu, 'Callback',{@SaveAsMat_Callback,FileNameBox,MessageBox});


%Fill Gates with generic info%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:4
    CurrentGate=eval(['GateInfo.g',num2str(k)]);
    if isempty(CurrentGate.Start)
        CurrentGate.Start=0;
        CurrentGate.Width=1+eps;
        CurrentGate.Threshold=0;
        CurrentGate.Type=1;
        CurrentGate.Color=1;
        CurrentGate.Visibility=0;
        CurrentGate.Thickness=1;
    end
end

%% Reorder Panels

uistack([MessageBox,FileNameBox,DrawPanel])


%% Assign the a name to appear in the window title.
f.Name = ProgramName;
movegui(f,'center')

%% set (gcf, 'WindowButtonMotionFcn', @MovingMouse);
f.Visible = 'on';

%% Gate Setup Functions
    function GateSettings_Callback(~,~)
        
        h=findobj('Name','Gate Settings Interface');
        if isempty(h)
            
            GateSettings_GUI(f)
        else
            figure(h)
        end
    end
    function SetSettings_Callback(~,~)
        
        h=findobj('Name','Settings');
        if isempty(h)
            SetSettings
        else
            figure(h)
        end
    end

    function CrossCorr_Callback(~,~)
        h=findobj('Name','Waveform Alignment Interface');
        if isempty(h)
            CrossCorrelation_GUI
        else
            figure(h)
        end
        CPanels=findobj('Tag','CPanel');
        APanels=findobj('Tag','APanel');
        n=length(CPanels);
        for i=1:n
            CPanel_loop=CPanels(n);
            StringChange=findobj(CPanel_loop,'Tag','ChooseType');
            StringChange.String={'Amp','TOF','Alignment','Velocity','TimeDiff'};
        end
        n=length(APanels);
        for i=1:n
            APanel_loop=APanels(n);
            APanel_loop.Children(end-2).String={'Collected Waveform','X-Corr Waveform'};
        end
    end

    function Wavespeed_Callback(~,~)
        h=findobj('Name','Calculate Wavespeed Interface');
        if isempty(h)
            CalculateWaveSpeed_GUI
        else
            figure(h)
        end
        
        CPanels=findobj('Tag','CPanel');
        n=length(CPanels);
        for i=1:n
            CPanel_loop=CPanels(n);
            
        CPanel_loop.Parent
            StringChange=findobj(CPanel_loop,'Tag','ChooseType');
            StringChange.String={'Amp','TOF','Aligment','Velocity','TimeDiff'};
        end
    end
 function Attenuation_Callback(~,~)
        h=findobj('Name','Calculate Attenuation Interface');
        if isempty(h)
            CalculateAttenuation_GUI
        else
            figure(h)
        end
 
        CPanels=findobj('Tag','CPanel');
        n=length(CPanels);
        for i=1:n
            CPanel_loop=CPanels(i);
            StringChange=findobj(CPanel_loop,'Tag','ChooseType');
            StringChange.String={'Amp','TOF','Aligment','Attenuation','TimeDiff'};
        end
    end
    function InsertC(~,~)
        [CScanAxes_temp,CPanel_temp]=CreateCScanPannel(f);
        CPanel_temp.Position=[.25, .25, .4, .4];
        ax_C_Vector{end+1}=CScanAxes_temp;
    end

    function InsertA(~,~)
        [AScanAxes_temp,APanel_temp]=CreateAScanPannel(f);
        APanel_temp.Position=[.45, .45, .4, .4];
        ax_A_Vector{end+1}=AScanAxes_temp;
    end

    function InsertFreq(~,~)
        [FreqAxes_temp,FreqPanel_temp]=CreateFreqPannel(f);
        FreqPanel_temp.Position=[.55, .55 .4, .4];
        ax_F_Vector{end+1}=FreqAxes_temp;
    end

end





