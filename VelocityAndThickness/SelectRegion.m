function SelectRegion(t_button,~,f,APanel,input1,input2, replacement_number)
val=t_button.Value;
f.WindowButtonDownFcn=[];
f.WindowButtonUpFcn=[];
f.WindowButtonMotionFcn=[];
if val==1
    toggles=findobj(f,'Style','togglebutton');
    for i=1:length(toggles)
        toggles(i).Value=0;
    end
    ax_modify=findobj(APanel,'Type','Axes');
    t_button.Value=1;
    f.WindowButtonDownFcn={@SelectRegionFunction,ax_modify,input1,input2,replacement_number};
else
    f.WindowButtonDownFcn=[];
    f.WindowButtonUpFcn=[];
    f.WindowButtonMotionFcn=[];
end

end