function VMaxCal = VMax_Calculator(folder, varargin)
% VMAX_CALCULATOR  Gain-linearization calibration for the EDC attenuation
% normalization step.
%
% VMaxCal = VMax_Calculator(folder)
% VMaxCal = VMax_Calculator(folder, 'SaturationThreshold', 0.97)
%
% Sweep gain on a fixed reflector, save one waveform per gain step as a
% single-waveform UTwin "UT A-Scan Waveform" export (header block, then a
% 'Time (us) , Amplitude (voltage)' column line, then two-column
% time,amplitude data -- confirmed against a real gain-sweep folder; this
% is a different, simpler export than the multi-waveform "UT C-Scan Data"
% format ExtractCSVData.m parses, so it is NOT reused here). Name each file
% with its gain -- either just the number (e.g. '0.csv', '15.csv', '33.csv')
% or with an explicit 'dB' suffix (e.g. '15dB.csv') -- both are accepted.
% This function reads every matching file, records the peak |amplitude|,
% fits a line to amplitude vs gain (dB) over the pre-saturation points, and
% returns the fit plus the raw data so the caller can evaluate VMax at
% whatever gain the real sample/reference scan used
% (VMax = polyval(VMaxCal.coeffs, actual_gain)) and can redraw/inspect the
% calibration later.
%
% INPUT
%   folder    char path to a folder of calibration csv files, OR a cellstr
%             of explicit file paths.
%   'SaturationThreshold'  amplitude (fraction of full scale, ~[0 1]) at/
%             above which a point is treated as clipped and excluded from
%             the fit. Default 0.97.
%
% OUTPUT  VMaxCal struct:
%   .gain        1 x N, dB, sorted ascending
%   .amplitude   1 x N, peak |amplitude| per file, same order as .gain
%   .saturated   1 x N logical, true where excluded from the fit
%   .coeffs      1 x 2, polyfit(gain(~saturated), amplitude(~saturated), 1)
%   .threshold   the saturation threshold used
%   .folder      the input folder (or '' if a file list was given)
%   .files       1 x N cellstr, full paths, same order as .gain
%   .skipped     cellstr of filenames that didn't match the gain pattern

p = inputParser;
addParameter(p, 'SaturationThreshold', 0.97, @(x) isnumeric(x) && isscalar(x));
parse(p, varargin{:});
threshold = p.Results.SaturationThreshold;

%% --- Resolve the file list ------------------------------------------------
if iscellstr(folder) || isstring(folder) && ~isscalar(folder) %#ok<ISCLSTR>
    files = cellstr(folder);
    folderOut = '';
else
    folder = char(folder);
    folderOut = folder;
    listing = [dir(fullfile(folder, '*.csv')); dir(fullfile(folder, '*.CSV'))];
    files = unique(fullfile({listing.folder}, {listing.name}));
end

if isempty(files)
    error('VMax_Calculator:NoFiles', 'No calibration files found in %s.', folderOut);
end

%% --- Parse gain from each filename, load, extract peak amplitude ---------
gain      = nan(1, numel(files));
amplitude = nan(1, numel(files));
skipped   = {};

for k = 1:numel(files)
    [~, name, ~] = fileparts(files{k});
    tok = regexpi(name, '(-?\d+\.?\d*)\s*dB', 'tokens', 'once');
    if isempty(tok)
        % No explicit 'dB' suffix -- accept a bare number as the gain
        % itself (this is how the lab actually names these, e.g. '0.csv',
        % '33.csv' for a 0-33 dB sweep).
        if ~isempty(regexpi(name, '^-?\d+\.?\d*$', 'once'))
            tok = {name};
        end
    end
    if isempty(tok)
        skipped{end+1} = files{k}; %#ok<AGROW>
        continue
    end
    gain(k) = str2double(tok{1});

    try
        amplitude(k) = ReadPeakAmplitude(files{k});
    catch ME
        error('VMax_Calculator:ReadFailed', ...
            'Failed to read waveform data from %s: %s', files{k}, ME.message);
    end
end

keep      = ~isnan(gain);
gain      = gain(keep);
amplitude = amplitude(keep);
files     = files(keep);

if numel(gain) < 2
    error('VMax_Calculator:TooFewPoints', ...
        'Fewer than 2 gain-labeled calibration files were found (parsed %d).', numel(gain));
end

%% --- Sort by gain, flag saturation, fit ------------------------------------
[gain, sortIdx] = sort(gain);
amplitude = amplitude(sortIdx);
files     = files(sortIdx);

saturated = amplitude >= threshold;

if sum(~saturated) < 2
    error('VMax_Calculator:TooFewUnsaturatedPoints', ...
        'Fewer than 2 unsaturated calibration points remain after excluding amplitude >= %.3f.', threshold);
end

coeffs = polyfit(gain(~saturated), amplitude(~saturated), 1);

%% --- Package output ---------------------------------------------------------
VMaxCal.gain      = gain;
VMaxCal.amplitude = amplitude;
VMaxCal.saturated = saturated;
VMaxCal.coeffs    = coeffs;
VMaxCal.threshold = threshold;
VMaxCal.folder    = folderOut;
VMaxCal.files     = files;
VMaxCal.skipped   = skipped;

end

function peakAmp = ReadPeakAmplitude(filepath)
% Reads a single-waveform UTwin "UT A-Scan Waveform" export: a text header
% block (Operator/Date/A-D settings/etc, one per line), then a
% 'Time (us) , Amplitude (voltage)' column-title line, then two-column
% comma-separated numeric data. Skips lines until the first one that
% starts (after trimming whitespace) with a digit -- the same "find the
% first numeric line" convention ExtractCSVData.m uses for its own header
% detection -- then reads everything from there as [time, amplitude] pairs.

fid = fopen(filepath, 'r');
if fid == -1
    error('Could not open file.');
end

headerLines = 0;
foundData = false;
while true
    line = fgetl(fid);
    if ~ischar(line)
        break
    end
    headerLines = headerLines + 1;
    trimmed = strtrim(line);
    if ~isempty(trimmed) && isstrprop(trimmed(1), 'digit')
        foundData = true;
        break
    end
end
fclose(fid);

if ~foundData
    error('No numeric data rows found.');
end

fid = fopen(filepath, 'r');
raw = textscan(fid, '%f%f', 'Delimiter', ',', 'HeaderLines', headerLines - 1);
fclose(fid);

amp = raw{2};
if isempty(amp)
    error('No amplitude data parsed.');
end
peakAmp = max(abs(amp));
end
