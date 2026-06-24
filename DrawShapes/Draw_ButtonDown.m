function Draw_ButtonDown(~,~,f,~)
global Draw
global OldPosition
global ax_C_Vector


 for i=1:length(ax_C_Vector)
     trial(i)=gca~=ax_C_Vector{i};
 end

if min(trial)~=0
    return
end

if isempty(Draw)
    Draw.NumPlots=0;
    Draw.NameArray=[];
    Draw.PlotData=[];
    Draw.KeepArray=[];
    Draw.SubtractArray=[];
    Draw.SelectedIndecies=[];
end


C = get (gca, 'CurrentPoint');
draw_panel=findobj('Tag','DrawPanel');
DropDown=findobj(draw_panel,'Style','popupmenu');
Val=DropDown.Value;

if Val==8
    OldPosition=[];
    for j=1:length(ax_C_Vector)
        CAxis=ax_C_Vector{j};
        LineArray=findobj(CAxis,'Type','Line');
        if ~isempty(LineArray)
            if length(LineArray)> Draw.NumPlots
                for i=1:length(LineArray)-Draw.NumPlots
                    delete(LineArray(i))
                end
            elseif length(LineArray) < Draw.NumPlots
                error('Not enough lines were drawing. Incorrect number entered or something else... I guess')
            end
        end
    end
end

for j=1:length(ax_C_Vector)
    if isvalid(ax_C_Vector{i})
        CAxis=ax_C_Vector{j};
        f.WindowButtonMotionFcn={@MovingMouseDraw,C,CAxis};
    end
end