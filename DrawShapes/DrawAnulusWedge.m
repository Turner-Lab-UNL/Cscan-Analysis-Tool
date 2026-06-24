function DrawAnulusWedge(f,Line1,Line2, XStartPos,XCurrentPos, YStartPos,YCurrentPos)
global NumberOldLocations
global ScanSettings
global VarArray
global OldPoints
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
        XUnit = r * cos(th) + XStartPos;
        YUnit = r * sin(th) + YStartPos;
        Line1.XData=[XStartPos,XCurrentPos]+ScanSettings.scan_res/2;
        Line1.YData=[YStartPos,YCurrentPos]+ScanSettings.index_res/2;
        Line1.Color='b';
        Line1.LineStyle='-.';
        Line1.Marker='none';
        
        Line2.XData=XUnit+ScanSettings.scan_res/2;
        Line2.YData=YUnit+ScanSettings.index_res/2;
        Line2.Color='r';
        Line2.LineStyle='--';
        Line2.Marker='none';
        
        VarArray.Circular=[r,0,angStart,360,XStartPos,YStartPos];
        f.WindowButtonUpFcn={@ButtonUpAnulus,Line1, 1};
        
    case 1           
        P0=OldPoints([1,2]);
        P1=OldPoints([3,4]);
        P2=[XCurrentPos,YCurrentPos];
        r1=sqrt((P0(1)-P1(1))^2+(P0(2)-P1(2))^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
        r1=round(r1)*min([ScanSettings.scan_res,ScanSettings.index_res]);
        r2=sqrt((P0(1)-P2(1))^2+(P0(2)-P2(2))^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
        r2=round(r2)*min([ScanSettings.scan_res,ScanSettings.index_res]);
        
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
        
        XUnit1 = r1 * cos(th) + P0(1);
        YUnit1 = r1 * sin(th) + P0(2);
        XUnit2 = r2 * cos(th) + P0(1);
        YUnit2 = r2 * sin(th) + P0(2);
        
        if abs(angStart-angEnd)<1 %NoAngleDifference
            th=0:pi/50:2*pi;
            XUnit1 = r1 * cos(th) + P0(1);
            YUnit1 = r1 * sin(th) + P0(2);
            XUnit2 = r2 * cos(th) + P0(1);
            YUnit2 = r2 * sin(th) + P0(2);
            Line1.XData=XUnit1+ScanSettings.scan_res/2;
            Line1.YData=YUnit1+ScanSettings.index_res/2;
            Line1.Color='g';
            Line1.LineStyle='-';
            Line1.Marker='none';
            
            Line2.XData=XUnit2+ScanSettings.scan_res/2;
            Line2.YData=YUnit2+ScanSettings.index_res/2;
            Line2.Color='g';
            Line2.LineStyle='-';
            Line2.Marker='none';
            NumberFigAdd=1;
            
            if abs(r1-r2)<min([ScanSettings.scan_res,ScanSettings.index_res])/2
                VarArray.Circular=[0,r1,0,360,P0(1),P0(2)];
            else
                VarArray.Circular=[min([r1,r2]),max([r1,r2]),0,360,P0(1),P0(2)];
            end
        elseif abs(r1-r2) < min([ScanSettings.scan_res,ScanSettings.index_res])/2 %Anulus

            delete(Line1)
            Line2.XData=[P0(1),XUnit1(1),XUnit1,P0(1)]+ScanSettings.scan_res/2;
            Line2.YData=[P0(2),YUnit1(1),YUnit1,P0(2)]+ScanSettings.index_res/2;
            Line2.Color='g';
            Line2.LineStyle='-';
            Line2.Marker='none';
            
            VarArray.Circular=[0,r1,angStart,angEnd,P0(1),P0(2)];
            NumberFigAdd=1;
        else
            
            if r2>r1
                Temp1=[XUnit1(1),YUnit1(1)];
                Temp2=[XUnit1(end),YUnit1(end)];
            else
                Temp1=[XUnit2(1),YUnit2(1)];
                Temp2=[XUnit2(end),YUnit2(end)];
            end
            Line1.XData=[P1(1),XUnit1,fliplr(XUnit2),P1(1)]+ScanSettings.scan_res/2;
            Line1.YData=[P1(2),YUnit1,fliplr(YUnit2),P1(2)]+ScanSettings.index_res/2;
            Line1.Color='r';
            Line1.LineStyle='-';
            Line1.Marker='none';
            

            Line2.XData=[Temp1(1),P0(1),Temp2(1)]+...
                ScanSettings.scan_res/2;
            Line2.YData=[Temp1(2),P0(2),Temp2(2)]+ScanSettings.index_res/2;
            Line2.Color='b';
            Line2.LineStyle='-.';
            Line2.Marker='none';
            NumberFigAdd=1;
            VarArray.Circular=[min([r1,r2]),max([r1,r2]),angStart,angEnd,P0(1),P0(2)];

        end
        f.WindowButtonUpFcn={@DrawButtonUp,Draw.NumPlots+NumberFigAdd};
end

end