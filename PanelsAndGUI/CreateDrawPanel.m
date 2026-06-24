function [DrawPanel,SelectRegionButton,...
    PlotAll,AddButton,SubtractButton,AddBox,SubtractBox ]...
    =CreateDrawPanel(f,Ax,RightPanel,FigInsertHeight)


global VarArray
global DropDownDrawArray
global Draw_popup
% global ax_A_Vector
global ax_C_Vector
% global ax_F_Vector
%
%% Drawing Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DrawHeight=.13;
PanelColor=[.95 .95 .95];

VarArray.Point=[0 0];
VarArray.Line=[0 0 1 1];
VarArray.Rectangle=[0 0 1 1];
VarArray.Matrix=[0 1 0 1 2 2];
VarArray.Circular=[0 1 0 360 1 1];
VarArray.FreeForm=[0;0];
VarArray.FreeFormOld=[0;0];

KeepYesNo=1;%For now always keep waves

DrawPanel= uipanel('Tag','DrawPanel','Units','normalized','BackgroundColor',PanelColor,...
    'Position',[RightPanel, DrawHeight, 1.005-RightPanel, FigInsertHeight-DrawHeight-.02]);

SelectRegionButton=uicontrol(DrawPanel,'Style','pushbutton','Units','normalized',...
    'String','Select Region','Position',[.005,.9,.48,.09],...
    'Callback',{@SelectRegion_Callback,f,ax_C_Vector},'Units','normalized','Tag','Off');

MeanButton=uicontrol(DrawPanel,'Style','pushbutton','Units','normalized',...
    'String','Mean','Position',[.51,.9,.22,.09],...
    'BackgroundColor',[.7 .7 1], 'Callback',@PlotMean_Callback);
VarianceButton=uicontrol(DrawPanel,'Style','pushbutton','Units','normalized',...
    'String','Variance','Position',[.75,.9,.22,.09],...
    'BackgroundColor',[.7 .7 1], 'Callback',@PlotVariance_Callback);
KurtosisButton=uicontrol(DrawPanel,'Style','pushbutton','Units','normalized',...
    'String','Kurtosis','Position',[.51,.8,.22,.09],...
    'BackgroundColor',[.7 .7 1], 'Callback',@PlotKurtosis_Callback);

Draw_popup     = uicontrol(DrawPanel,'Style','popupmenu','Units','normalized',...
    'String',{'Point','Line','Rectangle', 'Circle','Wedged Shaped','Anulus','Anulus Wedge','Free Form'},...
    'Position',[.005,.8,.48,.09]);
Draw_popup.Callback=@Drawpopup_menu_Callback;

AddLocations=uicontrol(DrawPanel,'Style','pushbutton','Units','normalized',...
    'String','Add Locations','Position',[.005,.7,.48,.09],'CallBack',@Keep_Callback);

DrawPanel.HitTest='off';
SelectRegionButton.HitTest='off';
MeanButton.HitTest='off';
VarianceButton.HitTest='off';
KurtosisButton.HitTest='off';
Draw_popup.HitTest='off';
Draw_popup.HitTest='off';
AddLocations.HitTest='off';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Input1Text      = uicontrol(DrawPanel,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'String','Input 1','Position',[.005,.6,.22,.09]);

Input1Value  = uicontrol(DrawPanel,'Tag','Input1','Style','edit',...
    'String','n/a','Units','normalized','Position',[.25,.6,.22,.09],...
    'Enable','off','CallBack',@VarPos_Callback);

Input2Text      = uicontrol(DrawPanel,'Style','text','Units','normalized',...
    'BackgroundColor',PanelColor,'String','Input 2','Position',[.51,.6,.22,.09]);

Input2Value  = uicontrol(DrawPanel,'Tag','Input2','Style','edit',...
    'String','n/a','Units','normalized','Position',[.75,.6,.22,.09],...
    'Enable','off','CallBack',@VarPos_Callback);

Input3Text      = uicontrol(DrawPanel,'Style','text','BackgroundColor',PanelColor,...
    'String','Input 3','Units','normalized','Position',[.005,.5,.22,.09]);

Input3Value  = uicontrol(DrawPanel,'Tag','Input3','Style','edit',...
    'String','n/a','Units','normalized','Position',[.25,.5,.22,.09],...
    'Enable','off','CallBack',@VarPos_Callback);

Input4Text      = uicontrol(DrawPanel,'Style','text','BackgroundColor',PanelColor,...
    'String','Input 4','Units','normalized','Position',[.51,.5,.22,.09]);

Input4Value  = uicontrol(DrawPanel,'Tag','Input4','Style','edit',...
    'String','n/a','Units','normalized','Position',[.75,.5,.22,.09],...
    'Enable','off','CallBack',@VarPos_Callback);

Input5Text      = uicontrol(DrawPanel,'Style','text','BackgroundColor',PanelColor,...
    'String','Input 5','Units','normalized','Position',[.005,.4,.22,.09]);

Input5Value  = uicontrol(DrawPanel,'Tag','Input5','Style','edit',...
    'String','n/a','Units','normalized','Position',[.25,.4,.22,.09],...
    'Enable','off','CallBack',@VarPos_Callback);

Input6Text      = uicontrol(DrawPanel,'Style','text','BackgroundColor',PanelColor,...
    'String','Input 6','Units','normalized','Position',[.51,.4,.22,.09]);

Input6Value  = uicontrol(DrawPanel,'Tag','Input6','Style','edit',...
    'String','n/a','Units','normalized','Position',[.75,.4,.22,.09],...
    'Enable','off','CallBack',@VarPos_Callback);

Input1Text.HitTest='off';
Input1Value.HitTest='off';
Input2Text.HitTest='off';
Input2Value.HitTest='off';
Input3Text.HitTest='off';
Input3Value.HitTest='off';
Input4Text.HitTest='off';
Input4Value.HitTest='off';
Input5Text.HitTest='off';
Input5Value.HitTest='off';
Input6Text.HitTest='off';
Input6Value.HitTest='off';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DropDownDrawArray=[Input1Text Input1Value Input2Text Input2Value ...
    Input3Text Input3Value Input4Text Input4Value Input5Text Input5Value Input6Text Input6Value];


AddButton=uicontrol(DrawPanel,'Tag','+','Style','pushbutton',...
    'String','+','Units','normalized','Position',[.005,.3,.22,.09],...
    'Callback',@AddButton_Callback,'BackgroundColor',[.5 1 .5]);

SubtractButton=uicontrol(DrawPanel,'Tag','-','Style','pushbutton',...
    'String','-','Units','normalized','Position',[.25,.3,.22,.09],...
    'Callback',@AddButton_Callback,'BackgroundColor',[0.7   0.7   0.7]);

PlotAll=uicontrol(DrawPanel,'Style','pushbutton','Units','normalized',...
    'String','Plot All','Position',[.51,.3,.22,.09],...
    'Callback',@PlotAll_Callback);
ResetButton=uicontrol(DrawPanel,'Style','pushbutton','Units','normalized',...
    'String','Reset','Position',[.75,.3,.22,.09],...
    'Callback',@DrawReset_Callback);

AddBox=uicontrol(DrawPanel,'Tag','AddBox','Style','listbox',...
    'Units','normalized','Position',[.005,.005,.48,.29],...
    'BackgroundColor',[.5 1 .5],'KeyPressFcn',@DeleteList);
SubtractBox=uicontrol(DrawPanel,'Tag','SubtractBox','Style','listbox',...
    'Units','normalized','Position',[.51,.005,.48,.29],...
    'BackgroundColor',[1 .5 .5],'KeyPressFcn',@DeleteList);

AddButton.HitTest='off';
SubtractButton.HitTest='off';
PlotAll.HitTest='off';
ResetButton.HitTest='off';
AddBox.HitTest='off';
SubtractBox.HitTest='off';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Drawpopup_menu_Callback(~,~)
        TypeOfFilterShape(DropDownDrawArray,Draw_popup.Value,VarArray)
    end

    function VarPos_Callback(~,~)
        % Function updates the values in the VarArray as the user enters in
        % the values

        VarArray=VariablePositionFunction(f,ax_C_Vector,Draw_popup.Value,VarArray,DropDownDrawArray);
    end

    function Keep_Callback(~,~)
        global ScanSettings
        
        if isempty(ScanSettings.f_s)
            ErrorMessage1
            return
        end
        for i=1:length(ax_C_Vector)
            ax=ax_C_Vector{i};
            if KeepYesNo==1
                KeepLocations_Callback(f,ax,AddBox,KeepYesNo,i)
            else
                KeepLocations_Callback(f,ax,SubtractBox,KeepYesNo,i)
            end
        end
    end

    function AddButton_Callback(fHandle,~)
        if fHandle.Tag=='+'
            SubtractButton.BackgroundColor=[0.7   0.7   0.7];
            AddButton.BackgroundColor=[.5 1 .5];
            KeepYesNo=1;
        else
            SubtractButton.BackgroundColor=[1   0.5   0.5];
            AddButton.BackgroundColor=[.7 .7 .7];
            KeepYesNo=0;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DrawReset_Callback(Button,~)
        global Draw
        global ScanSettings
        
        if isempty(ScanSettings.f_s)
            ErrorMessage1
            return
        end
        %         if isempty(Draw.SelectedIndecies)
        %             ErrorMessage2
        %             return
        %         end
        
        qstring='Would you like to reset the keep and discard shapes?';
        title='Reset';
        Choice = questdlg(qstring,title,'yes','no','yes');
        switch Choice
            case 'yes'
                AddBox.String={};
                SubtractBox.String={};
            case 'no'
                fprintf('Data Was not reset')
                return
        end
        Draw.NumPlots=0;
        Draw.NameArray=[];
        Draw.PlotData=[];
        Draw.KeepArray=[];
        Draw.SubtractArray=[];
        Draw.SelectedIndecies=[];
        ChangeButtons(f,Button)
        zoom off
        pan off
        rotate3d off
        f.WindowButtonMotionFcn=[];
        f.WindowButtonUpFcn=[];
        Update_CScan_Callback(1,1,f,1);
        MessageBox=findobj(f,'Tag','MessageBox');
        MessageBox.String='Drawing data has been rest.';
        MessageBox.BackgroundColor=[0 1 0];
    end

    function PlotAll_Callback(Button,~)
        global Draw
        global ScanSettings
        
        if isempty(ScanSettings.f_s)
            ErrorMessage1
            return
        end
        if isempty(Draw.SelectedIndecies)
            ErrorMessage2
            return
        end
        for i=1:length(ax_C_Vector)
            ax=ax_C_Vector{i};
            NumberOfPoints=PlotAllPoints(Button,ax,length(ax_C_Vector)-i);
        end
        MessageBox=findobj(f,'Tag','MessageBox');
        MessageBox.String=['The number of points plotted is ',num2str(NumberOfPoints)];
        MessageBox.BackgroundColor=[0 1 0];
  
    end
    function PlotVariance_Callback(~,~)
        global Draw
        global Waves
        global ScanSettings
        
        if isempty(ScanSettings.f_s)
            ErrorMessage1
            return
        end
        
        if isempty(Draw.SelectedIndecies)
            ErrorMessage2
            return
        end
        
        if nnz(Waves.shifted_matrix)>0
            Draw.SelectedIndecies(Draw.SelectedIndecies==0)=max(Draw.SelectedIndecies);
            Draw.SelectedIndecies=unique(Draw.SelectedIndecies);
            figure
            VarianceWave=var(Waves.shifted_matrix(Draw.SelectedIndecies,:));
            plot(ScanSettings.t,VarianceWave)
            title('Variance for Selected Indicies')
            xlabel('Time (s)');
            Len=length(Draw.SelectedIndecies);
            MessageBox=findobj(f,'Tag','MessageBox');
            MessageBox.String=(['Variance Plot has ', num2str(Len),' number of points']);
            MessageBox.BackgroundColor=[0 1 0];
        else
            Draw.SelectedIndecies(Draw.SelectedIndecies==0)=max(Draw.SelectedIndecies);
            Draw.SelectedIndecies=unique(Draw.SelectedIndecies);
            figure
            VarianceWave=var(Waves.waveform_matrix(Draw.SelectedIndecies,:));
            plot(ScanSettings.t,VarianceWave)
            title('Variance for Selected Indicies')
            xlabel('Time (s)');
            Len=length(Draw.SelectedIndecies);
            MessageBox=findobj(f,'Tag','MessageBox');
            MessageBox.String=('Varience was plotted for raw data. Alignment not yet Performed');
            MessageBox.BackgroundColor=[1 1 0];
        end
    end

    function PlotMean_Callback(~,~)
        global Draw
        global Waves
        global ScanSettings
        %         global SaveString
        if isempty(ScanSettings.f_s)
            ErrorMessage1
            return
        end
        if isempty(Draw.SelectedIndecies)
            ErrorMessage2
            return
        end
        
        if nnz(Waves.shifted_matrix)>0
            Draw.SelectedIndecies(Draw.SelectedIndecies==0)=max(Draw.SelectedIndecies);
            Draw.SelectedIndecies=unique(Draw.SelectedIndecies);
            figure
            mean_wave=mean(Waves.shifted_matrix(Draw.SelectedIndecies,:));
            plot(ScanSettings.t,mean_wave)
            title('Mean for Selected Indicies')
            xlabel('Time (s)');
            Len=length(Draw.SelectedIndecies);
            MessageBox=findobj(f,'Tag','MessageBox');
            MessageBox.String=(['Mean Plot has ', num2str(Len),' number of points']);
            MessageBox.BackgroundColor=[0 1 0];
        else
            Draw.SelectedIndecies(Draw.SelectedIndecies==0)=max(Draw.SelectedIndecies);
            Draw.SelectedIndecies=unique(Draw.SelectedIndecies);
            figure
            mean_wave=mean(Waves.waveform_matrix(Draw.SelectedIndecies,:));
            plot(ScanSettings.t,mean_wave)
            title('Mean for Selected Indicies')
            xlabel('Time (s)');
            MessageBox=findobj(f,'Tag','MessageBox');
            MessageBox.String=('Mean was plotted for raw data. Alignment not yet Performed');
            MessageBox.BackgroundColor=[1 1 0];
        end
    end

    function PlotKurtosis_Callback(~,~)
        global Draw
        global Waves
        global ScanSettings
        
        if isempty(ScanSettings.f_s)
            ErrorMessage1
            return
        end
        if isempty(Draw.SelectedIndecies)
            ErrorMessage2
            return
        end
        
        if nnz(Waves.shifted_matrix)>0
            Draw.SelectedIndecies(Draw.SelectedIndecies==0)=max(Draw.SelectedIndecies);
            Draw.SelectedIndecies=unique(Draw.SelectedIndecies);
            figure
            mean_wave=kurtosis(Waves.shifted_matrix(Draw.SelectedIndecies,:));
            plot(ScanSettings.t,mean_wave)
            title('Kurtosis for Selected Indicies')
            xlabel('Time (s)');
            Len=length(Draw.SelectedIndecies);
            MessageBox=findobj(f,'Tag','MessageBox');
            MessageBox.String=(['Kurtosis Plot has ', num2str(Len),' number of points']);
            MessageBox.BackgroundColor=[0 1 0];
        else
            Draw.SelectedIndecies(Draw.SelectedIndecies==0)=max(Draw.SelectedIndecies);
            Draw.SelectedIndecies=unique(Draw.SelectedIndecies);
            figure
            mean_wave=kurtosis(Waves.waveform_matrix(Draw.SelectedIndecies,:));
            plot(ScanSettings.t,mean_wave)
            title('Kurtosis for Selected Indicies')
            xlabel('Time (s)');
            MessageBox=findobj(f,'Tag','MessageBox');
            MessageBox.String=('Kurtosis was plotted for raw data. Alignment not yet Performed');
            MessageBox.BackgroundColor=[1 1 0];
        end
    end

    function ErrorMessage1
        MessageBox=findobj(f,'Tag','MessageBox');
        MessageBox.String=('Data must be loaded prior to using the selection tool!!');
        MessageBox.BackgroundColor=[1 1 0];
    end

    function ErrorMessage2
        MessageBox=findobj(f,'Tag','MessageBox');
        MessageBox.String=('Regions must be selected prior to this action!!');
        MessageBox.BackgroundColor=[1 1 0];
    end

end