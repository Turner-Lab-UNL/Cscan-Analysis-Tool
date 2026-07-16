function PlotVMaxCalibration(VMaxCal, label, actualGain)
% PLOTVMAXCALIBRATION  Diagnostic figure for a VMax_Calculator.m fit:
% amplitude vs gain, unsaturated points used in the fit, saturated points
% excluded, and the fitted line. Optionally marks where the actual
% sample/reference scan gain lands on that line.
%
% PlotVMaxCalibration(VMaxCal, label)
% PlotVMaxCalibration(VMaxCal, label, actualGain)

if nargin < 3
    actualGain = [];
end

fig = figure('Name', sprintf('VMax Calibration - %s', label), 'NumberTitle', 'off');
ax = axes('Parent', fig);
hold(ax, 'on');

used = ~VMaxCal.saturated;
plot(ax, VMaxCal.gain(used), VMaxCal.amplitude(used), 'o', ...
    'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'DisplayName', 'Used in fit');

if any(VMaxCal.saturated)
    plot(ax, VMaxCal.gain(VMaxCal.saturated), VMaxCal.amplitude(VMaxCal.saturated), 'rx', ...
        'MarkerSize', 9, 'LineWidth', 1.5, 'DisplayName', 'Excluded (saturated)');
end

gLine = linspace(min(VMaxCal.gain), max(VMaxCal.gain), 100);
aLine = polyval(VMaxCal.coeffs, gLine);
plot(ax, gLine, aLine, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Linear fit');

yline(ax, VMaxCal.threshold, 'r--', 'Saturation threshold', ...
    'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');

if ~isempty(actualGain) && ~isnan(actualGain)
    vmax = polyval(VMaxCal.coeffs, actualGain);
    plot(ax, actualGain, vmax, 'p', 'MarkerSize', 14, 'MarkerFaceColor', [0.9 0.6 0.1], ...
        'MarkerEdgeColor', 'k', 'DisplayName', sprintf('Scan gain = %.2f dB -> VMax = %.4f', actualGain, vmax));
end

xlabel(ax, 'Gain (dB)');
ylabel(ax, 'Peak Amplitude (fraction of full scale)');
title(ax, sprintf('%s VMax Calibration:  amplitude = %.4g*gain + %.4g', ...
    label, VMaxCal.coeffs(1), VMaxCal.coeffs(2)));
legend(ax, 'show', 'Location', 'best');
grid(ax, 'on');
hold(ax, 'off');

end
