function GateSettings_GUI(MainFig)
global GateInfo
global Waves
global ScanSettings
global GateOld
global current_index

CurrentGate=GateInfo.g1;
if CurrentGate.Type==1
    RadioValue=[1 0];
else
    RadioValue=[0 1];
end

GWidthString=num2str(CurrentGate.Width);
GStartString=num2str(CurrentGate.Start);
GThresholdString=num2str(CurrentGate.Threshold);



figWidth=400;
figHeight=200;
f = figure('Visible','off','Position',[0,0,figWidth,figHeight]);
f.Name='Gate Settings Interface';
f.WindowButtonMotionFcn=@GateUpdate;
f.NumberTitle='off';
f.MenuBar='none';
f.ToolBar='none';


GateParameters = uipanel('Tag','GateParameters','BackgroundColor',[.95,.95,.95],...
    'Units','normalized','Position',[.005, .2, .33-.005, 1-.2-.005]);

GatePopup=uicontrol(GateParameters,'Style','popupmenu',...
    'String',{'Gate 1','Gate 2','Gate 3', 'Gate 4'},...
    'Units','normalized','Position',[.15,.8,.7,1/6],...
    'Callback',@popup_menu_Callback);
EnableButton    = uicontrol(GateParameters,'Style', 'radiobutton',...
    'String','Enable','Units','normalized','Position',[.15,.63,.7,1/6],...
    'Tag','Fixed','Value',0,'Callback',@GateUpdate);

if ~isempty(CurrentGate.Visibility)
    EnableButton.Value=CurrentGate.Visibility;
end


uicontrol(GateParameters,'Style','text','Units','normalized',...
    'String','Gate Color','Position',[.15,.45,.7,1/6]);
GateColor=uicontrol(GateParameters,'Style','popupmenu','Value',1,...
    'String',{'Red','Green','Yellow','Blue ', 'Grey '},'Units','normalized',...
    'Position',[.15,.35,.7,1/6],'Callback',@GateUpdate);

uicontrol(GateParameters,'Style','text','Units','normalized',...
    'String','Line Width','Position',[.15,.15,.7,1/6]);
LineWidth=uicontrol(GateParameters,'Style','popupmenu',...
    'String',{'.5','1','2', '3','4','5'},'Value',1,...
    'Units','normalized','Position',[.15,.05,.7,1/6],...
    'Callback',@GateUpdate);


if ~isempty(CurrentGate.Thickness)
    LineWidth.Value=CurrentGate.Thickness;
end
if ~isempty(CurrentGate.Color)
    GateColor.Value=CurrentGate.Color;
end



GateInputs = uipanel('Tag','GateInputs','BackgroundColor',[.95,.95,.95],...
    'Units','normalized','Position',[.67, .2, .33-.005, 1-.2-.005]);

uicontrol(GateInputs,'Style','text','Units','normalized',...
    'String','Gate Start','Position',[.005,.8,.95,1/6]);
GateStart    = uicontrol(GateInputs,'Style','edit','Units','normalized',...
    'String',GStartString,'Position',[.15,.7,.7,1/6],'Callback',@GateUpdate);

uicontrol(GateInputs,'Style','text','Units','normalized',...
    'String','Gate Width','Position',[.005,.48,.95,1/6]);
GateWidth    = uicontrol(GateInputs,'Style','edit','Units','normalized',...
    'String',GWidthString,'Position',[.15,.38,.7,1/6],'Callback',@GateUpdate);

uicontrol(GateInputs,'Style','text','Units','normalized',...
    'String','Gate Threshold','Position',[.005,.16,.95,1/6]);
GateThreshold = uicontrol(GateInputs,'Style','edit','Units','normalized',...
    'String',GThresholdString,'Position',[.15,.05,.7,1/6],'Callback',@GateUpdate);



bg           = uibuttongroup('Visible','off','Title','Type of Gate',...
    'Units','normalized','Position',[.37 0.5 .25 .5]);

FixedGate    = uicontrol(bg,'Style', 'radiobutton', 'String','Fixed Gate',...
            'Units','normalized','Position',[.005 .5 .9 .5],'Tag','Fixed',...
            'Value',RadioValue(1),'Callback',@GateUpdate);

MovingGate   = uicontrol(bg,'Style', 'radiobutton', 'String','Moving Gate',...
            'Units','normalized','Position',[.005 .005 .9 .5],'Tag','Moving',...
            'Value',RadioValue(2),'Callback',@GateUpdate);


Apply        = uicontrol('Style','pushbutton','Units','normalized',...
    'String','Apply','Position',[.55,.005,.2,1/8],...
    'Callback',{@Apply_Callback, MainFig});

Close        = uicontrol('Style','pushbutton','Units','normalized',...
    'String','Close','Position',[.77,.005,.2,1/8],...
    'Callback',@Close_Callback);

f.Units             = 'normalized';
GateWidth.Units     = 'normalized';
GateStart.Units     = 'normalized';
GateThreshold.Units = 'normalized';
FixedGate.Units     = 'normalized';
MovingGate.Units    = 'normalized';
Apply.Units         = 'normalized';
Close.Units         = 'normalized';

movegui(f,'center')
bg.Visible = 'on';
set(gca,'Visible','off')
GateUpdate
f.Visible='on';


    function GateUpdate(~,~)
        GateInfo.CurrentGate=eval(['GateInfo.g',num2str(GatePopup.Value)]);
        GateInfo.CurrentGate.Visibility=EnableButton.Value;
        GateInfo.CurrentGate.Color=GateColor.Value;
        GateInfo.CurrentGate.Thickness=LineWidth.Value;
        GateInfo.CurrentGate.Start=str2double(GateStart.String);
        GateInfo.CurrentGate.Width=str2double(GateWidth.String);
        GateInfo.CurrentGate.Threshold=str2double(GateThreshold.String);
        GateInfo.CurrentGate.Type=FixedGate.Value;
        
        if FixedGate.Value==1
            GateThreshold.Enable='off';
        else
            GateThreshold.Enable='on';
        end
    end

    function popup_menu_Callback(Handle,~)
        GateInfo.CurrentGate=eval(['GateInfo.g',num2str(Handle.Value)]);
        
        if GateInfo.CurrentGate.Type==1
            FixedGate.Value=1;
            MovingGate.Value=0;
        else
            FixedGate.Value=0;
            MovingGate.Value=1;
        end
        
        GateWidth.String=num2str(GateInfo.CurrentGate.Width);
        GateStart.String=num2str(GateInfo.CurrentGate.Start);
        GateThreshold.String=num2str(GateInfo.CurrentGate.Threshold);
        GateColor.Value=GateInfo.CurrentGate.Color;
        LineWidth.Value=GateInfo.CurrentGate.Thickness;
        EnableButton.Value=GateInfo.CurrentGate.Visibility;
        if FixedGate.Value==1
            GateThreshold.Enable='off';
        else
            GateThreshold.Enable='on';
        end
        NullFiles=findobj(f,'Value',[]);
        for i=1:length(NullFiles)
           NullFiles(i).Value=1; 
        end
        
    end


    function Apply_Callback(~,~,MainFig)
%         GateOld
        GateUpdate
        if isempty(CurrentGate.Low)
            CurrentGate.Low=[0 1 100];
        end
        
        if isempty(CurrentGate.High)
            CurrentGate.High=[0 100 -100];
        end
        if isempty(CurrentGate.MouseClick)
            CurrentGate.MouseClick=0;
        end
        
        if isempty(Waves.waveform_matrix)==1
            errordlg(['Data has not yet been selected!',' Please select data before proceeding.'])
            return
        end
        for i=1:4
            GateInfo.CurrentGate=eval(['GateInfo.g',num2str(i)]);
            if GateInfo.CurrentGate.Visibility==1 && ~CheckDiff(GateInfo.CurrentGate,eval(['GateOld.g',num2str(i)]))
                ApplyGate(Waves.waveform_matrix,GateInfo.CurrentGate,ScanSettings);
                APanels=findobj('tag','APanel');
                for j=1:length(APanels)
                    APanel=APanels(j);
                    AxisInfo.Name=APanel.Children(end);
                    AxisInfo.Number=1;
                    AScanValue=APanel.Children(3).Value;
                    
                    if isempty(current_index)
                        [m,~]=size(Waves.waveform_matrix);
                        current_index=m/2;
                    end

                    switch AScanValue
                        case 1 %'Collected Waveform'
                            A_Scan_Plot_GUI(AxisInfo,Waves.waveform_matrix(current_index,:),current_index)
                        case 2 %'X-Corr Waveform'
                            A_Scan_Plot_GUI(AxisInfo,Waves.shifted_matrix(current_index,:),current_index)
                        otherwise
                            A_Scan_Plot_GUI(AxisInfo,Waves.waveform_matrix(current_index,:),current_index)
                    end
                end
            end
            OldGate(eval(['GateInfo.g',num2str(i)]),eval(['GateOld.g',num2str(i)]));
        end
        %         MainFig=findobj('name','C-Scan Plot Interface');
        Update_CScan_Callback(1,1,MainFig,0);
        figure(f)
    end

    function Close_Callback(~,~)
        
        close 'Gate Settings Interface'
    end


end
