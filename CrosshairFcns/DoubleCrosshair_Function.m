function DoubleCrosshair_Function(Button,~,f,Ax,TextHandles,update_function)

%% Variables
% f             - handle to figure cross hairs are to be added.
% Ax            - handle to axes that cross hairs are to be added.
%TextHandles    - handles to text that will be updated


%% Check to See if Button Has Been Previously Pressed
% This check looks at the tag of the Button. If cross hairs are currently
% on the figure, then the program deleates all the lines and sets the Tag
% to off. Hence pushing the button for the first time runs "else" and
% pushing the button a second time runs the first section
if Button.Value==0
%     TextHandles(1).String = '\Delta X = n/a';
%     TextHandles(2).String = '\Delta Y = n/a';
    % Set Tag to "Button Off"
%     Button.Tag='Button Off';
    
    % Find an array of all the lines with the Tag "Cross Hair". This will
    % only find the lines I have inserted to act as the cross hair.
    Lines=findobj(Ax.Children,'Tag','CrossHair');
    
    % Reset the WindowButtonMotionFcn to the default
    f.WindowButtonMotionFcn=[];
    z=zoom;
    z.ActionPostCallback=[];
    % Delete all the Cross hair lines
    for i=1:length(Lines)
        delete(Lines(i))
    end
    
else
%     TextHandles(1).String = '\Delta X = ';
%     TextHandles(2).String = '\Delta Y = ';
    
%     Buttons=findobj(Ax.Parent,'Tag','Button On');
%     for i=1:length(Buttons)
%         Buttons(i).Tag='Button Off';
%     end
    % Set the Tag to "Button On"
%     Button.Tag='Button On';
    
    z=zoom;
    z.ActionPostCallback={@CrosshairUpdateZoom,Ax};
    
    % Find all the CrossHair Lines (It Should be empty but it checks it)
    Lines=findobj(Ax.Parent,'Tag','CrossHair');
    
    % If somehow the cross hairs are still present, don't new ones, the
    % program just returns.
    if length(Lines)==4
        f.WindowButtonMotionFcn={@FindCrosshairMotion, Ax,TextHandles,update_function};
        return
    end
    

    %% Plot New Cross Hairs
    % Find the limits of the current axes so that the cross hairs fill the
    % whole screen.
    LimX=Ax.XLim;
    LimY=Ax.YLim;
    VertX=LimX(1)+(mean(abs(LimX))-LimX(1))*.1;
    VertX1=LimX(1)+(mean(abs(LimX))-LimX(1))*.2;
    VertY=LimY(1)+(mean(abs(LimY))-LimY(1))*.1;
    VertY1=LimY(1)+(mean(abs(LimY))-LimY(1))*.2;
    hold (Ax,'on')
    
    % Plot the four cross hair lines. If two are already present (due to
    % the single cross hair function) plot only two new ones.
    if length(Lines)==2
        plot(Ax,[VertX1,VertX1],[LimY(2),LimY(1)],'c','Tag','CrossHair')
        plot(Ax,[LimX(2),LimX(1)],[VertY1,VertY1],'c','Tag','CrossHair')
    else
        plot(Ax,[VertX,VertX],[LimY(2),LimY(1)],'r','Tag','CrossHair')
        plot(Ax,[LimX(2),LimX(1)],[VertY,VertY],'r','Tag','CrossHair')
        plot(Ax,[VertX1,VertX1],[LimY(2),LimY(1)],'c','Tag','CrossHair')
        plot(Ax,[LimX(2),LimX(1)],[VertY1,VertY1],'c','Tag','CrossHair')
    end    
    hold (Ax,'off')
    
    % Change the WindowButtonMotionFcn of f.
    f.WindowButtonMotionFcn={@FindCrosshairMotion, Ax,TextHandles,update_function};
    
end
end