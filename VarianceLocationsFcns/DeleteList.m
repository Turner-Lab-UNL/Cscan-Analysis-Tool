function DeleteList(ListHandle,event)

global Draw

f=figure(1);
MessageBox=findobj(f,'Tag','MessageBox');
CPanels=findobj(f,'Tag','CPanel');
CAxes=CPanels.Children(end);
% VPanel=findobj(f,'Tag','VariancePanel');

switch event.Key
    case 'delete'
        Val=ListHandle.Value;
        if isempty(Val) % Return when there is no data in the field
            return
        elseif isempty(ListHandle.String)
            return
        end
        
        OldString=ListHandle.String(Val);
        StringArray=ListHandle.String;
        ListHandle.Value=1;
        
        switch ListHandle.Tag
            case 'AddBox'
                for i=1:length(Draw.KeepArray)
                    if contains(Draw.KeepArray{i}.Name,OldString{1})
                        Draw.KeepArray{i}.Index=[];
                        Draw.KeepArray{i}.XData=-1;
                        Draw.KeepArray{i}.YData=-1;
                    end
                end
                
            case 'SubtractBox'
                for i=1:length(Draw.SubtractArray)
                    if contains(Draw.SubtractArray{i}.Name,OldString{1})
                        Draw.SubtractArray{i}.Index=[];
                        Draw.SubtractArray{i}.XData=-1;
                        Draw.SubtractArray{i}.YData=-1;
                    end
                end                
            otherwise
        end
        
        Draw.SelectedIndecies=CalculateAllPoints(Draw.KeepArray,Draw.SubtractArray);
        
        ReplotLineData(f,CAxes)
        
        if Val==1
            ListHandle.String=StringArray(Val+1:end);
        elseif Val==length(StringArray)
            ListHandle.String=StringArray(1:end-1);
        else
            ListHandle.String=[StringArray(1:Val-1)' ,StringArray(Val+1:end)']';
        end
        
        MessageBox.String=['Data for ',OldString,' has been deleated.'];
end
end
