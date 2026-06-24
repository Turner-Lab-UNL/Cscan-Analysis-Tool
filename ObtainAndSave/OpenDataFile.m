function [FilterIndex,filename,filepath]=OpenDataFile(~,~,OldFolder,SoftwareType)
global GateInfo
global ScanSettings
global Waves
global Draw
global xCorrSettings
[filename,filepath,FilterIndex] = uigetfile(fullfile(OldFolder,'*.mat;*.csv;*.txt*'),'select file');
FileName=fullfile(filepath,filename);

if FilterIndex==0
    filepath=OldFolder;
    return  %User did not select anything
end

Waves.waveform_matrix=[];
Waves.shifted_matrix=[];


Period=strfind(FileName,'.');
FileType=FileName(Period(end)+1:end);


switch FileType
    
    case 'mat'
        Data=load(FileName);
        %% Load Waves
        IfExists=isfield(Data,'Waves');
        if IfExists==0
            Waves.waveform_matrix=Data.waveform_matrix;
            
            IfExists=isfield(Data,'shifted_matrix');
            if IfExists==0
                IfExists=isfield(Data,'wfm');
                if IfExists==0
                    Waves.shifted_matrix=zeros(size(Data.waveform_matrix));
                else
                    Waves.shifted_matrix=Data.wfm;
                end
                
            else
                Waves.shifted_matrix=Data.shifted_matrix;
            end
        else
            Waves=Data.Waves;
            
        end
        
        %% Load ScanSettings
        IfExists=isfield(Data,'ScanSettings');
        if IfExists==0
            
            ScanSettings.f_s=Data.f_s;
            ScanSettings.scan_len=Data.scan_len;
            ScanSettings.scan_res=Data.scan_res;
            ScanSettings.index_len=Data.index_len;
            
            ScanSettings.index_res=Data.index_res;
            ScanSettings.w_s=Data.w_s;
            ScanSettings.w_w=Data.w_w;
            IndexPer(ScanSettings);
            NumberOfWaveforms(ScanSettings)
            
            [~,DataLength]=size(Waves.waveform_matrix);
            time(ScanSettings,DataLength)
        else
            ScanSettings=Data.ScanSettings;
        end
        
        %% Load GateInfo
        IfExists=isfield(Data,'GateInfo');
        if IfExists==0
            StringName={'g1','g2','g3','g4'};
            
            for i=1:length(StringName)
                if isfield(Data,StringName{i})
                    eval(['GateInfo.',StringName{i},'=Data.',StringName{i},';'])
                eval(['GateInfo.CurrentGate=Data.',StringName{i},';'])
                end
            end
        else
            
            GateInfo=Data.GateInfo;
        end
        %% Load Drawing Data
        
        
        IfExists=isfield(Data,'Draw');
        if IfExists==0
            StringName={'NameArray','KeepArray','SubtractArray','SelectedIndecies'};
            for i=1:length(StringName)
                if isfield(Data,StringName{i})
                    eval(['Draw.',StringName{i},'=Data.',StringName{i},';'])
                else
                    eval(['Draw.',StringName{i},'=[];'])
                end
            end
            Draw.NumPlots=length(Draw.NameArray);
        else
            Draw=Data.Draw;
        end
        Draw.NumPlots=0;
        
        %% Load xCorrSettings
        IfExists=isfield(Data,'xCorrSettings');
        if IfExists==0
            StringName={'StartIndex','EndIndex','WaveformIndex','ShiftVector'};
            for i=1:length(StringName)
                if isfield(Data,StringName{i})
                    eval(['xCorrSettings.',StringName{i},'=Data.',StringName{i},';'])
                else
                    eval(['xCorrSettings.',StringName{i},'=[];'])
                end
            end
        else
            xCorrSettings=Data.xCorrSettings;
        end
        
    case 'csv'
        % SoftwareType 
        % 1 is default
        % 2 is use text file input
        % 3 is use manual entering via text file
        ExtractCSVData(FileName,ScanSettings,Waves,SoftwareType);
        Waves.shifted_matrix=zeros(size(Waves.waveform_matrix));
    case 'CSV'
        ExtractCSVData(FileName,ScanSettings,Waves,SoftwareType);
        Waves.shifted_matrix=zeros(size(Waves.waveform_matrix));   
        
    case 'txt'
        SoftwareType=3;
        ExtractCSVData(FileName,ScanSettings,Waves,SoftwareType);
        Waves.shifted_matrix=zeros(size(Waves.waveform_matrix));
        
    otherwise
        error('A .csv or .mat file has not been selected')
end
end