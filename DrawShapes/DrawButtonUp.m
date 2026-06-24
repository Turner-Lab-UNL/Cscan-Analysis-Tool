function DrawButtonUp(f,~,NumFig)
global NumberOldLocations
global ax_C_Vector


for i=1:length(ax_C_Vector)
    Ax=ax_C_Vector{i};
NumberOldLocations=0;

% Ax=f.Children(end);
% Ax=gca;
LineArray=findobj(Ax,'Type','Line');

if ~isempty(LineArray)
    if length(LineArray)> NumFig
        for i=1:length(LineArray)-NumFig
           delete(LineArray(i)) 
        end        
    elseif length(LineArray) < NumFig
        error('Not enough lines were drawing. Incorrect number entered or something else... I guess')
    end
end
f.WindowButtonMotionFcn=[];
f.WindowButtonUpFcn=[];
end

end