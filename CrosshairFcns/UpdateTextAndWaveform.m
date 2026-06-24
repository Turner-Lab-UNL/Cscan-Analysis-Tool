function UpdateTextAndWaveform(Current_Panel,Lines,TextHandles)
global ScanSettings
global Waves
global CurrentIndex
global GateInfo

FigHandle=Current_Panel.Parent;
VertLine1=Lines(end);
HorzLine1=Lines(end-1);

if length(Lines)==4
    %Find Second lines if double cross hairs are used
    VertLine2=Lines(end-2);
    HorzLine2=Lines(end-3);
    
    %Find relative positions
    DeltaX=VertLine2.XData(1)-VertLine1.XData(1);
    DeltaY=HorzLine2.YData(1)-HorzLine1.YData(1);
    %Convert to strings
    DeltaXString=num2str(DeltaX);
    DeltaYString=num2str(DeltaY);
    %UpdateText
    TextHandles(1).String = ['Scan =',DeltaXString];
    TextHandles(2).String = ['Index =',DeltaYString];
else
    %Update Text
    TextHandles(1).String = ['Scan =',num2str(VertLine1.XData(1))];
    TextHandles(2).String = ['Index =',num2str(HorzLine1.YData(1))];
    % Update the Location in the A Scan
    
end



x=floor(VertLine1.XData(1)/ScanSettings.scan_res)+1;
y=floor(HorzLine1.YData(1)/ScanSettings.index_res)+1;

if x>ScanSettings.IndexPerRow
    xnew=ScanSettings.IndexPerRow;
else
    xnew=x;
end

if y>ScanSettings. IndexPerColumn
    ynew=ScanSettings. IndexPerColumn;
else
    ynew=y;
end

CurrentIndex=sub2ind([ScanSettings.IndexPerRow ...
    ScanSettings.IndexPerColumn],xnew,ynew);

Panels=findobj(FigHandle.Children,'Tag','APanel');
NumAPanels=length(Panels);
for i=1:NumAPanels
    UpdatePanel=Panels(i);
    AScanAxes=UpdatePanel.Children(end);
    AxisInfo.Name=AScanAxes;
    AxisInfo.Number=FigHandle.Number;
    AScanAxes.NextPlot='replacechildren';
    waveform_source=findobj(UpdatePanel,'Tag','Waveform_Source');
    Val=waveform_source.Value;

    switch Val
        case 1 % Amp
            A_Scan_Plot_GUI(AxisInfo,Waves.waveform_matrix(CurrentIndex,:),CurrentIndex)
        case 2 %'X-Corr Waveform'
            A_Scan_Plot_GUI(AxisInfo,Waves.shifted_matrix(CurrentIndex,:),CurrentIndex)
        otherwise
            A_Scan_Plot_GUI(AxisInfo,Waves.waveform_matrix(CurrentIndex,:),CurrentIndex)
    end
end

Panels=findobj(FigHandle.Children,'Tag','FreqPanel');
NumFreqPanels=length(Panels);
for i=1:NumFreqPanels

    %% THIS SECTION MUST BE UPDATED FOR SPECTROGRAM PLOTTING
    
    UpdatePanel=Panels(i);
    gate_option=findobj(UpdatePanel,'Tag','GateSource');
    gate_num=gate_option.Value;
    if isempty(gate_num)
        gate_option.Value=1;
        gate_num=gate_option.Value;
    end
    FreqScanAxes=UpdatePanel.Children(end);
    AxisInfo.Name=FreqScanAxes;
    AxisInfo.Number=FigHandle.Number;
    FreqScanAxes.NextPlot='replacechildren';
    gate=eval(['GateInfo.g',num2str(gate_num)]);
    
    if ~isempty(gate.fft_data)
        Freq_Scan_Plot_GUI(AxisInfo,gate.fft_data(CurrentIndex,:),gate.fft_freq)
    else
        Freq_Scan_Plot_GUI(AxisInfo,zeros(50,1),1:50)
    end
end


end