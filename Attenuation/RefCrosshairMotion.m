function RefCrosshairMotion(FigHandle,~,RefCAxes,RefAPanel,RefScanPosition,RefIndexPosition)
% REFCROSSHAIRMOTION  WindowButtonMotionFcn target for the reference
% C-scan crosshair. Snaps the current mouse position to the nearest
% reference pixel (using the same pixel-center convention as
% C_Scan_Plot_GUI.m's xvector/yvector), then updates:
%   - two crosshair lines spanning the reference C-scan axes
%   - the Scan=/Index= position readout
%   - the reference A-scan waveform (in place, no delete/recreate, so the
%     4 placeholder lines SelectRegionMove.m depends on are never touched)
%
% Does nothing if the mouse isn't currently over RefCAxes, so it's safe to
% leave this as the figure's WindowButtonMotionFcn without interfering
% with normal mouse movement elsewhere in the GUI.

global RefWaves
global RefScanSettings

if isempty(RefScanSettings.f_s) || isempty(RefWaves.waveform_matrix)
    return   % no reference data loaded yet
end

pt = get(RefCAxes,'CurrentPoint');
x = pt(1,1);
y = pt(1,2);

xl = RefCAxes.XLim;
yl = RefCAxes.YLim;
if x < xl(1) || x > xl(2) || y < yl(1) || y > yl(2)
    return   % mouse is outside the reference C-scan axes right now
end

%% --- snap to nearest pixel center, matching C_Scan_Plot_GUI.m exactly ---
xvector = linspace(0+RefScanSettings.scan_res/2, RefScanSettings.scan_len-RefScanSettings.scan_res/2, RefScanSettings.IndexPerRow);
yvector = linspace(0+RefScanSettings.index_res/2, RefScanSettings.index_len-RefScanSettings.index_res/2, RefScanSettings.IndexPerColumn);
[~,col] = min(abs(xvector-x));
[~,row] = min(abs(yvector-y));

% linear index matches C_Scan_Plot_GUI.m's reshape(...,[IndexPerRow,IndexPerColumn])
% column-major fill: scan direction (col) fastest, index direction (row) slower
wf_index = (row-1)*RefScanSettings.IndexPerRow + col;
wf_index = max(1, min(RefScanSettings.num_wfs, wf_index));

%% --- update crosshair lines (create once, then just move them) ----------
Lines = findobj(RefCAxes,'Tag','RefCrossHair');
if length(Lines) == 2
    Lines(1).XData = [xvector(col) xvector(col)];
    Lines(1).YData = yl;
    Lines(2).XData = xl;
    Lines(2).YData = [yvector(row) yvector(row)];
else
    delete(Lines)
    hold(RefCAxes,'on')
    plot(RefCAxes,[xvector(col) xvector(col)],yl,'w','Tag','RefCrossHair','HitTest','off','LineWidth',1);
    plot(RefCAxes,xl,[yvector(row) yvector(row)],'w','Tag','RefCrossHair','HitTest','off','LineWidth',1);
    hold(RefCAxes,'off')
end

%% --- update position readout ---------------------------------------------
RefScanPosition.String = ['Scan = ' num2str(xvector(col))];
RefIndexPosition.String = ['Index = ' num2str(yvector(row))];

%% --- update reference A-scan (in place) -----------------------------------
if sum(sum(RefWaves.shifted_matrix)) ~= 0
    wf = RefWaves.shifted_matrix(wf_index,:);
else
    wf = RefWaves.waveform_matrix(wf_index,:);
end

ax_ref = findobj(RefAPanel,'Type','Axes');
wfLine = findobj(ax_ref,'Tag','RefWaveformLine');
if ~isempty(wfLine)
    wfLine.XData = RefScanSettings.t;
    wfLine.YData = wf;
else
    % shouldn't normally happen (LoadReferenceAndPlot_Callback.m always
    % creates this line on load), but recreate defensively if missing
    hold(ax_ref,'on')
    h = plot(ax_ref,RefScanSettings.t,wf,'Color',[0.85 0.325 0.098]);
    h.Tag = 'RefWaveformLine';
    hold(ax_ref,'off')
end

end
