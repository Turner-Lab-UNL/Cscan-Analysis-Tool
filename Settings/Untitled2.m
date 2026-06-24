% spectrogram Function


h=gco;
f=gcf


j=f.WindowButtonDownFcn(2)
h.ButtonDownFcn=@temp


f.WindowButtonDownFcn=@localModeWindowButtonDownFcn  

plotedit('hidetoolsmenu')
plotedit('showtoolsmenu')
t = uitoolbar;
t.Visible = 'off';



figure
a = findall(gcf);
b = findall(a,'ToolTipString','Save Figure');
set(b,'Visible','Off')
b = findall(a,'ToolTipString','Open File');
set(b,'Visible','Off')
b = findall(a,'ToolTipString','New Figure');
set(b,'Visible','Off');
b = findall(a,'ToolTipString','Print Figure');
set(b,'Visible','Off');
b = findall(a,'ToolTipString','Insert Legend');
set(b,'Visible','Off');
b = findall(a,'ToolTipString','Insert Colorbar');
set(b,'Visible','Off');
b = findall(a,'ToolTipString','Rotate 3D');
set(b,'Visible','Off');
b = findall(a,'ToolTipString','Link Plot');
set(b,'Visible','Off');
b = findall(a,'ToolTipString','Show Plot Tools and Dock Figure');
set(b,'Visible','Off');
b = findall(a,'ToolTipString','Hide Plot Tools');
set(b,'Visible','Off');

Panels=findobj(FigHandle.Children,'Tag','APanel');
NumAPanels=length(Panels);
if 


for i=1:NumAPanels
    UpdatePanel=Panels(i);
    AScanAxes=UpdatePanel.Children(end);
    AScanAxes.PickableParts='none';
end


Panels=findobj(FigHandle.Children,'Tag','FreqPanel');
NumFreqPanels=length(Panels);
for i=1:NumFreqPanels
    UpdatePanel=Panels(i);
    FreqScanAxes=UpdatePanel.Children(end);
    FreqScanAxes.PickableParts='none';
end

Panels=findobj(FigHandle.Children,'Tag','CPanel');
NumFreqPanels=length(Panels);
for i=1:NumFreqPanels
    UpdatePanel=Panels(i);
    CScanAxes=UpdatePanel.Children(end);
    CScanAxes.PickableParts='none';
end