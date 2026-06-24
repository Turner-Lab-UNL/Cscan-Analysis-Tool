function MovingMouseDraw(f,~,C_in,~)
global ScanSettings
global VarArray
global DropDownDrawArray
global Draw
global ax_C_Vector
% global NumPlots

for i=1:length(ax_C_Vector)
    if isvalid(ax_C_Vector{i})
        Ax=ax_C_Vector{i};
        XStartPos=floor(C_in(1,1)/ScanSettings.scan_res)*ScanSettings.scan_res;
        YStartPos=floor(C_in(1,2)/ScanSettings.index_res)*ScanSettings.index_res;
        
        if ScanSettings.scan_len<XStartPos
            XStartPos=ScanSettings.scan_len;
        end
        if ScanSettings.index_len<YStartPos
            YStartPos=ScanSettings.index_len ;
        end
        
        DrawPanel=findobj(f,'Tag','DrawPanel');
        DropDown=findobj(DrawPanel,'Style','popupmenu');
        Val=DropDown.Value;
        C = get (gca, 'CurrentPoint');
        
        
        if Val==5 || Val==6 || Val==7
            NeededPlots=Draw.NumPlots+2;
        else
            NeededPlots = Draw.NumPlots+1;
        end
        
        
        LineArray=findobj(Ax,'Type','Line');
        
        NumLines=length(LineArray);
        if NeededPlots>NumLines
            hold(Ax,'on')
            Line1=plot(Ax,1,1);
            Line1.Tag='DrawLine1';
            hold(Ax,'off')
            if NeededPlots-NumLines==2
                hold(Ax,'on')
                Line2=plot(Ax,1,1);
                Line2.Tag='DrawLine2';
                hold(Ax,'off')
            elseif NumLines-NeededPlots >2
                error('To many needed lines. Program has deleated to many lines. ')
            end
        elseif NeededPlots==NumLines
            Line1=LineArray(1);
        else
            error('To many lines. Program has not deleated enough lines.')
        end
        
        Ax.NextPlot='ReplaceChildren';
        
        XCurrentPos=floor(C(1,1)/ScanSettings.scan_res)*ScanSettings.scan_res;
        YCurrentPos=floor(C(1,2)/ScanSettings.index_res)*ScanSettings.index_res;
        
        
        
        if ScanSettings.scan_len<=XCurrentPos
            XCurrentPos=ScanSettings.scan_len-ScanSettings.scan_res;
        end
        if ScanSettings.index_len<=YCurrentPos
            YCurrentPos=ScanSettings.index_len-ScanSettings.index_res;
        end
        if XCurrentPos<0
            XCurrentPos=0;
        end
        if YCurrentPos<0
            YCurrentPos=0;
        end
        % Need function to prevent going off the left and bottom screan
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch Val
            case 1 % Point
                Line1.Tag='Point';
                DrawPoint(Line1,XCurrentPos,YCurrentPos);
                TypeOfFilterShape(DropDownDrawArray,1,VarArray)
                f.WindowButtonUpFcn={@DrawButtonUp,Draw.NumPlots+1};
            case 2 % Line
                Line1.Tag='Line';
                DrawLine(Line1,XStartPos,XCurrentPos, YStartPos,YCurrentPos);
                TypeOfFilterShape(DropDownDrawArray,2,VarArray)
                f.WindowButtonUpFcn={@DrawButtonUp,Draw.NumPlots+1};
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 3 % Rectangle
                Line1.Tag='Rectangle';
                DrawRectangle(Line1, XStartPos,XCurrentPos, YStartPos,YCurrentPos);
                TypeOfFilterShape(DropDownDrawArray,3,VarArray)
                f.WindowButtonUpFcn={@DrawButtonUp,Draw.NumPlots+1};
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 4 % Circle
                Line1.Tag='Circle';
                DrawCircle(Line1, XStartPos,XCurrentPos, YStartPos,YCurrentPos,[]);
                TypeOfFilterShape(DropDownDrawArray,4,VarArray)
                f.WindowButtonUpFcn={@DrawButtonUp,Draw.NumPlots+1};
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 5 % Wedge Shaped
                % For SomeReason Line2 is not seen on plot
                Line2=Ax.Children(1);
                Line1=Ax.Children(2);
                Line1.Tag='Wedge';
                DrawWedgeShape(f,Line1,Line2,XStartPos,XCurrentPos, YStartPos,YCurrentPos)
                TypeOfFilterShape(DropDownDrawArray,5,VarArray)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 6 % Anulus
                Line2=Ax.Children(1);
                Line1=Ax.Children(2);
                Line1.Tag='Anulus-A';
                Line2.Tag='Anulus-B';
                DrawAnulus(f,Line1,Line2, XStartPos,XCurrentPos, YStartPos,YCurrentPos);
                TypeOfFilterShape(DropDownDrawArray,6,VarArray)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 7 % Anulus Wedge
                Line2=Ax.Children(1);
                Line1=Ax.Children(2);
                Line1.Tag='Anulus Wedge';
                DrawAnulusWedge(f,Line1,Line2, XStartPos,XCurrentPos, YStartPos,YCurrentPos);
                TypeOfFilterShape(DropDownDrawArray,7,VarArray)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 8 %FreeForm
                
                Line1.Tag='Free Form';
                var_exist=exist('c_motion');
                if var_exist==0
                    c_motion=1;
                    DrawFreeForm(Line1,XStartPos,XCurrentPos, YStartPos,YCurrentPos);
                    f.WindowButtonUpFcn={@DrawFreeFormButtonUp,Line1,Draw.NumPlots+1};
                end
        end
        
    end
end


end

