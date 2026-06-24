function CrossCorrelationClosestPeak(Waves,xCorrSettings,ScanSettings,PlotYesNo)

Panels=findobj('Tag','PlotPanel');
PlottingAxis=Panels.Children;


Domain=CrossLen(xCorrSettings);
[num_wfs,~]=size(Waves.waveform_matrix);
xc=zeros(num_wfs,length(Domain)*2-1);

wf_ref = Waves.waveform_matrix(xCorrSettings.WaveformIndex,Domain);


if isempty(Waves.shifted_vector)
    Waves.shifted_vector=zeros(num_wfs,1);
elseif max(abs(Waves.shifted_vector))==0
    Waves.shifted_vector=zeros(num_wfs,1);
end

% shft1=zeros(num_wfs,num_peaks);
% shft=zeros(num_wfs,1);
% wfm=zeros(num_wfs,q);
Thresh=.5; % Only look at peaks that have half the maximum amplitude

i=1;
while i<=num_wfs && Waves.StopAlignment==0
    xc(i,:) = xcorr(wf_ref,Waves.waveform_matrix(i,Domain)');
    
    [pks,locs]=findpeaks(xc(i,:),'sortstr','descend');
    pks=pks/max(pks); % Normalize the peak values
    [~,Keep]=find(pks>Thresh);
%     length(locs)
    locs=locs(Keep);
%     length(locs)
    num_peaks=length(locs);
    shft1 = (length(xc(i,:))+1)/2-locs(1:num_peaks);
    [~,n]=min(abs(shft1));
    Waves.shifted_vector(i)=shft1(n);
    %    wfm(i,:) = circshift(waveform_matrix(i,:),[1 -shft(i)]);
    
    %     [~,loc]=max(xc(i,:));
    %     Waves.shifted_vector(i) = (length(xc(i,:))+1)/2-loc;
    Waves.shifted_matrix(i,:) = circshift(Waves.waveform_matrix(i,:),[1 -Waves.shifted_vector(i)]);
    
    if PlotYesNo==1
        plot(PlottingAxis,ScanSettings.t,Waves.waveform_matrix(xCorrSettings.WaveformIndex,:),'r',ScanSettings.t,Waves.shifted_matrix(i,:),'b')
    end
    
    i=i+1;
    pause(.02)
end

end