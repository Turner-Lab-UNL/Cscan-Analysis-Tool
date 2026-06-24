function SingleCrosshair_Function(Button,~,f,Ax,TextHandles,update_function)

%% Variables
% f             - handle to figure cross hairs are to be added.
% Ax            - handle to axes that cross hairs are to be added.
%TextHandles    - handles to text that will be updated


%% Check to See if Button Has Been Previously Pressed
% This check looks at the tag of the Button. If cross hairs are currently
% on the figure, then the program deleates all the lines and sets the Tag
% to off. Hence pushing the button for the first time runs "else" and
% pushing the button a second time runs the first section

% if contains(Button.Tag,'On')
if Button.Value==0
% %     TextHandles(1).String = 'X = n/a';
% %     TextHandles(2).String = 'Y = n/a';    
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
% %     TextHandles(1).String = 'X = ';
% %     TextHandles(2).String = 'Y = ';
    
%     Buttons=findobj(Ax.Parent,'Tag','Button On');
%     for i=1:length(Buttons)
%         Buttons(i).Tag='Button Off';
%     end
    
    z=zoom;
    z.ActionPostCallback={@CrosshairUpdateZoom,Ax};
   
    % Set the Tag to "Button On"
%     Button.Tag='Button On';
    
    % Find all the CrossHair Lines (It Should be empty but it checks it)
    Lines=findobj(Ax.Parent,'Tag','CrossHair');
    % If somehow the cross hairs are still present, don't add new ones, the
    % program just returns.
    if length(Lines)==4
        
        for i=1:2
            delete(Lines(i))
        end
        Lines(3).Color='r';
        Lines(4).Color='r';
        f.WindowButtonMotionFcn={@FindCrosshairMotion,Ax, TextHandles,update_function};
        return
    elseif length(Lines)==2
        
        f.WindowButtonMotionFcn={@FindCrosshairMotion,Ax, TextHandles,update_function};
        return
    end
    
    %% Plot New Cross Hairs
    % Find the limits of the current axes so that the cross hairs fill the
    % whole screen.
    LimX=Ax.XLim;
    LimY=Ax.YLim;
    
    VertX=LimX(1)+(mean(abs(LimX))-LimX(1))*.1;
    VertY=LimY(1)+(mean(abs(LimY))-LimY(1))*.1;
    hold (Ax,'on')
    
    % Plot the four cross hair lines. If two are already present (due to
    % the single cross hair function) plot only two new ones.
    plot(Ax,[VertX,VertX],[LimY(2),LimY(1)],'r','Tag','CrossHair')
    plot(Ax,[LimX(2),LimX(1)],[VertY,VertY],'r','Tag','CrossHair')    
    hold (Ax,'off')
    

    
    % Change the WindowButtonMotionFcn of f.
    f.WindowButtonMotionFcn={@FindCrosshairMotion,Ax, TextHandles,update_function};
end
end