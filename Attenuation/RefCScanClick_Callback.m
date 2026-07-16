function RefCScanClick_Callback(src,~,RefAPanel)
% REFCSCANCLICK_CALLBACK  Maps a click on the reference C-scan image to a
% specific waveform in RefWaves.waveform_matrix and plots it into
% RefAPanel, so individual reference pixels can be inspected instead of
% only ever seeing the ROI-averaged waveform.
%
% CAVEAT: the row/col -> linear waveform-index mapping below is a
% best-effort guess mirroring how ExtractCSVData.m reshapes the raw file
% into waveform_matrix (reshape(...,[],num_wfs)'), assuming waveform index
% increases fastest along the scan direction (IndexPerRow) and slower
% along the index direction (IndexPerColumn), unidirectional (not
% serpentine). If the waveform shown doesn't match the pixel you clicked,
% this is the mapping to fix -- it doesn't affect the actual attenuation
% calculation, since the gate you select still defaults to the
% ROI-averaged waveform regardless of what this click shows.
%
% IMPORTANT: only the tagged 'RefWaveformLine' gets deleted and replaced
% here -- never a blanket delete of all lines on the axes, since that
% would also wipe the 4 placeholder lines SelectRegionMove.m depends on
% for correct gate-drag indexing.

global RefWaves
global RefScanSettings

ax = ancestor(src,'axes');
pt = get(ax,'CurrentPoint');
x_click = pt(1,1);
y_click = pt(1,2);

col = round(x_click / RefScanSettings.scan_res) + 1;
row = round(y_click / RefScanSettings.index_res) + 1;

col = max(1, min(RefScanSettings.IndexPerRow, col));
row = max(1, min(RefScanSettings.IndexPerColumn, row));

wf_index = (row-1)*RefScanSettings.IndexPerRow + col;
wf_index = max(1, min(RefScanSettings.num_wfs, wf_index));

if sum(sum(RefWaves.shifted_matrix)) ~= 0
    wf = RefWaves.shifted_matrix(wf_index,:);
else
    wf = RefWaves.waveform_matrix(wf_index,:);
end

ax_ref = findobj(RefAPanel,'Type','Axes');
delete(findobj(ax_ref,'Tag','RefWaveformLine'));

hold(ax_ref,'on')
h = plot(ax_ref,RefScanSettings.t,wf,'Color',[0.85 0.325 0.098]);
h.Tag = 'RefWaveformLine';
hold(ax_ref,'off')

end
