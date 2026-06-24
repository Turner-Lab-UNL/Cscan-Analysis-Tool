function DrawFreeFormButtonUp(f,~,Line,NumFig)
global ScanSettings
global VarArray
global OldPosition
global ax_C_Vector


for j=1:length(ax_C_Vector)
    if isvalid(ax_C_Vector{j})
        line_change=findobj(ax_C_Vector{j}.Children,'Tag','Free Form');
        
        XStart=line_change(1).XData(end)+ScanSettings.scan_res/2;
        XEnd=line_change(1).XData(1)+ScanSettings.scan_res/2;
        YStart=line_change(1).YData(end)+ScanSettings.index_res/2;
        YEnd=line_change(1).YData(1)+ScanSettings.index_res/2;
        OldXData=line_change(1).XData;
        OldYData=line_change(1).YData;
        P1=[XStart,YStart];
        P2=[XEnd,YEnd];
        
        KeepVector = LineFinder( P1, P2, ScanSettings.IndexPerRow, ScanSettings.IndexPerColumn, ScanSettings.scan_res, ScanSettings.index_res,'Plot_No');
        [Xs,Ys]=ind2sub([ScanSettings.IndexPerRow,ScanSettings.IndexPerColumn],KeepVector);
        Xs=sort(Xs)';
        Ys=sort(Ys)';
        %
        if Xs(1)<P1(1)/ScanSettings.scan_res+1 && Xs(1)>P1(1)/ScanSettings.scan_res-1
            %Good
        else
            Xs=fliplr(Xs);
        end
        if Ys(1)<P1(2)/ScanSettings.index_res+1 && Ys(1)>P1(2)/ScanSettings.index_res-1
            %Good
        else
            Ys=fliplr(Ys);
        end
        line_change(1).XData=[OldXData,Xs(1:end)*ScanSettings.scan_res-ScanSettings.scan_res/2];
        line_change(1).YData=[OldYData,Ys(1:end)*ScanSettings.index_res-ScanSettings.index_res/2];
        
        Ax=f.Children(end);
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
    
    VarArray.FreeForm=[line_change(1).XData/ScanSettings.scan_res+ScanSettings.scan_res;line_change(1).YData/ScanSettings.index_res+ScanSettings.index_res];
    f.WindowButtonMotionFcn=[];
    f.WindowButtonUpFcn=[];
    
    end
end