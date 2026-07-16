classdef WaveMatrices < handle
   properties
        waveform_matrix
        shifted_matrix
        shifted_vector
        StopAlignment
        Wavespeed
        TimeDiff

        Attenuation         % 1 x num_wfs, Np/mm, averaged over the auto-detected 50%-of-peak
                             % band (see AttenuationCalculator.m) -> feeds the C-scan image
        AttenuationSpectrum % num_wfs x Nf, Np/mm, full frequency-dependent attenuation
        AttenuationFreq     % 1 x Nf, MHz, frequency vector for AttenuationSpectrum
        AttenuationBandLow  % MHz, auto-detected 50%-of-peak lower edge (see AttenuationCalculator.m)
        AttenuationBandHigh % MHz, auto-detected 50%-of-peak upper edge
        Bs_amp              % num_wfs x Nf, sample backwall amplitude spectrum (QC/plotting)
        Br_amp              % 1 x Nf, reference backwall amplitude spectrum (QC/plotting)

        VMaxCal             % struct .gain .amplitude .saturated .coeffs .threshold .folder
                             % .files .skipped -- gain-sweep calibration fit used to normalize
                             % this waveform set's amplitude before the EDC ratio. Empty until
                             % calibrated via LoadVMaxScan_Callback/VMax_Calculator. Used for
                             % both the sample (Waves.VMaxCal) and reference (RefWaves.VMaxCal).
   end
   events
      Event1
   end
   methods
      function obj = MyClass(arg)
         if nargin > 0
            obj.Prop1 = arg;
         end
      end
      
      
   end
end