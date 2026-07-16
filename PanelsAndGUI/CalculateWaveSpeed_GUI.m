function CalculateWaveSpeed_GUI
global ScanSettings
global GateInfo

if isempty(ScanSettings.f_s)
errordlg('Data not select. Please select data!!')
    return
    
end

FigStart=0;
FigEnd=0;
FigWidth=800;
FigHight=600;

GateInfo.CurrentGate.MouseClick=0;

f= figure('Visible','off','Position',[FigStart,FigEnd,FigWidth,FigHight]);
f.SizeChangedFcn=@ResizeFunction;
delete(findall(f,'tag','Annotation.InsertLegend'));
delete(findall(f,'tag','Annotation.InsertColorbar'));
delete(findall(f,'tag','DataManager.Linking'));
delete(findall(f,'tag','Standard.PrintFigure'));
delete(findall(f,'tag','Standard.SaveFigure'));
delete(findall(f,'tag','Standard.FileOpen'));
delete(findall(f,'tag','Standard.NewFigure'));
delete(findall(f,'tag','Standard.OpenInspector'));
addToolbarExplorationButtons(f)
delete(findall(f,'tag','Exploration.Brushing'));
hEdit=findall(f,'tag','Standard.EditPlot');
if ~isempty(hEdit)
    hEdit.ClickedCallback = 'CurserCallback(gcbf)';
end



CreateCScanPannel(f);
CPanels=findobj(f,'Tag','CPanel');
CPanel=CPanels(1);
CPanel.Position=[.67, .605, 1/3, 1-.605-.005];
axis equal

CreateCScanPannel(f);
CPanels=findobj(f,'Tag','CPanel');
CPanel2=CPanels(1);
CPanel2.Position=[.005, .005, .75-.005,.5-.005];
axis equal
CPanel2.Children(end-3).Visible='off';
CPanel2.Children(end-4).Visible='off';
CPanel2.Children(end-5).Visible='off';
CPanel2.Children(end-6).Visible='off';

CreateAScanPannel(f);
APanels=findobj(f,'Tag','APanel');
APanel=APanels(1);
AScanAxes=APanel.Children(end);
AScanAxes.NextPlot='replacechildren';
APanels=findobj('Tag','APanel');
APanel=APanels(1);
APanel.Position=[.005,.605, .67-.005, 1-.605-.005];
AScanAxis=APanel.Children(end);



% WaveSpeed Buttons %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gap=.005;
num_buttons=3;
total_width=1-gap*(num_buttons+1);
b_width=total_width/num_buttons;

button_panel= uipanel('Tag','WaveSpeedPanel','BackgroundColor','white',...
    'Position',[0, .5, 1, .1]);

SelectFirstRegion    = uicontrol(button_panel,'Style','togglebutton',...
    'String','Select Region 1','Units','normalized',...
    'Position',[gap, .05, b_width, .9]);

SelectSecondRegion = uicontrol(button_panel,'Style','togglebutton',...
    'String','Store Region 2','Units','normalized',...
    'Position',[gap*2+b_width, .05, b_width, .9]);
CalculateWaveSpeed  = uicontrol(button_panel,'Style','pushbutton',...
    'String','Calculate','Units','normalized','Position',[gap*3+b_width*2, .05, b_width, .9]);


% Selection Values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PanelColor=[.95 .95 .95];

data_input_h= uipanel('Tag','HeightLocationData','BackgroundColor','white',...
    'Position',[.755, .005, 1-.755, .5-.005]);

MethodText     = uicontrol(data_input_h,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'String','Height Value (mm)','Position',[.005,.85,.44,.1]);

HeightValue  = uicontrol(data_input_h,'Tag','Input1','Style','edit',...
    'String','n/a','Units','normalized','Position',[.51,.8,.22*2,.09*2],...
    'Enable','on');

Input1Text      = uicontrol(data_input_h,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'String','Time 1/1','Position',[.005,.6,.22,.09]);

Input1Value  = uicontrol(data_input_h,'Tag','Input1','Style','edit',...
    'String','n/a','Units','normalized','Position',[.25,.6,.22,.09],...
    'Enable','on');

Input2Text      = uicontrol(data_input_h,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'String','Time 1/2','Position',[.51,.6,.22,.09]);

Input2Value  = uicontrol(data_input_h,'Tag','Input2','Style','edit',...
    'String','n/a','Units','normalized','Position',[.75,.6,.22,.09],...
    'Enable','on');

Input3Text      = uicontrol(data_input_h,'Style','text','BackgroundColor',PanelColor,...
    'String','Time 2/1','Units','normalized','Position',[.005,.5,.22,.09]);

Input3Value  = uicontrol(data_input_h,'Tag','Input3','Style','edit',...
    'String','n/a','Units','normalized','Position',[.25,.5,.22,.09],...
    'Enable','on');

Input4Text      = uicontrol(data_input_h,'Style','text','BackgroundColor',PanelColor,...
    'String','Time 2/2','Units','normalized','Position',[.51,.5,.22,.09]);

Input4Value  = uicontrol(data_input_h,'Tag','Input4','Style','edit',...
    'String','n/a','Units','normalized','Position',[.75,.5,.22,.09],...
    'Enable','on');

% Input5Text      = uicontrol(data_input_h,'Style','text','BackgroundColor',PanelColor,...
%     'String','Input 5','Units','normalized','Position',[.005,.4,.22,.09]);
% 
% Input5Value  = uicontrol(DrawPanel,'Tag','Input5','Style','edit',...
%     'String','n/a','Units','normalized','Position',[.25,.4,.22,.09],...
%     'Enable','off','CallBack',@VarPos_Callback);
% % 
% Input6Text      = uicontrol(data_input_h,'Style','text','BackgroundColor',PanelColor,...
%     'String','Rectification','Units','normalized','Position',[.51,.3,.22,.09]);
% 
% bg  = uibuttongroup(data_input_h,'Tag','bg_Rectification',...
%     'Units','normalized','Position',[.75,.3,.22,.09]);

% rb1 = uiradiobutton(bg,'Position',[10 60 91 15]);

bg1  = uipanel(data_input_h,'Tag','bg_Rectification',...
    'Units','normalized','Position',[.51,.3,.22*2,.09]);

RectificationButton    = uicontrol(bg1,'Style', 'radiobutton',...
    'String','Rectification','Units','normalized','Position',[.05,.05,.9,.9],...
    'Tag','Fixed','Value',1);

bg2  = uibuttongroup(data_input_h,'Tag','bg_Method',...
    'Units','normalized','Position',[.51,.1,.22*2,.09*2]);

speed_h    = uicontrol(bg2,'Style', 'radiobutton',...
    'String','Velocity','Units','normalized','Position',[.05,.51,.95,.44],...
    'Tag','Velocity','Value',1,'Callback',{@SpeedThickness_Callback,MethodText,'Height Value (mm)'});
thick_h    = uicontrol(bg2,'Style', 'radiobutton',...
    'String','Thickness','Units','normalized','Position',[.05,.05,.95,.44],...
    'Tag','Thickness','Value',0,'Callback',{@SpeedThickness_Callback,MethodText,'Wave Speed (mm/µs)'});
speed_h.HitTest='off';
thick_h.HitTest='off';
RectificationButton.HitTest='off';

MethodText.HitTest='off';
HeightValue.HitTest='off';
Input1Text.HitTest='off';
Input1Value.HitTest='on';
Input2Text.HitTest='off';
Input2Value.HitTest='off';
Input3Text.HitTest='off';
Input3Value.HitTest='off';
Input4Text.HitTest='off';
Input4Value.HitTest='off';
% Input5Text.HitTest='off';
% Input5Value.HitTest='off';
% Input6Text.HitTest='off';
% Input6Value.HitTest='off';

% SelectPoints.Callback={@SelectRegion,f,APanel,Input1Value,Input2Value,1};

SelectFirstRegion.Callback={@SelectRegion,f,APanel,Input1Value,Input2Value,1};
SelectSecondRegion.Callback={@SelectRegion,f,APanel,Input3Value,Input4Value,2};
CalculateWaveSpeed.Callback={@CalculateWaveSpeed_Callback,data_input_h};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(ScanSettings.scan_len)
    CPanel.Children(end).XLim=[0 ScanSettings.scan_len];
    CPanel.Children(end).YLim=[0 ScanSettings.index_len];
    APanel.Children(end).YLim=[-1 1];
    APanel.Children(end).XLim=[ScanSettings.w_s,ScanSettings.w_s+ScanSettings.w_w];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AlignPanel= uipanel('Tag','AlignPanel','BackgroundColor','white',...
%     'Position',[.7, .65, .3-.01, .17-.01]);
% 
% StartButton  = uicontrol(AlignPanel,'Style','pushbutton','Units','normalized',...
%     'String','Start Alignment','Position',[.08, .53, .35, .25],...
%     'Callback',@StartAlign_Callback);
% 
% CancelButton  = uicontrol(AlignPanel,'Style','pushbutton','Units','normalized',...
%     'String','Cancle','Position',[.6 .53 .35 .25 ],...
%     'Callback',@CancleAlign_Callback);
% 
% PlotOnOff  = uicontrol(AlignPanel,'Style','pushbutton','Units','normalized',...
%     'String','Plot On','Position',[.08, .15, .35, .25],...
%     'Callback',@PlotOnOff_Callback,'BackgroundColor',[0 1 0]);
% 
% CorrelationMethod = uicontrol(AlignPanel,'Style','popupmenu','Units','normalized',...
%     'String',{'Maximum Peak x-Corr','Closest Peak x-Corr','Given Threshold','none'},'Position',[.6 .15 .35 .25],...
%     'Callback',@CorrelationMethod_menu_Callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ClearAllMethod = uicontrol(f,'Style','pushbutton','Units','normalized',...
%     'String','Clear All','Position',[.73 .56 .25 .08],'BackgroundColor',[1 0 0],...
%     'Callback',@ClearAll_Callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f.Name = 'Calculate Wavespeed Interface';
f.NumberTitle='off';
movegui(f,'center')
Update_CScan_Callback(1 ,1,f,0)
f.Visible='on';

f.Units              = 'normalized';
% XWindowPanel.Units      = 'normalized';
SelectFirstRegion.Units = 'normalized';
SelectSecondRegion.Units  = 'normalized';

end