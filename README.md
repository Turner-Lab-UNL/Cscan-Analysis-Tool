# Cscan-Analysis-Tool

A MATLAB GUI for post-processing ultrasonic C-scan/A-scan data: visualization,
gating, waveform alignment, wave speed calculation, and ultrasonic attenuation
calculation. Originally developed by Nathanial Matz (who refused to have a
GitHub ID despite several motivations from his labmates); maintained by the
Turner Lab at the University of Nebraska-Lincoln.

## Features

- **C-scan / A-scan visualization** — load a C-scan data file and interactively
  navigate it: click or hover on the C-scan image to inspect the corresponding
  A-scan waveform at that pixel, with configurable gates (`Functions > Gate
  Settings`) for amplitude/time-of-flight extraction.
- **Waveform alignment** — cross-correlation-based alignment of waveforms
  across a C-scan (`Functions > Waveform Alignment`), useful for correcting
  time-of-flight jitter before downstream analysis.
- **Wave speed calculator** — computes material wave speed from a gated
  time-of-flight measurement across a C-scan (`Functions > Wavespeed`).
- **Attenuation calculator** — ultrasonic attenuation via the Experimental
  Diffraction Correction (EDC) method (`Functions > Attenuation`), comparing a
  sample C-scan against a reference (e.g. fused silica) C-scan. Includes:
  - **VMax gain normalization**: a gain-sweep calibration procedure (sweep
    A/D gain on a fixed reflector up to saturation, fit amplitude vs. gain)
    used to put sample and reference amplitude on a comparable absolute
    scale even when the two were scanned at different gains — the
    acquisition software's own recorded gain field is not reliable enough
    to correct for this directly.
  - **Automatic frequency-band detection**: rather than requiring a
    manually-chosen frequency band, the usable band is auto-detected as the
    50%-of-peak (≈ −6 dB) bandwidth around the sample backwall's spectral
    peak, and used to produce both a per-pixel attenuation C-scan image and
    an attenuation-vs-frequency plot.
- **Variance/location tools** — select and track regions of interest across a
  C-scan (`VarianceLocationsFcns/`), useful for comparing measurements at
  specific locations.
- Multiple C-scan / A-scan / spectrum panels can be inserted into the same
  session (`Insert` menu) for side-by-side comparison.

## Getting Started

### Requirements
- MATLAB, R2018b or later (the GUI code uses the modern axes `Toolbar`
  property, introduced in R2018b).
- No additional MATLAB toolboxes beyond the base installation are required.

### Running
1. Clone or download this repository.
2. In MATLAB, `cd` into the repository root (or add it to your path).
3. Run:
   ```matlab
   MainFunction_V6
   ```
   This adds all the required subfolders (`AdditionalFcns`, `Alignment`,
   `ClassTypes`, `CrosshairFcns`, `DrawShapes`, `KeepArrayFcns`,
   `ObtainAndSave`, `Settings`, `PanelsAndGUI`, `VarianceLocationsFcns`,
   `VelocityAndThickness`, `Attenuation`) to the MATLAB path automatically and
   opens the main GUI window.
4. Use `File > Load Data` to load a C-scan file (`.csv` from a UTwin-style
   export, or a previously-saved `.mat` session).

### Data format
C-scan files are expected in the UTwin "UT C-Scan Data" CSV export format
(a text header block describing acquisition settings — gain, delay, sampling
rate, scan/index length and resolution — followed by one row per waveform:
`index number, scanning number, waveform samples...`). Reference and VMax
gain-calibration data follow related, but not identical, UTwin export formats;
see `Attenuation/VMax_Calculator.m` for the calibration-sweep file format
specifically.

## Project Structure
- `MainFunction_V6.m` — application entry point.
- `PanelsAndGUI/` — the GUI panel-building functions for each interface
  (C-scan, A-scan, wave speed, attenuation, gate settings, etc.).
- `Attenuation/` — the EDC attenuation calculator: calculation core, VMax
  gain-calibration, reference-data handling, and supporting GUI callbacks.
- `VelocityAndThickness/` — the wave speed calculator.
- `Alignment/` — cross-correlation-based waveform alignment.
- `VarianceLocationsFcns/` — region-of-interest selection/tracking tools.
- `CrosshairFcns/`, `DrawShapes/`, `KeepArrayFcns/`, `AdditionalFcns/` —
  shared UI interaction and drawing utilities.
- `ClassTypes/` — core data classes (`WaveMatrices`, `ScanParameters`, `Gate`,
  etc.).
- `ObtainAndSave/`, `Settings/` — file I/O and persistent settings.
- `CLAUDE.md` — detailed internal architecture notes, known gotchas, and
  design decisions for the Attenuation Calculator feature; useful reading
  before modifying that code.

## License
Distributed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.
