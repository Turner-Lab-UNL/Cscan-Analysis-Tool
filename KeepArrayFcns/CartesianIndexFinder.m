function [ KeepVector ] = CartesianIndexFinder( P1,P2,scan_res,index_res,index_per_row,index_per_column,TypeOfPlot)
%% Calculate indicies using cartesian coordinates

% Description:  This function allows the user to obtain all indicies found
%               within a rectangular region. The user inputs two points
%               which are used to define the region. 
%
% Creator:      Nate Matz
% Date:         7/19/2017
%
% Modification: 
%
% Variables:
%   P1          - Lower lefthand corner of desired square
%   P2          - Upper righhand corner of desired square
%   KeepVector  - Vector countaining all indecies within the desired region.
%   scan_len    - Length of c-scan in scanning direction.
%   scan_res    - Scanning resolution in scanning direction.
%   index_len   - Length of c-scan in indexing direction.
%   index_res   - Scanning resolution in indexing direction.

%% Preliminary Calculations
% Convert/Calculate parameters to indecies
column=round([P1(1),P2(1)]/scan_res);      % Convert lower lefthand point
row=round([P1(2),P2(2)]/index_res);       % Convert upper righthand point
% index_per_row=scan_len/scan_res;              % Number of indecies per row
% index_per_column=index_len/index_res;         % Number of indecies per column

% Check to see if P1 and P2 fall within the scanning and indexing
% boundaries. If not, an error is shown.
if column(2)>index_per_row
    error('the desired region is outside the scaning boundaries')
elseif column(1)<0
     error('the desired region is below the scaning boundaries')
end

if row(2)>index_per_column
    error ('the desired region is outside the indexing boundaries')
elseif row(1)<0
    error ('the desired region is below the indexing boundaries')
end

%% Calculations
% This section finds the x y coordinates (in index space) for the desired
% region. The output vector contains the values for the global indecies.

[x, y]=meshgrid(column(1)+1:column(2),row(1)+1:row(2));
x=reshape(x,numel(x),1);
y=reshape(y,numel(y),1);
KeepVector=sort(sub2ind([index_per_row index_per_column],x,y));

%% Plot Scan Area Function
% Due to the nature of the code, the x y positions are always at the
% top right corner of their respected areas (similar to their pixels). For
% this reason, the x y positions have been shifted by half the
% scanning/indexing resolutions. This places the points in the center of
% their respected areas.
switch TypeOfPlot
    case 'Plot_Yes'
        scan_len=index_per_row*scan_res;
        index_len=index_per_column*index_res;
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
