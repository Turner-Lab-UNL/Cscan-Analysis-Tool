function LoadReferenceData_Callback(~,~,FileNameBox,MessageBox)
% LOADREFERENCEDATA_CALLBACK  Loads the reference-sample C-scan (fused
% silica or other non-scattering reference) used by the EDC attenuation
% method, mirroring SelectData_Callback.m.
%
% CAVEAT: OpenDataFile.m ignores the struct arguments passed to it and
% always reads/writes the GLOBAL Waves/ScanSettings/GateInfo/Draw/
% xCorrSettings. To reuse it without clobbering your sample data, this
% callback swaps in FRESH, empty instances of those globals before calling
% OpenDataFile, lets it populate the fresh instances with the reference
% file, captures the result into RefWaves/RefScanSettings, then puts the
% original sample objects back.
%
% This "swap to fresh instance, then restore the original" approach is
% deliberate rather than a simple stash/restore: if WaveMatrices /
% ScanParameters / Gate / Draw / CrossCorParameters turn out to be HANDLE
% classes, a plain "Stashed = Waves" only stashes a reference to the same
% object OpenDataFile is about to mutate, and restoring it afterward would
% silently do nothing. Swapping in a brand-new object avoids that failure
% mode regardless of whether these are handle or value classes.
%
% Long-term cleaner fix: refactor OpenDataFile.m to return
% Waves/ScanSettings/etc. as outputs instead of writing globals directly,
% so it can be called generically for any target (sample, reference, or
% more) without this workaround.

global CurrentFolderRef
global RefScanSettings
global RefWaves
global ScanSettings Waves GateInfo Draw xCorrSettings

MessageBox.String = 'Reference Load in Process';
MessageBox.BackgroundColor = [1 1 0];
SoftwareType = 1;

%% --- keep the original sample objects, then swap in fresh instances ----
StashedWaves        = Waves;
StashedScanSettings  = ScanSettings;
StashedGateInfo      = GateInfo;
StashedDraw          = Draw;
StashedxCorrSettings = xCorrSettings;

Waves        = WaveMatrices();
ScanSettings = ScanParameters();
GateInfo     = StashedGateInfo;   % gate settings aren't file-dependent; fine to leave as-is
Draw         = StashedDraw;       % same for Draw
xCorrSettings = CrossCorParameters();

[FilterIndex,filename,CurrentFolderRef] = OpenDataFile(RefScanSettings,RefWaves,CurrentFolderRef,SoftwareType);

%% --- OpenDataFile just populated the fresh instances; capture them ------
RefWaves        = Waves;
RefScanSettings = ScanSettings;

%% --- restore the untouched original sample objects -----------------------
Waves        = StashedWaves;
ScanSettings = StashedScanSettings;
GateInfo     = StashedGateInfo;
Draw         = StashedDraw;
xCorrSettings = StashedxCorrSettings;

if FilterIndex == 0
    MessageBox.BackgroundColor = [1 1 0];
    MessageBox.String = 'User Terminated Reference Load';
    return    % user exited out
end

MessageBox.String = 'Reference Data Acquired';
MessageBox.BackgroundColor = [0 1 0];
FileNameBox.String = filename;
end
