function SelectData_Callback(~,~,FileNameBox,MessageBox,~,~)
global CurrentFolder
global ScanSettings
global Waves
global current_index
global ax_C_Vector
global ax_A_Vector

current_index=1;
MessageBox.String='Load in Process';
MessageBox.BackgroundColor=[1 1 0];
SoftwareType=1;
[FilterIndex,filename,CurrentFolder]=OpenDataFile(ScanSettings,Waves,CurrentFolder,SoftwareType);
if FilterIndex==0
    MessageBox.BackgroundColor=[1 1 0];
    MessageBox.String='User Terminated Load';
    return    % The user exited out
end

MessageBox.String='Data Aquired';
MessageBox.BackgroundColor=[0 1 0];
FileNameBox.String=filename;
for i=1:length(ax_C_Vector)
    if isvalid(ax_C_Vector{i})
        ax_C_Vector{i}.YLim=[0,ScanSettings.index_len];
        ax_C_Vector{i}.XLim=[0,ScanSettings.scan_len];
    end
end

for i=1:length(ax_A_Vector)
    if isvalid(ax_A_Vector{i})
        ax_A_Vector{i}.YLim=[-1,1];
        ax_A_Vector{i}.XLim=[ScanSettings.w_s,ScanSettings.w_w+ScanSettings.w_s];
    end
end
end