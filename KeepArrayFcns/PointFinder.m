function KeepVector=PointFinder(P, index_per_row, index_per_column, scan_res, index_res)

% IndexPerRow=scan_len/scan_res;             % Number of indecies per row
% IndexPerColumn=index_len/index_res;         % Number of indecies per column
X=P(1)/scan_res;
Y=P(2)/index_res;
KeepVector=sort(sub2ind([index_per_row index_per_column],X,Y))';

end