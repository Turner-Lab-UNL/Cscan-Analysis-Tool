function DrawPoint(Line,XCurrentPos,YCurrentPos)
global VarArray
global ScanSettings
DelX=ScanSettings.scan_res;
DelY=ScanSettings.index_res;
Line.XData=XCurrentPos+[-DelX DelX DelX -DelX -DelX]/2+DelX/2;
Line.YData=YCurrentPos+[-DelY -DelY DelY DelY -DelY]/2+DelY/2;
Line.Color='r';
Line.LineStyle='-';
Line.Marker='none';
VarArray.Point=[XCurrentPos,YCurrentPos];
end