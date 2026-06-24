function CrosshairButtonUp(f,~,Ax,TextHandles,update_function)
%% CrosshairButtonUp
% This function resets the WindowButtonMotionFcn to the FindCrosshairMotion
% function. It also sets the WindowButtonDownFcn and the WindowButtonUpFcn
% to the defaults and the Point back to 'arrow'.

f.WindowButtonMotionFcn={@FindCrosshairMotion,Ax,TextHandles,update_function};
f.WindowButtonDownFcn=[];
f.WindowButtonUpFcn=[];
f.Pointer='arrow';
end