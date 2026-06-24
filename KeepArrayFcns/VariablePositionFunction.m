function VarArray=VariablePositionFunction(f,Ax,Val,VarArray,DropDownVarianceArray)
global Draw
global ScanSettings

if Val==4 ||Val==5 || Val==6 || Val==7
    Val=4; %All of these are based on Circles
end
for i=1:length(Ax)
    ax=Ax{i};
    
    LineArray=findobj(ax,'Type','Line');
    if length(LineArray)==Draw.NumPlots
        return
    end
    
    Line=ax.Children(1);
    
    
    switch Val
        case 1 % Point
            VarArray.Point(1)=str2double(DropDownVarianceArray(2).String);
            VarArray.Point(2)=str2double(DropDownVarianceArray(4).String);
            DrawPoint(Line, VarArray.Point(1), VarArray.Point(2));
        case 2 % Line
            VarArray.Line(1)=str2double(DropDownVarianceArray(2).String);
            VarArray.Line(2)=str2double(DropDownVarianceArray(4).String);
            VarArray.Line(3)=str2double(DropDownVarianceArray(6).String);
            VarArray.Line(4)=str2double(DropDownVarianceArray(8).String);
            DrawLine(Line, VarArray.Line(1), VarArray.Line(3),VarArray.Line(2), VarArray.Line(4));
        case 3 % Rectangle
            
            VarArray.Rectangle(1)=str2double(DropDownVarianceArray(2).String);
            VarArray.Rectangle(2)=str2double(DropDownVarianceArray(4).String);
            VarArray.Rectangle(3)=str2double(DropDownVarianceArray(6).String);
            VarArray.Rectangle(4)=str2double(DropDownVarianceArray(8).String);
            DrawRectangle(Line, VarArray.Rectangle(1), VarArray.Rectangle(3)-ScanSettings.scan_res,VarArray.Rectangle(2), VarArray.Rectangle(4)-ScanSettings.index_res);
            
        case 4 % Circular
            VarArray.Circular(1)=str2double(DropDownVarianceArray(2).String);
            VarArray.Circular(2)=str2double(DropDownVarianceArray(4).String);
            VarArray.Circular(3)=str2double(DropDownVarianceArray(6).String);
            VarArray.Circular(4)=str2double(DropDownVarianceArray(8).String);
            VarArray.Circular(5)=str2double(DropDownVarianceArray(10).String);
            VarArray.Circular(6)=str2double(DropDownVarianceArray(12).String);
            ReDrawAnulusWedge(Line,VarArray.Circular(1),VarArray.Circular(2),VarArray.Circular(3),VarArray.Circular(4),[VarArray.Circular(5),VarArray.Circular(6)]);
            
        otherwise
    end
    
end
end