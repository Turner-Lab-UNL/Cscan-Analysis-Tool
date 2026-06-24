function SelectedIndecies=CalculateAllPoints(KeepArray,SubtractArray)

KL=length(KeepArray);
SL=length(SubtractArray);
TotalKeep=[];
for i=1:KL    
    Temp=[TotalKeep,KeepArray{i}.Index'];
    TotalKeep=Temp;
end
TotalKeep=unique(TotalKeep);


TotalSubtract=[];
for i=1:SL
   Temp=[TotalSubtract,SubtractArray{i}.Index'];
   TotalSubtract=Temp;
end

TotalSubtract=unique(TotalSubtract);

SelectedIndecies=TotalKeep.*(1-ismember(TotalKeep,TotalSubtract));

end