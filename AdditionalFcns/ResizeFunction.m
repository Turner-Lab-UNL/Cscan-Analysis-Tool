function ResizeFunction(f,~)
% Two failure modes guarded here:
%
% 1. RECURSIVE RE-ENTRY: set(findall(f,...), 'FontSize', v) changes child
%    properties, which can trigger SizeChangedFcn again before this call
%    returns.  A persistent guard would block cross-figure, so we use
%    per-figure appdata instead.
%
% 2. RAPID-FIRE EVENTS: dragging the window edge fires SizeChangedFcn
%    hundreds of times per second.  findall(f,...) + set on 50+ objects
%    is expensive; the backlog builds faster than it clears, freezing the
%    GUI.  We debounce by skipping updates when the resulting font size
%    would change by less than 0.5 pt.
%
% NOTE: the formula sqrt(16*L^2+80) is designed for NORMALIZED figure
% position units (0–1).  It produces ~8–12 pt for typical window sizes.
% If called while figure units are still 'pixels' (during construction),
% L is huge and newSize would overflow; the sanity clamp handles that.

if ~isvalid(f), return; end

% Per-figure re-entry guard
if getappdata(f, 'ResizeInProgress'), return; end

FNew     = f.Position(3:4);
L        = FNew(1)^2 + FNew(2)^2;
newSize  = sqrt(16 * L^2 + 80);

% Sanity clamp: formula is only meaningful with normalized units (values ~9-13).
% If figure units are pixels L is huge and newSize is astronomical.
if ~isfinite(newSize) || newSize < 6 || newSize > 24
    return
end

% Debounce: skip if font size would not change meaningfully
lastSize = getappdata(f, 'ResizeLastFontSize');
if ~isempty(lastSize) && abs(newSize - lastSize) < 0.5
    return
end

setappdata(f, 'ResizeInProgress',    true);
setappdata(f, 'ResizeLastFontSize',  newSize);
try
    set(findall(f, '-property', 'FontSize'), 'FontSize', newSize);
catch
end
setappdata(f, 'ResizeInProgress', false);

end