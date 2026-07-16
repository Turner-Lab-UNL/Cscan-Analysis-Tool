# Project Context: Ultrasonic NDE C-Scan GUI — Attenuation Calculator Feature

## Who's using this
Research scientist (ultrasonic NDE, polycrystalline/AM materials) extending an
existing MATLAB GUI application (`MainFunction_V6.m` is the entry point) that
does ultrasonic C-scan/A-scan analysis, wave speed calculation, and waveform
alignment. The **Attenuation Calculator** feature (Experimental Diffraction
Correction / EDC method, mirroring the existing Wave Speed calculator's
structure) now also includes a VMax gain-normalization step and an
auto-detected (not user-dragged) usable frequency band — see "The physics"
and "File inventory" below for the current state.

## How to work with this codebase
- MATLAB GUIDE-free, hand-built GUIs using `uicontrol`/`uipanel`/`axes` with
  heavy use of nested closures, `Tag`-based `findobj` lookups, and **global
  variables** for shared state (not passed as function arguments in most
  places, even when it would be safer).
- Core globals: `Waves` (a `WaveMatrices` handle class — see below),
  `ScanSettings` (a `ScanParameters` handle class), `GateInfo` (4 gates,
  `Gate` handle class, not yet seen), `xCorrSettings`, `Draw`, `CurrentFolder`.
- New globals added for this feature: `RefWaves`, `RefScanSettings`,
  `CurrentFolderRef` — mirror the sample-side globals but for reference
  C-scan data (needed for the EDC method's reference/calibration signal).

## CRITICAL architectural gotchas discovered the hard way this session
These cost real debugging cycles — read before touching panel/axes code:

1. **`WaveMatrices` and `ScanParameters` are HANDLE classes** (confirmed via
   uploaded `WaveMatrices.m`/`ScanParameters.m`). Assigning `a = b` copies the
   reference, not the data. When you need an independent copy (e.g. to
   temporarily swap out `Waves` so a shared-global function like
   `OpenDataFile.m` doesn't clobber it), you must swap in a **fresh instance**
   (`WaveMatrices()`), not stash-and-restore the same object.

2. **`OpenDataFile.m` ignores its function arguments and always reads/writes
   the GLOBAL `Waves`/`ScanSettings`/`GateInfo`/`Draw`/`xCorrSettings`.**
   `LoadReferenceData_Callback.m` works around this by swapping in fresh
   instances before calling it, capturing the result, then restoring the
   original sample globals.

3. **The `'APanel'` tag is treated as a global broadcast target.**
   `GateSettings_GUI.m`'s `Apply_Callback` does an unscoped
   `findobj('tag','APanel')` and overwrites *every* matching panel across the
   whole app with the sample's `Waves.waveform_matrix` — no per-figure or
   per-pair scoping. `CreateCScanPannel.m`'s crosshair click handlers likely
   do the same. **Any reference-data A-scan panel must NOT carry the
   `'APanel'` tag**, or sample-side interactions will silently overwrite it.
   This was the cause of "reference A-scan shows sample data" — fixed by
   building the reference A-scan panel manually with `Tag='RefAPanel'`
   instead of using `CreateAScanPannel.m`.

4. **`SelectRegionMove.m` locates the "active" waveform line via a hardcoded
   `ax.Children(end-4)`** — the 5th-oldest object on the axes, counting from
   when the axes was created. `SelectRegionFunction.m` adds exactly 3 new
   objects (a `'SelectBox'` line + two `'SelectRegion'` lines) on the FIRST
   gate-drag interaction on a given axes. This means: **the real waveform
   line must be the 5th object ever created on that axes**, with exactly 4
   other objects created before it, for gate-dragging to grab the right line.
   - We now build this deliberately for the reference A-scan panel: 4
     placeholder lines (`plot(ax,nan,nan)`) created first, then a 5th line
     tagged `'RefWaveformLine'` created immediately after (with real 2+
     element placeholder data, e.g. `[0 1],[0 0]`) — **not lazily on data
     load**. `LoadReferenceAndPlot_Callback.m` and `RefCrosshairMotion.m`
     must only ever *update* this line's `XData`/`YData` in place, **never
     delete and recreate it** — deleting would break the object count/order.
   - **Do NOT use `'HandleVisibility','off'`** on the placeholder lines —
     that hides them from `ax.Children` entirely, which breaks this scheme
     outright (this was an earlier bug: dummies existed but weren't counted,
     so `end-4` indexed out of range / grabbed the wrong object).
   - **Root cause found and fixed (2026-07-09).** The for loop that created
     the 4 placeholder lines was running with `hold` still **off**
     (`NextPlot='replace'`), so each `plot(ax,nan,nan)` call silently cleared
     the axes before adding its line. Only 1 placeholder survived the loop,
     leaving 2 children total. After `SelectRegionFunction` added 3 objects
     the count became 5, making `end-4 = 1`, which indexed the newest
     SelectRegion line (`XData=[0]`, length 1) — hence "must not exceed 1".
     **Fix:** `hold(RefAScanAxes,'on')` is now called **before** the for loop
     in `CalculateAttenuation_GUI.m`, so all 4 dummies accumulate (5 children
     before any drag; 8 after the first drag, with `end-4=4` = RefWaveformLine).

5. **`CreateCScanPannel.m`'s `CScanAxes.Toolbar.Visible = 'off'`** disables
   the modern MATLAB axes toolbar, which can otherwise intercept clicks
   before they reach a figure-level `WindowButtonDownFcn`. Any manually-built
   axes meant to participate in this app's custom click/drag system should
   set this too (already done for `RefAScanAxes`/`RefCAxes`).

6. **`Update_CScan_Callback.m`'s `case 4` originally hardcoded
   `Waves.Wavespeed`** regardless of what the `ChooseType` dropdown label
   actually said. Since `Attenuation_Callback` (in `MainFunction_V6.m`)
   relabels option 4 from `'Velocity'` to `'Attenuation'`, this was a latent
   bug: selecting "Attenuation" would've shown stale/empty wave-speed data.
   **Fixed** — `case 4` now checks `WaveTypeHandel.String{4}` and reads
   `Waves.Attenuation` if the label says `'Attenuation'`, else falls back to
   `Waves.Wavespeed` (backward compatible with the existing Wave Speed
   feature).

7. **`A_Scan_Plot_GUI.m` is NOT safely reusable for reference data** — it
   hardcodes `global ScanSettings` for its time axis (would plot reference
   waveforms against the *sample's* time base) and expects a `'Rectification'`
   uicontrol plus the full 4-gate `GateInfo` overlay system to exist on the
   panel. The reference A-scan intentionally uses a much simpler custom plot
   instead of trying to force-fit this function.

8. **`C_Scan_Plot_GUI.m` IS safely reusable** — unlike the above, it takes
   `ScanSettings` as a plain argument (not a global), so it's called directly
   with `RefScanSettings` for the reference C-scan image. Reshape convention
   confirmed from its source: `PlottingMatrix = reshape(PlottingVector,
   [IndexPerRow, IndexPerColumn])` then `image(xvector,yvector,
   PlottingMatrix','CDataMapping','scaled')` — i.e. waveform index increases
   fastest along the scan direction (`IndexPerRow`), slower along the index
   direction (`IndexPerColumn`), column-major, unidirectional (no serpentine
   correction visible in this function, so raw data storage is assumed
   already in this order).

9. **`ExtractCSVData.m`'s `A/D Gain(dB)` header field is unreliable** — it
   doesn't match the gain actually dialed in experimentally, per the user.
   Never trust it for anything gain-sensitive. This is why VMax gain
   calibration (see "The physics" below) parses gain from **filenames**
   (`0dB.csv`, `15dB.csv`, ...) for the calibration sweep, and requires
   **manual gain entry** in the GUI (`gain_s`/`gain_r` fields) for the actual
   sample/reference scan gain — never auto-read from either file's header.

10. **The attenuation frequency band is no longer user-selected at all —
    an earlier interactive drag-to-select design (`SelectAttenuationBand_GUI.m`)
    was replaced** after the user reported the dragging didn't work (root
    cause never fully isolated — most likely the default axes
    `Interactions` (pan/zoom/data-tip, separate from `Toolbar.Visible`)
    were still consuming clicks; if a future interactive-drag figure is
    ever added in this app, set `ax.Interactions = [];` in addition to
    `Toolbar.Visible='off'`) and asked for the band to be auto-detected
    instead. See "The physics" below for the current (auto-detect) design,
    and `PlotAttenuationSpectrum.m` (a plain static plot, no mouse handlers
    at all) which replaced the old file.

11. **`gain_s`/`gain_r` edit fields live in `button_panel` (row 2), not
    `data_input_h`** — they were added there deliberately (see file
    inventory) so the VMax controls sit next to their own load buttons.
    A callback that does `findobj(data_input_h,'Tag','gain_s')` gets an
    empty `matlab.graphics.GraphicsPlaceholder` (not an error) — calling
    `.String` on that placeholder is what throws
    `Unrecognized method, property, or field 'String'`. This actually
    happened (2026-07-16 session) and was fixed by searching the whole
    figure (`findobj(f,'Tag','gain_s')`) instead. **General lesson for
    this codebase**: when a Tag'd control is added to a panel other than
    the one a callback's `findobj` calls are scoped to, either scope to
    the whole figure or double-check which panel it actually landed in —
    `findobj` failing silently (empty result, not an error) until you
    touch a property on it is an easy trap here.

12. **Reference data loaded via the main menu's "Load Reference Data" item
    doesn't automatically show up in the Attenuation GUI's reference
    panels.** The menu item (`MainFunction_V6.m`) is wired to the bare
    `LoadReferenceData_Callback.m`, which only populates the global
    `RefWaves`/`RefScanSettings` — it has no idea `CalculateAttenuation_GUI.m`'s
    `RefAPanel`/`RefWaveformLine`/`RefCAxes` exist (they might not, if the
    Attenuation GUI hasn't been opened yet). Previously, only the
    Attenuation GUI's own "Load Reference Data" button
    (`LoadReferenceAndPlot_Callback.m`) rendered into those panels, so
    loading from the main menu first left the GUI's reference panels blank
    even though `RefWaves` already had valid data — the user couldn't gate
    a signal that wasn't visibly plotted. **Fixed**: the render step was
    split out into `RenderReferenceData.m` (see file inventory), called
    both by `LoadReferenceAndPlot_Callback.m` after a fresh load AND by
    `CalculateAttenuation_GUI.m` at build time if `RefWaves.waveform_matrix`
    is already non-empty.

## Files still never seen (ask the user if something depends on these)
- `CreateAScanPannel.m` — still don't have this; the sample A-scan panel's
  exact internal object structure is still inferred, not confirmed.
- `FindCrosshairMotion.m`, `UpdateTextAndWaveform.m` — referenced by
  `SingleCrosshair_Function.m`/`DoubleCrosshair_Function.m` as the real
  crosshair update mechanism; not available, so a self-contained equivalent
  (`RefCrosshair_Callback.m`/`RefCrosshairMotion.m`) was built instead,
  tailored to `RefWaves`/`RefScanSettings`.
- `Gate.m`, `ApplyGate.m` — the 4-gate system's class definition and
  application logic. Not needed for the current EDC calculation (which uses
  simple `SelectRegion`-based time gating, not the app's 4-gate system), but
  would be needed if the reference C-scan should ever show proper gated
  Amp/TOF instead of the current simplified peak-to-peak amplitude image.

## The physics: EDC attenuation method
Implemented per the lab manual (MECH 996, Lab 3), Eq. 15-16:

```
alpha_s(f) = -1/(2*z_s) * [ ln( Bs(f)*(1-Rr^2)*Rr / (Br(f)*(1-Rs^2)*Rs) ) - 2*alpha_f(f)*dz_f ]
dz_f = zf_r - zf_s
```
- `Bs`, `Br`: FFT amplitude spectra of the sample/reference backwall gated
  windows (sample gated per-pixel; reference is the ROI-averaged waveform).
- `Rs`, `Rr`: fluid/solid reflection coefficients, `R = |(Z - Zf)/(Z + Zf)|`,
  `Z = rho*c`.
- `alpha_f(f) = 2.53*f_Hz^2*1e-14` Np/m (room-temp water estimate).
- `z_s`: sample thickness (material path); `zf_s`/`zf_r`: water paths used
  for sample/reference acquisition.
- Reference is assumed non-attenuating (e.g. fused silica), so `alpha_r ~ 0`
  and drops out.

This log-ratio formula was verified line-by-line against the lab's original
scripts and is correct on its own. What was **missing** (and is the likely
cause of a negative-attenuation bug reported for a previously-known-good
sample) is **VMax gain normalization**: `Bs`/`Br` are computed from raw
%FSS-scale amplitude data (`ExtractCSVData.m` rescales into roughly [-1,1]
but never removes the A/D gain setting). If the sample and reference were
scanned at different gains, the `Bs/Br` ratio is skewed before the log is
even taken. The fix (implemented, see file inventory below): sweep gain on a
fixed reflector up to saturation, record peak reflection amplitude per gain
step, fit a line to amplitude-vs-gain over the pre-saturation points, and
divide the gated sample/reference backwall segments by that line evaluated
at the actual scan gain — before the FFT. This normalization is **optional
and backward-compatible**: if a side isn't calibrated (no `VMaxCal` / no
gain entered), that side is used un-normalized and a warning is surfaced,
matching pre-normalization behavior exactly.

Band-averaging (which frequency range feeds the per-pixel attenuation
C-scan) is **no longer a pre-calculation input** (`fLow`/`fHigh` used to be
required before running the calc) **and, as of 2026-07-16, is no longer
user-selected at all — it's auto-detected**. Since these C-scans are
acquired over an area wider than the sample (open water beyond the sample
edges is in the same scan), blindly pre-choosing a band was unreliable, and
an interactive drag-to-select design (tried first, see gotcha #10) didn't
work reliably either. The current design: at "Calculate Attenuation" time,
take the FFT of the SAMPLE backwall gate on whichever single pixel is
currently displayed in the Sample A-scan panel (`global CurrentIndex`, set
by `UpdateTextAndWaveform.m` whenever the Sample C-scan crosshair moves —
i.e. the exact same waveform the backwall gate was just drawn on), find its
peak amplitude, and walk outward from the peak in both directions while the
amplitude stays >= 50% of that peak (a standard half-max / "-6dB" bandwidth
around the transducer's backwall echo). That `[bandLow, bandHigh]` (MHz) is
the band `alpha_s_avg` is averaged over for ALL C-scan pixels (not just the
one used to detect the band), and the only band the attenuation-vs-frequency
plot (`PlotAttenuationSpectrum.m`) or the single-frequency "Display Freq"
feature (`UpdateAttenuationFreq_Callback.m`) will accept. This is
per-sample-signal only — the reference's own bandwidth is NOT intersected
in, per the user (confirmed explicitly: sample-driven only).

Implemented in `AttenuationCalculator.m` (per-pixel loop over the sample
C-scan, producing the full frequency-dependent spectrum AND the
band-detection/averaging, both in this one function now — no separate
interactive step).

## File inventory — new files for this feature (all in an `Attenuation/`
folder added to the MATLAB path via `MainFunction_V6.m`)
- `AttenuationCalculator.m` — core EDC math, mirrors `WaveSpeedCalculator.m`.
  Signature: `[freq,alpha_s_spectrum,alpha_s_avg,bandLow,bandHigh,Bs_amp,
  Br_amp,VMaxWarning] = AttenuationCalculator(Waves,RefWaves,ScanSettings,
  RefScanSettings,MatProps,TimeCuts,RefTimeCuts,SampleIndex)` —
  `SampleIndex` (new) is the row into `Waves.waveform_matrix`/`shifted_matrix`
  for whichever pixel is currently shown in the Sample A-scan panel
  (`global CurrentIndex` in the caller); `bandLow`/`bandHigh` (new, MHz) are
  the auto-detected 50%-of-peak band (see "The physics" above);
  `alpha_s_avg` (back again, but now band-averaged internally rather than
  by an external interactive step) is `[1 x num_wfs]`, feeds the C-scan
  image. `MatProps.gain_s`/`gain_r` (optional, NaN = skip) drive the VMax
  normalization step.
- `VMax_Calculator.m` — gain-sweep calibration: parses gain from filenames
  (bare number, e.g. `0.csv`...`33.csv` — confirmed against a real
  gain-sweep folder this is how the lab actually names them — or an
  explicit `NdB.csv` suffix, both accepted), takes global max `|amplitude|`
  per file, auto-excludes saturated points (amplitude >= 0.97 by default),
  and `polyfit`s the rest. Returns a `VMaxCal` struct stored on
  `Waves.VMaxCal` / `RefWaves.VMaxCal`.
  - **Does NOT use `ExtractCSVData.m`** (an earlier version of this file
    did, and that was a bug). A real gain-sweep calibration file is a
    single-waveform UTwin **"UT A-Scan Waveform"** export — header block,
    then a `Time (us) , Amplitude (voltage)` column-title line, then plain
    two-column `time,amplitude` data — which is a *different, simpler*
    export than the multi-waveform **"UT C-Scan Data"** format
    `ExtractCSVData.m` parses (it has no `Scanning Length:`/`C-Scan
    Settings` section at all, so routing it through `ExtractCSVData.m`
    would fail). `VMax_Calculator.m` has its own local `ReadPeakAmplitude`
    helper: skip lines until the first one that starts with a digit after
    trimming (same "find the first numeric line" idea `ExtractCSVData.m`
    uses for its own header, just applied to this different format), then
    `textscan` the rest as `[time, amplitude]` pairs. Amplitude in these
    files is already a fraction of full scale (confirmed: peak climbs
    smoothly from ~0.016 to a clipped 1.0 across a real 0-33 dB sweep) —
    no `/100` rescale needed, unlike `ExtractCSVData.m`'s C-scan path.
  - Also note the `A/D Gain(dB)` header field in these calibration files is
    identical across every gain step in a real sweep (confirmed) — another
    reminder this field cannot be trusted for anything gain-related (see
    gotcha #9).
- `PlotVMaxCalibration.m` — diagnostic scatter+fit-line figure for a
  `VMaxCal` struct (used vs. excluded points, optional actual-gain marker).
- `LoadVMaxScan_Callback.m` — shared sample/reference GUI callback: folder
  picker -> `VMax_Calculator` -> stores on `Waves.VMaxCal`/`RefWaves.VMaxCal`
  -> status readout -> `PlotVMaxCalibration`. Sample and reference are
  independent workflows (reference is a one-time/rarely-redone calibration;
  sample gets a fresh calibration per scanned sample, per the user).
- `PlotAttenuationSpectrum.m` — plain STATIC mean+-std attenuation-vs-frequency
  plot across all C-scan pixels, `XLim` clamped to `[bandLow,bandHigh]`. No
  mouse handlers at all (replaced the old interactive
  `SelectAttenuationBand_GUI.m` — see gotcha #10). Purely a display step;
  all the calculation (including band detection) already happened inside
  `AttenuationCalculator.m` by the time this is called.
- `RenderReferenceData.m` — renders whatever is currently in the global
  `RefWaves`/`RefScanSettings` into the Attenuation GUI's `RefAPanel`
  (mean waveform into `'RefWaveformLine'`) and `RefCAxes` (peak-to-peak
  amplitude image via `C_Scan_Plot_GUI.m`). Split out of
  `LoadReferenceAndPlot_Callback.m` so `CalculateAttenuation_GUI.m` can
  also call it at build time — see gotcha #12.
- `CalculateAttenuation_Callback.m` — reads GUI inputs (Tag-based lookups,
  not the fragile `Children(end-N)` indexing the original wave-speed callback
  uses) including the optional `gain_s`/`gain_r` fields (searched across the
  whole figure `f`, NOT `data_input_h` — see gotcha #11) and `global
  CurrentIndex` (-> `SampleIndex`), calls `AttenuationCalculator`, stores the
  spectrum + auto-detected band on `Waves`, surfaces `VMaxWarning` via the
  `'AttnStatusBox'`-tagged status box, refreshes the result C-scan itself
  (palette-reset + `ChooseType`-dropdown + `Update_CScan_Callback` — no
  longer delegated to a separate interactive figure), and calls
  `PlotAttenuationSpectrum.m` to display the result.
- `CalculateAttenuation_GUI.m` — the interface itself; current layout:
  - Top band (4 columns): Sample A-scan | Sample C-scan (nav, full
    `CreateCScanPannel`) | Reference A-scan (manual, `Tag='RefAPanel'`) |
    Reference C-scan (manual, `Tag='RefCPanel'`)
  - Middle band, 2 rows: row 1 — the original 5 buttons (Select Sample
    Backwall, Select Reference Backwall, Load Reference Data, Gate Settings,
    Calculate Attenuation); row 2 — VMax gain-calibration controls, sample
    (left half) / reference (right half): load button, `gain_s`/`gain_r`
    edit field, status readout each
  - Bottom band: Result C-scan (full `CreateCScanPannel`, shows Amp/TOF/
    Attenuation/etc. via `ChooseType`) | material property panel (4x4 grid,
    16 fields: gates, thickness, water paths, wave speeds, densities,
    `fLow`/`fHigh` — `Enable='off'` read-only readouts of the
    auto-detected band, not editable inputs), side by side — user
    specifically requested this layout (easier for students) over an
    earlier full-width-properties-panel version
  - At GUI build time: if `RefWaves.waveform_matrix` is already non-empty
    (reference loaded via the main menu before this GUI was opened), calls
    `RenderReferenceData.m` immediately so the reference panels aren't
    left blank — see gotcha #12
- `LoadReferenceData_Callback.m` — loads reference C-scan file via
  `OpenDataFile.m`, using the fresh-instance swap trick (see gotcha #1/#2)
- `LoadReferenceAndPlot_Callback.m` — wraps the above, updates the
  pre-existing `'RefWaveformLine'` in place, renders the reference C-scan via
  `C_Scan_Plot_GUI.m`
- `RefCrosshair_Callback.m` / `RefCrosshairMotion.m` — continuous
  hover-crosshair navigation for the reference C-scan (self-built equivalent
  of the sample's crosshair system, see missing-files note above)
- `GetRefCScan_Callback.m` — pop-out button for the reference C-scan,
  mirrors `CreateCScanPannel.m`'s own `GetCScan_Callback`
- `OpenGateSettings_Callback.m` — opens `GateSettings_GUI.m` from within the
  Attenuation interface

## Files modified in place (not new, existing app files)
- `MainFunction_V6.m` — added `RefWaves`/`RefScanSettings`/`CurrentFolderRef`
  globals + initialization, `Attenuation/` addpath, "Load Reference Data"
  File-menu item, "Attenuation" Functions-menu item + `Attenuation_Callback`
  nested function (fixed a pre-existing bug while at it: the original
  `Wavespeed_Callback` looped `CPanels(n)` instead of `CPanels(i)`, updating
  the same panel `n` times instead of each panel once — the new
  `Attenuation_Callback` loops correctly)
- `WaveMatrices.m` — added properties: `Attenuation`, `AttenuationSpectrum`,
  `AttenuationFreq`, `AttenuationBandLow`, `AttenuationBandHigh` (MHz,
  auto-detected band edges), `Bs_amp`, `Br_amp`, `VMaxCal` (gain-calibration
  fit, used for both `Waves.VMaxCal` and `RefWaves.VMaxCal`)
- `Update_CScan_Callback.m` — `case 4` fix, see gotcha #6 above
- `UpdateAttenuationFreq_Callback.m` — the "Display Freq" single-frequency
  slice feature; its valid-range check now uses
  `Waves.AttenuationBandLow`/`AttenuationBandHigh` (the auto-detected band)
  instead of the full raw FFT range, since attenuation outside that band
  isn't considered reliable.

## Immediate next step
This round's fixes (2026-07-16: `gain_s`/`gain_r` figure-scoping crash,
`VMax_Calculator.m` file-format correction, reference-data propagation,
replacing drag-select with auto band-detection) have **not yet been run
against the live app** (implemented by reading source only — no MATLAB
available in the environment they were written in). Recommended
verification order:
1. Load reference data via the main-menu "Load Reference Data" item
   *before* opening the Attenuation GUI, then open it — confirm the
   reference A-scan/C-scan panels show the data immediately (gotcha #12),
   not blank panels requiring a second load.
2. Select the sample backwall gate, click "Calculate Attenuation" with no
   VMax calibration loaded — confirm it still runs (status box shows the
   "not calibrated" warning) and that `fLow`/`fHigh` populate with a
   plausible auto-detected band (should roughly bracket the transducer's
   center frequency) rather than erroring or showing a degenerate
   near-zero-width band.
3. Load real sample + reference VMax gain-sweep folders, enter the actual
   scan gains, re-run on the sample previously known to give correct
   (positive) attenuation — confirm sign/magnitude looks right.
4. Try "Update C-scan at Freq" with a frequency inside vs. outside the
   auto-detected band — confirm the outside case is rejected with the new
   band-specific error message.
5. Confirm `PlotAttenuationSpectrum.m`'s figure shows the expected
   mean+-std curve clipped to the band, and that clicking "Calculate
   Attenuation" again cleanly replaces the previous spectrum figure
   instead of accumulating stale ones.
