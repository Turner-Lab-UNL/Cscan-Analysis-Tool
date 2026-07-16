function KeepLocations_Callback(f,Ax,TextBox,KeepYesNo,plot_number)

global Draw
global ScanSettings
global LastAdd

%% Get the Name to Store the Values As
Lines=findobj(Ax,'Type','Line');
LineType=Lines(1).Tag;

NumPreviousLineType=length(findobj(Lines,'Tag',LineType));
NewName=[LineType,' #',num2str(NumPreviousLineType)];

% Lists all the names for all the figures. These names will be used to
% manipulate all the plotting data. The values can be modified here. 

if plot_number==1
    if isempty(Draw.NameArray)
        Draw.NameArray{1}=NewName;
    else
        Draw.NameArray{end+1}=NewName;
    end



%% Store the Data for the plots
if ~LastAdd==4
    Add=2;
else
    Add=1;
end
for i=1:Add
    Draw.NumPlots=Draw.NumPlots+1;
end
end
%% Calculate and Find Locations of domains
DrawPanel=findobj(f,'Tag','DrawPanel');
DropDown=findobj(DrawPanel,'Style','popupmenu');
Val=DropDown.Value;
% Find the X, Y locations for the number of plots to Keep
IndexValues=PlotLocationsFunction(Val,ScanSettings);
%Obtain the X,Y positions for Plotting
[X,Y]=ind2sub([ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn],IndexValues);
X=X*ScanSettings.scan_res-ScanSettings.scan_res/2;
Y=Y*ScanSettings.index_res-ScanSettings.index_res/2;
hold(Ax,'on')
NewPlot=plot(Ax,X,Y,'*');
if ~isempty(NewPlot)
    NewPlot.Color = [1 1 1];
    NewPlot.Tag = 'AddedRegionPoints';
end
hold(Ax,'off')

if plot_number==1
OldText=TextBox.String;
if isempty(OldText)
    TextBox.String{1}=NewName;
else
    TextBox.String{end+1}=NewName;
end

if KeepYesNo==1
    if isempty(Draw.KeepArray)
        Draw.KeepArray{1}.Name=NewName;
        Draw.KeepArray{1}.Index=IndexValues;        
        Draw.KeepArray{1}.XData=Ax.Children(2).XData;
        Draw.KeepArray{1}.YData=Ax.Children(2).YData;
    else
        Draw.KeepArray{end+1}.Name=NewName;
        Draw.KeepArray{end}.Index=IndexValues;
        Draw.KeepArray{end}.XData=Ax.Children(2).XData;
        Draw.KeepArray{end}.YData=Ax.Children(2).YData;
    end
    
else
    if isempty(Draw.SubtractArray)
        Draw.SubtractArray{1}.Name=NewName;
        Draw.SubtractArray{1}.Index=IndexValues;
        Draw.SubtractArray{1}.XData=Ax.Children(2).XData;
        Draw.SubtractArray{1}.YData=Ax.Children(2).YData;    
    else
        Draw.SubtractArray{end+1}.Name=NewName;
        Draw.SubtractArray{end}.Index=IndexValues;
        Draw.SubtractArray{end}.XData=Ax.Children(2).XData;
        Draw.SubtractArray{end}.YData=Ax.Children(2).YData;
    end
end

TextBox.Value=1;
Draw.SelectedIndecies=CalculateAllPoints(Draw.KeepArray,Draw.SubtractArray);
end   
end
