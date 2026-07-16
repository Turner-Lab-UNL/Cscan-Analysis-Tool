function CalculateAttenuation_Callback(~,~,data_input_h)
% CALCULATEATTENUATION_CALLBACK  GUI callback that reads the sample/reference
% backwall gates and material properties from the input panel, runs the EDC
% attenuation calculation (including the auto-detected 50%-of-peak
% frequency band, see AttenuationCalculator.m), stores the result on
% Waves, refreshes the result C-scan, and shows the attenuation-vs-frequency
% plot restricted to that band, mirroring the structure of
% CalculateWaveSpeed_Callback.m.
%
% NOTE ON GUI WIRING: unlike CalculateWaveSpeed_Callback.m (which indexes
% data_input_h.Children(end-N)), this callback looks up fields by 'Tag' via
% findobj. That means each edit box in your attenuation input panel needs
% its Tag property set to match the strings below:
%   t1_sample, t2_sample   sample backwall gate (us)
%   t1_ref,    t2_ref      reference backwall gate (us)
%   z_s,  z_r              sample / reference thickness (mm)
%   zf_s, zf_r             water path, sample / reference (mm)
%   c_s,  c_f,  c_r        wave speed: sample / fluid / reference (m/s)
%   rho_s, rho_f, rho_r    density: sample / fluid / reference (kg/m^3)
%   gain_s, gain_r         actual scan gain (dB), sample / reference --
%                          optional; leave blank to skip VMax normalization
%
% Wire the sample gate (t1_sample/t2_sample) and reference gate
% (t1_ref/t2_ref) to SelectRegion.m the same way t1f/t2f/t1s/t2s are wired
% in your existing wave-speed panel -- just point the reference toggle's
% SelectRegion call at the reference C-scan's axes instead of the sample's.

global ScanSettings RefScanSettings
global Waves RefWaves
global GateInfo
global CurrentIndex

f = gcf;
StatusBox = findobj(f,'Tag','AttnStatusBox');

%% --- Gate times ------------------------------------------------------
TimeCuts.t1    = str2double(findobj(data_input_h,'Tag','t1_sample').String);
TimeCuts.t2    = str2double(findobj(data_input_h,'Tag','t2_sample').String);
RefTimeCuts.t1 = str2double(findobj(data_input_h,'Tag','t1_ref').String);
RefTimeCuts.t2 = str2double(findobj(data_input_h,'Tag','t2_ref').String);

if any(isnan([TimeCuts.t1, TimeCuts.t2, RefTimeCuts.t1, RefTimeCuts.t2]))
    errordlg('User did not select the sample and/or reference back-wall region(s).');
    return
end

%% --- Material / geometry properties -----------------------------------
MatProps.z_s   = str2double(findobj(data_input_h,'Tag','z_s').String);    % mm
MatProps.z_r   = str2double(findobj(data_input_h,'Tag','z_r').String);    % mm
MatProps.zf_s  = str2double(findobj(data_input_h,'Tag','zf_s').String);   % mm
MatProps.zf_r  = str2double(findobj(data_input_h,'Tag','zf_r').String);   % mm
MatProps.c_s   = str2double(findobj(data_input_h,'Tag','c_s').String);    % m/s
MatProps.c_f   = str2double(findobj(data_input_h,'Tag','c_f').String);    % m/s
MatProps.c_r   = str2double(findobj(data_input_h,'Tag','c_r').String);    % m/s
MatProps.rho_s = str2double(findobj(data_input_h,'Tag','rho_s').String);  % kg/m^3
MatProps.rho_f = str2double(findobj(data_input_h,'Tag','rho_f').String);  % kg/m^3
MatProps.rho_r = str2double(findobj(data_input_h,'Tag','rho_r').String);  % kg/m^3

propFields = fieldnames(MatProps);
for k = 1:length(propFields)
    if any(isnan(MatProps.(propFields{k})))
        errordlg('One or more material/geometry properties were not entered correctly.');
        return
    end
end

% Actual scan gain (dB) -- optional. NaN (blank field) skips VMax
% normalization for that side; AttenuationCalculator.m handles that
% gracefully and reports it via VMaxWarning below.
% NOTE: gain_s/gain_r live in button_panel (row 2), not data_input_h --
% search the whole figure (f), not just data_input_h, to find them.
MatProps.gain_s = str2double(findobj(f,'Tag','gain_s').String);
MatProps.gain_r = str2double(findobj(f,'Tag','gain_r').String);

if isempty(RefWaves.waveform_matrix)
    errordlg('No reference C-scan has been loaded. Use "Load Reference Data" first.');
    return
end

% The frequency band is auto-detected from whichever single pixel is
% currently displayed in the Sample A-scan panel (the same waveform the
% backwall gate above was drawn on) -- see CrosshairFcns/UpdateTextAndWaveform.m,
% which sets this global whenever the Sample C-scan crosshair moves.
SampleIndex = CurrentIndex;
if isempty(SampleIndex)
    SampleIndex = 1;
end

%% --- Run the calculation -----------------------------------------------
[freq,alpha_s_spectrum,alpha_s_avg,bandLow,bandHigh,Bs_amp,Br_amp,VMaxWarning] = AttenuationCalculator( ...
    Waves,RefWaves,ScanSettings,RefScanSettings,MatProps,TimeCuts,RefTimeCuts,SampleIndex);

Waves.AttenuationFreq     = freq;               % MHz
Waves.AttenuationSpectrum = alpha_s_spectrum;   % Np/mm, [num_wfs x nfreq]
Waves.Attenuation         = alpha_s_avg;        % Np/mm, [1 x num_wfs] -> C-scan image
Waves.AttenuationBandLow  = bandLow;            % MHz
Waves.AttenuationBandHigh = bandHigh;           % MHz
Waves.Bs_amp = Bs_amp;
Waves.Br_amp = Br_amp;

if ~isempty(StatusBox)
    if isempty(VMaxWarning)
        StatusBox.String = sprintf('Attenuation calculated (VMax-normalized), band %.2f-%.2f MHz', bandLow, bandHigh);
        StatusBox.BackgroundColor = [0 1 0];
    else
        StatusBox.String = sprintf('%s Band %.2f-%.2f MHz', VMaxWarning, bandLow, bandHigh);
        StatusBox.BackgroundColor = [1 1 0];
    end
end

%% --- Reflect the auto-detected band in the read-only Low/High fields ----
fLowEdit  = findobj(data_input_h, 'Tag', 'fLow');
fHighEdit = findobj(data_input_h, 'Tag', 'fHigh');
if ~isempty(fLowEdit),  fLowEdit.String  = num2str(bandLow, '%.2f');  end
if ~isempty(fHighEdit), fHighEdit.String = num2str(bandHigh, '%.2f'); end

%% --- Set display-frequency field default (band midpoint) ------------
f_mid = mean([bandLow, bandHigh]);
fDispEdit = findobj(data_input_h,'Tag','fDisplay');
if ~isempty(fDispEdit)
    fDispEdit.String = num2str(f_mid, '%.2f');
end

%% --- Refresh the result C-scan (ChooseType='Attenuation') ---------------
for gk = {'g1','g2','g3','g4'}
    GateInfo.(gk{1}).Low(4)  = NaN;
    GateInfo.(gk{1}).High(4) = NaN;
end

CPanels = findobj(f, 'Tag', 'CPanel');
for i = 1:length(CPanels)
    StringChange = findobj(CPanels(i), 'Tag', 'ChooseType');
    StringChange.String = {'Amp','TOF','Aligment','Attenuation','TimeDiff'};
end
if ~isempty(CPanels)
    choice = findobj(CPanels(1), 'Tag', 'ChooseType');
    choice.Value = 4;
end

Update_CScan_Callback(1,1,f,0);

%% --- Attenuation-vs-frequency plot, restricted to the auto-detected band -
PlotAttenuationSpectrum(freq, alpha_s_spectrum, bandLow, bandHigh);

figure(f);

end
