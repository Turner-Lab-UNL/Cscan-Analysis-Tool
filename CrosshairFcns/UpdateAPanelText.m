function UpdateAPanelText(~,Lines,TextHandles)

VertLine1=Lines(end);
HorzLine1=Lines(end-1);

if length(Lines)==4
    %Find Second lines if double cross hairs are used
    VertLine2=Lines(end-2);
    HorzLine2=Lines(end-3);
    
    %Find relative positions
    DeltaX=VertLine2.XData(1)-VertLine1.XData(1);
    DeltaY=HorzLine2.YData(1)-HorzLine1.YData(1);
    %Convert to strings
    DeltaXString=num2str(round(DeltaX,3));
    DeltaYString=num2str(round(DeltaY,3));
    %UpdateText
    TextHandles(1).String = ['Time =',DeltaXString];
    TextHandles(2).String = ['Amplitude =',DeltaYString];
else
    %Update Text
    TextHandles(1).String = ['Time =',num2str(round(VertLine1.XData(1),3))];
    
    TextHandles(2).String = ['Amplitude =',num2str(round(HorzLine1.YData(1),3))];
    % Update the Location in the A Scan

end


end