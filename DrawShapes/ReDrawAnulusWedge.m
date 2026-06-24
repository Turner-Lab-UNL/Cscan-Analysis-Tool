function ReDrawAnulusWedge(Line1, r1,r2,angStart,angEnd,P0)

global ScanSettings

% Find out if it is a circle or not
if r1==r2 && angStart==angEnd
    Type=1; 
elseif r1==0 && angStart==angEnd
    Type=1;
elseif r1==0 && angStart==0 && angEnd==360
    Type=1;
else
    Type=2;
end



if r1==r2
    r1=0;
    %Circle or WedgeShaped
end

if angStart==angEnd
    angStart=0;
    angEnd=360;
end

P1=r1*[cos(angStart*pi/180),sin(angStart*pi/180)]+P0;
if angStart > angEnd
    th=[linspace(angStart*pi/180,2*pi,180),linspace(0,angEnd*pi/180,180)];
else
    th = linspace(angStart*pi/180,angEnd*pi/180,360);
end

if angStart > angEnd
    th=[angStart*pi/180:pi/50:2*pi,0:pi/50:angEnd*pi/180];
end

XUnit1 = r1 * cos(th) + P0(1);
YUnit1 = r1 * sin(th) + P0(2);
XUnit2 = r2 * cos(th) + P0(1);
YUnit2 = r2 * sin(th) + P0(2);

switch Type
    case 1 %Circle
        Line1.XData=XUnit2+ScanSettings.scan_res/2;
        Line1.YData=YUnit2+ScanSettings.index_res/2;
    otherwise %Anulus Wedge
        
        Line1.XData=[P1(1),XUnit1,fliplr(XUnit2),P1(1)]+ScanSettings.scan_res/2;
        Line1.YData=[P1(2),YUnit1,fliplr(YUnit2),P1(2)]+ScanSettings.index_res/2;
end
Line1.Color='r';
Line1.LineStyle='-';
Line1.Marker='none';
end