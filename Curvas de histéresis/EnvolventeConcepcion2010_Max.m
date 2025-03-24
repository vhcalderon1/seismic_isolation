% =========================================================================
% HYSTERETIC BEHAVIOR ANALYSIS OF BASE ISOLATION SYSTEMS
% =========================================================================
% Author:       Victor Calderón (August 2020)
% Updated:      Jefferson De la Cuba (February 2025)
% --------------------------------------------------------------------------
%   Analyzes hysteretic behavior of base isolation systems through force-
%   displacement relationships. Calculates effective stiffness and equivalent
%   viscous damping ratio. Generates publication-ready hysteresis envelopes
%   with user-selected control points. Implements automatic file management
%   and memory optimization.
%
% Inputs:
%   1. Fuerza_aislamientototal_Concepcion2010_FuerteY.txt
%      - Experimental data file (displacement [mm], force [kN])
%      - Location: ../datasets/ (relative to code directory)
%   2. User interaction:
%      - 8 mouse-selected points (4 initial + 4 refined envelope points)
%
% Outputs:
%   1. Console:
%      - Effective stiffness (k_eff) [kN/m]
%      - Equivalent viscous damping ratio (ξ_eff) [%]
%   2. Figures:
%      - InitialPointSelection.png
%      - RefinedPointSelection.png
%      - HysteresisEnvelope.png
%      - Location: ../outputs/ (auto-created if non-existent)

%% Initialization
clear
close all
clc

%% File Management
% Configure output directory
output_dir = fullfile('..', 'outputs');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% ======================== DATA LOADING ================================
% Load experimental hysteresis data
data_file = fullfile('..', 'datasets', 'Fuerza_aislamientototal_Concepcion2010_FuerteY.txt');
hysteresis_data = load(data_file);

% Unit conversions
displacement_m = -hysteresis_data(:,1)/1000;  % mm -> m (SI units)
force_kN = hysteresis_data(:,2);              % Maintain kN force units

%% ====================== POINT SELECTION ===============================
% First stage: Initial envelope approximation
figure('Name', 'Initial Point Selection', 'Color', 'w')
plot(displacement_m, force_kN, 'b-', 'LineWidth', 1.2)
grid on
title({'Initial Envelope Approximation'; 'Select 4 Extreme Points (Clockwise)'})
xlabel('Displacement (m)')
ylabel('Force (kN)')
set(gca, 'FontSize', 10, 'FontName', 'Arial')

[initial_disp_points, initial_force_points] = ginput(4);
initial_disp_points = [initial_disp_points; initial_disp_points(1)];
initial_force_points = [initial_force_points; initial_force_points(1)];

% Save and close initial selection figure
print(fullfile(output_dir, 'InitialPointSelection'), '-dpng', '-r300')
close(gcf)

% Second stage: Refined envelope selection
figure('Name', 'Refined Point Selection', 'Color', 'w')
plot(displacement_m, force_kN, 'b-',...
     initial_disp_points, initial_force_points, 'r--', 'LineWidth', 1.2)
grid on
title({'Refined Envelope Selection'; 'Select 4 Final Points (Clockwise)'})
xlabel('Displacement (m)')
ylabel('Force (kN)')
set(gca, 'FontSize', 10, 'FontName', 'Arial')

[final_disp_points, final_force_points] = ginput(4);
final_disp_points = [final_disp_points; final_disp_points(1)];
final_force_points = [final_force_points; final_force_points(1)];

% Save and close refined selection figure
print(fullfile(output_dir, 'RefinedPointSelection'), '-dpng', '-r300')
close(gcf)

%% ============= HYSTERESIS PROPERTIES CALCULATION ======================
% Extract envelope coordinates
d = final_disp_points(1:4);  % Displacement coordinates [m]
f = final_force_points(1:4); % Force coordinates [kN]

% Effective stiffness (kN/m)
k_eff = (abs(f(1)) + abs(f(3))) / (abs(d(1)) + abs(d(3)));

% Energy dissipation (kN·m)
energy = abs((d(1)*f(2) + d(2)*f(3) + d(3)*f(4) + d(4)*f(1)) -...
           (f(1)*d(2) + f(2)*d(3) + f(3)*d(4) + f(4)*d(1))) / 2;

% Equivalent viscous damping ratio (%)
xi_eff = round(1/pi * energy / (k_eff * (abs(d(1))^2 + abs(d(3))^2)) * 100, 1);

% Display results
disp(['Effective Stiffness: ', num2str(k_eff), ' kN/m'])
disp(['Equivalent Viscous Damping: ', num2str(xi_eff), '%'])

%% ====================== FINAL VISUALIZATION ===========================
figure('Name', 'Hysteresis Envelope', 'Color', 'w',...
       'Position', [100 100 600 400])
hold on

% Plot configuration
plot(displacement_m, force_kN, '--', 'Color', [0.5 0.5 0.5],...
    'DisplayName', 'Experimental Data')
plot(final_disp_points, final_force_points, 'k-',...
    'LineWidth', 1.5, 'DisplayName', 'Hysteresis Envelope')
plot([-0.3 0.3], [0 0], 'k', 'HandleVisibility', 'off')
plot([0 0], [-800 800], 'k', 'HandleVisibility', 'off')

% Axis formatting
axis([-0.3 0.3 -800 800])
xticks(-0.3:0.1:0.3)
yticks(-800:400:800)
set(gca, 'LineWidth', 1.2,...
         'FontSize', 11,...
         'FontName', 'Times New Roman',...
         'XMinorTick', 'on',...
         'YMinorTick', 'on')

% Labels and legend
xlabel('Displacement (m)', 'FontSize', 12, 'FontWeight', 'bold')
ylabel('Force (kN)', 'FontSize', 12, 'FontWeight', 'bold')
legend('Location', 'southeast', 'Box', 'off')

% Save final figure
print(fullfile(output_dir, 'HysteresisEnvelope'), '-dpng', '-r300')
close(gcf)