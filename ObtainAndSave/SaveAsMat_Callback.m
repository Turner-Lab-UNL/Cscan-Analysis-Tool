    function SaveAsMat_Callback(~,~,FileNameBox,MessageBox)
%     global CurrentFolder
        % this gives the user the ability to save the cross correlated data
        % as a .mat file. This might be very usefull for later use.
global CurrentFolder
global SaveString
global ScanSettings
global Waves
global Draw
global xCorrSettings
global GateInfo

        Index = strfind(FileNameBox.String, '.');
        filename=[FileNameBox.String(1:Index-1),'.mat'];
        
        
        [filename,filepath,FilterIndex] = uiputfile({fullfile(CurrentFolder,'*.mat')},'Save .mat file',fullfile(CurrentFolder,filename));
        if FilterIndex==0
            MessageBox.BackgroundColor=[1 1 0];
            MessageBox.String='User Terminated Save';
            return    % The user exited out
        else
            MessageBox.BackgroundColor=[1 1 0];
            MessageBox.String='Save In Progress';
        end

        FileName=fullfile(filepath,filename);
        MessageBox.String=['Data is in the process of being saved as ' filename];
        MessageBox.BackgroundColor=[1 1 0];
        pause(.1)
        
        if isempty(SaveString.Waves)
            
        end
        if isempty(SaveString.ScanSettings)

        end 
        if isempty(SaveString.Gates)
            g1=GateInfo.g1;
            g2=GateInfo.g2;
            g3=GateInfo.g3;
            g4=GateInfo.g4;            
        end

        if isempty(SaveString.ScanSettings)
            scan_len=ScanSettings.scan_len;
            scan_res=ScanSettings.scan_res;
            index_len=ScanSettings.index_len;
            index_res=ScanSettings.index_res;
            IndexPerRow=ScanSettings.IndexPerRow;
            IndexPerColumn=ScanSettings.IndexPerColumn;
            t=ScanSettings.t;
            w_s=ScanSettings.w_s;
            w_w=ScanSettings.w_w;
            f_s=ScanSettings.f_s;
            num_wfs=ScanSettings.num_wfs;            
        end 
        if isempty(SaveString.XCorr)
            StartIndex=xCorrSettings.StartIndex;
            EndIndex=xCorrSettings.EndIndex;
            WaveformIndex=xCorrSettings.WaveformIndex;
            ShiftVector=xCorrSettings.ShiftVector;
        end
        if isempty(SaveString.Waves)
            waveform_matrix=Waves.waveform_matrix;
            shifted_matrix=Waves.shifted_matrix;
        end
        if isempty(SaveString.Draw)
            SelectedIndecies=Draw.SelectedIndecies;
            NameArray=Draw.NameArray;
            KeepArray=Draw.KeepArray;
            SubtractArray=Draw.SubtractArray;
        end
        
%         save(FileName,'ScanSettings','Waves','GateInfo','xCorrSettings','-v7.3')
       mainString=['save(FileName,',SaveString.String,',''-v7.3'');'];
        eval(mainString)
   
        MessageBox.String=['Data has been saved as ' filename];
        MessageBox.BackgroundColor=[0 1 0];
    end