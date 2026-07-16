function RefCrosshair_Callback(Button,~,f,RefCAxes,RefAPanel,RefScanPosition,RefIndexPosition)
% REFCROSSHAIR_CALLBACK  Toggles continuous hover-crosshair navigation on
% the reference C-scan, mirroring SingleCrosshair_Callback (the nested
% function behind CreateCScanPannel.m's '+' button) as closely as possible
% without SingleCrosshair_Function.m/FindCrosshairMotion.m/
% UpdateTextAndWaveform.m -- those hardcode global Waves/ScanSettings, so
% they can't be reused for RefWaves/RefScanSettings directly. This is a
% self-contained equivalent: same toggle/mutual-exclusion convention (any
% other togglebutton in the figure, including Select Sample/Reference
% Backwall and the sample panel's own crosshair buttons, turns this off
% and vice versa), but the crosshair lines, position readout, and A-scan
% update are driven by RefCrosshairMotion.m against the reference data.

if Button.Value == 0
    % turning off: stop tracking and remove the crosshair lines
    f.WindowButtonMotionFcn = [];
    delete(findobj(RefCAxes,'Tag','RefCrossHair'));
else
    % turning on: enforce the same single-active-mode convention used
    % throughout this app (SelectRegion.m, SingleCrosshair_Callback, etc.)
    toggles = findobj(f,'Style','togglebutton');
    for i = 1:length(toggles)
        toggles(i).Value = 0;
    end
    Button.Value = 1;
    f.WindowButtonDownFcn = [];
    f.WindowButtonUpFcn = [];
    f.WindowButtonMotionFcn = {@RefCrosshairMotion,RefCAxes,RefAPanel,RefScanPosition,RefIndexPosition};
end

end
