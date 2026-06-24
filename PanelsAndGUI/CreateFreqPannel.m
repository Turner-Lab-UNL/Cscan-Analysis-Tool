function [Freq,FreqPanel]=CreateFreqPannel(FigHandle)
global GateInfo


PanelTag='FreqPanel';

FigDim=[950,425];
ButtonWidth=90;
ButtonHigth=25;
DropDownWidth=100;
Displacment=0;
PlotPosition =[FigDim(1)*.03,FigDim(2)/5,FigDim(1)/3,FigDim(2)*.70];
ButtonShift = [0,10+PlotPosition(4) , ButtonWidth-PlotPosition(3), ButtonHigth- PlotPosition(4)];
DropShift = [DropDownWidth+Displacment,10+PlotPosition(4) , DropDownWidth-PlotPosition(3), ButtonHigth- PlotPosition(4)];

% Construct A-Scan Plot
FreqPanel= uipanel(FigHandle,'Tag',PanelTag,'BackgroundColor','white',...
    'Units','Points','Position',[0, 0, 300, 325]);
FreqPanel.Units='normalized';


Freq = axes(FreqPanel,'Units','Normalized','Position',[.07 .195 .8 .7],'Tag','Axes');
Freq.NextPlot='replacechildren';
% Freq.HitTest='off';
Freq.Toolbar.Visible = 'off';


GetFreqScan     = uicontrol(FreqPanel,'Style','pushbutton',...
    'String','Get','Units','normalized','Position', [.04 .91 .2 .075],...
    'Callback',@GetAScan_Callback,'Tag','Get');

ChooseGate = uicontrol(FreqPanel,'Style','popupmenu',...
    'String',{'Gate 1','Gate 2', 'Gate 3','Gate 4'},'Units','normalized',...
    'Position',[.26 .90 .2 .075],'Tag','GateSource',...
    'Callback',@ChooseGate_Callback);

Freeze=uicontrol(FreqPanel,'Style','pushbutton',...
    'String','Freeze','Units','normalized','Position',[.67, .91, .12 .075],...
    'Callback',@FreezeFrame_Callback,'Tag','SingleCross','HitTest','off');

SingleCrosshair    = uicontrol(FreqPanel,'Style','pushbutton',...
    'String','+','Units','normalized','Position',[.81, .91, .075 .075],...
    'Callback',@SingleCrosshair_Callback,'Tag','SingleCross');

DoubleCrosshair    = uicontrol(FreqPanel,'Style','pushbutton',...
    'String','++','Units','normalized','Position',[.9 .91 .075 .075],...
    'Callback',@DoubleCrosshair_Callback,'Tag','DoubleCross');

FeedbackPanel = uipanel('Parent',FreqPanel,'BackgroundColor',[.8 .8 .8],'Visible','on',...
    'Units','Normalized','Position',[0.0002,.0002,.52,.13],'Tag','PositionPanel');

curser_string=uicontrol(FeedbackPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Curser Output','Units','normalized','Position',...
    [.02 .21 .5 .77],'HorizontalAlignment','left');
Amplitude_Val=uicontrol(FeedbackPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Frequency = ','Units','normalized','Position',...
    [.02 -.3 .6 .77],'Tag','Scan','HorizontalAlignment','left');
Time_Val=uicontrol(FeedbackPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Amplitude = ','Units','normalized','Position',...
    [.51 -.3 .6 .77],'Tag','Index','HorizontalAlignment','left');

GateInfo.CurrentGate.AScanNumStr='Collected Waveform';

GetFreqScan.HitTest='off';
ChooseGate.HitTest='off';
Freeze.HitTest='off';
SingleCrosshair.HitTest='off';
DoubleCrosshair.HitTest='off';
FeedbackPanel.HitTest='off';
curser_string.HitTest='off';
Amplitude_Val.HitTest='off';
Time_Val.HitTest='off';


    function ChooseGate_Callback(source,~)
        global CurrentIndex
        
        if isempty(CurrentIndex)
           CurrentIndex=1; 
        end
        str = get(source, 'String');
        val = get(source,'Value');
        GateInfo.CurrentGate.AScanNumStr=str{val};
        UpdatePanel=source.Parent;
        FreqScanAxes=UpdatePanel.Children(end);
        AxisInfo.Name=FreqScanAxes;
        AxisInfo.Number=UpdatePanel.Parent.Number;
        FreqScanAxes.NextPlot='replacechildren';
        gate=eval(['GateInfo.g',num2str(val)]);
    
        if ~isempty(gate.fft_data)
            Freq_Scan_Plot_GUI(AxisInfo,gate.fft_data(CurrentIndex,:),gate.fft_freq)
        else
            Freq_Scan_Plot_GUI(AxisInfo,zeros(50,1),1:50)
        end
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
        copyobj(Freq,fig);
        set(gca,'ActivePositionProperty','outerposition')
        set(gca,'Units','normalized')
        set(gca,'OuterPosition',[0 0 1 1])
        set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
    end


    function SingleCrosshair_Callback(Button,Event)
        if ~isempty(Freq.Children)
            ChangeButtons(FigHandle,Button);
            SingleCrosshair_Function(Button,Event,FigHandle,Freq,[Amplitude_Val,Time_Val],@UpdateAPanelText)
        end
    end

    function DoubleCrosshair_Callback(Button,Event)
        if ~isempty(Freq.Children)
            ChangeButtons(FigHandle,Button);
            DoubleCrosshair_Function(Button,Event,FigHandle,Freq,[Amplitude_Val,Time_Val],@UpdateAPanelText)
        end
    end


    function FreezeFrame_Callback(a,~)
        
        if a.BackgroundColor==[0 1 1]
            h=findobj(Freq.Children,'Tag','FreezeFrame');
            delete(h)
            
            a.BackgroundColor=[0.94 .94 .94];
            
        else
            if ~isempty(Freq.Children)
                xdata=Freq.Children(end).XData;
                ydata=Freq.Children(end).YData;
                hold(Freq,'on')
                frozen=plot(Freq,xdata,ydata,'c');
                hold(Freq,'off')
                frozen.Tag='FreezeFrame';
                a.BackgroundColor=[0 1 1];
            end
        end
        
    end

end