function [ KeepVector ] = PolarIndexFinder( CP, Radius, ThetaLimits, index_per_row, index_per_column, scan_res, index_res,TypeOfPlot)
%% Locate Indecies Using Polar Coordinates

% Description:  This function allows the user to obtain all indicies found
%               within a circular region. Both lower and upper bounds of
%               the radius and angle can be defined
%
% Creator:      Nate Matz
% Date:         7/19/2017
%
% Modification:
%
% Variables:
%   CP          - Center Point, Center of the desired circular region in mm
%   Radius      - Vector containing inner and outer radius (order not
%                 important).If the lower bound is not 0, a anulus is formed.
%   ThetaLimits - Upper and lower bounds for theta in degrees (order is
%                 important). The zero angle starts at right horizongal,
%                 and travels counterclockwise from 0-360. One can also enter
%                 in values from -180 to 180 with the zero at the same
%                 location. In the second case, values cannot exceed
%                 abs(180)
%   KeepVector  - Vector countaining all indecies within the desired region.
%   scan_len    - Length of c-scan in scanning direction.
%   scan_res    - Scanning resolution in scanning direction.
%   index_len   - Length of c-scan in indexing direction.
%   index_res   - Scanning resolution in indexing direction.


%% Preliminary Calculations
% Convert/Calculate parameters to indecies
CP_Scan=round(CP(1)/scan_res);              % Center point scan index number
CP_Index=round(CP(2)/index_res);            % Center point index index number
% index_per_row=scan_len/scan_res;              % Number of indecies per row
% index_per_column=index_len/index_res;         % Number of indecies per column

% Get bounds for Radius and Theta (in radians)
Radius_i=min(Radius);                       % InnerRadius
Radius_o=max(Radius);                       % OuterRadius

ThetaLimits_Radians=deg2rad(ThetaLimits);   % Convert to Radians
ThetaFirst=ThetaLimits_Radians(1);          % First Theta Value
ThetaLast=ThetaLimits_Radians(2);           % Second Theta Value

% Create meshgrid for all index points
[Scan_Val, Index_Val]=meshgrid(1:index_per_row,1:index_per_column);
%% Calculations based on user input
% Premis: the code goes through each location and checks the radius and
% theta requirments. This is all performed using matrix calculations. If
% the location satisfies the requirments, a value of 1 is assigned, if not,
% a value of 0 is assigned. This is done for both Radius (R) and angle
% (Theta). By summing both matricies results in a value for 2 that
% satisfies all requirments.

% Radius requirments
R=sqrt(((Scan_Val-CP_Scan)*scan_res).^2+((Index_Val-CP_Index)*index_res).^2);
R(R>Radius_o)=0;                            % Check upper bound
R(R<Radius_i)=0;                            % Check lower bound
if(Radius_i==0)
    R(CP_Index,CP_Scan)=1;                  % Satisfy center of circle
end
R(R>0)=1;                                   % Assign 1 to all kept points

% Angle requirments

if(ThetaFirst<0)                            % Acount for negative angles
    Theta=(atan2(Index_Val-CP_Index,Scan_Val-CP_Scan));
else
    Theta=wrapTo2Pi(atan2(Index_Val-CP_Index,Scan_Val-CP_Scan));
end

if(ThetaFirst<=0)                           % Check zero angle line
    Theta(Theta==0)=mean(ThetaLimits_Radians)+10^-4;
end

if(ThetaLast==0)                           % Check zero angle line
    Theta(Theta==0)=ThetaFirst+1/1000000;
end

if ThetaLast>ThetaFirst
    Theta(Theta>ThetaLast)=0;                   % Check theta upper bound
    Theta(Theta<ThetaFirst)=0;                  % Check theta lower bound
    Theta(abs(Theta)>0)=1;                      % Assign 1 to all kept points
    Theta(CP_Index,CP_Scan)=1;                  % Assign 1 to center point
else
    
    if ThetaFirst==pi/2 || ThetaFirst==pi ||ThetaFirst==3*pi/2
        Theta(Theta==ThetaFirst)=ThetaFirst+1/100000000;
    end
    Theta(Theta==1)=1+eps;
    Theta(Theta<ThetaLast)=1;                   % Check theta upper bound
    Theta(Theta>ThetaFirst)=1;                  % Check theta lower bound
    Theta(abs(Theta)~=1)=0;                      % Assign 1 to center point
    Theta(CP_Index,CP_Scan)=1;                  % Assign 1 to all kept points
end



%% Find locations that satisfy both radial and angular criteria
Solution=R+Theta;
[Rows,Columns]=find(Solution==2);           % Find Satisfied Locations
% Find vector of indicies
KeepVector=sort(sub2ind([index_per_row index_per_column],Columns,Rows));

%% Plot Scan Area Function

switch TypeOfPlot
    case 'Plot_Yes'
        scan_len=index_per_row*scan_res;
        index_len=index_per_column*index_res;
        figure(1941);plot(Columns*scan_res,Rows*index_res,'.');
        xlim([0,scan_len])
        ylim([0,index_len])
        axis equal
    case 'Plot_No'
    case 'Plot_On_Top'
        hold on
        plot(Columns*scan_res,Rows*index_res,'.');
        hold off
    otherwise
        % Error Message
        errordlg('Incorrect plotting input. The final function input should be Plot_Yes to plot and Plot_No not to plot')
end
end
