function LoadVMaxScan_Callback(~,~,Target,StatusBox,GainEdit)
% LOADVMAXSCAN_CALLBACK  Prompts for a folder of gain-sweep calibration
% files (one waveform per gain step, filenames like '0dB.csv'), runs
% VMax_Calculator, stores the fit on the target waveform set's VMaxCal
% property, and shows a diagnostic plot.
%
% Target: 'sample'    -> global Waves
%         'reference'  -> global RefWaves
%
% GainEdit (optional): edit-box handle holding the actual scan gain (dB),
% used only to mark where that gain lands on the fitted line in the
% diagnostic plot -- purely visual, not required for the fit itself.

global Waves RefWaves

switch Target
    case 'sample'
        W = Waves;
        label = 'Sample';
    case 'reference'
        W = RefWaves;
        label = 'Reference';
    otherwise
        error('LoadVMaxScan_Callback:BadTarget', 'Target must be ''sample'' or ''reference''.');
end

folder = uigetdir(pwd, sprintf('Select %s VMax gain-sweep folder', label));
if isequal(folder, 0)
    return  % user cancelled
end

StatusBox.String = sprintf('%s VMax: fitting...', label);
StatusBox.BackgroundColor = [1 1 0];
drawnow;

try
    VMaxCal = VMax_Calculator(folder);
catch ME
    StatusBox.String = sprintf('%s VMax: failed', label);
    StatusBox.BackgroundColor = [1 0 0];
    errordlg(ME.message, sprintf('%s VMax Calibration Failed', label));
    return
end

W.VMaxCal = VMaxCal;

nUsed = sum(~VMaxCal.saturated);
nSat  = sum(VMaxCal.saturated);
StatusBox.String = sprintf('%s VMax: %d pts (%d excl.)', label, nUsed, nSat);
StatusBox.BackgroundColor = [0 1 0];

actualGain = [];
if nargin >= 5 && ~isempty(GainEdit) && isvalid(GainEdit)
    actualGain = str2double(GainEdit.String);
end
PlotVMaxCalibration(VMaxCal, label, actualGain);

end
