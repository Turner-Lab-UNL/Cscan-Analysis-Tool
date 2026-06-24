function TotalString=DeleteString(FullStructure,Search,Replace)

                CurrentString=FullStructure.String;
                TotalLength=length(CurrentString);
                Start=strfind(CurrentString,Search);
                End=Start+TotalLength;

                if Start~=1 && End~=TotalLength
                TotalString=[CurrentString(1:Start-1),Replace,CurrentString(End+1:end)];
                elseif Start~=1 && End==TotalLength
                    TotalString=[CurrentString(1:Start-1),Replace];
                elseif Start==1 && End~=TotalLength
                    TotalString=[Replace,CurrentString(End+1:end)];
                end
end