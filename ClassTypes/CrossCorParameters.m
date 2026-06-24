classdef CrossCorParameters < handle
   properties
        StartIndex
        EndIndex
        WaveformIndex
        ShiftVector
      
   end
   events
      Event1
   end
   
   methods
      function output = CrossLen(object)        
            output = object.StartIndex:object.EndIndex;
      end
      
      
   end
end