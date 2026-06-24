function CloseFig(f,~,Name,filepath)

global SelectRegionCount
global NumPlots

global Waves
global Draw
global ScanSettings
global NumberOldLocations
global xCorrSettings

global CurrentFolder
global GateInfo
global GateOld

global SaveString

button = questdlg(['Do you want to exit the program ',Name,'?'],'Quit Program?','Yes','No','Yes');
switch button
    case 'Yes'
        delete(f)
        SelectRegionCount=[];
        NumPlots=[];
        Waves=[];
        Draw=[];
        ScanSettings=[];
        NumberOldLocations=[];
        xCorrSettings=[];
        CurrentFolder=[];
        GateInfo=[];
        GateOld=[];
        SaveString=[];

        rmpath(fullfile(filepath,'AdditionalFcns'));
        rmpath(fullfile(filepath,'Alignment'));
        rmpath(fullfile(filepath,'ClassTypes'));
        rmpath(fullfile(filepath,'CrosshairFcns'));
        rmpath(fullfile(filepath,'DrawShapes'));
        rmpath(fullfile(filepath,'KeepArrayFcns'));
        rmpath(fullfile(filepath,'ObtainAndSave'));
        rmpath(fullfile(filepath,'Settings'));
        rmpath(fullfile(filepath,'PanelsAndGUI'));
        rmpath(fullfile(filepath,'VarianceLocationsFcns'));
        
        fig_close=findobj('NumberTitle','off');
        
        for i=1:length(fig_close)
            delete(fig_close(i))
        end
        
        
        
        
        
    case 'No'
        fprintf('Program was not closed\n')
        return
        
end

end
