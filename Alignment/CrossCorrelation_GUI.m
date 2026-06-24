function CrossCorrelation_GUI
global ScanSettings
global Waves
global GateInfo
global xCorrSettings
global CurrentIndex

if isempty(Waves.waveform_matrix)
errordlg('Data not select. Please select data!!')
    return
    
end

FigStart=0;
FigEnd=0;
FigWidth=1000;
FigHight=600;


PlotYesNo=1;
Waves.StopAlignment=0;
AlignMethod = 1;
GateInfo.CurrentGate.MouseClick=0;

f= figure('Visible','off','Position',[FigStart,FigEnd,FigWidth,FigHight]);
f.SizeChangedFcn=@ResizeFunction;
% f.WindowButtonMotionFcn=@MovingMouse;
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
addToolbarExplorationButtons(f)
delete(findall(f,'tag','Exploration.Brushing'));


PlotPanel= uipanel('Tag','PlotPanel','BackgroundColor','white',...
    'Position',[.005, .005, 2/3+.001, .5-.005]);

FigureAxes = axes(PlotPanel,'Position',[.1,.1,.85,.85]);
FigureAxes.HitTest='off';

% Cross Correlation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XWindowPanel= uipanel('Tag','CrossCorrPanel','BackgroundColor','white',...
    'Position',[.7, .82, .3-.01, .17-.01]);

SelectPoints    = uicontrol(XWindowPanel,'Style','togglebutton',...
    'String','Select Region','Units','normalized',...
    'Position',[.08, .53, .35, .25]);

PanelColor=[.95 .95 .95];

Input1Text      = uicontrol(XWindowPanel,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'String','Start Time','Position',[.005,.1,.22,.25]);

Input1Value  = uicontrol(XWindowPanel,'Tag','Input1','Style','edit',...
    'String','n/a','Units','normalized','Position',[.25,.1,.22,.25],...
    'Enable','on');

Input2Text      = uicontrol(XWindowPanel,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'String','End Time','Position',[.51,.1,.22,.25]);

Input2Value  = uicontrol(XWindowPanel,'Tag','Input2','Style','edit',...
    'String','n/a','Units','normalized','Position',[.75,.1,.22,.25],...
    'Enable','on');





% StoreData  = uicontrol(XWindowPanel,'Style','pushbutton',...
%     'String','Store Region','Units','normalized',...
%     'Position',[.6, .53, .35, .25],'Callback',@StoreData_Callback);
% ResetPositions  = uicontrol(XWindowPanel,'Style','pushbutton',...
%     'String','Reset','Units','normalized','Position',[.08, .15, .35, .25],...
%     'Callback',@ResetDomain);

% ,'Callback',@SelectRegion_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CreateCScanPannel(f);
CPanels=findobj(f,'Tag','CPanel');
CPanel=CPanels(1);

CreateAScanPannel(f);
APanels=findobj(f,'Tag','APanel');
APanel=APanels(1);
AScanAxes=APanel.Children(end);
AScanAxes.NextPlot='replacechildren';

% f.Position=[f.Position(1),f.Position(2),1000,600];

CPanels=findobj('Tag','CPanel');
CPanel=CPanels(1);
CPanel.Position=[2/3+.01, .005, 1/3, .55];

APanels=findobj('Tag','APanel');
APanel=APanels(1);
APanel.Position=[.005,.5, 2/3+.001, .5-.005];
AScanAxis=APanel.Children(end);

if ~isempty(ScanSettings.scan_len)
    CPanel.Children(end).XLim=[0 ScanSettings.scan_len];
    CPanel.Children(end).YLim=[0 ScanSettings.index_len];
    APanel.Children(end).YLim=[-1 1];
    APanel.Children(end).XLim=[ScanSettings.w_s,ScanSettings.w_s+ScanSettings.w_w];
end


SelectPoints.Callback={@SelectRegion,f,APanel,Input1Value,Input2Value,1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AlignPanel= uipanel('Tag','AlignPanel','BackgroundColor','white',...
    'Position',[.7, .65, .3-.01, .17-.01]);

StartButton  = uicontrol(AlignPanel,'Style','pushbutton','Units','normalized',...
    'String','Start Alignment','Position',[.08, .53, .35, .25],...
    'Callback',@StartAlign_Callback);

CancelButton  = uicontrol(AlignPanel,'Style','pushbutton','Units','normalized',...
    'String','Cancel','Position',[.6 .53 .35 .25 ],...
    'Callback',@CancelAlign_Callback);

PlotOnOff  = uicontrol(AlignPanel,'Style','pushbutton','Units','normalized',...
    'String','Plot On','Position',[.08, .15, .35, .25],...
    'Callback',@PlotOnOff_Callback,'BackgroundColor',[0 1 0]);

CorrelationMethod = uicontrol(AlignPanel,'Style','popupmenu','Units','normalized',...
    'String',{'Maximum Peak x-Corr','Closest Peak x-Corr','Given Threshold','none'},'Position',[.6 .15 .35 .25],...
    'Callback',@CorrelationMethod_menu_Callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ClearAllMethod = uicontrol(f,'Style','pushbutton','Units','normalized',...
    'String','Clear All','Position',[.73 .56 .25 .08],'BackgroundColor',[1 0 0],...
    'Callback',@ClearAll_Callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f.Name = 'Waveform Alignment Interface';
f.NumberTitle='off';
movegui(f,'center')
Update_CScan_Callback(1 ,1,f,0)
f.Visible='on';

f.Units              = 'normalized';
SelectPoints.Units = 'normalized';
PlotPanel.Units         = 'normalized';
FigureAxes.Units        = 'normalized';
StoreData.Units  = 'normalized';
XWindowPanel.Units      = 'normalized';
% ResetPositions.Units    = 'normalized';
AlignPanel.Units        = 'normalized';
StartButton.Units       = 'normalized';
CancelButton.Units      = 'normalized';
PlotOnOff.Units         = 'normalized';
CorrelationMethod.Units = 'normalized';

if ~isempty(Waves.shifted_vector)
    
    if max(abs(Waves.shifted_vector))~=0
        StringChange=findobj(CPanel,'Tag','ChooseType');
        StringChange.String={'Amp','TOF','Aligment'};
        APanel.Children(end-2).String={'Collected Waveform','X-Corr Waveform'};
    end
    
end

    function ObtainIndecies
        ax=gca;
        lines=findobj(ax,'Tag','SelectRegion');

        if ~isempty(lines)            

            t1f=str2num(Input1Value.String);
            t2f=str2num(Input2Value.String);
            t1f_index=find(t1f<ScanSettings.t,1);       % Start Time of first signal
            t2f_index=find(t2f<ScanSettings.t,1);       % End time of first signal
            indicies=t1f_index:t2f_index;
            
            xCorrSettings.StartIndex=indicies(1);            
            xCorrSettings.EndIndex=indicies(end);

        end

    end


    function StartAlign_Callback(~,~)
        ObtainIndecies
        Waves.StopAlignment=0; %  allows the program to keep running
        Waves.shifted_vector=xCorrSettings.ShiftVector;
        StringChange=findobj(CPanel,'Tag','ChooseType');
        StringChange.String={'Amp','TOF','X-Corr'};
%         CPanel.Children(7).String={'Amp','TOF','X-Corr'};
        APanel.Children(end-2).String={'Collected Waveform','X-Corr Waveform'};
        
        xCorrSettings.WaveformIndex=CurrentIndex;
        [num_wfs,~]=size(Waves.waveform_matrix);
        xCorrSettings.ShiftVector=zeros(1,num_wfs);
        switch AlignMethod
            case 1
                CrossCorrelationMaximumPeak(Waves,xCorrSettings,ScanSettings,PlotYesNo)
            case 2
                CrossCorrelationClosestPeak(Waves,xCorrSettings,ScanSettings,PlotYesNo)
            case 3
                
            case 4
                Waves.shifted_matrix=Waves.waveform_matrix;
                Waves.shifted_vector=zeros(num_wfs,1);
            otherwise
                
        end
        
    end

    function CancelAlign_Callback(~,~)
        % A stop Alignment ~= one results in stopping the calculations
        Waves.StopAlignment=1;
        
    end

    function CorrelationMethod_menu_Callback(source,~)
        AlignMethod = get(source,'Value');
        % Several types of alignment options, they are numbers as follows
        
        % 1- Maximum Cross Correlation Method
        % 2- Closest Cross Correlated Peak Method
        % 3- Given Threshold. Use the first instance of an object
        % 4- None, use the collected data for the program
        % 5 and up can be implimented by the user.
        
        % This value is used to run the alignment options
    end

    function PlotOnOff_Callback(~,~)
        if PlotYesNo==1
            PlotYesNo=0;
            PlotOnOff.String = 'Plot Off';
            PlotOnOff.BackgroundColor = [1 0 0];
        else
            PlotYesNo=1;
            PlotOnOff.String = 'Plot On';
            PlotOnOff.BackgroundColor = [0 1 0];
        end
    end

    function ClearAll_Callback(~,~)
        
        button = questdlg('Do you want to clear the cross correlation data?''?','Quit Program?','Yes','No','Yes');
        if contains(button, 'Yes')
            
            Waves.shifted_matrix=[];
            Waves.shifted_vector=[];
        end        
    end

end