function [ hImage ] = C_Scan_Plot_GUI( AxisInfo,ScanSettings,PlottingVector,limits,reset)
xvector=linspace(0+ScanSettings.scan_res/2,ScanSettings.scan_len-ScanSettings.scan_res/2,ScanSettings.IndexPerRow);
yvector=linspace(0+ScanSettings.index_res/2,ScanSettings.index_len-ScanSettings.index_res/2,ScanSettings.IndexPerColumn);

PlottingMatrix=reshape(PlottingVector,[length(xvector),length(yvector)]);

if isempty(AxisInfo.Name)
    
    hImage=image(xvector,yvector,PlottingMatrix','CDataMapping','scaled');
    set(gca,'YDir','normal')
    colorbar;
    colormap jet
else

    if reset==1 || isempty(AxisInfo.Name.Children)
        hImage=image(AxisInfo.Name,xvector,yvector,PlottingMatrix','CDataMapping','scaled');
    else
        AxisInfo.Name.Children(end).CData=PlottingMatrix';
        AxisInfo.Name.Children(end).XData=xvector;
        AxisInfo.Name.Children(end).YData=yvector;
    end

    set(AxisInfo.Name,'YDir','normal')
    colorbar(AxisInfo.Name);
    colormap(AxisInfo.Name, 'jet');

    % Guard: caxis requires a 2-element strictly-increasing finite vector.
    % Non-finite or equal limits arise when the data is uniform (min==max)
    % or contains Inf (e.g. WaveSpeed = 2*d/0).  Fall back to the actual
    % data range; if that is also degenerate, add a unit offset so the
    % call never errors.
    if ~isfinite(limits(1)) || ~isfinite(limits(2)) || limits(1) >= limits(2)
        lo = min(PlottingMatrix(:));
        hi = max(PlottingMatrix(:));
        if ~isfinite(lo) || ~isfinite(hi) || lo >= hi
            lo = double(~isfinite(lo)) * 0;   % 0 if non-finite
            hi = lo + 1;
        end
        limits = [lo, hi];
    end
    caxis(AxisInfo.Name,limits)
end
end

