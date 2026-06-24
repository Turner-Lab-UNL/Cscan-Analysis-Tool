classdef ScanParameters < handle
   properties
      f_s
      scan_len
      scan_res
      index_len
      index_res
      w_s
      w_w
      
      t
      num_wfs
      IndexPerRow
      IndexPerColumn
   end
   events
      Event1
   end
   methods
      
        function time(object,DataLength)
            object.t = linspace(object.w_s,object.w_s+object.w_w,DataLength);  
        end
      
        function NumberOfWaveforms(object)
            object.num_wfs = round((object.scan_len/object.scan_res))*round((object.index_len/object.index_res));
        end
        
        function IndexPer(object)
            object.IndexPerRow=round(object.scan_len/object.scan_res);              
            object.IndexPerColumn=round(object.index_len/object.index_res); 
        end

      
   end
end