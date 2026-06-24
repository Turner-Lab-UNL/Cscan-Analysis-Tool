function ResizeFunction(f,~) 

FNew(1)=f.Position(3);
FNew(2)=f.Position(4);
L=FNew(1)^2+FNew(2)^2;
set( findall( f, '-property', 'FontSize' ), 'FontSize', sqrt(16*L^2+80))

end