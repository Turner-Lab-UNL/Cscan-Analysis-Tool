function DrawWedgeShape(f,Line1,Line2, XStartPos,XCurrentPos, YStartPos,YCurrentPos)
global NumberOldLocations
global ScanSettings
global VarArray
global OldPoints;
global Draw

switch NumberOldLocations
    
    case 0
        r=sqrt((XStartPos-XCurrentPos)^2+(YStartPos-YCurrentPos)^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
        r=round(r)*min([ScanSettings.scan_res,ScanSettings.index_res]);
        P0=[XStartPos,YStartPos];
        P1=[XCurrentPos,YCurrentPos];
        Rel1=P1-P0;
        angStart = (-atan2(Rel1(1),Rel1(2))+pi/2)*180/pi;
        OldPoints=[P0,P1];
        
        if angStart<0
            angStart=angStart+360;
        end
        
        th = 0:pi/50:2*pi;
        XUnit = r * cos(th) + XStartPos+ScanSettings.scan_res/2;
        YUnit = r * sin(th) + YStartPos+ScanSettings.index_res/2;
        Line1.XData=[XStartPos,XCurrentPos]+ScanSettings.scan_res/2;
        Line1.YData=[YStartPos,YCurrentPos]+ScanSettings.index_res/2;
        Line1.Color='b';
        Line1.LineStyle='-.';
        Line1.Marker='none';
        
        Line2.XData=XUnit;
        Line2.YData=YUnit;
        Line2.Color='r';
        Line2.LineStyle='--';
        Line2.Marker='none';
        
        VarArray.Circular=[r,0,angStart,360,XStartPos,YStartPos];
        f.WindowButtonUpFcn={@ButtonUpAnulus,Line1,1};
        
    case 1
        P0=OldPoints([1,2]);
        P1=OldPoints([3,4]);
        P2=[XCurrentPos,YCurrentPos];
        r=sqrt((P0(1)-P1(1))^2+(P0(2)-P1(2))^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
        r=round(r)*min([ScanSettings.scan_res,ScanSettings.index_res]);
        
        Rel1=P1-P0;
        angStart = (-atan2(Rel1(1),Rel1(2))+pi/2)*180/pi;
        
        if angStart<0
            angStart=angStart+360;
        end
        
        Rel2=P2-P0;
        angEnd = (-atan2(Rel2(1),Rel2(2))+pi/2)*180/pi;
        if angEnd<0
            angEnd=angEnd+360;
        end
        
        if angStart > angEnd
            th=[linspace(angStart*pi/180,2*pi,180),linspace(0,angEnd*pi/180,180)];
        else
            th = linspace(angStart*pi/180,angEnd*pi/180,360);
        end
        
        if angStart > angEnd
            th=[angStart*pi/180:pi/50:2*pi,0:pi/50:angEnd*pi/180];
        end
        
        delete(Line2);
        if abs(angStart-angEnd)<1
            th = 0:pi/50:2*pi;
            XUnit = r * cos(th) + OldPoints(1);
            YUnit = r * sin(th) + OldPoints(2);
            Line1.XData=XUnit+ScanSettings.scan_res/2;
            Line1.YData=YUnit+ScanSettings.index_res/2;
            Line1.Color='g';
            Line1.LineStyle='-';
            Line1.Marker='none';
            
            VarArray.Circular=[0,r,0,360,P0(1),P0(2)];
        else
            XUnit = r * cos(th) + OldPoints(1);
            YUnit = r * sin(th) + OldPoints(2);
            Line1.XData=[P0(1),XUnit,P0(1)]+ScanSettings.scan_res/2;
            Line1.YData=[P0(2),YUnit,P0(2)]+ScanSettings.index_res/2;
            Line1.Color='r';
            Line1.LineStyle='-';
            Line1.Marker='none';
            
            VarArray.Circular=[r,0,angStart,angEnd,P0(1),P0(2)];
        end
        f.WindowButtonUpFcn={@DrawButtonUp,Draw.NumPlots+1};        
    otherwise
end


end