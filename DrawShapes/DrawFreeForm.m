function DrawFreeForm(Line,XStartPos,XCurrentPos, YStartPos,YCurrentPos)
global ScanSettings
global OldPosition
global ax_C_Vector

OldXData=Line.XData-ScanSettings.scan_res/2+ScanSettings.scan_res;
OldYData=Line.YData-ScanSettings.index_res/2+ScanSettings.index_res;
if isempty(OldPosition)
    OldPosition(1)=XStartPos;
    OldPosition(2)=YStartPos;
end

ChangeX=(OldPosition(1)-XCurrentPos)/ScanSettings.scan_res;
ChangeY=(OldPosition(2)-YCurrentPos)/ScanSettings.index_res;
if ChangeX^2+ChangeY^2 <1
    return
end

if length(OldXData)==1
    
    P1=[XStartPos,YStartPos]+[ScanSettings.scan_res,ScanSettings.index_res];
    P2=[XCurrentPos,YCurrentPos]+[ScanSettings.scan_res,ScanSettings.index_res];
    KeepVector = LineFinder( P1, P2, ScanSettings.IndexPerRow, ScanSettings.IndexPerColumn, ScanSettings.scan_res, ScanSettings.index_res,'Plot_No');
    [Xs,Ys]=ind2sub([ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn],KeepVector);
    Xs=sort(Xs)';
    Ys=sort(Ys)';
    if Xs(1)<P1(1)/ScanSettings.scan_res+1 && Xs(1)>P1(1)/ScanSettings.scan_res-1
        %Good
    else
        Xs=fliplr(Xs);
    end
    if Ys(1)<P1(2)/ScanSettings.index_res+1 && Ys(1)>P1(2)/ScanSettings.index_res-1
        %Good
    else
        Ys=fliplr(Ys);
    end
    
    Line.XData=Xs*ScanSettings.scan_res+ScanSettings.scan_res/2;
    Line.YData=Ys*ScanSettings.index_res+ScanSettings.index_res/2;
else
    %    OldPosition
    P1=OldPosition+[ScanSettings.scan_res,ScanSettings.index_res];
    P2=[XCurrentPos,YCurrentPos]+[ScanSettings.scan_res,ScanSettings.index_res];
    KeepVector = LineFinder( P1, P2, ScanSettings.IndexPerRow, ScanSettings.IndexPerColumn, ScanSettings.scan_res, ScanSettings.index_res,'Plot_No');
    [Xs,Ys]=ind2sub([ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn],KeepVector);
    Xs=sort(Xs)';
    Ys=sort(Ys)';
    
    if Xs(1)<P1(1)/ScanSettings.scan_res+1 && Xs(1)>P1(1)/ScanSettings.scan_res-1
        %Good
    else
        Xs=fliplr(Xs);
    end
    if Ys(1)<P1(2)/ScanSettings.index_res+1 && Ys(1)>P1(2)/ScanSettings.index_res-1
        %Good
    else
        Ys=fliplr(Ys);
    end
    Line.XData=[OldXData,Xs(2:end)*ScanSettings.scan_res]+ScanSettings.scan_res/2;
    Line.YData=[OldYData,Ys(2:end)*ScanSettings.index_res]+ScanSettings.index_res/2;
end

Line.XData=Line.XData-ScanSettings.scan_res;
Line.YData=Line.YData-ScanSettings.index_res;
OldPosition=[XCurrentPos,YCurrentPos];


for i=1:length(ax_C_Vector)
    if isvalid(ax_C_Vector{i})
        
        line_change=findobj(ax_C_Vector{i}.Children,'Tag','Free Form');
        if isempty(line_change)
%             ax_C_Vector{i}.Parent
%             line_change=plot(ax_C_Vector{i},1,1);
%             line_change.Tag='Free Form';
        else
        line_change(1).XData=Line.XData;
        line_change(1).YData=Line.YData;
        line_change(1).Color='r';
        line_change(1).LineStyle='-';
        line_change(1).Marker='none';
        end
    end
end

end