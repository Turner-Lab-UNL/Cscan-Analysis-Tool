function CrosshairUpdateZoom(~,~,Ax)
Lines=findobj(Ax.Children,'Tag','CrossHair');
if length(Lines)==4
VertLine1=Lines(end);
HorzLine1=Lines(end-1);
VertLine2=Lines(end-2);
HorzLine2=Lines(end-3);


HorzLine1.XData=Ax.XLim;
HorzLine1.LineWidth=.5;
HorzLine2.XData=Ax.XLim;
HorzLine2.LineWidth=.5;
VertLine1.YData=Ax.YLim;
VertLine1.LineWidth=.5;
VertLine2.YData=Ax.YLim;
VertLine2.LineWidth=.5;
end

if length(Lines)==2
VertLine1=Lines(end);
HorzLine1=Lines(end-1);

HorzLine1.XData=Ax.XLim;
HorzLine1.LineWidth=.5;
VertLine1.YData=Ax.YLim;
VertLine1.LineWidth=.5;
end


end