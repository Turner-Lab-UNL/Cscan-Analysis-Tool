function SelectRegionFunction(f,~,ax,input1,input2, replacement_number)
point = get (gca, 'CurrentPoint');
lines=findobj(ax,'Tag','SelectRegion');
plot_box=findobj(ax,'Tag','SelectBox');

hold(ax,'on')
colors(1,:)=[0.4660, 0.6740, 0.1880];
colors(2,:)=[0.3010, 0.7450, 0.9330];
if length(plot_box)==1
    line_box=plot_box(1);
     line_box.Tag='SelectBox';
     line_box.Color=[0 0 0];
elseif isempty(plot_box)
    line_box=plot(ax,0,0);
    line_box.Tag='SelectBox';
    line_box.Color=[0 0 0];
end

if length(lines)==1
    'To few lines'
    
elseif  length(lines)==2
    line=lines(replacement_number);
else
    lines(2)=plot(ax,0,0);
    lines(2).Tag='SelectRegion';
    lines(2).Color=colors(1,:);
    lines(1)=plot(ax,0,0);
    lines(1).Tag='SelectRegion';
    lines(1).Color=colors(2,:);
    line=lines(replacement_number);
end

hold(ax,'off')

f.WindowButtonUpFcn={@SelectRegionRelease};
f.WindowButtonMotionFcn={@SelectRegionMove,point,line_box,line,input1,input2};
end