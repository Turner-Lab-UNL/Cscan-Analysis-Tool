function UpdateAttenuationFreq_Callback(~,~,data_input_h,f)
% UPDATEATTENUATIONFREQ_CALLBACK  Re-slices the stored attenuation spectrum
% at a user-specified frequency and refreshes the result C-scan.
%
% The result C-scan normally shows band-averaged attenuation after
% "Calculate Attenuation".  Enter a frequency (MHz) in the "Display Freq"
% field and click "Update C-scan at Freq" to show the single-frequency
% slice instead.  The nearest available frequency in Waves.AttenuationFreq
% is used; the field is updated to reflect the actual value used.
%
% The requested frequency must fall within Waves.AttenuationBandLow/High --
% the auto-detected 50%-of-peak usable band from AttenuationCalculator.m --
% not just anywhere in the raw FFT range, since attenuation outside that
% band is not considered reliable.

global Waves

if isempty(Waves.AttenuationFreq)
    errordlg('No attenuation data available. Run "Calculate Attenuation" first.');
    return
end

fDispEdit = findobj(data_input_h, 'Tag', 'fDisplay');
fReq = str2double(fDispEdit.String);
if isnan(fReq)
    errordlg('Enter a numeric frequency (MHz) in the "Display Freq" field.');
    return
end

freq = Waves.AttenuationFreq;
bandLow  = Waves.AttenuationBandLow;
bandHigh = Waves.AttenuationBandHigh;
if fReq < bandLow || fReq > bandHigh
    errordlg(sprintf(['Frequency %.2f MHz is outside the auto-detected usable band ' ...
        '[%.2f, %.2f] MHz (50%% of the sample backwall spectrum''s peak).'], ...
        fReq, bandLow, bandHigh));
    return
end

[~, idx] = min(abs(freq - fReq));
fDispEdit.String = num2str(freq(idx), '%.3f');  % show actual freq used

Waves.Attenuation = Waves.AttenuationSpectrum(:, idx)';  % 1 x num_wfs

Update_CScan_Callback(1, 1, f, 0);
end
