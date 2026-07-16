function KeepArray=PlotLocationsFunction(Val,ScanSettings)
global VarArray

scan_res=ScanSettings.scan_res;
scan_len=ScanSettings.scan_len;
index_res=ScanSettings.index_res;
index_len=ScanSettings.index_len;
index_per_row=ScanSettings.IndexPerRow;
index_per_column=ScanSettings.IndexPerColumn;

switch Val
    case 1 % Point
        P=[VarArray.Point(1)+ScanSettings.scan_res,VarArray.Point(2)+ScanSettings.index_res];
       KeepArray  = PointFinder(P,index_per_row, index_per_column, scan_res, index_res);
    
    
    case 2 % Line
        P1=[VarArray.Line(1)+ScanSettings.scan_res,VarArray.Line(2)+ScanSettings.index_res];
        P2=[VarArray.Line(3)+ScanSettings.scan_res,VarArray.Line(4)+ScanSettings.index_res];
        KeepArray  = LineFinder(P1, P2,index_per_row, index_per_column, scan_res, index_res,'Plot_No');
        
    case 3 % Rectangle
%         P1=[VarArray.Rectangle(1)+ScanSettings.scan_res,VarArray.Rectangle(2)+ScanSettings.index_res];
%         P2=[VarArray.Rectangle(3)+ScanSettings.scan_res,VarArray.Rectangle(4)+ScanSettings.index_res];
        P1=[VarArray.Rectangle(1),VarArray.Rectangle(2)];
        P2=[VarArray.Rectangle(3),VarArray.Rectangle(4)];
        P1(P1(1,1)<0,1)=0;
        P1(P1(1,2)<0,2)=0;  
        
        scan_len=index_per_row*scan_res;
        index_len=index_per_column*index_res;
        P2(P2(1,1)>=scan_len,1)=scan_len;
        P2(P2(1,2)>= index_len,2)= index_len;
        KeepArray  = CartesianIndexFinder( P1,P2,scan_res,index_res,index_per_row,index_per_column,'Plot_No');
    case 4 % Circular
        Radius=[VarArray.Circular(1),VarArray.Circular(2)];
        ThetaLimits=[VarArray.Circular(3),VarArray.Circular(4)];
        CP=[VarArray.Circular(5)+ScanSettings.scan_res,VarArray.Circular(6)+ScanSettings.index_res];
        KeepArray= PolarIndexFinder( CP, Radius, ThetaLimits, index_per_row, index_per_column, scan_res, index_res,'Plot_No');
        
    case 5 % Wedge Shaped
        Radius=[VarArray.Circular(1),VarArray.Circular(2)];
        ThetaLimits=[VarArray.Circular(3),VarArray.Circular(4)];
        CP=[VarArray.Circular(5)+ScanSettings.scan_res,VarArray.Circular(6)+ScanSettings.index_res];
        KeepArray= PolarIndexFinder( CP, Radius, ThetaLimits, index_per_row, index_per_column, scan_res, index_res,'Plot_No');
    case 6 %Anulus
        Radius=[VarArray.Circular(1),VarArray.Circular(2)];
        ThetaLimits=[VarArray.Circular(3),VarArray.Circular(4)];
        CP=[VarArray.Circular(5)+ScanSettings.scan_res,VarArray.Circular(6)+ScanSettings.index_res];
        KeepArray= PolarIndexFinder( CP, Radius, ThetaLimits, index_per_row, index_per_column, scan_res, index_res,'Plot_No');  
    case 7 % Anulus Wedge
         Radius=[VarArray.Circular(1),VarArray.Circular(2)];
        ThetaLimits=[VarArray.Circular(3),VarArray.Circular(4)];
        CP=[VarArray.Circular(5)+ScanSettings.scan_res,VarArray.Circular(6)+ScanSettings.index_res];
        KeepArray= PolarIndexFinder( CP, Radius, ThetaLimits, index_per_row, index_per_column, scan_res, index_res,'Plot_No');  
        
    case 8 %Free Form
        X=VarArray.FreeForm(1,:);
        Y=VarArray.FreeForm(2,:);
        if isa(X,'double')
            X=uint16(X);            
        end
        if isa(Y,'double')
            Y=uint16(Y);
        end
        ind=sub2ind([ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn],X,Y);
        mat=zeros(ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn);
        %        ind
        mat(ind)=1;
        Fillmat = imfill(mat);
        [Xkeep,Ykeep]=find(Fillmat==1);
        KeepArray=sub2ind([ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn],Xkeep,Ykeep);
    otherwise
end
% KeepArray=round(KeepArray);

end