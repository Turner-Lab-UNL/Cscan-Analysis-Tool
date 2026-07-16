function LoadReferenceAndPlot_Callback(hObject,eventdata,FileNameBox,MessageBox,RefAPanel,RefCAxes)
% LOADREFERENCEANDPLOT_CALLBACK  Wraps LoadReferenceData_Callback.m: loads
% the reference C-scan into the global RefWaves/RefScanSettings, then
% renders it via RenderReferenceData.m (shared with CalculateAttenuation_GUI.m's
% build-time "was reference data already loaded via the main menu?" check).

global RefWaves

LoadReferenceData_Callback(hObject,eventdata,FileNameBox,MessageBox);

if isempty(RefWaves.waveform_matrix)
    return   % user cancelled the load, or nothing was loaded
end

RenderReferenceData(RefAPanel, RefCAxes);

end
