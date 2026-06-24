function SelectGlobalSaveStringArray(Group)
global SaveString

CheckBoxHandles=Group.all;
SaveString=[];
SaveString.String=[];
SaveString.ScanSettings=[];
SaveString.XCorr=[];
SaveString.Waves=[];
SaveString.Gates=[];
SaveString.Draw=[];

% Check The correct headboxes

if length(findobj(Group.one,'Value',1))==2
    Group.headings(1).Value=1;
end
if length(findobj(Group.two,'Value',1))==11
    Group.headings(2).Value=1;
end
if length(findobj(Group.three,'Value',1))==4
    Group.headings(3).Value=1;
end
if length(findobj(Group.four,'Value',1))==4
    Group.headings(4).Value=1;
end
if length(findobj(Group.five,'Value',1))==4
    Group.headings(5).Value=1;
end

for i=1:length(CheckBoxHandles)
    
    if CheckBoxHandles(i).Value==1
        if ~contains(CheckBoxHandles(i).Tag,'GroupHead')
            String=CheckBoxHandles(i).Tag;

            if isempty(SaveString.String)
                SaveString.String=[', ''',String,''''];
            else
                SaveString.String=[SaveString.String,', ''',String,''''];
            end
        end        
    end    
    
    if contains(CheckBoxHandles(i).Tag,'Waves') && CheckBoxHandles(i).Value==1
        SaveString.Waves=1;
        ReplaceString=', ''shifted_matrix'', ''waveform_matrix''';
        SaveString.String=DeleteString(SaveString,ReplaceString,', ''Waves''');
        
    elseif contains(CheckBoxHandles(i).Tag,'ScanSettings') && CheckBoxHandles(i).Value==1
        SaveString.ScanSettings=1;
        ReplaceString=[', ''num_wfs'', ''f_s'', ''w_w'', ''w_s'', ''t'',',...
            ' ''IndexPerColumn'', ''IndexPerRow'', ''index_res'',',...
            ' ''index_len'', ''scan_res'', ''scan_len'''];

        SaveString.String=DeleteString(SaveString,ReplaceString,', ''ScanSettings''');
        
    elseif contains(CheckBoxHandles(i).Tag,'XCorr') && CheckBoxHandles(i).Value==1
        SaveString.XCorr=1;
        ReplaceString=', ''ShiftVector'', ''WaveformIndex'', ''EndIndex'', ''StartIndex''';
        SaveString.String=DeleteString(SaveString,ReplaceString,', ''xCorrSettings''');
    elseif contains(CheckBoxHandles(i).Tag,'Gates') && CheckBoxHandles(i).Value==1
        
        SaveString.Gates=1;
        ReplaceString=', ''g4'', ''g3'', ''g2'', ''g1''';
        SaveString.String=DeleteString(SaveString,ReplaceString,', ''GateInfo''');
    elseif contains(CheckBoxHandles(i).Tag,'Draw') && CheckBoxHandles(i).Value==1
        SaveString.Draw=1;
        ReplaceString=', ''SubtractArray'', ''KeepArray'', ''NameArray'', ''SelectedIndecies''';
        SaveString.String=DeleteString(SaveString,ReplaceString,', ''Draw''');
    end
    
end

if ~isempty(SaveString.String)
    SaveString.String=SaveString.String(2:end);
   
end
end