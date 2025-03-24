% ===========================================================================
% Displacement Orbit Analysis for Seismic Events
% ===========================================================================
% Author: Victor Calderón (August 2020)
% Updated: Jefferson De la Cuba (February 2025)
% --------------------------------------------------------------------------
% Compares theoretical and measured displacement orbits from earthquake data. 
% Theoretical orbits are defined as circles, while measured data is loaded 
% from external text files. Outputs include a formatted plot for visual comparison.
%
% INPUTS:
% - Orb_Desl_Concepcion_2010_Fuerte_Y.txt: Time-history displacement data 
%     with columns [time(s), X_disp(mm), Y_disp(mm)]. Located in ../datasets/.
%
% OUTPUTS:
% - Displacement_Orbit_Comparison.png: Plot comparing theoretical and 
%     measured displacement orbits. Saved to ../outputs/.

%% Clear Workspace and Figures
clear
close all
clc

%% ========== PARAMETERS & DATA LOADING ==========
% Define displacement orbit parameters
centerX = 0;                % X-coordinate of circle center [cm]
centerY = 0;                % Y-coordinate of circle center [cm]
radius = 29.6;              % Radius of theoretical displacement circle [cm]

% Configure input/output paths
inputFolder = '../datasets/';               
outputFolder = '../outputs/';             

% Create outputs directory if non-existent
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Load earthquake displacement data
inputFileName = 'Orb_Slip_Concepcion2010_Strong_Y.txt';
displacementData = load(fullfile(inputFolder, inputFileName)); % Columns: [time(s), X_disp(mm), Y_disp(mm)]

%% ========== DATA PROCESSING ==========
% Convert measurements to centimeters
displacementX = displacementData(:, 2)/10;            % X-disp [mm] → [cm]
displacementY = displacementData(:, 3)/10;            % Y-disp [mm] → [cm]

% Generate theoretical displacement coordinates
theta = 0:pi/50:2*pi;                                 
theoreticalX = radius * cos(theta) + centerX;         % Theoretical X [cm]
theoreticalY = radius * sin(theta) + centerY;         % Theoretical Y [cm]

%% ========== PLOTTING & VISUALIZATION ==========
figure
hold on

% Plot theoretical vs. measured displacement
theoryPlot = plot(theoreticalX, theoreticalY, 'k--', 'LineWidth', 1.5);
dataPlot = plot(displacementX, displacementY, 'k-', 'LineWidth', 1.5);

%% ========== PLOT FORMATTING ==========
axisLimits = [-35 35 -35 35];             % Axis limits [cm]
axis(axisLimits)
xticks(-30:10:30); yticks(-30:10:30);    % Tick spacing [cm]

set(gca, 'LineWidth', 1.5, 'FontSize', 12, 'FontName', 'Times New Roman', 'Box', 'off')
xlabel('\Delta_x [cm]', 'FontSize', 14, 'FontName', 'Times New Roman')
ylabel('\Delta_y [cm]', 'FontSize', 14, 'FontName', 'Times New Roman')

legend([theoryPlot, dataPlot],...
    {'Theoretical Displacement', 'Measured Displacement'},...
    'FontName', 'Times New Roman', 'FontSize', 14, 'Location', 'best', 'Box', 'off')

%% ========== FIGURE EXPORT ==========
% Configure and save figure
outputFileName = 'Displacement_Orbit_Comparison.png';
print(fullfile(outputFolder, outputFileName), '-dpng', '-r300')

% Close figure to prevent memory buildup
close(gcf)