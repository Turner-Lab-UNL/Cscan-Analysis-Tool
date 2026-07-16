function CalculateWaveSpeed_Callback(~,~,data_input_h)
global ScanSettings
global Waves
global GateInfo

f=gcf;
CPanels=findobj(f,'Tag','CPanel');


TimeCuts.t1f=str2double(data_input_h.Children(end-3).String);  % Start Time of first signal
TimeCuts.t2f=str2double(data_input_h.Children(end-5).String);  % End time of first signal

TimeCuts.t1s=str2double(data_input_h.Children(end-7).String);  % Start time of second signal
TimeCuts.t2s=str2double(data_input_h.Children(end-9).String);  % End time of second signal


if isnan(TimeCuts.t1f) || isnan(TimeCuts.t2f) || isnan(TimeCuts.t1s) || isnan(TimeCuts.t2s)
    errordlg('User did notselect region(s) for calculation.') ;   
    return
end

rect_button=findobj(data_input_h,'string', 'Rectification');
rect_signal=rect_button.Value;


constant=str2double(data_input_h.Children(end-1).String);
if isnan(constant)
   errordlg('User did not enter in a number for the height.') ;
   return
end

method_button=findobj(data_input_h,'Tag', 'Velocity');
method_type=method_button.Value;
if method_type==1
    method_string='Velocity';
elseif method_type==0
   method_string='Thickness'; 
else
    method_string=[];
end
% ChooseType=findobj(CPanels(1),'Tag','ChooseType');
% if length(ChooseType.String)~=5
    for i=1:length(CPanels)
        StringChange=findobj(CPanels(i),'Tag','ChooseType');
        StringChange.String={'Amp','TOF','Aligment',method_string,'TimeDiff'};
    end
% end




[timeDiff,velocity]=WaveSpeedCalculator(Waves,ScanSettings,constant,TimeCuts,rect_signal, method_type);
% 
Waves.Wavespeed=velocity;
Waves.TimeDiff=timeDiff;

% Reset the Velocity/Thickness pallet in every gate before updating so
% Update_CScan_Callback always auto-scales to the new data range.
% Without this, a previous bad calculation (e.g. all-Inf velocities) would
% leave Low(4)/High(4) = Inf; ~isnan(Inf) is true so the stale value is
% reused, the pallet never refreshes, and caxis([Inf Inf]) crashes.
for gk = {'g1','g2','g3','g4'}
    GateInfo.(gk{1}).Low(4)  = NaN;
    GateInfo.(gk{1}).High(4) = NaN;
end

choice=findobj(CPanels(1),'Tag','ChooseType');
choice.Value=4;
Update_CScan_Callback(1,1, f,0)
end