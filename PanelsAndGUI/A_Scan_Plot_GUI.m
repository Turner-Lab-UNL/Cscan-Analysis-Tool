function A_Scan_Plot_GUI(AxisInfo,WaveformLine,current_index)
global ScanSettings
global GateInfo

GColor=zeros(4,3);
GThickness=zeros(4,1);
Gs=zeros(4,1);
Ge=zeros(4,1);

AxisInfo.Name.NextPlot='replacechildren';
Limits=AxisInfo.Name.YLim;
Ratio=10/Limits(2);

GateShape=[-1,1,0,0,1,-1]/Ratio;
NumGates=0;
panel=AxisInfo.Name.Parent;

% firstFour=AxisInfo.Name.Children(1:4);
% temp=1;
% for i=1:length(firstFour)
%     if contains(firstFour(i).Tag,'CrossHair')
%     cross_lines(temp)=firstFour(i);
%     temp=temp+1;
%     end
% end
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



for i=1:4
    
    NumGates=NumGates+1;
    if eval(['GateInfo.g',num2str(i),'.Visibility'])==1 %Enabled or Disabled
        if eval(['GateInfo.g',num2str(i),'.Type'])==0 % Moving Gate
            t=eval(['GateInfo.g',num2str(i),'.ThreshShift(',num2str(current_index),')']);
            if t~=0
                Gs(NumGates)=ScanSettings.t(eval(['GateInfo.g',num2str(i),'.ThreshShift(',num2str(current_index),')']))+eval(['GateInfo.g',num2str(i),'.Start']);
                Ge(NumGates)=eval(['GateInfo.g',num2str(i),'.Width'])+Gs(NumGates);
            end
        else % Fixed Gate
            Gs(NumGates)=eval(['GateInfo.g',num2str(i),'.Start']);
            Ge(NumGates)=eval(['GateInfo.g',num2str(i),'.Width + GateInfo.g',num2str(i),'.Start']);
        end
    else
        Gs(NumGates)=-1;
        Ge(NumGates)=-1;
    end
    
    
    switch eval(['GateInfo.g',num2str(i),'.Color'])+5-eval(['GateInfo.g',num2str(i),'.Visibility'])*5
        case 1 %red
            GColor(NumGates,:)=[1 0 0];
        case 2 %Green
            GColor(NumGates,:)=[0 0.7 0];
        case 3 % Yellow
            GColor(NumGates,:)=[0.8 0.8 0];
        case 4 % Blue
            GColor(NumGates,:)=[0 0 1];
        case 5 %Grey
            GColor(NumGates,:)=[0.1 0.1 0.1];
        otherwise
            GColor(NumGates,:)=[1 1 1 ];
    end
    switch eval(['GateInfo.g',num2str(i),'.Thickness'])+5-eval(['GateInfo.g',num2str(i),'.Visibility'])*5
        case 1 %red
            GThickness(NumGates,:)=.5;
        case 2 %Green
            GThickness(NumGates,:)=1;
        case 3 % Yellow
            GThickness(NumGates,:)=2;
        case 4 % Blue
            GThickness(NumGates,:)=3;
        case 5 %Grey
            GThickness(NumGates,:)=4;
        case 6
            GThickness(NumGates,:)=5;
        otherwise
            
            GThickness(NumGates,:)=0.1;
    end
end


wave_button=findobj(panel,'Tag','Rectification');
wave_plot=wave_button.Value;


if wave_plot==2
    WaveformLine=abs(WaveformLine);
    if AxisInfo.Name.YLim(1)<0
        AxisInfo.Name.YLim(1)=0;
    end
elseif wave_plot==3
    WaveformLine(WaveformLine<0)=0;
    if AxisInfo.Name.YLim(1)<0
        AxisInfo.Name.YLim(1)=0;
    end
elseif wave_plot ==4
    WaveformLine(WaveformLine>0)=0;
   if AxisInfo.Name.YLim(2)>0 
       AxisInfo.Name.YLim(2)=0;
   end

else
    if AxisInfo.Name.YLim(1)==0 
    AxisInfo.Name.YLim(1)=-abs(AxisInfo.Name.YLim(2));
    end
    
   if AxisInfo.Name.YLim(2)==0 
       AxisInfo.Name.YLim(2)=abs(AxisInfo.Name.YLim(1));
   end
end

if isempty(freeze_lines)


plot(AxisInfo.Name,[Gs(4),Gs(4),Gs(4),Ge(4),Ge(4),Ge(4)],GateShape,...
    [Gs(3),Gs(3),Gs(3),Ge(3),Ge(3),Ge(3)],GateShape,...
    [Gs(2),Gs(2),Gs(2),Ge(2),Ge(2),Ge(2)],GateShape,...
    [Gs(1),Gs(1),Gs(1),Ge(1),Ge(1),Ge(1)],GateShape,...
    ScanSettings.t,WaveformLine,...
    cross_xdata1,cross_ydata1,...
    cross_xdata2,cross_ydata2,...
    cross_xdata3,cross_ydata3,...
    cross_xdata4,cross_ydata4);
    AxisInfo.Name.Children(end-4).Color=[0 0 1];
else
    
    freeze_y=freeze_lines.YData;
plot(AxisInfo.Name,[Gs(4),Gs(4),Gs(4),Ge(4),Ge(4),Ge(4)],GateShape,...
    [Gs(3),Gs(3),Gs(3),Ge(3),Ge(3),Ge(3)],GateShape,...
    [Gs(2),Gs(2),Gs(2),Ge(2),Ge(2),Ge(2)],GateShape,...
    [Gs(1),Gs(1),Gs(1),Ge(1),Ge(1),Ge(1)],GateShape,...
    ScanSettings.t,freeze_y,...
    ScanSettings.t,WaveformLine,...
    cross_xdata1,cross_ydata1,...
    cross_xdata2,cross_ydata2,...
    cross_xdata3,cross_ydata3,...
    cross_xdata4,cross_ydata4);

    AxisInfo.Name.Children(end-4).Color=[0 1 1];
    AxisInfo.Name.Children(end-4).Tag='FreezeFrame';
    AxisInfo.Name.Children(end-5).Color=[0 0 1];
end


AxisInfo.Name.Children(1).Color=c1;
AxisInfo.Name.Children(2).Color=c2;
AxisInfo.Name.Children(3).Color=c3;
AxisInfo.Name.Children(4).Color=c4;

AxisInfo.Name.Children(end-3).Color=GColor(1,:);
AxisInfo.Name.Children(end-2).Color=GColor(2,:);
AxisInfo.Name.Children(end-1).Color=GColor(3,:);
AxisInfo.Name.Children(end).Color=GColor(4,:);


AxisInfo.Name.Children(end-3).LineWidth=GThickness(1);
AxisInfo.Name.Children(end-2).LineWidth=GThickness(2);
AxisInfo.Name.Children(end-1).LineWidth=GThickness(3);
AxisInfo.Name.Children(end).LineWidth=GThickness(4);


AxisInfo.Name.Children(1).Tag=cross_tag;
AxisInfo.Name.Children(2).Tag=cross_tag;
AxisInfo.Name.Children(3).Tag=cross_tag;
AxisInfo.Name.Children(4).Tag=cross_tag;
end