function SelectRegion_Callback(Button,~,f,~)
global DropDownDrawArray
global ScanSettings
global ax_C_Vector

if isempty(ScanSettings.f_s)
    MessageBox=findobj(f,'Tag','MessageBox');
    MessageBox.String=('Data must be loaded prior to using the selection tool!!');
    MessageBox.BackgroundColor=[1 1 0];
    return
end

if contains(Button.Tag, 'Off') || isempty(Button.Tag)
    ChangeButtons(f,Button);
    f.WindowButtonMotionFcn=[];
    f.WindowButtonUpFcn=[];
    %Set axis button down function
    f.WindowButtonDownFcn={@Draw_ButtonDown,f,ax_C_Vector};
    Button.Tag='Button On';
    Button.BackgroundColor=[0 1 1];
    Button.String='Done';
  
    crosshairs=findobj(f,'Tag','CrossHair');
    for i=1:length(crosshairs)
        delete(crosshairs(i))
    end
    
    ReplotLineData(f,ax_C_Vector)
else
    f.WindowButtonDownFcn=[];
    f.WindowButtonMotionFcn=[];
    f.WindowButtonUpFcn=[];
    Button.Tag='Button Off';
    Button.String='Select Region';
    Button.BackgroundColor=[0.9400 0.9400 0.9400];
    TypeOfFilterShape(DropDownDrawArray,8,1)
    f.Pointer='arrow';
end
end