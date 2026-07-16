function PlotAttenuationSpectrum(freq, alpha_s_spectrum, bandLow, bandHigh)
% PLOTATTENUATIONSPECTRUM  Static mean+-std attenuation-vs-frequency plot
% across all C-scan pixels, restricted to the auto-detected usable band
% [bandLow, bandHigh] (see AttenuationCalculator.m -- the 50%-of-peak
% bandwidth around the sample backwall spectrum at the currently-displayed
% A-scan pixel). No interactivity: the band is fully determined by the
% calculation itself, not chosen by dragging.

mean_alpha = mean(alpha_s_spectrum, 1, 'omitnan');
std_alpha  = std(alpha_s_spectrum, 0, 1, 'omitnan');

band = freq >= bandLow & freq <= bandHigh;
freq_band  = freq(band);
mean_band  = mean_alpha(band);
std_band   = std_alpha(band);

old = findobj('Type','figure','Tag','AttnSpectrumFig');
if ~isempty(old)
    delete(old);
end

fig = figure('Name','Attenuation Spectrum','NumberTitle','off', 'Tag','AttnSpectrumFig');
ax = axes('Parent', fig);
hold(ax, 'on');

fill(ax, [freq_band, fliplr(freq_band)], [mean_band + std_band, fliplr(mean_band - std_band)], ...
    [0.75 0.87 1.0], 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'DisplayName', '\pm1 Std Dev');
plot(ax, freq_band, mean_band, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Mean');

xlabel(ax, 'Frequency (MHz)');
ylabel(ax, 'Attenuation (Np/mm)');
title(ax, sprintf('Attenuation vs Frequency  [%.2f - %.2f MHz, auto-detected 50%% of peak]', ...
    bandLow, bandHigh));
legend(ax, 'show', 'Location', 'best');
grid(ax, 'on');
ax.XLim = [freq_band(1), freq_band(end)];
hold(ax, 'off');

end
