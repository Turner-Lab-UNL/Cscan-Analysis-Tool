classdef WaveMatrices < handle
   properties
        waveform_matrix
        shifted_matrix
        shifted_vector
        StopAlignment
        Wavespeed
        TimeDiff
      
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