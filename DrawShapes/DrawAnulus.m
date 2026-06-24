function DrawAnulus(f,Line1,Line2, XStartPos,XCurrentPos, YStartPos,YCurrentPos)
global NumberOldLocations
global ScanSettings
global VarArray
global OldPoints
   
        switch NumberOldLocations            
            case 0
                r=sqrt((XStartPos-XCurrentPos)^2+(YStartPos-YCurrentPos)^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
                r=round(r)*min([ScanSettings.scan_res,ScanSettings.index_res]);
                P0=[XStartPos,YStartPos];
                P1=[XCurrentPos,YCurrentPos];
                th = 0:pi/50:2*pi;
                XUnit = r * cos(th) + P0(1)+ScanSettings.scan_res/2;
                YUnit = r * sin(th) + P0(2)+ScanSettings.index_res/2;
                
                OldPoints=[P0,P1];
                delete(Line2)
                
                Line1.XData=XUnit;
                Line1.YData=YUnit;
                Line1.Color='r';
                Line1.LineStyle='-';
                Line1.Marker='none';
                
                VarArray.Circular=[0,r,0,360,OldPoints(1),OldPoints(2)];
                f.WindowButtonUpFcn={@ButtonUpAnulus,Line1, 1};
                
            case 1
                
                P0=OldPoints([1,2]);
                P1=OldPoints([3,4]);
                P2=[XCurrentPos,YCurrentPos];
                
                r1=sqrt((P0(1)-P1(1))^2+(P0(2)-P1(2))^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
                r1=round(r1)*min([ScanSettings.scan_res,ScanSettings.index_res]);
                th = 0:pi/50:2*pi;
                XUnit1 = r1 * cos(th) + P0(1);
                YUnit1 = r1 * sin(th) + P0(2);
                
                r2=sqrt((P0(1)-P2(1))^2+(P0(2)-P2(2))^2)/min([ScanSettings.scan_res,ScanSettings.index_res]);
                r2=round(r2)*min([ScanSettings.scan_res,ScanSettings.index_res]);
                XUnit2 = r2 * cos(th) + P0(1);
                YUnit2 = r2 * sin(th) + P0(2);
                
                if abs(r1-r2)<min([ScanSettings.scan_res,ScanSettings.index_res])/2
                    delete(Line2)
                    Line1.XData=XUnit1+ScanSettings.scan_res/2;
                    Line1.YData=YUnit1+ScanSettings.index_res/2;
                    Line1.Color='g';
                    Line1.LineStyle='-';
                    Line1.Marker='none';
                    VarArray.Circular=[0,r1,0,360,P0(1),P0(2)];
                else
                    
                    Line1.XData=XUnit2+ScanSettings.scan_res/2;
                    Line1.YData=YUnit2+ScanSettings.index_res/2;
                    Line1.Color='r';
                    Line1.LineStyle='-';
                    Line1.Marker='none';
                    Line2.XData=XUnit1+ScanSettings.scan_res/2;
                    Line2.YData=YUnit1+ScanSettings.index_res/2;
                    Line2.Color='r';
                    Line2.LineStyle='-';
                    Line2.Marker='none';
                    
                    VarArray.Circular=[min([r1,r2]),...
                        max([r1,r2]),0,360,P0(1),P0(2)];
                end
                
                f.WindowButtonUpFcn={@ButtonUpAnulus,Line1,2};
        end



end