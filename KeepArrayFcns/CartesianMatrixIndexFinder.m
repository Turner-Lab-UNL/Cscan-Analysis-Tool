function [ KeepMatrix] = CartesianMatrixIndexFinder( P1,P2,scan_parti,index_parti,scan_res,index_res,scan_len,index_len, TypeOfPlot )
%% Calculates several sets of indicies in cartesian coordinates
%
% Description: This function is a more advanced version of
%              CartesianIndexFinder. This function will find the index
%              values for several rectangular regions within a scan area.
%              The user inputs two points to set up the overall area, as
%              well as the scanning and indexing partitions desired. The
%              returned value is a matrix of indecies desired with each row
%              being a different region. 
%
% Creator:      Nate Matz
% Date:         7/19/2017
%
% Modification: 
%
% Variables:
%   P1          - Lower lefthand corner of desired region
%   P2          - Upper righhand corner of desired region
%   scan_parti  - Number of partitions desired in scanning direction. The
%                 function automatically rounds down. 
%   index_parti - Number of partitions desired in indexing direction. The
%                 function automatically rounds down.
%   KeepVector  - Vector countaining all indecies within the desired region.
%   scan_len    - Length of c-scan in scanning direction.
%   scan_res    - Scanning resolution in scanning direction.
%   index_len   - Length of c-scan in indexing direction.
%   index_res   - Scanning resolution in indexing direction.
%   TypeOfPlot  - Tells function weather to plot regions (Plot_Yes), or if
%                 the program should not plot regions (Plot_No).

%% Preliminary Calculations
% Convert/Calculate parameters to indecies
column=floor([P1(1),P2(1)]/scan_res);       % Convert lower lefthand point
row=floor([P1(2),P2(2)]/index_res);        % Convert upper righthand point
IndexPerRow=scan_len/scan_res;              % Number of indecies per row
IndexPerColumn=index_len/index_res;         % Number of indecies per column

% Check to see if P1 and P2 fall within the scanning and indexing
% boundaries. If not, an error is shown.
if column(2)>IndexPerRow
    error('the desired region is outside the scaning boundaries')
elseif column(1)<0
     error('the desired region is below the scaning boundaries')
end

if row(2)>IndexPerColumn
    error ('the desired region is outside the indexing boundaries')
elseif row(1)<0
    error ('the desired region is below the indexing boundaries')
end
%% Calculate number of indecies in each partitian and perform check
ScanParti=floor((column(2)-column(1))/floor(scan_parti));
IndexParti=floor((row(2)-row(1))/floor(index_parti));

if ScanParti==0                             % Check scanning partitian
    ScanParti=1;
    error('scan partitioning desired is greater than number of data points possible')
end

if IndexParti==0                            % Check indexing partitian
    IndexParti=1;
    error('index partitioning desired is greater than number of data points possible')
end

%% Calculate all of the indecies for each region 
% Set temp to one for starting region and zero the KeepMatrix
temp=1;
KeepMatrix=zeros(floor(index_parti)*floor(scan_parti),ScanParti*IndexParti);

for i=0:scan_parti-1                        % Loop through scanning partitians
                                            % Calculate indecies for the columns
    ColumnSec=[column(1)+ScanParti*i,column(1)+ScanParti*(1+i)];
    
    for j=0:index_parti-1                   % Loop through indexing partitians
                                            % Calculate the indecies for the rows   
    RowSec=[row(1)+IndexParti*j,row(1)+IndexParti*(1+j)];
    [x, y]=meshgrid(ColumnSec(1)+1:ColumnSec(2),RowSec(1)+1:RowSec(2));
    x=reshape(x,numel(x),1);
    y=reshape(y,numel(y),1);
                                            % Calculate indecies for region and store in matrix
    KeepMatrix(temp,:)=sort(sub2ind([IndexPerRow IndexPerColumn],x,y));
    temp=temp+1;                            % Plot/not plot regions
        switch TypeOfPlot
            case 'Plot_Yes'                        
                figure(1812);
                plot(x*scan_res-scan_res/2,y*index_res-index_res/2,'.');
                xlim([0,scan_len])
                ylim([0,index_len])
                axis equal
                hold on
            case 'Plot_No'                
            otherwise
                                            % Error Message
                error('Incorrect plotting input. The final function input should be Plot_Yes to plot and Plot_No not to plot')
        end
    end
end
                                        
if 1==strcmp(TypeOfPlot,'Plot_Yes')         % Hold off of figure if plotted
hold off;
end

end

