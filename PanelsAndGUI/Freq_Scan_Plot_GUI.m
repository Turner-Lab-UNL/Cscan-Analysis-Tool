function Freq_Scan_Plot_GUI(AxisInfo,WaveformLine,xdata)

AxisInfo.Name.NextPlot='replacechildren';

cross_lines=findobj(AxisInfo.Name,'Tag','CrossHair');
freeze_lines=findobj(AxisInfo.Name,'Tag','FreezeFrame');

cross_tag='CrossHair';
if ~isempty(cross_lines)
    if length(cross_lines)==2
        cross_xdata3=0;
        cross_ydata3=0;
        cross_xdata4=0;
        cross_ydata4=0;
        c3='none';
        c4='none';
        
        cross_xdata1=cross_lines(2).XData;
        cross_ydata1=cross_lines(2).YData;
        cross_xdata2=cross_lines(1).XData;
        cross_ydata2=cross_lines(1).YData;
        c1='r';
        c2='r';
    elseif length(cross_lines)==4
        cross_xdata1=cross_lines(4).XData;
        cross_ydata1=cross_lines(4).YData;
        cross_xdata2=cross_lines(3).XData;
        cross_ydata2=cross_lines(3).YData;
        c1='c';
        c2='c';
        cross_xdata3=cross_lines(2).XData;
        cross_ydata3=cross_lines(2).YData;
        cross_xdata4=cross_lines(1).XData;
        cross_ydata4=cross_lines(1).YData;
        c3='r';
        c4='r';
        
    else
        cross_xdata1=0;
        cross_xdata2=0;
        cross_xdata3=0;
        cross_xdata4=0;
        cross_ydata1=0;
        cross_ydata2=0;
        cross_ydata3=0;
        cross_ydata4=0;
        c1='none';
        c2='none';
        c3='none';
        c4='none';
        
    end
    
else
    cross_xdata1=0;
    cross_xdata2=0;
    cross_xdata3=0;
    cross_xdata4=0;
    cross_ydata1=0;
    cross_ydata2=0;
    cross_ydata3=0;
    cross_ydata4=0;
    c1='none';
    c2='none';
    c3='none';
    c4='none';
end




if isempty(freeze_lines)

plot(AxisInfo.Name,xdata,WaveformLine,...
    cross_xdata1,cross_ydata1,...
    cross_xdata2,cross_ydata2,...
    cross_xdata3,cross_ydata3,...
    cross_xdata4,cross_ydata4);
    AxisInfo.Name.Children(end-4).Color=[0 0 1];
else

    freeze_y=freeze_lines.YData;
    freeze_x=freeze_lines.XData;
    
plot(AxisInfo.Name,freeze_x,freeze_y,...
    xdata,WaveformLine,...
    cross_xdata1,cross_ydata1,...
    cross_xdata2,cross_ydata2,...
    cross_xdata3,cross_ydata3,...
    cross_xdata4,cross_ydata4);

    AxisInfo.Name.Children(end).Color=[0 1 1];
    AxisInfo.Name.Children(end).Tag='FreezeFrame';
    AxisInfo.Name.Children(end-1).Color=[0 0 1];
end


AxisInfo.Name.Children(1).Color=c1;
AxisInfo.Name.Children(2).Color=c2;
AxisInfo.Name.Children(3).Color=c3;
AxisInfo.Name.Children(4).Color=c4;

AxisInfo.Name.Children(1).Tag=cross_tag;
AxisInfo.Name.Children(2).Tag=cross_tag;
AxisInfo.Name.Children(3).Tag=cross_tag;
AxisInfo.Name.Children(4).Tag=cross_tag;
end