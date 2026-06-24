function [timeDiff,output]=WaveSpeedCalculator(Waves,ScanSettings,constant,TimeCuts,rect_signal,method_type)

t1f=TimeCuts.t1f;    % Start Time of first signal
t2f=TimeCuts.t2f;    % End time of first signal
t1s=TimeCuts.t1s;    % Start time of second signal
t2s=TimeCuts.t2s;    % End time of second signal

if t1f>t1s
   temp=t1f;
   t1f=t1s;
   t1s=temp;
   temp=t2f;
   t2f=t2s;
   t2s=temp;    
end


%%%%%%%%%%%%%%%%%
%% Find Index Values

t1f_index=find(t1f<=ScanSettings.t,1);       % Start Time of first signal
t2f_index=find(t2f<=ScanSettings.t,1);       % End time of first signal
t1s_index=find(t1s<=ScanSettings.t,1);      % End time of second signal
t2s_index=find(t2s<=ScanSettings.t,1);       % End time of second signal

tcf=round((t1f_index+t2f_index)/2);
tcs=round((t1s_index+t2s_index)/2);


%% Cut Regions
timeDiff=zeros(1,ScanSettings.num_wfs);
% output=zeros(1,ScanSettings.num_wfs);
if sum(sum(Waves.shifted_matrix)) ~=0
    wf1_array=Waves.shifted_matrix(:,t1f_index:t2f_index);
    wf2_array=Waves.shifted_matrix(:,t1s_index:t2s_index);
else
    wf1_array=Waves.waveform_matrix(:,t1f_index:t2f_index);
    wf2_array=Waves.waveform_matrix(:,t1s_index:t2s_index);
end

for i=1:ScanSettings.num_wfs
    
    %% Calculate the Cross Correlation
    if rect_signal==1
        [acor,lag] = xcorr(abs(wf1_array(i,:)),abs(wf2_array(i,:)));
    else
        [acor,lag] = xcorr(wf1_array(i,:),wf2_array(i,:));
    end
    %% Calculate the time lag and Velocity
    [~,index2] = max(acor);                                                % find index of difference for better correlation
    lagDiff = lag(index2);
    lagIndex=tcs-tcf-lagDiff;

    timeDiff(i)= (ScanSettings.t(lagIndex)-ScanSettings.t(1));
end

if method_type==1
    output=2*constant./timeDiff;
else
    output=constant.*timeDiff/2;
end