function CrossHairButtonDown(f,~,Ax,Line,TextHandles,update_function)
f.WindowButtonMotionFcn={@UpdateCrosshairMotion,Ax,Line,TextHandles,update_function};
end