function OpenGateSettings_Callback(~,~,f)
% OPENGATESETTINGS_CALLBACK  Opens the existing Gate Settings interface
% (GateSettings_GUI.m) from within the Attenuation GUI, so gate parameters
% can be tuned without switching back to the main window. Mirrors
% MainFunction_V6's GateSettings_Callback nested function.
%
% SCOPE NOTE: GateSettings_GUI.m's Apply_Callback recomputes gated Amp/TOF
% via ApplyGate(Waves.waveform_matrix,...) -- the SAMPLE data only. It does
% not touch RefWaves. That's fine for this GUI's Result C-scan (which uses
% the standard GateInfo.CurrentGate.Amp/TOF machinery like any other
% CPanel), but it means the Reference C-scan panel here (a simplified
% peak-to-peak amplitude image, not gate-based) won't reflect gate changes.
% If you want the reference C-scan to use proper gated Amp/TOF instead of
% the peak-to-peak approximation, share Gate.m and ApplyGate.m -- extending
% gate application to RefWaves safely requires knowing how GateInfo.g1-g4
% store their computed Amp/TOF internally, since they're shared globals
% not duplicated per-dataset, and applying them to reference data naively
% risks overwriting the sample's currently-displayed gated values.

h=findobj('Name','Gate Settings Interface');
if isempty(h)
    GateSettings_GUI(f)
else
    figure(h)
end
end
