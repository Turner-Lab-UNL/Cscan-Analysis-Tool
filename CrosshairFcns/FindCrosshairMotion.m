function FindCrosshairMotion(f,~,Ax,TextHandles,update_function)
%% Variables
% f             - handle to figure cross hairs are to be added.   
%TextHandles    - handles to text that will be updated

% If the zoom tool is on, don't run the program.
h = zoom;
if isprop(h,'Enable') && (ischar(h.Enable) || isstring(h.Enable)) && strcmpi(h.Enable,'on')
    return
end
h = pan;
if isprop(h,'Enable') && (ischar(h.Enable) || isstring(h.Enable)) && strcmpi(h.Enable,'on')
    return
end
h = rotate3d;
if isprop(h,'Enable') && (ischar(h.Enable) || isstring(h.Enable)) && strcmpi(h.Enable,'on')
    return
end

%% Get Current Point
C = get (gca, 'CurrentPoint');
Location=[C(1,1),C(1,2)];


%% Get Lines Used Crosshairs and Their Relative Locations
% This section creates a normalized domain. This means that location (0,0)
% is at the bottom left corner and (1,1) is at the top right corner. The
% program finds where the crosshairs and curser are in this domain. Using
% this information, the program decides if the curser is close enough to
% the crosshairs. If so, then the program changes the WindowsButtonDownFcn
% so that the user can update the crosshair. 


XLims=Ax.XLim;
YLims=Ax.YLim;

% RelComparison is the variable that allows the program to know if the user
% is close to a crosshair. The values are for percentages. A 1 means within
% 1 percent a 0.5 means within .5 percent. This can make it easier or more
% difficult to select a crosshair. The criteria to find the center is twice
% this amount.

RelComparison=1; 

RelLocation =[(Location(1)-XLims(1))/(XLims(2)-XLims(1)),...
    (Location(2)-YLims(1))/(YLims(2)-YLims(1))];

% Find all the lines in the axes
Lines=findobj(Ax.Children,'Tag','CrossHair');
if ~isvalid(Ax) || isempty(Ax.Children)
    return
end
Lines = findobj(Ax.Children,'Tag','CrossHair');
if isempty(Lines) || length(Lines) < 2
    return
end
VertLine1=Lines(end);
HorzLine1=Lines(end-1);

%Find first center of crosshair1 in normalized space
Center1=[VertLine1.XData(1),HorzLine1.YData(1)];
RelCross1=[(Center1(1)-XLims(1))/(XLims(2)-XLims(1)),...
    (Center1(2)-YLims(1))/(YLims(2)-YLims(1))];

%Find normalized distance from first crosshair 
ChangeX1=RelLocation(1)-RelCross1(1);
ChangeY1=RelLocation(2)-RelCross1(2);
RVal1=sqrt(ChangeX1^2+ChangeY1^2);

if RVal1*2 < 1* RelComparison /100*2  % Check to see if point is near center
    f.Pointer='fleur';
    f.WindowButtonDownFcn={@CrossHairButtonDown,Ax,[HorzLine1,VertLine1],TextHandles,update_function};
    return
elseif abs(ChangeY1) < 1*RelComparison/100 % Check near horizontal line
    f.Pointer='top';    
    f.WindowButtonDownFcn={@CrossHairButtonDown,Ax,HorzLine1,TextHandles,update_function};
    return
elseif abs(ChangeX1) < 1*RelComparison/100 % Check near vertical line
    f.Pointer='left';
    f.WindowButtonDownFcn={@CrossHairButtonDown,Ax,VertLine1,TextHandles,update_function};
    return
else
    f.Pointer='arrow';
    f.WindowButtonDownFcn=[];
end

% Run this program is the user is using double crosshairs. 
if length(Lines)==4
    %Find remaining lines
VertLine2=Lines(end-2);
HorzLine2=Lines(end-3);

%Find second center of crosshair in normalized space
Center2=[VertLine2.XData(1),HorzLine2.YData(1)];
RelCross2=[(Center2(1)-XLims(1))/(XLims(2)-XLims(1)),...
    (Center2(2)-YLims(1))/(YLims(2)-YLims(1))];

%Find normalized distance from second crosshair 
ChangeX2=RelLocation(1)-RelCross2(1);
ChangeY2=RelLocation(2)-RelCross2(2);
RVal2=sqrt(ChangeX2^2+ChangeY2^2);

if RVal2*2 < 1*RelComparison/100*2  % Check to see if point is near center
    f.Pointer='fleur';
    f.WindowButtonDownFcn={@CrossHairButtonDown,Ax,[HorzLine2,VertLine2],TextHandles,update_function};    
    return
elseif abs(ChangeY2) < 1*RelComparison/100 % Check near horizontal line
    f.Pointer='top';
    f.WindowButtonDownFcn={@CrossHairButtonDown,Ax,HorzLine2,TextHandles,update_function};
    return
elseif abs(ChangeX2) < 1*RelComparison/100 % Check near vertical line 
    f.Pointer='left';
    f.WindowButtonDownFcn={@CrossHairButtonDown,Ax,VertLine2,TextHandles,update_function};
    return
else
    f.Pointer='arrow';
    f.WindowButtonDownFcn=[];
end

end

end
