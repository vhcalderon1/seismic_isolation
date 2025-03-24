%% ========================================================
% SEISMIC ISOLATION SYSTEM DESIGN CURVE GENERATOR
% ========================================================
% Author: Victor Calderón (August 2020)
% Updated: Jefferson De la Cuba (February 2025)
% ----------------------------------------------------------------------
% Description:
% Generates seismic design curves for base-isolated structures including
% base shear, superstructure shear, and displacement relationships.
% Implements NZS 1170.5 seismic provisions with customizable parameters.
%
% Inputs:
% - Configuration parameters defined in script (no external files required)
% - External datasets (if used) located in ../datasets/ directory (.txt)
%
% Outputs:
% - SeismicDesignCurves.png: Design curves plot
% - Auto-created ../outputs/ directory for results storage
% ========================================================

%% Initialization
clear
close all
clc

%% ========================
% DESIGN PARAMETERS SECTION
% =========================
%% Seismic Design Parameters (Limited Ductility Walls)
designPeriods = 1.5:0.01:4.5;   % Structural periods range (s)
zoneCoefficient = 0.45;          % Seismic zone coefficient
soilCoefficient = 1.05;          % Soil type coefficient
gravity = 981;                   % Gravitational acceleration (cm/s²)

%% Structural Configuration Factors
redundancyFactor = 1;            % Structural redundancy factor
isolatedBaseReduction = 1;       % Base isolation reduction factor
superstructureReduction = 1.5;   % Isolated superstructure reduction
nonIsolatedReduction = 4;        % Non-isolated structure reduction
heightIrregularity = 1;          % Vertical irregularity factor
planIrregularityIsolated = 1;    % Torsional irregularity (isolated)
planIrregularity = 0.75;         % Torsional irregularity (non-isolated)
shortPeriod = 0.6;               % Transition period Tp (s)
longPeriod = 2;                  % Transition period Tl (s)

%% Mass Properties
structuralWeight = 3800;         % Superstructure weight (kN)
totalWeight = 4815;              % Total system weight (kN)

%% Damping Parameters
targetDamping = 0.26;            % Equivalent viscous damping ratio
dampingReduction = 2.4;          % Acceleration reduction factor
displacementReduction = 2.1;     % Displacement reduction factor

%% =====================
% PATH CONFIGURATION
% =====================
% Configure output directory using path traversal
scriptFolder = fileparts(mfilename('fullpath'));
outputFolder = fullfile(scriptFolder, '..', 'outputs');

% Create outputs directory if non-existent
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder)
end
%% ======================
% SEISMIC ANALYSIS CALCULATIONS
% ======================
% Preallocate arrays for performance
numPeriods = length(designPeriods);
[pseudoAcceleration, displacement] = deal(zeros(numPeriods, 1));
[normalizedSuperstructureShear, baseShear] = deal(zeros(numPeriods, 1));
[minShear, accelerationResponse] = deal(zeros(numPeriods, 1));

for i = 1:numPeriods
    %% Base Isolation System Calculations
    % Compute spectral acceleration using ZUCS formula
    baseAcceleration = 1.5 * zoneCoefficient * redundancyFactor * soilCoefficient / ...
        (isolatedBaseReduction * heightIrregularity * planIrregularityIsolated);
    
    % Determine spectral shape factor C based on period
    currentPeriod = designPeriods(i);
    if currentPeriod <= 0.2*shortPeriod
        shapeFactor = 1 + 7.5*currentPeriod/shortPeriod;
    elseif currentPeriod <= shortPeriod
        shapeFactor = 2.5;
    elseif currentPeriod <= longPeriod
        shapeFactor = 2.5*shortPeriod/currentPeriod;
    else
        shapeFactor = 2.5*shortPeriod*longPeriod/currentPeriod^2;
    end
    
    % Store pseudo-acceleration and displacement values
    pseudoAcceleration(i) = baseAcceleration * shapeFactor * gravity;
    displacement(i) = pseudoAcceleration(i) * currentPeriod^2 / ...
        (4*pi^2 * displacementReduction);
    
    %% Superstructure Shear Calculations
    normalizedSuperstructureShear(i) = pseudoAcceleration(i)/(gravity * dampingReduction) * ...
        1/superstructureReduction * (structuralWeight/totalWeight)^(1-2.5*targetDamping);
    
    %% Non-Isolated Structure Comparison
    nonIsolatedAcceleration = zoneCoefficient * redundancyFactor * soilCoefficient / ...
        (nonIsolatedReduction * heightIrregularity * planIrregularity);
    
    % Determine spectral shape factor for non-isolated system
    if currentPeriod < shortPeriod
        shapeFactor = 2.5;
    elseif currentPeriod <= longPeriod
        shapeFactor = 2.5*shortPeriod/currentPeriod;
    else
        shapeFactor = 2.5*shortPeriod*longPeriod/currentPeriod^2;
    end
    
    % Apply minimum acceleration constraints
    accelerationResponse(i) = nonIsolatedAcceleration * shapeFactor;
    if accelerationResponse(i) <= 0.030
        accelerationResponse(i) = 0.030; % Absolute minimum shear
    end
    
    % Enforce minimum shear requirements
    minShear(i) = accelerationResponse(i);
    if normalizedSuperstructureShear(i) < minShear(i)
        normalizedSuperstructureShear(i) = minShear(i);
    end
    
    %% Base Shear Calculation
    baseShear(i) = pseudoAcceleration(i)/(gravity * dampingReduction);
end

% Apply 15% displacement increase for design
designDisplacement = displacement * 1.15;

%% =================
% PLOTTING SECTION
% =================
figureHandle = figure('Color', 'white', 'Units', 'centimeters', 'Position', [0 0 12.5 10]);

% Preallocate graphic objects array
plotHandles = gobjects(4,1);  

%% Primary Axis: Shear Forces (Blue Theme)
yyaxis left
plotHandles(1) = plot(designPeriods, baseShear, 'b-', 'LineWidth', 1.5, 'DisplayName','Base Shear (V_b)'); 
hold on
plotHandles(2) = plot(designPeriods, normalizedSuperstructureShear, 'b--', 'LineWidth', 1.5, 'DisplayName','Superstructure Shear (V_s)');

%% Secondary Axis: Displacements (Red Theme)
yyaxis right
plotHandles(3) = plot(designPeriods, displacement, 'r-', 'LineWidth', 1.5, 'DisplayName','Calculated Displacement (D_M)');
plotHandles(4) = plot(designPeriods, designDisplacement, 'r--', 'LineWidth', 1.5, 'DisplayName','Design Displacement (D_{TM})');

%% Axis Formatting
% Left axis
yyaxis left
ylabel('Normalized Design Shear, V/W', 'FontSize',12, 'FontName','Times New Roman', 'Color','b');
ylim([0 0.3])
yticks(0:0.05:0.3)
set(gca, 'YColor','b')

% Right axis
yyaxis right
ylabel('Isolation System Displacement (cm)', 'FontSize',12, 'FontName','Times New Roman', 'Color','r');

% Common properties
xlabel('Effective Period (s)', 'FontSize',14, 'FontName','Times New Roman');
xlim([1.5 4.5])
xticks(1.5:0.5:4.5)
box off
grid on

%% Legend Configuration
legend(plotHandles, 'Location','northeast',...
    'FontName','Times New Roman',...
    'FontSize',10,...
    'AutoUpdate','off'); % Prevent automatic additions

%% Decorative Elements (Added AFTER legend to prevent inclusion)
% Add baseline axes
hold on
yyaxis left
plot([1.5 4.5], [0 0], 'k:', 'LineWidth',0.5, 'HandleVisibility','off') % X-axis
plot([1.5 1.5], [0 0.3], 'k:', 'LineWidth',0.5, 'HandleVisibility','off') % Y-axis

%% ==================
% EXPORT SETTINGS
% ==================
% Set publication-quality dimensions
figureWidth = 12.5;  % cm
figureHeight = 10;    % cm

set(figureHandle, ...
    'PaperUnits', 'centimeters', ...
    'PaperSize', [figureWidth figureHeight], ...
    'PaperPositionMode', 'manual', ...
    'PaperPosition', [0 0 figureWidth figureHeight]);

%% Save Figure
outputFileName = fullfile(outputFolder, 'SeismicDesignCurves.png');
print(figureHandle, outputFileName, '-dpng', '-r300');
close(gcf);  % Close figure after saving

disp('Design curves successfully saved to outputs folder');