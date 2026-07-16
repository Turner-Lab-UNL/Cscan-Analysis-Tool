function [freq,alpha_s_spectrum,alpha_s_avg,bandLow,bandHigh,Bs_amp,Br_amp,VMaxWarning] = ...
    AttenuationCalculator(Waves,RefWaves,ScanSettings,RefScanSettings,MatProps,TimeCuts,RefTimeCuts,SampleIndex)
% ATTENUATIONCALCULATOR  Frequency-dependent ultrasonic attenuation via the
% Experimental Diffraction Correction (EDC) method, Eq. 15-16
% (Lerch & Neal 2003; Yu, Guo, Margetan & Thompson 2001), following the
% same gating/looping conventions as WaveSpeedCalculator.m.
%
% alpha_s(f) = -1/(2*z_s) * [ ln( Bs(f)*(1-Rr^2)*Rr / (Br(f)*(1-Rs^2)*Rs) ) ...
%                              - 2*alpha_f(f)*dz_f ]
%
% INPUTS
%   Waves, RefWaves               structs with .waveform_matrix / .shifted_matrix
%                                  for the SAMPLE and REFERENCE C-scans, and
%                                  (optionally) .VMaxCal -- a gain-sweep
%                                  calibration fit from VMax_Calculator.m
%   ScanSettings, RefScanSettings structs with .t (time vector, us), .f_s
%                                  (sampling frequency, MHz), .num_wfs
%   MatProps  struct with fields:
%       z_s, z_r    sample / reference thickness (material path)   [mm]
%       zf_s, zf_r  water path used for sample / reference meas.   [mm]
%       c_s, c_f, c_r     wave speed:  sample, fluid, reference     [m/s]
%       rho_s, rho_f, rho_r  density:  sample, fluid, reference     [kg/m^3]
%       gain_s, gain_r  actual scan gain (dB) for sample/reference, used to
%                       evaluate Waves.VMaxCal/RefWaves.VMaxCal. NaN (or
%                       field absent) skips normalization for that side.
%   TimeCuts     struct .t1 .t2 - gate on the SAMPLE back-wall reflection (us)
%   RefTimeCuts  struct .t1 .t2 - gate on the REFERENCE back-wall reflection (us)
%   SampleIndex  scalar row index into Waves.waveform_matrix/shifted_matrix --
%                the single pixel currently displayed in the Sample A-scan
%                panel (i.e. global CurrentIndex) at the moment the sample
%                backwall gate was selected. Its gated spectrum defines the
%                frequency band (see bandLow/bandHigh below) -- NOT an
%                average across the C-scan.
%
% OUTPUTS
%   freq              1 x Nf   frequency vector (MHz), positive half of FFT
%   alpha_s_spectrum  num_wfs x Nf   attenuation coefficient (Np/mm), full
%                      frequency range (for QC/plotting only)
%   alpha_s_avg       1 x num_wfs    attenuation averaged over
%                      [bandLow,bandHigh] -> feed this into the
%                      ChooseType='Attenuation' C-scan image
%   bandLow, bandHigh MHz -- the auto-detected usable frequency band: the
%                      contiguous region around the peak of
%                      Bs_amp(SampleIndex,:) where the amplitude stays at
%                      or above 50% of that peak (a standard -6dB/half-max
%                      bandwidth), clamped to the available spectrum edges.
%   Bs_amp, Br_amp    amplitude spectra used (QC / plotting)
%   VMaxWarning       char, non-empty if sample and/or reference VMax
%                      normalization was skipped (not calibrated, or no
%                      gain entered) -- surface this to the user, don't
%                      silently drop the correction.
%
% ASSUMPTIONS (flag these if they don't match your setup):
%   - Reference backwall spectrum is the FFT of the MEAN waveform over all
%     reference waveforms in RefTimeCuts (i.e. you selected an ROI on a
%     uniform, non-scattering reference like fused silica and want a
%     noise-averaged B_r(f)).
%   - Sample attenuation is computed PER PIXEL (per waveform, num_wfs of
%     them), exactly like WaveSpeedCalculator loops per pixel, so you get
%     an attenuation C-scan image, not just a single scalar.
%   - The usable frequency band is driven ENTIRELY by the sample signal at
%     SampleIndex (not intersected with the reference's own bandwidth) --
%     per the user, this matches how the band is meant to be chosen.
%   - R_s, R_r use the magnitude form of Eq. 7 (paper defines R = |-Rs| = Rf).
%   - ScanSettings.f_s (sampling frequency) is assumed common between the
%     sample and reference acquisitions; if not, resample one to match
%     before calling this function.
%   - VMax normalization (if MatProps.gain_s/gain_r and Waves.VMaxCal/
%     RefWaves.VMaxCal are available) divides each gated backwall segment
%     by the gain-fit-predicted full-scale amplitude at the actual scan
%     gain, per VMax_Calculator.m -- this puts sample and reference on a
%     comparable absolute scale even when scanned at different gains,
%     which the raw %FSS amplitude data does not do on its own.

%% --- Unit handling (mm -> m) -------------------------------------------
z_s  = MatProps.z_s  / 1000;
z_r  = MatProps.z_r  / 1000;   %#ok<NASGU> % kept for completeness/QC, not used below
zf_s = MatProps.zf_s / 1000;
zf_r = MatProps.zf_r / 1000;
dz_f = zf_r - zf_s;                          % Eq. 16

%% --- Reflection coefficients, magnitude form of Eq. 7 -------------------
Z_s = MatProps.rho_s * MatProps.c_s;
Z_f = MatProps.rho_f * MatProps.c_f;
Z_r = MatProps.rho_r * MatProps.c_r;

R_s = abs((Z_s - Z_f) / (Z_s + Z_f));
R_r = abs((Z_r - Z_f) / (Z_r + Z_f));

%% --- Locate time gates ----------------------------------------------------
t1_index  = find(TimeCuts.t1    <= ScanSettings.t,    1);
t2_index  = find(TimeCuts.t2    <= ScanSettings.t,    1);
t1r_index = find(RefTimeCuts.t1 <= RefScanSettings.t, 1);
t2r_index = find(RefTimeCuts.t2 <= RefScanSettings.t, 1);

if isempty(t1_index) || isempty(t2_index) || isempty(t1r_index) || isempty(t2r_index)
    error('AttenuationCalculator:GateOutOfRange', ...
        'One or more time gates fall outside the recorded time base.')
end

%% --- Pull backwall segments -----------------------------------------------
if sum(sum(Waves.shifted_matrix)) ~= 0
    sample_segments = Waves.shifted_matrix(:, t1_index:t2_index);
else
    sample_segments = Waves.waveform_matrix(:, t1_index:t2_index);
end

if sum(sum(RefWaves.shifted_matrix)) ~= 0
    ref_segments = RefWaves.shifted_matrix(:, t1r_index:t2r_index);
else
    ref_segments = RefWaves.waveform_matrix(:, t1r_index:t2r_index);
end

%% --- VMax gain normalization (optional, backward-compatible) --------------
VMaxWarning = '';

gain_s = NaN; gain_r = NaN;
if isfield(MatProps, 'gain_s'), gain_s = MatProps.gain_s; end
if isfield(MatProps, 'gain_r'), gain_r = MatProps.gain_r; end

if ~isempty(Waves.VMaxCal) && ~isnan(gain_s)
    sample_segments = sample_segments / polyval(Waves.VMaxCal.coeffs, gain_s);
else
    VMaxWarning = [VMaxWarning 'Sample VMax not calibrated - normalization skipped. '];
end

if ~isempty(RefWaves.VMaxCal) && ~isnan(gain_r)
    ref_segments = ref_segments / polyval(RefWaves.VMaxCal.coeffs, gain_r);
else
    VMaxWarning = [VMaxWarning 'Reference VMax not calibrated - normalization skipped.'];
end

%% --- Reference spectrum: FFT of the ROI-averaged reference waveform -------
ref_mean_wf = mean(ref_segments, 1);

nfft = 2^nextpow2(max(size(sample_segments,2), size(ref_segments,2)));
fs   = ScanSettings.f_s * 1e6;                 % MHz -> Hz

Br_full   = abs(fft(ref_mean_wf, nfft));
freq_full = (0:nfft-1) * (fs / nfft);          % Hz
half      = 1:floor(nfft/2);
freq      = freq_full(half) / 1e6;             % report back in MHz
Br_amp    = Br_full(half);

%% --- Water/fluid attenuation, alpha_f(f), Np/m, f in Hz --------------------
f_Hz    = freq_full(half);
alpha_f = 2.53 * (f_Hz.^2) * 1e-14;            % Np/m (room-temp water estimate)

%% --- Loop over sample waveforms (per C-scan pixel) -------------------------
num_wfs = ScanSettings.num_wfs;
Bs_amp           = zeros(num_wfs, length(half));
alpha_s_spectrum = zeros(num_wfs, length(half));

for i = 1:num_wfs
    Bs_full     = abs(fft(sample_segments(i,:), nfft));
    Bs_amp(i,:) = Bs_full(half);

    ratio = (Bs_amp(i,:) .* (1-R_r^2) .* R_r) ./ (Br_amp .* (1-R_s^2) .* R_s);
    alpha_s_spectrum(i,:) = (-1/(2*z_s)) .* ( log(ratio) - 2*alpha_f.*dz_f );
end

alpha_s_spectrum = alpha_s_spectrum / 1000;    % Np/m -> Np/mm

%% --- Auto-detect the usable band: 50%-of-peak around the sample-index spectrum
if SampleIndex < 1 || SampleIndex > num_wfs
    SampleIndex = 1;
end
repSpec = Bs_amp(SampleIndex, :);
[peakVal, peakIdx] = max(repSpec);
halfLevel = 0.5 * peakVal;

lowIdx = peakIdx;
while lowIdx > 1 && repSpec(lowIdx - 1) >= halfLevel
    lowIdx = lowIdx - 1;
end

highIdx = peakIdx;
while highIdx < length(repSpec) && repSpec(highIdx + 1) >= halfLevel
    highIdx = highIdx + 1;
end

if highIdx == lowIdx
    lowIdx  = max(1, lowIdx - 1);
    highIdx = min(length(repSpec), highIdx + 1);
end

bandLow  = freq(lowIdx);
bandHigh = freq(highIdx);

%% --- Band-averaged attenuation for the result C-scan -----------------------
band = freq >= bandLow & freq <= bandHigh;
alpha_s_avg = mean(alpha_s_spectrum(:, band), 2, 'omitnan')';

end
