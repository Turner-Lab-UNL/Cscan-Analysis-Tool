function Update_CScan_Callback(ObjectHandle ,~,FigHandle,reset)
global GateInfo
global ScanSettings
global Waves

f=gcf;
if isa(ObjectHandle,'double')
    % This indicates that the GateSettings have been updated, hence updata
    % all cplots in figures;
    CPanelArray=findobj(f,'Tag','CPanel');
    for i=1:length(CPanelArray)
        CPanel=CPanelArray(i);
        %         reset=0;
        MainUpdate(CPanel,reset)
    end
else
    % Only update current figure
    CPanel=ObjectHandle.Parent;
    %     reset=0;
    MainUpdate(CPanel,reset)
end

figure(f)
    function MainUpdate(CPanel,reset)
        GateHandel=findobj(CPanel,'Tag','GateNumber');
        ChooseTypeVal=GateHandel.Value;
        switch ChooseTypeVal
            case 1 %'Gate 1'
                GateInfo.CurrentGate=GateInfo.g1;
            case 2 %'Gate 2'
                GateInfo.CurrentGate=GateInfo.g2;
            case 3 % 'Gate 3'
                GateInfo.CurrentGate=GateInfo.g3;
            case 4 %'Gate 4'
                GateInfo.CurrentGate=GateInfo.g4;
            otherwise
        end
        
        % Establish type of Gate to be plotted
        WaveTypeHandel=findobj(CPanel,'Tag','ChooseType');
        ChooseTypeVal=WaveTypeHandel.Value;
        switch ChooseTypeVal
            case 1 %'Amp'
                GateInfo.CurrentGate.CurrentData=GateInfo.CurrentGate.Amp;
            case 2 %'TOF'
                GateInfo.CurrentGate.CurrentData=GateInfo.CurrentGate.TOF;
            case 3 %'x corr'
                GateInfo.CurrentGate.CurrentData=Waves.shifted_vector;
            case 4 %'Wavespeed' (Wave Speed interface) or 'Attenuation' (Attenuation interface)
                if strcmpi(WaveTypeHandel.String{4},'Attenuation')
                    GateInfo.CurrentGate.CurrentData=Waves.Attenuation;
                else
                    GateInfo.CurrentGate.CurrentData=Waves.Wavespeed;
                end
            case 5 %'Time Difference'
                GateInfo.CurrentGate.CurrentData=Waves.TimeDiff;
            otherwise
        end
        
        % Load Pallet scales as long as user is not updating them
        LowPalletValue=findobj(CPanel,'Tag','LowPalletValue');
        HighPalletValue=findobj(CPanel,'Tag','HighPalletValue');
        
        %% Updates the fields — auto-scale when stored limits are absent or invalid
        % isnan catches uninitialised slots; ~isfinite also catches Inf/-Inf
        % that can arise from division-by-zero in WaveSpeedCalculator (zero
        % timeDiff → Inf velocity).  Once Inf is stored, isnan(Inf)=false so
        % the old code would never re-trigger auto-scale on subsequent calls,
        % leaving the pallet frozen at 'Inf' and crashing caxis downstream.
        if gco==LowPalletValue
            HighPalletValue.String=num2str(GateInfo.CurrentGate.High(ChooseTypeVal));

        elseif gco==HighPalletValue
            LowPalletValue.String=num2str(GateInfo.CurrentGate.Low(ChooseTypeVal));
        else

            if ~isfinite(GateInfo.CurrentGate.Low(ChooseTypeVal))
                LowPalletValue.String=num2str(min(min(GateInfo.CurrentGate.CurrentData)));
            else
                LowPalletValue.String=num2str(GateInfo.CurrentGate.Low(ChooseTypeVal));
            end

            if ~isfinite(GateInfo.CurrentGate.High(ChooseTypeVal))
                HighPalletValue.String=num2str(max(max(GateInfo.CurrentGate.CurrentData)));
            else
                HighPalletValue.String=num2str(GateInfo.CurrentGate.High(ChooseTypeVal));
            end
        end


        GateInfo.CurrentGate.High(ChooseTypeVal)=str2double(HighPalletValue.String);
        GateInfo.CurrentGate.Low(ChooseTypeVal)=str2double(LowPalletValue.String);
 %% Checks if user entered a non-finite value (NaN, Inf)
        if ~isfinite(GateInfo.CurrentGate.Low(ChooseTypeVal))
            LowPalletValue.String=num2str(min(min(GateInfo.CurrentGate.CurrentData)));
        else
            LowPalletValue.String=num2str(GateInfo.CurrentGate.Low(ChooseTypeVal));
        end

        if ~isfinite(GateInfo.CurrentGate.High(ChooseTypeVal))
            HighPalletValue.String=num2str(max(max(GateInfo.CurrentGate.CurrentData)));
        else
            HighPalletValue.String=num2str(GateInfo.CurrentGate.High(ChooseTypeVal));
        end
  %% Assigns Gate Pallet Scale      
        GateInfo.CurrentGate.High(ChooseTypeVal)=str2double(HighPalletValue.String);
        GateInfo.CurrentGate.Low(ChooseTypeVal)=str2double(LowPalletValue.String);
        HiLow=[GateInfo.CurrentGate.High(ChooseTypeVal),GateInfo.CurrentGate.Low(ChooseTypeVal)];
        
        
        
     %% Updates C-Scan Plot 
        if ~isnan(HiLow(1)) && ~isnan(HiLow(2))
            limits=flip(HiLow);
        else
            limits=[-1,1];
        end

        AxisInfo.Number=FigHandle.Number;
        AxisInfo.Name=findobj(CPanel,'Type','Axes');
        
        if ~isempty(GateInfo.CurrentGate.CurrentData) && GateInfo.CurrentGate.Visibility==1
            CurrentData=GateInfo.CurrentGate.CurrentData;
            C_Scan_Plot_GUI( AxisInfo,ScanSettings,CurrentData,limits,reset);
        else
            zeroField=zeros(1,ScanSettings.IndexPerRow*ScanSettings.IndexPerColumn);
            C_Scan_Plot_GUI( AxisInfo,ScanSettings,zeroField,limits, reset);
        end
        
    end
end
