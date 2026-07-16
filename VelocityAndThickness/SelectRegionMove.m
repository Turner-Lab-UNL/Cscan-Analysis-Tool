function SelectRegionMove(~,~,point1,line_box,line,input1,input2)

% Use the axes that owns line_box rather than gca.  gca changes whenever
% the mouse drifts over a different axes (C-scan, ref panel, etc.) and
% ax.Children(end-4) would then index into the wrong object, throwing an
% error that silently keeps WindowButtonMotionFcn active and makes the
% GUI appear unresponsive.
ax = ancestor(line_box, 'axes');
if isempty(ax) || ~isvalid(ax), return; end

hold(ax, 'on')

point2 = get(ax, 'CurrentPoint');
xmax=max(point1(1,1),point2(1,1));
xmin=min(point1(1,1),point2(1,1));
ymax=max(point1(1,2),point2(1,2));
ymin=min(point1(1,2),point2(1,2));


%% Update Selection Box
line_box.XData=[xmin,xmax,xmax,xmin,xmin];
line_box.YData=[ymin,ymin,ymax,ymax,ymin];


%% Obtain Data and Axis Information
if length(ax.Children) < 5, return; end  % guard: fewer objects than expected
x_values=ax.Children(end-4).XData;
y_values=ax.Children(end-4).YData;
if length(x_values) < 2, return; end     % guard: waveform line not yet populated
x_width=x_values(2)-x_values(1);

%% Locate Cut Regions
x_fi=find(x_values>=xmin(1));
x_fi=x_fi(1);
x_si=find(x_values<xmax(1)+x_width/2);
x_si=x_si(end);
x_new=x_values(x_fi:x_si);
y_new=y_values(x_fi:x_si);

%% Update Lines
line.XData=x_new;
line.YData=y_new;


if xmin<min(x_new)
xmin=x_new(1);
end
if xmax> max(x_new)
    xmax=x_new(end);
end
% if replacement_number==1
% input_panel.Children(end-5).String = num2str(xmax);
% input_panel.Children(end-3).String = num2str(xmin);
% else
   input1.String=num2str(xmin); 
   input2.String=num2str(xmax); 
%    
% input_panel.Children(end-9).String = num2str(xmax);
% input_panel.Children(end-7).String = num2str(xmin);
 
% end


end