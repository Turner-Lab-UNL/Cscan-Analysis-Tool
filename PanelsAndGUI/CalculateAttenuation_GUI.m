function CalculateAttenuation_GUI
global ScanSettings
global GateInfo
global RefWaves

if isempty(ScanSettings.f_s)
    errordlg('Data not selected. Please select sample data first!!')
    return
end

FigStart=0;
FigEnd=0;
FigWidth=1200;
FigHight=850;

GateInfo.CurrentGate.MouseClick=0;

f = figure('Visible','off','Position',[FigStart,FigEnd,FigWidth,FigHight]);
f.SizeChangedFcn=@ResizeFunction;
delete(findall(f,'tag','Annotation.InsertLegend'));
delete(findall(f,'tag','Annotation.InsertColorbar'));
delete(findall(f,'tag','DataManager.Linking'));
delete(findall(f,'tag','Standard.PrintFigure'));
delete(findall(f,'tag','Standard.SaveFigure'));
delete(findall(f,'tag','Standard.FileOpen'));
delete(findall(f,'tag','Standard.NewFigure'));
delete(findall(f,'tag','Standard.OpenInspector'));
addToolbarExplorationButtons(f)
delete(findall(f,'tag','Exploration.Brushing'));
hEdit=findall(f,'tag','Standard.EditPlot');
if ~isempty(hEdit)
    hEdit.ClickedCallback = 'CurserCallback(gcbf)';
end

%% Panels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Layout (normalized):
%   Top band   [.605,.995]   : Sample A-scan | Sample C-scan (nav) | Reference A-scan | Reference C-scan (nav)
%   Mid band   [.455,.6]     : 2 rows -- row 1: 5 gate/calc buttons; row 2: VMax gain-calibration
%                              controls (sample + reference, see Problem 1 in the attenuation plan)
%   Bottom band[.005,.45]    : Result C-scan (Amp/TOF/Attenuation/etc.) | Material property panel, side by side
%
% This mirrors CalculateWaveSpeed_GUI.m's split more closely: a dedicated
% Result panel (full ChooseType dropdown, incl. 'Attenuation' once
% Attenuation_Callback in MainFunction_V6 relabels it) sits next to the
% inputs, while the top band handles gate selection/navigation for both
% datasets.
%
% Reference C-scan (top band, col 4) is still NOT built with
% CreateCScanPannel -- its click-navigation is wired myself directly to
% RefWaves/RefScanSettings (see LoadReferenceAndPlot_Callback.m /
% RefCrosshair_Callback.m / RefCrosshairMotion.m), since CreateCScanPannel's built-in machinery
% is tied to the global Waves.

gap=.005;
top_y = .605; top_h = .39;
col_w = (1 - gap*5)/4;
col1_x = gap;
col2_x = col1_x + col_w + gap;
col3_x = col2_x + col_w + gap;
col4_x = col3_x + col_w + gap;

% -- Sample A-scan (backwall gate selected here) --------------------------
CreateAScanPannel(f);
APanels=findobj(f,'Tag','APanel');
APanel=APanels(1);
AScanAxes=APanel.Children(end);
AScanAxes.NextPlot='replacechildren';
APanel.Position=[col1_x, top_y, col_w, top_h];

% -- Sample C-scan (navigation; full-featured, not hidden) ----------------
CreateCScanPannel(f);
CPanels=findobj(f,'Tag','CPanel');
SampleCPanel=CPanels(1);
SampleCPanel.Position=[col2_x, top_y, col_w, top_h];

% -- Reference A-scan (manual; deliberately NOT tagged 'APanel') ----------
% CRITICAL: GateSettings_GUI.m's Apply_Callback does an UNSCOPED
% findobj('tag','APanel') sweep and overwrites every matching panel with
% the SAMPLE waveform (Waves.waveform_matrix) -- no per-pair awareness.
% CreateCScanPannel's crosshair click handlers almost certainly do the
% same. If this panel carried the 'APanel' tag (as it did when built via
% CreateAScanPannel), any sample-side crosshair click or Gate Settings
% Apply silently overwrites its contents with sample data -- this was the
% cause of the reference A-scan showing sample waveforms. Building it
% manually with tag 'RefAPanel' keeps it outside that broadcast entirely.
RefAPanel = uipanel('Tag','RefAPanel','BackgroundColor','white',...
    'Position',[col3_x, top_y, col_w, top_h]);
RefAScanAxes = axes('Parent',RefAPanel,'Units','normalized','Position',[.12,.15,.83,.75]);
RefAScanAxes.XLabel.String = 'Time (us)';
RefAScanAxes.YLabel.String = 'Amplitude';
RefAScanAxes.Toolbar.Visible = 'off';
RefATitle = uicontrol(RefAPanel,'Style','text','Units','normalized',...
    'BackgroundColor','white','String','Reference A-scan',...
    'Position',[.05,.91,.9,.07]);
RefATitle.HitTest='off';

% Pre-seed 4 placeholder lines so the real waveform line (created right
% after, as the 5th object on this axes) lands exactly where
% SelectRegionMove.m expects it: ax.Children(end-4). SelectRegionFunction.m
% adds exactly 3 new objects (a SelectBox line + 2 SelectRegion lines) on
% the FIRST gate drag, all newer than anything already on the axis -- so
% the fixed end-4 offset only lands on the correct line if the real
% waveform was the 5th object ever created here.
%
% CRITICAL: these must NOT use 'HandleVisibility','off' -- that hides an
% object from ax.Children entirely, which previously broke gate selection
% on this panel.
% hold must be on BEFORE the loop so each plot() call accumulates rather
% than replacing. With hold off (NextPlot='replace'), each plot() clears
% the axes first, so only the last placeholder would survive — leaving only
% 2 children total (1 placeholder + waveform line). SelectRegionFunction
% then adds 3 objects, making end=5 and end-4=1, which lands on the newest
% SelectRegion line (XData=[0], length 1) instead of the waveform line.
hold(RefAScanAxes,'on')
for k=1:4
    plot(RefAScanAxes,nan,nan);
end
RefWaveformLine = plot(RefAScanAxes,[0 1],[0 0],'Color',[0 0.447 0.741]);
RefWaveformLine.Tag = 'RefWaveformLine';
hold(RefAScanAxes,'off')

% -- Reference C-scan (manual, reads RefWaves directly) -------------------
RefCPanel = uipanel('Tag','RefCPanel','BackgroundColor','white',...
    'Position',[col4_x, top_y, col_w, top_h]);
RefCAxes = axes('Parent',RefCPanel,'Units','normalized','Position',[.07,.195,.8,.7],'Tag','Axes');
RefCAxes.NextPlot = 'replacechildren';
RefCAxes.Toolbar.Visible = 'off';
RefCAxes.XLabel.String = 'Scan Position (mm)';
RefCAxes.YLabel.String = 'Index Position (mm)';
RefCTitle = uicontrol(RefCPanel,'Style','text','Units','normalized',...
    'BackgroundColor','white','String','Reference C-scan (load data to populate)',...
    'Position',[.05,.91,.9,.07]);
RefCTitle.HitTest='off';

RefGetCScan = uicontrol(RefCPanel,'Style','pushbutton',...
    'String','Get','Units','normalized','Position',[.04,.91,.2,.075],...
    'Callback',{@GetRefCScan_Callback,RefCAxes});

RefCrosshairButton = uicontrol(RefCPanel,'Style','togglebutton',...
    'String','+','Units','normalized','Position',[.81,.91,.15,.075]);

RefPositionPanel = uipanel('Parent',RefCPanel,'BackgroundColor',[.8 .8 .8],'Visible','on',...
    'Units','normalized','Position',[0.0002,.0002,.6,.13],'Tag','RefPositionPanel');
RefPosText = uicontrol(RefPositionPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Click image to navigate','Units','normalized',...
    'Position',[.02,.21,.6,.77],'HorizontalAlignment','left');
RefScanPosition = uicontrol(RefPositionPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Scan =','Units','normalized','Position',[.02,-.3,.45,.77],...
    'Tag','RefScan','HorizontalAlignment','left');
RefIndexPosition = uicontrol(RefPositionPanel,'Style','text','BackgroundColor',[.8 .8 .8],...
    'String','Index = ','Units','normalized','Position',[.48,-.3,.5,.77],...
    'Tag','RefIndex','HorizontalAlignment','left');
RefGetCScan.HitTest='off';
RefCrosshairButton.HitTest='off';
RefPositionPanel.HitTest='off';
RefPosText.HitTest='off';
RefScanPosition.HitTest='off';
RefIndexPosition.HitTest='off';

%% Buttons %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Two rows: row 1 (top) is the original 5-button workflow; row 2 (bottom)
% is the VMax gain-calibration workflow -- separate for sample and
% reference, since the reference calibration is a one-time/rarely-redone
% thing while the sample calibration is collected fresh per scanned
% sample (see CLAUDE.md EDC normalization notes).
num_buttons=5;
total_width=1-gap*(num_buttons+1);
b_width=total_width/num_buttons;

button_panel = uipanel('Tag','AttenuationPanel','BackgroundColor','white',...
    'Position',[0, .455, 1, .145]);

SelectSampleGate = uicontrol(button_panel,'Style','togglebutton',...
    'String','Select Sample Backwall','Units','normalized',...
    'Position',[gap, .54, b_width, .42]);

SelectRefGate = uicontrol(button_panel,'Style','togglebutton',...
    'String','Select Reference Backwall','Units','normalized',...
    'Position',[gap*2+b_width, .54, b_width, .42]);

LoadRefButton = uicontrol(button_panel,'Style','pushbutton',...
    'String','Load Reference Data','Units','normalized',...
    'Position',[gap*3+b_width*2, .54, b_width, .42]);

GateSettingsButton = uicontrol(button_panel,'Style','pushbutton',...
    'String','Gate Settings','Units','normalized',...
    'Position',[gap*4+b_width*3, .54, b_width, .42]);

CalculateAttenuationButton = uicontrol(button_panel,'Style','pushbutton',...
    'String','Calculate Attenuation','Units','normalized',...
    'Position',[gap*5+b_width*4, .54, b_width, .42]);

% -- Row 2: VMax gain calibration, sample (left half) / reference (right half) --
LoadSampleVMaxButton = uicontrol(button_panel,'Style','pushbutton',...
    'String','Load Sample VMax Scan','Units','normalized',...
    'Position',[.005, .06, .20, .38]);
GainSampleLabel = uicontrol(button_panel,'Style','text','Units','normalized',...
    'BackgroundColor','white','HorizontalAlignment','left','FontSize',8,...
    'String','Gain (dB):','Position',[.215, .06, .075, .38]);
GainSampleLabel.HitTest='off';
GainSampleEdit = uicontrol(button_panel,'Tag','gain_s','Style','edit','Units','normalized',...
    'String','','Position',[.293, .06, .05, .38]);
VMaxStatus_s = uicontrol(button_panel,'Style','text','Units','normalized',...
    'BackgroundColor',[.85 .85 .85],'HorizontalAlignment','left','FontSize',8,...
    'String','Sample VMax: not calibrated','Position',[.348, .06, .145, .38]);
VMaxStatus_s.HitTest='off';

LoadRefVMaxButton = uicontrol(button_panel,'Style','pushbutton',...
    'String','Load Reference VMax Scan','Units','normalized',...
    'Position',[.505, .06, .20, .38]);
GainRefLabel = uicontrol(button_panel,'Style','text','Units','normalized',...
    'BackgroundColor','white','HorizontalAlignment','left','FontSize',8,...
    'String','Gain (dB):','Position',[.715, .06, .075, .38]);
GainRefLabel.HitTest='off';
GainRefEdit = uicontrol(button_panel,'Tag','gain_r','Style','edit','Units','normalized',...
    'String','','Position',[.793, .06, .05, .38]);
VMaxStatus_r = uicontrol(button_panel,'Style','text','Units','normalized',...
    'BackgroundColor',[.85 .85 .85],'HorizontalAlignment','left','FontSize',8,...
    'String','Reference VMax: not calibrated','Position',[.848, .06, .145, .38]);
VMaxStatus_r.HitTest='off';

%% Bottom band: Result C-scan + Material Property panel, side by side %%%%%
% -- Result C-scan (full ChooseType, incl. Attenuation after calc) --------
CreateCScanPannel(f);
CPanels=findobj(f,'Tag','CPanel');
ResultCPanel=CPanels(1);
ResultCPanel.Position=[.005, .005, .4925, .445];

PanelColor=[.95 .95 .95];

data_input_h = uipanel('Tag','AttenuationInputData','BackgroundColor','white',...
    'Position',[.5025, .005, .4925, .445]);

TitleText = uicontrol(data_input_h,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'FontWeight','bold',...
    'String','EDC Attenuation Inputs','Position',[.005,.93,.99,.05]);
TitleText.HitTest='off';

% -- status / reference filename readouts ---------------------------------
RefFileNameBox = uicontrol(data_input_h,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'HorizontalAlignment','left',...
    'String','Reference File Name','Position',[.005,.005,.62,.06]);
RefFileNameBox.HitTest='off';

StatusBox = uicontrol(data_input_h,'Tag','AttnStatusBox','Style','text','Units','normalized',...
    'BackgroundColor',[0.6 0.6 0.6],'HorizontalAlignment','left',...
    'String','Status','Position',[.63,.005,.365,.06]);
StatusBox.HitTest='off';

% -- explicit field layout: 4 columns x 4 rows -----------------------------
col_x = [.005,.255,.505,.755];
row_y = [.82,.60,.38,.16];
label_w = .14; edit_w = .095; field_h = .08;

fieldDefs = { ...
    % row 1: gates (auto-filled by Select Sample/Reference Backwall)
    't1_sample','Sample BW t1 (us)','n/a'; ...
    't2_sample','Sample BW t2 (us)','n/a'; ...
    't1_ref','Ref BW t1 (us)','n/a'; ...
    't2_ref','Ref BW t2 (us)','n/a'; ...
    % row 2: thickness / water path
    'z_s','Sample Thick. z_s (mm)','n/a'; ...
    'z_r','Ref Thick. z_r (mm)','6.35'; ...
    'zf_s','Sample Water Path (mm)','n/a'; ...
    'zf_r','Ref Water Path (mm)','n/a'; ...
    % row 3: wave speeds + low band edge
    'c_s','Sample Speed c_s (m/s)','n/a'; ...
    'c_f','Fluid Speed c_f (m/s)','1486'; ...
    'c_r','Ref Speed c_r (m/s)','5968'; ...
    'fLow','Band Low (MHz) [auto]','n/a'; ...
    % row 4: densities + high band edge
    'rho_s','Sample Density (kg/m3)','n/a'; ...
    'rho_f','Fluid Density (kg/m3)','1000'; ...
    'rho_r','Ref Density (kg/m3)','2200'; ...
    'fHigh','Band High (MHz) [auto]','n/a'; ...
    };

editHandles = struct();
idx = 1;
for r = 1:4
    for c = 1:4
        x = col_x(c);
        y = row_y(r);
        tag   = fieldDefs{idx,1};
        label = fieldDefs{idx,2};
        default = fieldDefs{idx,3};

        lbl = uicontrol(data_input_h,'Style','text','Units','normalized',...
            'BackgroundColor',PanelColor,'HorizontalAlignment','left',...
            'FontSize',8,'String',label,'Position',[x, y, label_w, field_h]);
        lbl.HitTest='off';

        ed = uicontrol(data_input_h,'Tag',tag,'Style','edit','Units','normalized',...
            'String',default,'Position',[x+label_w, y, edit_w, field_h],...
            'Enable','on');
        ed.HitTest='on';

        editHandles.(tag) = ed;
        idx = idx + 1;
    end
end

% fLow/fHigh are a read-only readout of the auto-detected 50%-of-peak band
% (see AttenuationCalculator.m), computed fresh on every "Calculate
% Attenuation" click -- not a pre-calc input, disable typing into them.
editHandles.fLow.Enable  = 'off';
editHandles.fHigh.Enable = 'off';

% -- Display-frequency selector (between 4x4 grid and status bar) ---------
% Initial C-scan shows band-averaged attenuation; enter a specific frequency
% here then click "Update C-scan" to show attenuation at that frequency.
fDispLabel = uicontrol(data_input_h,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'HorizontalAlignment','left',...
    'FontSize',8,'String','Display Freq (MHz):',...
    'Position',[.005, .08, .185, .07]);
fDispLabel.HitTest = 'off';

uicontrol(data_input_h,'Tag','fDisplay','Style','edit','Units','normalized',...
    'String','n/a','Position',[.195, .08, .095, .07],'Enable','on');

UpdateFreqButton = uicontrol(data_input_h,'Style','pushbutton','Units','normalized',...
    'String','Update C-scan at Freq','Position',[.30, .08, .25, .07]);

%% Wiring %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SelectSampleGate.Callback = {@SelectRegion,f,APanel,editHandles.t1_sample,editHandles.t2_sample,1};
SelectRefGate.Callback    = {@SelectRegion,f,RefAPanel,editHandles.t1_ref,editHandles.t2_ref,1};
LoadRefButton.Callback    = {@LoadReferenceAndPlot_Callback,RefFileNameBox,StatusBox,RefAPanel,RefCAxes};
RefCrosshairButton.Callback = {@RefCrosshair_Callback,f,RefCAxes,RefAPanel,RefScanPosition,RefIndexPosition};
GateSettingsButton.Callback = {@OpenGateSettings_Callback,f};
CalculateAttenuationButton.Callback = {@CalculateAttenuation_Callback,data_input_h};
UpdateFreqButton.Callback  = {@UpdateAttenuationFreq_Callback,data_input_h,f};
LoadSampleVMaxButton.Callback = {@LoadVMaxScan_Callback,'sample',VMaxStatus_s,GainSampleEdit};
LoadRefVMaxButton.Callback    = {@LoadVMaxScan_Callback,'reference',VMaxStatus_r,GainRefEdit};

% If reference data was already loaded via the main menu's "Load Reference
% Data" item (wired to the bare LoadReferenceData_Callback, which only
% populates the RefWaves/RefScanSettings globals -- it has no idea this
% GUI's RefAPanel/RefCAxes exist) before this GUI was opened, RefWaves
% already holds valid data even though these panels were just built blank.
% Render it now instead of leaving the user with a blank reference A-scan
% they can't gate against.
if ~isempty(RefWaves.waveform_matrix)
    RefFileNameBox.String = 'Reference already loaded';
    RenderReferenceData(RefAPanel, RefCAxes);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(ScanSettings.scan_len)
    SampleCPanel.Children(end).XLim=[0 ScanSettings.scan_len];
    SampleCPanel.Children(end).YLim=[0 ScanSettings.index_len];
    ResultCPanel.Children(end).XLim=[0 ScanSettings.scan_len];
    ResultCPanel.Children(end).YLim=[0 ScanSettings.index_len];
    APanel.Children(end).YLim=[-1 1];
    APanel.Children(end).XLim=[ScanSettings.w_s,ScanSettings.w_s+ScanSettings.w_w];
end

RefAScanAxes.YLim=[-1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f.Name = 'Calculate Attenuation Interface';
f.NumberTitle='off';
movegui(f,'center')
Update_CScan_Callback(1,1,f,0)
f.Visible='on';

f.Units = 'normalized';
SelectSampleGate.Units = 'normalized';
SelectRefGate.Units    = 'normalized';

end
