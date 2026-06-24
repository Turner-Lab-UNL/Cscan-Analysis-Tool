function [CScanAxes,CPanel]=CreateCScanPannel(FigHandle)
global GateInfo;
PanelTag='CPanel';

% Construct C-Scan Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CPanel= uipanel('Parent',FigHandle,'Tag',PanelTag,'BackgroundColor','white','Visible','on',...
    'Units','Normalized','Position',[0, 0, .5, .5]);
%             CPanel.ButtonDownFcn@ButtonDownFnc_axis;
CPanel.Units='normalized';

CScanAxes = axes(CPanel,'Units','Normalized','Position',[.07 .195 .8 .7],'Tag','Axes');
CScanAxes.NextPlot='replacechildren';
% CScanAxes.HitTest='off';
CScanAxes.Toolbar.Visible = 'off';

GetCScan    = uicontrol(CPanel,'Style','pushbutton',...
    'String','Get','Units','normalized','Position', [.04 .91 .2 .075],...
    'Callback',@GetCScan_Callback,'Tag','Get');

ChooseCType = uicontrol(CPanel,'Style','popupmenu',...
    'String',{'Amp','TOF'},'Units','normalized','Position',[.26 .90 .25 .075],...
    'Callback',{@Update_CScan_Callback,FigHandle,0},'Tag','ChooseType');

SingleCrosshair    = uicontrol(CPanel,'Style','togglebutton',...
    'String','+','Units','normalized','Position',[.81, .91, .075 .075],...
    'Callback',@SingleCrosshair_Callback,'Tag','SingleCross');

DoubleCrosshair    = uicontrol(CPanel,'Style','togglebutton',...
    'String','++','Units','normalized','Position',[.9 .91 .075 .075],...
    'Callback',@DoubleCrosshair_Callback,'Tag','DoubleCross');


GateNumber = uicontrol(CPanel,'Style','popupmenu',...
    'String',{'Gate 1','Gate 2', 'Gate 3','Gate 4'},'Units','normalized',...
    'Position',[.54 .9 .25 .075],...
    'Callback',{@Update_CScan_Callback,FigHandle,0},'Tag','GateNumber');

PositionPanel = uipanel('Parent',CPanel,'BackgroundColor',[.8 .8 .8],'Visible','on',...
    'Units','Normalized','Position',[0.0002,.0002,.52,.13],'Tag','PositionPanel');

position_text=uicontrol(PositionPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Position','Units','normalized','Position',[.02 .21 .5 .77],'HorizontalAlignment','left');
ScanPosition=uicontrol(PositionPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Scan =','Units','normalized','Position',[.02 -.3 .6 .77],'Tag','Scan','HorizontalAlignment','left');
IndexPosition=uicontrol(PositionPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Index = ','Units','normalized','Position',[.51 -.3 .6 .77],'Tag','Index','HorizontalAlignment','left');


LowPallet       = uicontrol(CPanel,'Style','text','BackgroundColor','White',...
    'Units','Normalized','String','Low Pallet','Position',[.52 .01 .2 .05]);

LowPalletValue  = uicontrol(CPanel,'Style','edit','Units','Normalized',...
    'String','0','Position',[.72 .01 .2 .05],...
    'Callback',{@Update_CScan_Callback,FigHandle,0},'Tag','LowPalletValue');

HighPallet       = uicontrol(CPanel,'Style','text','BackgroundColor','White',...
    'Units','Normalized','String','High Pallet','Position',[.52,.063,.2,.05]);

HighPalletValue   = uicontrol(CPanel,'Style','edit','Units','Normalized',...
    'String',num2str(GateInfo.CurrentGate.High(1)),'Position',[.72,.063,.2,.05],...
    'Callback',{@Update_CScan_Callback,FigHandle,0},'Tag','HighPalletValue');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetCScan.HitTest='off';
ChooseCType.HitTest='off';
GateNumber.HitTest='off';
SingleCrosshair.HitTest='off';
DoubleCrosshair.HitTest='off';
PositionPanel.HitTest='off';
position_text.HitTest='off';
ScanPosition.HitTest='off';
IndexPosition.HitTest='off';
LowPallet.HitTest='off';
LowPalletValue.HitTest='off';
HighPallet.HitTest='off';
HighPalletValue.HitTest='off';
CPanel.Visible='On';

    function GetCScan_Callback(~,~)
        fig=figure;clf;
        copyobj(CScanAxes,fig);
        set(gca,'ActivePositionProperty','outerposition')
        set(gca,'Units','normalized')
        set(gca,'OuterPosition',[0 0 1 1])
        set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
        DeletedLines=findobj(fig,'Visible','off');
        if ~isempty(DeletedLines)
            delete(DeletedLines)
        end
        colorbar;
    end


    function SingleCrosshair_Callback(Button,Event)
        f=gcf;
        f.WindowButtonDownFcn=[];
        f.WindowButtonUpFcn=[];
        f.WindowButtonMotionFcn=[];
        
        if ~isempty(CScanAxes.Children)
            %             ChangeButtons(FigHandle,Button);
            val=Button.Value;
            f=gcf;
            if val==1
                toggles=findobj(f,'Style','togglebutton');
                for i=1:length(toggles)
                    toggles(i).Value=0;
                end
                Button.Value=1;
                clear update_function
                update_function=@UpdateTextAndWaveform;
                SingleCrosshair_Function(Button,Event,FigHandle,CScanAxes,[ScanPosition,IndexPosition],update_function);
            else
                clear update_function
                update_function=@UpdateTextAndWaveform;
                SingleCrosshair_Function(Button,Event,FigHandle,CScanAxes,[ScanPosition,IndexPosition],update_function);
            end
        end
    end

    function DoubleCrosshair_Callback(Button,Event)
        f=gcf;
        f.WindowButtonDownFcn=[];
        f.WindowButtonUpFcn=[];
        f.WindowButtonMotionFcn=[];
        
        if ~isempty(CScanAxes.Children)
            %             ChangeButtons(FigHandle,Button);
            val=Button.Value;
            f=gcf;
            if val==1
                toggles=findobj(f,'Style','togglebutton');
                for i=1:length(toggles)
                    toggles(i).Value=0;
                end
                Button.Value=1;
                update_function=@UpdateTextAndWaveform;
                DoubleCrosshair_Function(Button,Event,FigHandle,CScanAxes,[ScanPosition,IndexPosition],update_function)
            else
                clear update_function
                update_function=@UpdateTextAndWaveform;
                SingleCrosshair_Function(Button,Event,FigHandle,CScanAxes,[ScanPosition,IndexPosition],update_function);
            end
            
            
        end
    end
end