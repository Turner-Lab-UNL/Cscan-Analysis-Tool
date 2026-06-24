function ButtonUpAnulus(f,~,~,PointNumber)
global NumberOldLocations
global VarArray
global Draw
global ax_C_Vector

for i=1:length(ax_C_Vector)
    if PointNumber==1
        NumberOldLocations=PointNumber;
        f.WindowButtonMotionFcn=[];
        f.WindowButtonUpFcn=[];
    else
        
        Ax=ax_C_Vector{i};
        Line=Ax.Children(2);
        ReDrawAnulusWedge(Line,VarArray.Circular(1),VarArray.Circular(2),...
            VarArray.Circular(3),VarArray.Circular(4),[VarArray.Circular(5),...
            VarArray.Circular(6)]);
        if i==length(ax_C_Vector)
            DrawButtonUp(f,1,Draw.NumPlots+1); 
        end       
        
        %     f.WindowButtonUpFcn={@DrawButtonUp,NumPlots+1};
    end
    
end
end