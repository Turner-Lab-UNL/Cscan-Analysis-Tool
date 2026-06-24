function Line=DrawCircle(Line, XStartPos,XCurrentPos, YStartPos,YCurrentPos,r)
global ScanSettings
global VarArray
if isempty(r)
r=sqrt((XStartPos-XCurrentPos)^2+(YStartPos-YCurrentPos)^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
r=round(r)*min([ScanSettings.scan_res,ScanSettings.index_res]); 
end
th = 0:pi/50:2*pi;
XUnit = r * cos(th) + XStartPos;
YUnit = r * sin(th) + YStartPos;
Line.XData=XUnit+ScanSettings.scan_res/2;
Line.YData=YUnit+ScanSettings.index_res/2;
Line.Color='r';
Line.LineStyle='-';
Line.Marker='none';
VarArray.Circular=[0,r,0,360,XStartPos,YStartPos];
end