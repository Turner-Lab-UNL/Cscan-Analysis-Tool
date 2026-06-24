function ReplotLineData(f,~)
global KeepArray
global SubtractArray
global ax_C_Vector

for k=1:length(ax_C_Vector)
Ax=ax_C_Vector{k};

Update_CScan_Callback(1,1,f,0);
hold(Ax,'on')

KL=length(KeepArray);
SL=length(SubtractArray);

for i=1:KL
    PlotHandle=plot(Ax,KeepArray{i}.XData,KeepArray{i}.YData,'r');
    PlotHandle.LineStyle='-';
    NameWithNum=KeepArray{i}.Name;
    SpaceLocation=find(NameWithNum==' ');
    PlotHandle.Tag=NameWithNum(1:SpaceLocation-1);
    if isempty(KeepArray{i}.Index)
        PlotHandle.Visible='off';
    else
        PlotHandle.Visible='on';
    end
end

for i=1:SL
    PlotHandle=plot(Ax,SubtractArray{i}.XData,SubtractArray{i}.YData,'r');
    PlotHandle.LineStyle='-';
    NameWithNum=SubtractArray{i}.Name;
    SpaceLocation=find(NameWithNum==' ');
    PlotHandle.Tag=NameWithNum(1:SpaceLocation-1);
    if isempty(SubtractArray{i}.Index)
        PlotHandle.Visible='off';
    else
        PlotHandle.Visible='on';
    end
end

hold(Ax,'off')
end
end