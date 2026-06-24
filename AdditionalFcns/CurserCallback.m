function CurserCallback(gcbf)

hEdit=findall(gcbf,'tag','Standard.EditPlot');
axes_list=findall(gcbf,'Type','axes');
lines_list=findall(gcbf,'Type','Line');
switch hEdit.State
    case 'on'
        for i=1:length(axes_list)
           axes_list(i).HitTest='off'; 
        end
        for i=1:length(lines_list)
           lines_list(i).HitTest='off'; 
        end
    case 'off'
         for i=1:length(axes_list)
           axes_list(i).HitTest='on'; 
         end
        for i=1:length(lines_list)
           lines_list(i).HitTest='on'; 
        end
end
      
plotedit(gcbf,'toggle')

end
