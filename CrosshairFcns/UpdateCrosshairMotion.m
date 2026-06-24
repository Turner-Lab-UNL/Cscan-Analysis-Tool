function UpdateCrosshairMotion(f,~,Ax,Line,TextHandles,update_function)
%% Update WindowsButtonUpFcn
% This updates the WindowButtonUpFcn so that when the user releases the
% button, the WindowsButtonMotionFcn goes back to @FindCrosshairMotion. 
f.WindowButtonUpFcn={@CrosshairButtonUp,Ax,TextHandles,update_function};

%% UpdateCrosshairMotion
% This function updates the crosshairs on the GUI based on the user data.
% The function First gets the current position, then it Updates the Line
% variable. This variable is a Line array. A length of one means either the
% x or y portion of the crosshair is being updates. A length of two means
% the center is being updated. Once the lines have been updates, the text
% is updates. 

C = get (gca, 'CurrentPoint');
% Ax=f.Children(end);
YLims=Ax.YLim;
XLims=Ax.XLim;


ChangeH=0;
ChangeV=0;
 %% Change the Corresponding Lines the CurrentPossition
 % This section changes the crosshair line(s) so that the figure updates
 % itself with the correct crosshair placement. It was found that the
 % function would allow the C to go off of the axes. This would plot the
 % crosshair off the axes and where the user wasn't able to locate. Hence,
 % the program checks the current location with the edges of the axes.If
 % the edges are reached the line is placed at the edge and the thickness
 % is increased. 
 
if length(Line)==2
% If both the x and y of a crosshair must be changed

    % Change Horizontal Line
    if C(1,2)>YLims(1)&& C(1,2)<YLims(2)
        Line(1).YData=[1,1]*C(1,2);
    elseif C(1,2)>YLims(1)
        Line(1).YData=[1,1]*YLims(2);
        ChangeH=1;
    elseif C(1,2)<YLims(2)
        Line(1).YData=[1,1]*YLims(1);
        ChangeH=1;
    end
    
    % Change Virtical Line
    if C(1,1)>XLims(1)&& C(1,1)<XLims(2)
        Line(2).XData=[1,1]*C(1,1);
    elseif C(1,1)>XLims(1)
        Line(2).XData=[1,1]*XLims(2);
        ChangeV=1;
    elseif C(1,1)<XLims(2)
        Line(2).XData=[1,1]*XLims(1);
        ChangeV=1;
    end
    
    % If line is on edge of axes, increase the width. If not on edge, make
    % smaller width
    if ChangeH==1
        Line(1).LineWidth=3;
    else
        Line(1).LineWidth=0.5;
    end
    
    if ChangeV==1
        Line(2).LineWidth=3;
    else
        Line(2).LineWidth=0.5;
    end
    
else
% If only one of the crosshairs must be changed

    XData=Line.XData;
    if XData(1)-XData(2)==0 %Line is vert
        if C(1,1)>XLims(1)&& C(1,1)<XLims(2)
            Line.XData=[1,1]*C(1,1);
        elseif C(1,1)>XLims(1)
            Line.XData=[1,1]*XLims(2);
            ChangeH=1;
        elseif C(1,1)<XLims(2)
            Line.XData=[1,1]*XLims(1);
            ChangeH=1;
        end
    else                    % Line is horz
        if C(1,2)>YLims(1)&& C(1,2)<YLims(2)
            Line.YData=[1,1]*C(1,2);
        elseif C(1,2)>YLims(1)
            Line.YData=[1,1]*YLims(2);
            ChangeH=1;
        elseif C(1,2)<YLims(2)
            Line.YData=[1,1]*YLims(1);
            ChangeH=1;
        end
    end
    
    %Change width of line as before
    if ChangeH==1
        Line.LineWidth=3;
    else
        Line.LineWidth=0.5;
    end
end


%% Update GUI
% It is possible to change this section
% depending upon what the user wants. The user could sent this information 
% to another function that ultimately gets displayed in a different way. 

% Find Lines
Lines=findobj(Ax.Children,'Tag','CrossHair');
update_function(Ax.Parent,Lines,TextHandles)
% UpdateTextAndWaveform(f,Lines,TextHandles)
end