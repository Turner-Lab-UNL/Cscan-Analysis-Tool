function SettingsCheckmarks(Group)
global SaveString

if ~isempty(SaveString)
    if isempty(SaveString.Waves)
        Group.headings(1).Value=0;
        for i=1:length(Group.one)
            Tag=Group.one(i).Tag;
            if ~contains(SaveString.String,Tag)
                Group.one(i).Value=0;
            end
        end
    end
    if isempty(SaveString.ScanSettings)
        Group.headings(2).Value=0;
        for i=1:length(Group.two)
            Tag=Group.two(i).Tag;
            if ~contains(SaveString.String,Tag)
                Group.two(i).Value=0;
            end
        end
    end
    if isempty(SaveString.Gates)
        Group.headings(3).Value=0;
        for i=1:length(Group.three)
            Tag=Group.three(i).Tag;
            if ~contains(SaveString.String,Tag)
                Group.three(i).Value=0;
            end
        end        
    end
    if isempty(SaveString.XCorr)
        Group.headings(4).Value=0;
        for i=1:length(Group.four)
            Tag=Group.four(i).Tag;
            if ~contains(SaveString.String,Tag)
                Group.four(i).Value=0;
            end
        end        
    end
    
    if isempty(SaveString.Draw)
        Group.headings(5).Value=0;
        for i=1:length(Group.five)
            Tag=Group.five(i).Tag;
            if ~contains(SaveString.String,Tag)
                Group.five(i).Value=0;
            end
        end        
    end
    
end


end