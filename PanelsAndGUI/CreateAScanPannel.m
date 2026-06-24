function [AScanAxes,APanel]=CreateAScanPannel(FigHandle)
global GateInfo
global ScanSettings

PanelTag='APanel';

% FigDim=[950,425];
% ButtonWidth=90;
% ButtonHigth=25;
% DropDownWidth=100;
% Displacment=0;
% PlotPosition =[FigDim(1)*.03,FigDim(2)/5,FigDim(1)/3,FigDim(2)*.70];
% ButtonShift = [0,10+PlotPosition(4) , ButtonWidth-PlotPosition(3), ButtonHigth- PlotPosition(4)];
% DropShift = [DropDownWidth+Displacment,10+PlotPosition(4) , DropDownWidth-PlotPosition(3), ButtonHigth- PlotPosition(4)];

% Construct A-Scan Plot
APanel= uipanel(FigHandle,'Tag',PanelTag,'BackgroundColor','white',...
    'Units','Points','Position',[0, 0, 300, 325]);
APanel.Units='normalized';


AScanAxes = axes(APanel,'Units','Normalized','Position',[.07 .195 .8 .7],'Tag','Axes');
AScanAxes.NextPlot='replacechildren';
if ~isempty(ScanSettings.w_s)
   AScanAxes.XLim=([0,ScanSettings.w_w]+ScanSettings.w_s);
   AScanAxes.YLim=([-1,1]);
end


% AScanAxes.HitTest='off';
AScanAxes.Toolbar.Visible = 'off';

GetAScan     = uicontrol(APanel,'Style','pushbutton',...
    'String','Get','Units','normalized','Position', [.04 .91 .2 .075],...
    'Callback',@GetAScan_Callback,'Tag','Get');

ChooseAScan = uicontrol(APanel,'Style','popupmenu',...
    'String',{'Collected Waveform'},'Units','normalized',...
    'Position',[.26 .90 .2 .075],'Tag','Waveform_Source',...
    'Callback',@ChooseAScan_menu_Callback);

Rectification = uicontrol(APanel,'Style','popupmenu',...
    'String',{'Full Waveform','Full Rectification','Postive','Negative',},'Units','normalized',...
    'Position',[.47 .90 .20 .075],'Tag','Rectification',...
    'Callback',@ChooseAScanType_Callback);

Freeze=uicontrol(APanel,'Style','pushbutton',...
    'String','Freeze','Units','normalized','Position',[.67, .91, .12 .075],...
    'Callback',@FreezeFrame_Callback,'Tag','Freeze');

SingleCrosshair    = uicontrol(APanel,'Style','togglebutton',...
    'String','+','Units','normalized','Position',[.81, .91, .075 .075],...
    'Callback',@SingleCrosshair_Callback,'Tag','SingleCross');

DoubleCrosshair    = uicontrol(APanel,'Style','togglebutton',...
    'String','++','Units','normalized','Position',[.9 .91 .075 .075],...
    'Callback',@DoubleCrosshair_Callback,'Tag','DoubleCross');

FeedbackPanel = uipanel('Parent',APanel,'BackgroundColor',[.8 .8 .8],'Visible','on',...
    'Units','Normalized','Position',[0.0002,.0002,.52,.13],'Tag','PositionPanel');

curser_string=uicontrol(FeedbackPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Curser Output','Units','normalized','Position',[.02 .21 .5 .77],'HorizontalAlignment','left');
Amplitude_Val=uicontrol(FeedbackPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Time = ','Units','normalized','Position',[.02 -.3 .6 .77],'Tag','Scan','HorizontalAlignment','left');
Time_Val=uicontrol(FeedbackPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Amplitude = ','Units','normalized','Position',[.51 -.3 .6 .77],'Tag','Index','HorizontalAlignment','left');

GateInfo.CurrentGate.AScanNumStr='Collected Waveform';


GetAScan.HitTest='off';
ChooseAScan.HitTest='off';
Rectification.HitTest='off';
Freeze.HitTest='off';
SingleCrosshair.HitTest='off';
DoubleCrosshair.HitTest='off';
FeedbackPanel.HitTest='off';
curser_string.HitTest='off';
Amplitude_Val.HitTest='off';
Time_Val.HitTest='off';


    function ChooseAScan_menu_Callback(source,~)
        str = get(source, 'String');
        val = get(source,'Value');
        GateInfo.CurrentGate.AScanNumStr=str{val};
        
    end

    function ChooseAScanType_Callback(source,~)
        global CurrentIndex
        global Waves
        
        current_ax=findobj(source.Parent,'Type','Axes');
        if isempty(current_ax.Children)
            return
        end
        
        wave_plot=source.Value;
        freeze_lines=findobj(current_ax,'Tag','FreezeFrame');
        wave_source=findobj(source.Parent,'Tag','Waveform_Source');
        
        wave=current_ax.Children(end-4);
        
        if wave_source.Value==2
            WaveformLine=Waves.shifted_matrix(CurrentIndex,:);
        else
            WaveformLine=Waves.waveform_matrix(CurrentIndex,:);
        end
        
        
        
        if wave_plot==2
            WaveformLine=abs(WaveformLine);
            if current_ax.YLim(2)==0
                current_ax.YLim(2)=abs(current_ax.YLim(1));
            end
            if current_ax.YLim(1)<0
                current_ax.YLim(1)=0;
            end
        elseif wave_plot==3
            WaveformLine(WaveformLine<0)=0;
            if current_ax.YLim(2)==0
                current_ax.YLim(2)=abs(current_ax.YLim(1));
            end
            if current_ax.YLim(1)<0
                current_ax.YLim(1)=0;
            end
        elseif wave_plot ==4
            WaveformLine(WaveformLine>0)=0;
            if current_ax.YLim(1)==0
                current_ax.YLim(1)=-abs(current_ax.YLim(2));
            end
            if current_ax.YLim(2)>0
                current_ax.YLim(2)=0;
            end
        else
            if current_ax.YLim(1)==0
                current_ax.YLim(1)=-abs(current_ax.YLim(2));
            end
            if current_ax.YLim(2)==0
                current_ax.YLim(2)=abs(current_ax.YLim(1));
            end
        end
        wave.YData=WaveformLine;
    end

    function GetAScan_Callback(~,~)
        fig=figure;clf;
        copyobj(AScanAxes,fig);
        set(gca,'ActivePositionProperty','outerposition')
        set(gca,'Units','normalized')
        set(gca,'OuterPosition',[0 0 1 1])
        set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
    end


%     function SingleCrosshair_Callback(Button,Event)
%         if ~isempty(AScanAxes.Children)
%             ChangeButtons(FigHandle,Button);
%             SingleCrosshair_Function(Button,Event,FigHandle,AScanAxes,[Amplitude_Val,Time_Val],@UpdateAPanelText)
%         end
% end

    function SingleCrosshair_Callback(Button,Event)
        f=gcf;
        f.WindowButtonDownFcn=[];
        f.WindowButtonUpFcn=[];
        f.WindowButtonMotionFcn=[];
        
        if ~isempty(AScanAxes.Children)
            val=Button.Value;
            if val==1
                toggles=findobj(f,'Style','togglebutton');
                for i=1:length(toggles)
                    toggles(i).Value=0;
                end
                Button.Value=1;
                SingleCrosshair_Function(Button,Event,FigHandle,AScanAxes,[Amplitude_Val,Time_Val],@UpdateAPanelText);
            else
                SingleCrosshair_Function(Button,Event,FigHandle,AScanAxes,[Amplitude_Val,Time_Val],@UpdateAPanelText);
            end
        end
    end

%     function DoubleCrosshair_Callback(Button,Event)
%         if ~isempty(AScanAxes.Children)
%             ChangeButtons(FigHandle,Button);
%             DoubleCrosshair_Function(Button,Event,FigHandle,AScanAxes,[Amplitude_Val,Time_Val],@UpdateAPanelText)
%         end
%     end

    function DoubleCrosshair_Callback(Button,Event)
        f=gcf;
        f.WindowButtonDownFcn=[];
        f.WindowButtonUpFcn=[];
        f.WindowButtonMotionFcn=[];
        
        if ~isempty(AScanAxes.Children)
            val=Button.Value;
            if val==1
                toggles=findobj(f,'Style','togglebutton');
                for i=1:length(toggles)
                    toggles(i).Value=0;
                end
                Button.Value=1;
                DoubleCrosshair_Function(Button,Event,FigHandle,AScanAxes,[Amplitude_Val,Time_Val],@UpdateAPanelText);
            else
                DoubleCrosshair_Function(Button,Event,FigHandle,AScanAxes,[Amplitude_Val,Time_Val],@UpdateAPanelText);
            end
        end
    end

    function FreezeFrame_Callback(a,~)
        
        if a.BackgroundColor==[0 1 1]
            h=findobj(AScanAxes.Children,'Tag','FreezeFrame');
            delete(h)
            
            a.BackgroundColor=[0.94 .94 .94];
            
        else
            if ~isempty(AScanAxes.Children)
                xdata=AScanAxes.Children(end-4).XData;
                ydata=AScanAxes.Children(end-4).YData;
                hold(AScanAxes,'on')
                frozen=plot(AScanAxes,xdata,ydata,'c');
                hold(AScanAxes,'off')
                frozen.Tag='FreezeFrame';
                a.BackgroundColor=[0 1 1];
            end
        end
        
    end

end