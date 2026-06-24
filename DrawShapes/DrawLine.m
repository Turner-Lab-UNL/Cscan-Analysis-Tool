function Line=DrawLine(Line, XStartPos,XCurrentPos, YStartPos,YCurrentPos)
global VarArray
global ScanSettings
        Line.Color='r';
        Line.LineStyle='-';
        Line.Marker='none';        
        
        Line.XData=[XStartPos,XCurrentPos]+ScanSettings.scan_res/2;
        Line.YData=[YStartPos,YCurrentPos]+ScanSettings.index_res/2;
        
        
        VarArray.Line=[XStartPos,YStartPos,XCurrentPos,YCurrentPos];
end