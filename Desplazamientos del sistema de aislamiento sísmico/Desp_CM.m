% ===========================================================================
% CENTER OF MASS DISPLACEMENT ANALYSIS FOR SEISMICALLY ISOLATED STRUCTURES
% ===========================================================================
% Author: Victor Calderón (February 2019)
% Updated: Jefferson De la Cuba (February 2025)
% ---------------------------------------------------------------------------
% % Calculates maximum center-of-mass (CoM) displacements from earthquake records.
% Processes X/Y displacement time histories to compute resultant magnitudes,
% generates displacement plots, and saves statistical results.
%
% Inputs: 
% - 7 earthquake record files in ../datasets/ (text files with 
%
% Outputs:
% - max_displacement_results.txt: Text file with average maximum displacement
% - 7 PNG figures: Displacement time histories for each earthquake record

%% Initialize Environment
clc; close all; clearvars;

% Configure paths using relative addressing
input_folder = fullfile('..', 'datasets');
output_folder = fullfile('..', 'outputs');

% Create outputs directory if non-existent
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
    fprintf('Created output directory: %s\n', output_folder);
end

%% Load Earthquake Records (Millimeter Data)
fprintf('Loading seismic records from: %s\n', input_folder);

% Peruvian Earthquakes
arequipa_data = load(fullfile(input_folder, 'CM_Arequipa2001_FuerY_nominal.txt'));
lima1966_data = load(fullfile(input_folder, 'CM_Lima1966_FuerY_nominal.txt')); 
lima1974_data = load(fullfile(input_folder, 'CM_Lima1974_FuerY_nominal.txt'));
pisco2007_data = load(fullfile(input_folder, 'CM_Pisco2007_FuerY_nominal.txt'));

% Chilean Earthquakes
concepcion2010_data = load(fullfile(input_folder, 'CM_Concepcion2010_FuerY_nominal.txt'));
curico2010_data = load(fullfile(input_folder, 'CM_Curico2010_FuerY_nominal.txt'));
hualane2010_data = load(fullfile(input_folder, 'CM_Hualane2010_FuerY_nominal.txt'));

%% Unit Conversion (mm → cm)
convert_to_cm = @(data) data / 10;

% Peruvian Records
x_arequipa = convert_to_cm(arequipa_data(:,1)); y_arequipa = convert_to_cm(arequipa_data(:,2));
x_lima1966 = convert_to_cm(lima1966_data(:,1)); y_lima1966 = convert_to_cm(lima1966_data(:,2));
x_lima1974 = convert_to_cm(lima1974_data(:,1)); y_lima1974 = convert_to_cm(lima1974_data(:,2));
x_pisco2007 = convert_to_cm(pisco2007_data(:,1)); y_pisco2007 = convert_to_cm(pisco2007_data(:,2));

% Chilean Records
x_concepcion = convert_to_cm(concepcion2010_data(:,1)); y_concepcion = convert_to_cm(concepcion2010_data(:,2));
x_curico = convert_to_cm(curico2010_data(:,1)); y_curico = convert_to_cm(curico2010_data(:,2));
x_hualane = convert_to_cm(hualane2010_data(:,1)); y_hualane = convert_to_cm(hualane2010_data(:,2));

%% Compute Resultant Displacements
compute_magnitude = @(x, y) sqrt(x.^2 + y.^2);

D_arequipa = compute_magnitude(x_arequipa, y_arequipa);
D_lima1966 = compute_magnitude(x_lima1966, y_lima1966);
D_lima1974 = compute_magnitude(x_lima1974, y_lima1974);
D_pisco2007 = compute_magnitude(x_pisco2007, y_pisco2007);
D_concepcion = compute_magnitude(x_concepcion, y_concepcion);
D_curico = compute_magnitude(x_curico, y_curico);
D_hualane = compute_magnitude(x_hualane, y_hualane);

%% Generate and Save Displacement Plots
earthquake_names = {'Arequipa2001', 'Lima1966', 'Lima1974', 'Pisco2007',...
                    'Concepcion2010', 'Curico2010', 'Hualane2010'};
displacements = {D_arequipa, D_lima1966, D_lima1974, D_pisco2007,...
                 D_concepcion, D_curico, D_hualane};

for idx = 1:length(earthquake_names)
    fig = figure('Visible', 'off');
    plot(displacements{idx}, 'LineWidth', 1.5);
    title(sprintf('CoM Displacement - %s', strrep(earthquake_names{idx}, '_', ' ')));
    xlabel('Time Step'); 
    ylabel('Displacement (cm)');
    grid on;
    
    % Save figure
    saveas(fig, fullfile(output_folder, sprintf('%s_displacement.png', earthquake_names{idx})));
    close(fig);
end

%% Calculate Maximum Displacements
max_displacements = cellfun(@max, displacements);
avg_max_displacement = mean(max_displacements);

% Display and save results
fprintf('\nAverage Maximum Displacement: %.2f cm\n', avg_max_displacement);

results_file = fullfile(output_folder, 'max_displacement_results.txt');
fid = fopen(results_file, 'w');
if fid ~= -1
    fprintf(fid, 'Seismic Isolation Performance Report\n');
    fprintf(fid, '------------------------------------\n');
    fprintf(fid, 'Average Maximum Displacement: %.2f cm\n', avg_max_displacement);
    fprintf(fid, '\nIndividual Event Maxima (cm):\n');
    fprintf(fid, [strjoin(earthquake_names, '\t'), '\n']);
    fprintf(fid, '%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n', max_displacements);
    fclose(fid);
else
    warning('Failed to save results file');
end

fprintf('\nAnalysis complete. Results saved to: %s\n', output_folder);