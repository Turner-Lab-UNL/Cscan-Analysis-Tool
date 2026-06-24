function Line=DrawRectangle(Line, XStartPos,XCurrentPos, YStartPos,YCurrentPos)
global VarArray
global ScanSettings

if XStartPos > XCurrentPos
XStartPos=XStartPos+ScanSettings.scan_res;
% XCurrentPos=XCurrentPos-ScanSettings.scan_res;
Line.XData=[XStartPos,XStartPos,XCurrentPos,XCurrentPos,XStartPos];
else 
    
XCurrentPos=XCurrentPos+ScanSettings.scan_res;
Line.XData=[XStartPos,XStartPos,XCurrentPos,XCurrentPos,XStartPos];  
end

if YStartPos> YCurrentPos
YStartPos=YStartPos+ScanSettings.index_res;
Line.YData=[YStartPos,YCurrentPos,YCurrentPos,YStartPos,YStartPos];
else
   YCurrentPos=YCurrentPos+ScanSettings.index_res; 
Line.YData=[YStartPos,YCurrentPos,YCurrentPos,YStartPos,YStartPos];  
end


Line.Color='r';
Line.LineStyle='-';
Line.Marker='none';


% Output=[min([XStartPos,XCurrentPos])-ScanSettings.scan_res,...
%     min([YStartPos,YCurrentPos])-ScanSettings.index_res,...
%     max([XStartPos,XCurrentPos])-ScanSettings.index_res,...
%     max([YStartPos,YCurrentPos])-ScanSettings.index_res];
Output=[min([XStartPos,XCurrentPos]),...
    min([YStartPos,YCurrentPos]),...
    max([XStartPos,XCurrentPos]),...
    max([YStartPos,YCurrentPos])];

VarArray.Rectangle=Output;

end