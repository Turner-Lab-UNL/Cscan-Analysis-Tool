function RenderReferenceData(RefAPanel, RefCAxes)
% RENDERREFERENCEDATA  Renders whatever is currently in the global
% RefWaves/RefScanSettings into the Attenuation GUI's reference A-scan
% panel (mean waveform into the pre-existing 'RefWaveformLine') and
% reference C-scan axes (peak-to-peak amplitude image via C_Scan_Plot_GUI).
%
% Split out of LoadReferenceAndPlot_Callback.m so it can also be called
% once at CalculateAttenuation_GUI.m build time -- if the reference data
% was already loaded via the main menu's "Load Reference Data" item
% (wired to the bare LoadReferenceData_Callback, which only touches the
% RefWaves/RefScanSettings globals, not any Attenuation-GUI-specific
% panel) before the Attenuation GUI was ever opened, the GUI otherwise
% opens with blank reference panels even though RefWaves already holds
% valid data -- there was no visible signal to gate against.
%
% IMPORTANT: RefAPanel's axes has a fixed structure set up in
% CalculateAttenuation_GUI.m: 4 untagged placeholder lines, then a 5th
% line tagged 'RefWaveformLine' created at GUI-build time (not lazily
% here). SelectRegionMove.m locates the active data line via the fixed
% index ax.Children(end-4), which only lands correctly if that structure
% is never disturbed. So this function must only ever UPDATE
% 'RefWaveformLine's XData/YData -- never delete and recreate it, and
% never touch the 4 placeholders.

global RefWaves
global RefScanSettings

if isempty(RefWaves.waveform_matrix)
    return   % nothing loaded yet
end

%% --- default gate target: mean waveform over the whole reference scan ---
ax_ref = findobj(RefAPanel,'Type','Axes');

% clear any leftover gate-selection artifacts from a previous load (a
% prior gate is no longer meaningful against new data), but leave the 4
% placeholders and the RefWaveformLine itself alone
delete(findobj(ax_ref,'Tag','SelectRegion'));
delete(findobj(ax_ref,'Tag','SelectBox'));

if sum(sum(RefWaves.shifted_matrix)) ~= 0
    mean_wf = mean(RefWaves.shifted_matrix,1);
else
    mean_wf = mean(RefWaves.waveform_matrix,1);
end

wfLine = findobj(ax_ref,'Tag','RefWaveformLine');
wfLine.XData = RefScanSettings.t;
wfLine.YData = mean_wf;

ax_ref.YLim=[-1 1];
ax_ref.XLim=[RefScanSettings.w_s, RefScanSettings.w_s+RefScanSettings.w_w];

%% --- reference C-scan image: peak-to-peak amplitude per waveform --------
if sum(sum(RefWaves.shifted_matrix)) ~= 0
    src_matrix = RefWaves.shifted_matrix;
else
    src_matrix = RefWaves.waveform_matrix;
end

amp_map = max(src_matrix,[],2) - min(src_matrix,[],2);   % num_wfs x 1

RefAxisInfo.Name = RefCAxes;
RefAxisInfo.Number = ancestor(RefCAxes,'figure').Number;
limits = [min(amp_map) max(amp_map)];

C_Scan_Plot_GUI(RefAxisInfo, RefScanSettings, amp_map, limits, 1);

end
