classdef Gate < handle
    properties
        % Gate Settings
        Start
        Width
        Type
        Threshold
        
        % Gate Properties
        Color
        Thickness
        Visibility
        
        %DataToPlotGate
        AScanNumStr
        CScanNumStr
        High
        Low
        MouseClick
        CurrentData
        % These parameters are attached to the gate only to be updated when
        % the gate settings change.
        Amp
        TOF
        ThreshShift
        Wavespeed
        TimeDifference
        fft_data
        fft_freq
    
        
    end
    events
        Event1
    end
    
    methods
        %% Compare Two Different Gate Settings
        % Function checks the Gate Settings between two objects of this
        % class. This is used to see if Amp and TOF need to be updated.
        
        function output = CheckDiff(Obj1,Obj2)
            if Obj1.Start==Obj2.Start && Obj1.Width==Obj2.Width && ...
                    Obj1.Type==Obj2.Type && Obj1.Threshold==Obj2.Threshold ...
                    && Obj1.Visibility==Obj2.Visibility
                output=1;
            else
                output=0;
            end
        end
        
        %% Apply Gate Settings to get Amp and TOF
        % Function updates the values of Amp and TOF given a matrix of
        % waveforms, the object, and the scan settings.
        function  ApplyGate(WaveMatrix, Obj, ScanSettings)
            
            if Obj.Type==1 %Fixed Gate
                GateEnd=Obj.Start+Obj.Width;
                GEndIndex=find(ScanSettings.t>=GateEnd,1,'first');
                if isempty(GEndIndex)==1
                    GEndIndex=length(ScanSettings.t);
                end
                GStartIndex=find(ScanSettings.t>=Obj.Start,1,'first');
                if isempty(GStartIndex)==1         % Whole Gate to Right of time domain
                    [aa,~]=size(WaveMatrix);
                    Obj.Amp=zeros(aa,1);           % Set amplitudes to zero
                    Obj.CurrentData=Obj.Amp;
                    Obj.TOF=zeros(aa,1);           % Set time of flight to zero
                    Obj.fft_data=[];               % Set fft_data to null
                    Obj.fft_freq=[];
                    msgbox('Gate is not within time window!!','Warning');
                elseif GEndIndex==1                % Whole Gate is Left of time domain
                    [aa,~]=size(WaveMatrix);
                    Obj.Amp=zeros(aa,1);           % Set amplitudes to zero
                    Obj.CurrentData=Obj.Amp;
                    Obj.TOF=zeros(aa,1);           % Set time of flight to zero
                    Obj.fft_data=[];               % Set fft_data to null
                    Obj.fft_freq=[];
                    msgbox('Gate is not within time window!!','Warning');
                else
                    [Obj.Amp,TOF_Index]=max(WaveMatrix(:,GStartIndex:GEndIndex),[],2);
                    Obj.CurrentData=Obj.Amp;
                    Obj.TOF=ScanSettings.t(TOF_Index+GStartIndex-1);
                    
                    L=length(GStartIndex:GEndIndex);
                    fft_array=fft(WaveMatrix(:,GStartIndex:GEndIndex),[],2);
                    P2=abs(fft_array/(L));
                    Obj.fft_data=P2(:,1:round(L/2+1));
                    Obj.fft_data(:,2:end-1)=2*Obj.fft_data(:,2:end-1);
                    Obj.fft_freq=ScanSettings.f_s*(0:round((L/2)))/L;
                end

            else % Moving Gate
                Obj.Width
                ScanSettings.f_s
                GWidthIndex = Obj.Width*ScanSettings.f_s;
                GOffSetIndex=Obj.Start*ScanSettings.f_s;
                [aa,~]=size(WaveMatrix);
                GStartIndex=zeros(1,aa);
                NoData=zeros(1,aa);
                StartOffsett=zeros(1,aa);
                tof_times=zeros(1,aa);
                for i=1:aa
                    [~,temp2]=find(WaveMatrix(i,:)>=Obj.Threshold,1,'first');
                    
                    if isempty(temp2)==1
                        GStartIndex(i)=0;
                        NoData(i)=i;
                        StartOffsett(i)=0;
                    else
                        GStartIndex(i)=temp2+GOffSetIndex;
                        StartOffsett(i)=temp2;
                    end
                end

                for i=1:aa
                    if GStartIndex(i)==0
                        Obj.Amp(i)=0;
                        Obj.TOF(i)=ScanSettings.t(1);  
                    elseif GStartIndex(i)>length(ScanSettings.t)
                        Obj.Amp(i)=0;
                        Obj.TOF(i)=ScanSettings.t(1);
                    elseif GStartIndex(i)+GWidthIndex<=1
                        Obj.Amp(i)=0;
                        Obj.TOF(i)=ScanSettings.t(1);     
                    else
                        if GStartIndex(i)+GWidthIndex>length(ScanSettings.t)
                            [Obj.Amp(i),Obj.TOF(i)]=max(WaveMatrix(i,GStartIndex(i):end),[],2);
                        elseif GStartIndex(i)<0
                            [Obj.Amp(i),Obj.TOF(i)]=max(WaveMatrix(i,1:GWidthIndex+GStartIndex(i)),[],2);
                            tof_times(i)=ScanSettings.t(Obj.TOF(i));                             
                        else
                            [Obj.Amp(i),Obj.TOF(i)]=max(WaveMatrix(i,GStartIndex(i)+(1:GWidthIndex)),[],2);
                            tof_times(i)=ScanSettings.t(Obj.TOF(i)+GStartIndex(i));
                        end
                    end
                end
                
                
                Obj.TOF=tof_times;
                NoData=nonzeros(unique(NoData));
                
                Obj.Amp(NoData)=0;
                Obj.ThreshShift=StartOffsett;
            end

            
        end
        
        %% Calculate old Gate Settings
        function GateOld=OldGate(GateNew,GateOld)
            GateOld.Start=GateNew.Start;
            GateOld.Width=GateNew.Width;
            GateOld.Threshold=GateNew.Threshold;
            GateOld.Type=GateNew.Type;
            GateOld.Visibility=GateNew.Visibility;
        end
        
        %% Generate Gate Settings with general, yet unrealistic, parameters
        function GeneralGateFill(Obj)
            Obj.Start=eps; % Small Number unable to match user settings
            Obj.Width=1;
            Obj.Threshold=0;
            Obj.Type=1;
        end
        
        
    end
end