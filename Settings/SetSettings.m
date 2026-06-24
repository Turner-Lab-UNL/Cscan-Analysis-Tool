function SetSettings
global Group

settings_fig = figure('Visible','off','Position',[0 0 400 420]);
% f = figure;
settings_fig.Name='Settings';
settings_fig.NumberTitle='off';

% f.Position=[0 0 400 420];
tgroup = uitabgroup('Parent', settings_fig);
Tab1 = uitab('Parent', tgroup, 'Title', 'Save Parameters');
Tab2 = uitab('Parent', tgroup, 'Title', 'Color Choices');
Tab3 = uitab('Parent', tgroup, 'Title', 'Other Settings');

DownShift=.05;
ButtonWidth=.3;
RowTwo=.6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartGroup=[.1 0.9 ButtonWidth .05];
Change=[0 -DownShift 0 0];
BothWaves   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Waveforms','Units','normalized',...
    'Position',StartGroup+[-.07 0 0 0],'HitTest','off','Tag','GroupHead Waves');
OriginalWaveforms   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Original Waveforms','Units','normalized',...
    'Position',StartGroup+Change,'HitTest','off','Tag','waveform_matrix');
AlignedWaveforms   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Aligned Waveforms','Units','normalized',...
    'Position',StartGroup+Change*2,'HitTest','off','Tag','shifted_matrix');

BothWaves.Callback={@SelectSet_Callback,[OriginalWaveforms,AlignedWaveforms]};
OriginalWaveforms.Callback={@Selection_Callback,BothWaves};
AlignedWaveforms.Callback={@Selection_Callback,BothWaves};
Group.one=[OriginalWaveforms,AlignedWaveforms];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

StartGroup=[.1 0.7 ButtonWidth .05];
Change=[0 -DownShift 0 0];
ScanSettignsCheck   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Scan Settings','Units','normalized',...
    'Position',StartGroup+[-.07 0 0 0],'HitTest','off','Tag','GroupHead ScanSettings');
ScanLen  = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Scan Length','Units','normalized',...
    'Position',StartGroup+Change,'HitTest','off','Tag','scan_len');
ScanRes   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Scan Resolution','Units','normalized',...
    'Position',StartGroup+Change*2,'HitTest','off','Tag','scan_res');
IndexLen   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Index Length','Units','normalized',...
    'Position',StartGroup+Change*3,'HitTest','off','Tag','index_len');
IndexRes  = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Index Resolution','Units','normalized',...
    'Position',StartGroup+Change*4,'HitTest','off','Tag','index_res');
IndeciesPerRow   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Indecies Per Row','Units','normalized',...
    'Position',StartGroup+Change*5,'HitTest','off','Tag','IndexPerRow');
IndeciesPerColumn   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Indecies Per Column','Units','normalized',...
    'Position',StartGroup+Change*6,'HitTest','off','Tag','IndexPerColumn');
Time  = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Time','Units','normalized',...
    'Position',StartGroup+Change*7,'HitTest','off','Tag','t');
WindowStart   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Window Start','Units','normalized',...
    'Position',StartGroup+Change*8,'Tag','w_s');
WindowWidth   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Window Width','Units','normalized',...
    'Position',StartGroup+Change*9,'HitTest','off','Tag','w_w');
FrequencyRate = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Frequency Rate','Units','normalized',...
    'Position',StartGroup+Change*10,'HitTest','off','Tag','f_s');
WaveNums = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Number of Waveforms','Units','normalized',...
    'Position',StartGroup+Change*11,'HitTest','off','Tag','num_wfs');

ScanSettignsCheck.Callback={@SelectSet_Callback,[ScanLen,ScanRes,...
    IndexLen,IndexRes,IndeciesPerRow,IndeciesPerColumn,Time,WindowStart,...
    WindowWidth,FrequencyRate,WaveNums]};
ScanLen.Callback={@Selection_Callback,ScanSettignsCheck};
ScanRes.Callback={@Selection_Callback,ScanSettignsCheck};
IndexLen.Callback={@Selection_Callback,ScanSettignsCheck};
IndexRes.Callback={@Selection_Callback,ScanSettignsCheck};
IndeciesPerRow.Callback={@Selection_Callback,ScanSettignsCheck};
IndeciesPerColumn.Callback={@Selection_Callback,ScanSettignsCheck};
Time.Callback={@Selection_Callback,ScanSettignsCheck};
WindowStart.Callback={@Selection_Callback,ScanSettignsCheck};
WindowWidth.Callback={@Selection_Callback,ScanSettignsCheck};
FrequencyRate.Callback={@Selection_Callback,ScanSettignsCheck};
WaveNums.Callback={@Selection_Callback,ScanSettignsCheck};
Group.two=[ScanLen,ScanRes,IndexLen,IndexRes,IndeciesPerRow,IndeciesPerColumn...
    Time,WindowStart,WindowWidth,FrequencyRate,WaveNums];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartGroup=[RowTwo 0.9 ButtonWidth .05];
Change=[0 -DownShift 0 0];

GateInfo   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Gates','Units','normalized',...
    'Position',StartGroup+[ -.07 0 0 0],'HitTest','off','Tag','GroupHead Gates');
Gate1   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Gate #1','Units','normalized',...
    'Position',StartGroup+Change,'HitTest','off','Tag','g1');
Gate2   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Gate #2','Units','normalized',...
    'Position',StartGroup+Change*2,'HitTest','off','Tag','g2');
Gate3 = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Gate #3','Units','normalized',...
    'Position',StartGroup+Change*3,'HitTest','off','Tag','g3');
Gate4 = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Gate #4','Units','normalized',...
    'Position',StartGroup+Change*4,'HitTest','off','Tag','g4');

GateInfo.Callback={@SelectSet_Callback,[Gate1,Gate2,Gate3,Gate4]};
Gate1.Callback={@Selection_Callback,GateInfo};
Gate2.Callback={@Selection_Callback,GateInfo};
Gate3.Callback={@Selection_Callback,GateInfo};
Gate4.Callback={@Selection_Callback,GateInfo};
Group.three=[Gate1,Gate2,Gate3,Gate4];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartGroup=[RowTwo 0.6 ButtonWidth .05];
Change=[0 -DownShift 0 0];

AlignmentInfo   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Alignment (X-Correlation)','Units','normalized',...
    'Position',StartGroup+[ -.07 0 .1 0],'HitTest','off','Tag','GroupHead XCorr');

StartIndex   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Starting Index','Units','normalized',...
    'Position',StartGroup+Change,'HitTest','off','Tag','StartIndex');
EndIndex   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Ending Index','Units','normalized',...
    'Position',StartGroup+Change*2,'HitTest','off','Tag','EndIndex');
UsedWaveIndex = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Used Waform Index','Units','normalized',...
    'Position',StartGroup+Change*3,'HitTest','off','Tag','WaveformIndex');
ShiftedArray = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Shifted Array','Units','normalized',...
    'Position',StartGroup+Change*4,'HitTest','off','Tag','ShiftVector');

AlignmentInfo.Callback={@SelectSet_Callback,[StartIndex,EndIndex,...
    UsedWaveIndex,ShiftedArray]};
StartIndex.Callback={@Selection_Callback,AlignmentInfo};
EndIndex.Callback={@Selection_Callback,AlignmentInfo};
UsedWaveIndex.Callback={@Selection_Callback,AlignmentInfo};
ShiftedArray.Callback={@Selection_Callback,AlignmentInfo};
Group.four=[StartIndex,EndIndex,UsedWaveIndex,ShiftedArray];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartGroup=[RowTwo 0.3 ButtonWidth .05];
Change=[0 -DownShift 0 0];

SelectedParameters   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Selected Parameters','Units','normalized',...
    'Position',StartGroup+[ -.07 0 .1 0],'HitTest','off','Tag','GroupHead Draw');
SelectedIndecies   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Selected Indecies','Units','normalized',...
    'Position',StartGroup+Change,'HitTest','off','Tag','SelectedIndecies');
DrawnNames   = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Shape Names','Units','normalized',...
    'Position',StartGroup+Change*2,'HitTest','off','Tag','NameArray');
KeepArray = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Kept Regions','Units','normalized',...
    'Position',StartGroup+Change*3,'HitTest','off','Tag','KeepArray');
SubtractArray = uicontrol(Tab1,'Style','checkbox','Value',1,...
    'String','Subtract Regions','Units','normalized',...
    'Position',StartGroup+Change*4,'HitTest','off','Tag','SubtractArray');

SelectedParameters.Callback={@SelectSet_Callback,[SelectedIndecies,DrawnNames,...
    KeepArray,SubtractArray]};
SelectedIndecies.Callback={@Selection_Callback,SelectedParameters};
DrawnNames.Callback={@Selection_Callback,SelectedParameters};
KeepArray.Callback={@Selection_Callback,SelectedParameters};
SubtractArray.Callback={@Selection_Callback,SelectedParameters};


SaveButton = uicontrol(Tab1,'Style','togglebutton',...
    'String','Save','Units','normalized','Value',1,...
    'Position',[.005 .005 .25 .05],'HitTest','off');
SaveButton.Callback=@SelectSave_Callback;

Group.five=[SelectedIndecies,DrawnNames,KeepArray,SubtractArray];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Group.headings=[BothWaves,ScanSettignsCheck,GateInfo,AlignmentInfo,SelectedParameters];
Group.all=findobj(Tab1,'Style','checkbox');
SettingsCheckmarks(Group);

movegui(settings_fig,'center')
settings_fig.Visible='on';
settings_fig.CloseRequestFcn=@CloseSaveFig;
    function SelectSave_Callback(object,~)
        object.Value=1;
        SelectGlobalSaveStringArray(Group);
%         settings_fig.CloseRequestFcn={@CloseFig,'Save'};

    end

    function Selection_Callback(Object,~,Parent)
        
        Val=Object.Value;
        if Val==0
            Parent.Value=0;
        end
        SaveButton.Value=0;
    end


    function SelectSet_Callback(Object,~,ToSelect)
        
        Val=Object.Value;
        for i=1:length(ToSelect)
            ToSelect(i).Value=Val;
        end
        SaveButton.Value=0;
    end

    function CloseSaveFig(~,~)
        if SaveButton.Value~=1
            button = questdlg('Do you wish to save?',...
                'Save Settings','Save','Cancel','Close','Save');
            switch button
                case 'Save'
                    SelectSave_Callback(SaveButton, 0);
                    delete(settings_fig)
                case 'Close'
                    delete(settings_fig)
            end
        else
            delete(settings_fig)
        end
    end
end











