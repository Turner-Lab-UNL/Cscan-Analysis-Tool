function [ KeepVector ] = LineFinder( P1, P2, index_per_row, index_per_column, scan_res, index_res,TypeOfPlot)

% Description:  This function allows the user to find all indecies found
%               along a line. Two points are used to find the indecies. 
%               which are used to define the region. This will naturally
%               create jagged lines due to the finite width of the region.
%
% Creator:      Nate Matz
% Date:         9/11/2017
%
% Modification: 
%
% Variables:
%   P1          - Lower lefthand corner of desired line
%   P2          - Upper righhand corner of desired line
%   KeepVector  - Vector countaining all indecies within the desired line.
%   scan_len    - Length of c-scan in scanning direction.
%   scan_res    - Scanning resolution in scanning direction.
%   index_len   - Length of c-scan in indexing direction.
%   index_res   - Scanning resolution in indexing direction.



%% Preliminary Calculations
% Convert/Calculate parameters to indecies

column=round([P1(1),P2(1)]/scan_res);       % Convert lower lefthand point
row=round([P1(2),P2(2)]/index_res);         % Convert upper righthand point
% IndexPerRow=scan_len/scan_res;             % Number of indecies per row
% IndexPerColumn=index_len/index_res;         % Number of indecies per column
scan_len=index_per_row*scan_res;
index_len=index_per_row*index_res;


% Check to see if P1 and P2 fall within the scanning and indexing
% boundaries. If not, an error is shown.
if column(2)>index_per_row || column(1)<0
    error('the desired region is outside the scaning boundaries')
end

if row(2)>index_per_column || row(1)<0
    error ('the desired region is outside the indexing boundaries')
end

%% Calculations
Resolution=max([abs(column(1)-column(2)),abs(row(1)-row(2))]);
% m=(row(2)-row(1))/(column(2)-column(1));
% b=row(1)-m*column(1);

x=linspace(column(1),column(2),Resolution+1);
% row
y=linspace(row(1),row(2),Resolution+1);
% if m==inf || m==-inf %This is for Vertical lines
%     y=min(row):max(row);
%     x=linspace(column(1),column(2),Resolution+1);
% else
% y=round(m*x+b);
% end

x=round(x);
y=round(y);
KeepVector=sort(sub2ind([index_per_row index_per_column],x,y))';
% length(KeepVector)
% KeepVector=unique(KeepVector);
% length(KeepVector)
%% Plot Scan Area Function
% Due to the nature of the code, the x y positions are always at the
% top right corner of their respected areas (similar to their pixels). For
% this reason, the x y positions have been shifted by half the
% scanning/indexing resolutions. This places the points in the center of
% their respected areas.
switch TypeOfPlot
    case 'Plot_Yes'
        figure(1776);plot(x*scan_res-scan_res/2,y*index_res-index_res/2,'.');
        xlim([0,scan_len])
        ylim([0,index_len])
        axis equal
    case 'Plot_No'
    case 'Plot_On_Top'
        hold on
        plot(x*scan_res-scan_res/2,y*index_res-index_res/2,'.');
        hold off
    otherwise
                                            % Error Message
    error('Incorrect plotting input. The final function input should be Plot_Yes to plot and Plot_No not to plot')
end

end