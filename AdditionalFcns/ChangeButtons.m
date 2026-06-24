function ChangeButtons(f,Button)
       OnButton=findobj(f,'Tag','Button On');
       
       if ~contains(Button.String,'Reset')
                   Button.BackgroundColor=[0 1 1];
       else
           Button.BackgroundColor=[0.9400 0.9400 0.9400];
       end
        
        
        for i=1:length(OnButton)
            if OnButton~= Button
                OnButton(i).Tag='Button Off';
                OnButton(i).BackgroundColor=[0.9400 0.9400 0.9400];
                if contains(OnButton(i).String,'Done')
                   OnButton(i).String='Select Region'; 
                end
            else
                Button.BackgroundColor=[0.9400 0.9400 0.9400];
            end
        end
end