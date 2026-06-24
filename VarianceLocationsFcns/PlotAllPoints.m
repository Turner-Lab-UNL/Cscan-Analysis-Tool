function NumberOfPoints=PlotAllPoints(Button,Ax,num)

global Draw
global ScanSettings

Draw.SelectedIndecies=unique(Draw.SelectedIndecies);
LineArray=findobj(Ax,'Type','Line');
if isempty(LineArray)
   NumberOfPoints=0;
   return
end
if contains(LineArray(1).Tag,'AddedRegionPoints')
    Button.Tag='';
end

if isempty(Button.Tag)
    [X,Y]=ind2sub([ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn],Draw.SelectedIndecies);
    X=X*ScanSettings.scan_res-ScanSettings.scan_res/2;
    Y=Y*ScanSettings.index_res-ScanSettings.index_res/2;
    
    NumLines=length(LineArray);
    if Draw.NumPlots+1>NumLines && ~isempty(X)
        hold(Ax,'on')
        Line1=plot(Ax,X,Y);
        Line1.Tag='TotalRegion';
        hold(Ax,'off')
    elseif Draw.NumPlots+1==NumLines
        Line1=LineArray(1);
        Line1.XData=X;
        Line1.YData=Y;
    end
    
    Line1.Color=[1 1 1];
    Line1.LineStyle='none';
    Line1.Marker='*';
    Line1.Tag='TotalRegion';
    if num==0
    Button.Tag='off';
    end
else
    if num==0
    Button.Tag='';
    end
    TotalRegionLine=findobj(Ax,'Tag','TotalRegion');
    if ~isempty(TotalRegionLine)
        delete(TotalRegionLine);
    end
    
end
NumberOfPoints=length(Draw.SelectedIndecies);

end