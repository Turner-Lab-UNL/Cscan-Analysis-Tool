function TypeOfFilterShape(DropDownDrawArray,Val,VarArray)

switch Val
    case 1
        DropDownDrawArray(1).String='X1';
        DropDownDrawArray(3).String='Y1';
        DropDownDrawArray(5).String='Input 3';
        DropDownDrawArray(7).String='Input 4';
        DropDownDrawArray(9).String='Input 5';
        DropDownDrawArray(11).String='Input 6';
        DropDownDrawArray(2).Enable='on';
        DropDownDrawArray(4).Enable='on';
        DropDownDrawArray(6).Enable='off';
        DropDownDrawArray(8).Enable='off';
        DropDownDrawArray(10).Enable='off';
        DropDownDrawArray(12).Enable='off';
        DropDownDrawArray(2).String=num2str(VarArray.Point(1));
        DropDownDrawArray(4).String=num2str(VarArray.Point(2));      
        DropDownDrawArray(6).String='n/a';
        DropDownDrawArray(8).String='n/a';
        DropDownDrawArray(10).String='n/a';
        DropDownDrawArray(12).String='n/a'; 
    
    case 2 % Line
        VarArray.Line;
        DropDownDrawArray(1).String='X1';
        DropDownDrawArray(3).String='Y1';
        DropDownDrawArray(5).String='X2';
        DropDownDrawArray(7).String='Y2';
        DropDownDrawArray(9).String='Input 5';
        DropDownDrawArray(11).String='Input 6';
        DropDownDrawArray(2).Enable='on';
        DropDownDrawArray(4).Enable='on';
        DropDownDrawArray(6).Enable='on';
        DropDownDrawArray(8).Enable='on';
        DropDownDrawArray(10).Enable='off';
        DropDownDrawArray(12).Enable='off';
        DropDownDrawArray(2).String=num2str(VarArray.Line(1));
        DropDownDrawArray(4).String=num2str(VarArray.Line(2));       
        DropDownDrawArray(6).String=num2str(VarArray.Line(3));
        DropDownDrawArray(8).String=num2str(VarArray.Line(4));
        DropDownDrawArray(10).String='n/a';
        DropDownDrawArray(12).String='n/a';
        
    case 3 % Rectangle
        DropDownDrawArray(1).String='X1';
        DropDownDrawArray(3).String='Y1';
        DropDownDrawArray(5).String='X2';
        DropDownDrawArray(7).String='Y2';
        DropDownDrawArray(9).String='Input 5';
        DropDownDrawArray(11).String='Input 6';
        DropDownDrawArray(2).Enable='on';
        DropDownDrawArray(4).Enable='on';
        DropDownDrawArray(6).Enable='on';
        DropDownDrawArray(8).Enable='on';
        DropDownDrawArray(10).Enable='off';
        DropDownDrawArray(12).Enable='off';
        DropDownDrawArray(2).String=num2str(VarArray.Rectangle(1));
        DropDownDrawArray(4).String=num2str(VarArray.Rectangle(2));       
        DropDownDrawArray(6).String=num2str(VarArray.Rectangle(3));
        DropDownDrawArray(8).String=num2str(VarArray.Rectangle(4));
        DropDownDrawArray(10).String='n/a';
        DropDownDrawArray(12).String='n/a';        
       
    case 4 % Circular
        DropDownDrawArray(1).String='r in';
        DropDownDrawArray(3).String='r out';
        DropDownDrawArray(5).String='Ang 1';
        DropDownDrawArray(7).String='Agn 2';
        DropDownDrawArray(9).String='Cent X';
        DropDownDrawArray(11).String='Cent Y';
        DropDownDrawArray(2).Enable='off';
        DropDownDrawArray(4).Enable='on';
        DropDownDrawArray(6).Enable='off';
        DropDownDrawArray(8).Enable='off';
        DropDownDrawArray(10).Enable='on';
        DropDownDrawArray(12).Enable='on';
        DropDownDrawArray(2).String=num2str(VarArray.Circular(1));
        DropDownDrawArray(4).String=num2str(VarArray.Circular(2));       
        DropDownDrawArray(6).String=num2str(VarArray.Circular(3));
        DropDownDrawArray(8).String=num2str(VarArray.Circular(4));
        DropDownDrawArray(10).String=num2str(VarArray.Circular(5));
        DropDownDrawArray(12).String=num2str(VarArray.Circular(6)); 
        
    case 5  %Wedge Shaped
        DropDownDrawArray(1).String='r in';
        DropDownDrawArray(3).String='r out';
        DropDownDrawArray(5).String='Ang 1';
        DropDownDrawArray(7).String='Agn 2';
        DropDownDrawArray(9).String='Cent X';
        DropDownDrawArray(11).String='Cent Y';
        DropDownDrawArray(2).Enable='off';
        DropDownDrawArray(4).Enable='on';
        DropDownDrawArray(6).Enable='on';
        DropDownDrawArray(8).Enable='on';
        DropDownDrawArray(10).Enable='on';
        DropDownDrawArray(12).Enable='on';
        DropDownDrawArray(2).String=num2str(VarArray.Circular(2));
        DropDownDrawArray(4).String=num2str(VarArray.Circular(1));       
        DropDownDrawArray(6).String=num2str(VarArray.Circular(3));
        DropDownDrawArray(8).String=num2str(VarArray.Circular(4));
        DropDownDrawArray(10).String=num2str(VarArray.Circular(5));
        DropDownDrawArray(12).String=num2str(VarArray.Circular(6)); 
        
    case 6 %Anulus
        
        DropDownDrawArray(1).String='r in';
        DropDownDrawArray(3).String='r out';
        DropDownDrawArray(5).String='Ang 1';
        DropDownDrawArray(7).String='Agn 2';
        DropDownDrawArray(9).String='Cent X';
        DropDownDrawArray(11).String='Cent Y';
        DropDownDrawArray(2).Enable='on';
        DropDownDrawArray(4).Enable='on';
        DropDownDrawArray(6).Enable='off';
        DropDownDrawArray(8).Enable='off';
        DropDownDrawArray(10).Enable='on';
        DropDownDrawArray(12).Enable='on';
        DropDownDrawArray(2).String=num2str(VarArray.Circular(2));
        DropDownDrawArray(4).String=num2str(VarArray.Circular(1));       
        DropDownDrawArray(6).String=num2str(VarArray.Circular(3));
        DropDownDrawArray(8).String=num2str(VarArray.Circular(4));
        DropDownDrawArray(10).String=num2str(VarArray.Circular(5));
        DropDownDrawArray(12).String=num2str(VarArray.Circular(6)); 
        
    case 7 %pi Anulus        
        DropDownDrawArray(1).String='r in';
        DropDownDrawArray(3).String='r out';
        DropDownDrawArray(5).String='Ang 1';
        DropDownDrawArray(7).String='Agn 2';
        DropDownDrawArray(9).String='Cent X';
        DropDownDrawArray(11).String='Cent Y';
        DropDownDrawArray(2).Enable='on';
        DropDownDrawArray(4).Enable='on';
        DropDownDrawArray(6).Enable='on';
        DropDownDrawArray(8).Enable='on';
        DropDownDrawArray(10).Enable='on';
        DropDownDrawArray(12).Enable='on';
        DropDownDrawArray(2).String=num2str(VarArray.Circular(2));
        DropDownDrawArray(4).String=num2str(VarArray.Circular(1));       
        DropDownDrawArray(6).String=num2str(VarArray.Circular(3));
        DropDownDrawArray(8).String=num2str(VarArray.Circular(4));
        DropDownDrawArray(10).String=num2str(VarArray.Circular(5));
        DropDownDrawArray(12).String=num2str(VarArray.Circular(6));
        
    otherwise
        
        DropDownDrawArray(1).String='Input 1';
        DropDownDrawArray(3).String='Input 2';
        DropDownDrawArray(5).String='Input 3';
        DropDownDrawArray(7).String='Input 4';
        DropDownDrawArray(9).String='Input 5';
        DropDownDrawArray(11).String='Input 6';
        DropDownDrawArray(2).Enable='off';
        DropDownDrawArray(4).Enable='off';
        DropDownDrawArray(6).Enable='off';
        DropDownDrawArray(8).Enable='off';
        DropDownDrawArray(10).Enable='off';
        DropDownDrawArray(12).Enable='off';
        DropDownDrawArray(2).String='n/a';
        DropDownDrawArray(4).String='n/a';      
        DropDownDrawArray(6).String='n/a';
        DropDownDrawArray(8).String='n/a';
        DropDownDrawArray(10).String='n/a';
        DropDownDrawArray(12).String='n/a';

end




end