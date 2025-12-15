% Script to compare EEDFs from variable and uniform grids with fewer points
% This script runs both grid types and plots the EEDFs for comparison

clear; clc; close all;

% Parameters for comparison
N_variable = 50;  % Number of points for variable grid
N_uniform = 295;   % Number of points for uniform grid
maxEnergy = 20;    % Maximum energy in eV

fprintf('=== EEDF Grid Comparison ===\n');
fprintf('Variable grid: %d points\n', N_variable);
fprintf('Uniform grid: %d points\n', N_uniform);
fprintf('Max energy: %.1f eV\n\n', maxEnergy);

% Create output directory for comparison
output_dir = 'Output/eedf_comparison';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Run variable grid simulation
fprintf('Running variable grid simulation...\n');
variable_input = 'Input/eedf_variable_grid.in';
variable_output = fullfile(output_dir, 'variable_grid');

% Update input file with current parameters
update_input_file(variable_input, N_variable, maxEnergy);

% Run simulation
try
    % Extract just the filename without the Input/ prefix
    [~, filename, ext] = fileparts(variable_input);
    lokibcl([filename ext]);
    fprintf('Variable grid simulation completed.\n');
catch ME
    fprintf('Error running variable grid simulation: %s\n', ME.message);
    return;
end

% Run uniform grid simulation
fprintf('Running uniform grid simulation...\n');
uniform_input = 'Input/eedf_uniform_grid.in';
uniform_output = fullfile(output_dir, 'uniform_grid');

% Update input file with current parameters
update_input_file(uniform_input, N_uniform, maxEnergy);

% Run simulation
try
    % Extract just the filename without the Input/ prefix
    [~, filename, ext] = fileparts(uniform_input);
    lokibcl([filename ext]);
    fprintf('Uniform grid simulation completed.\n');
catch ME
    fprintf('Error running uniform grid simulation: %s\n', ME.message);
    return;
end

% Read and plot results
fprintf('Reading results and creating comparison plots...\n');

% Read EEDF data
variable_eedf_file = fullfile('Output', 'eedf_variable_grid', 'eedf.txt');
uniform_eedf_file = fullfile('Output', 'eedf_uniform_grid', 'eedf.txt');

if exist(variable_eedf_file, 'file') && exist(uniform_eedf_file, 'file')
    % Read EEDF data with space delimiter (the data appears to be space-separated)
    variable_data = readtable(variable_eedf_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    uniform_data = readtable(uniform_eedf_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    
    % Debug: check table dimensions
    fprintf('Variable data table size: %d rows, %d columns\n', height(variable_data), width(variable_data));
    fprintf('Uniform data table size: %d rows, %d columns\n', height(uniform_data), width(uniform_data));
    
    % Check if we have enough columns
    if width(variable_data) < 2 || width(uniform_data) < 2
        fprintf('Error: Not enough columns in EEDF files!\n');
        fprintf('Variable data columns: %d\n', width(variable_data));
        fprintf('Uniform data columns: %d\n', width(uniform_data));
        return;
    end
    
    % Extract energy and EEDF columns using hardcoded indices
    % Column 1: Energy(eV), Column 2: EEDF(eV^-(3/2)), Column 3: Anisotropy(eV^-(3/2))
    energy_var = variable_data{:, 1};
    eedf_var = variable_data{:, 2};
    energy_uni = uniform_data{:, 1};
    eedf_uni = uniform_data{:, 2};
    
    % Create comparison plot
    figure('Position', [100, 100, 1200, 800]);
    
    % Main EEDF plot
    subplot(2, 2, [1, 3]);
    semilogy(energy_var, eedf_var, 'b-', 'LineWidth', 2, 'DisplayName', 'Variable Grid');
    hold on;
    semilogy(energy_uni, eedf_uni, 'r--', 'LineWidth', 2, 'DisplayName', 'Uniform Grid');
    xlabel('Energy (eV)', 'FontSize', 12);
    ylabel('EEDF (arbitrary units)', 'FontSize', 12);
    title('EEDF Comparison: Variable vs Uniform Grid', 'FontSize', 14);
    legend('Location', 'best');
    grid on;
    
    % Difference plot
    subplot(2, 2, 2);
    % Interpolate to common energy grid for comparison
    common_energy = linspace(0, maxEnergy, 1000);
    eedf_var_interp = interp1(energy_var, eedf_var, common_energy, 'linear', 'extrap');
    eedf_uni_interp = interp1(energy_uni, eedf_uni, common_energy, 'linear', 'extrap');
    
    % Calculate relative difference
    rel_diff = (eedf_var_interp - eedf_uni_interp) ./ eedf_uni_interp * 100;
    plot(common_energy, rel_diff, 'k-', 'LineWidth', 1.5);
    xlabel('Energy (eV)', 'FontSize', 12);
    ylabel('Relative Difference (%)', 'FontSize', 12);
    title('Relative Difference: (Var - Uni) / Uni', 'FontSize', 12);
    grid on;
    yline(0, '--', 'Color', [0.5, 0.5, 0.5]);
    
    % Grid spacing comparison
    subplot(2, 2, 4);
    % Calculate grid spacing
    spacing_var = diff(energy_var);
    energy_centers_var = (energy_var(1:end-1) + energy_var(2:end)) / 2;
    spacing_uni = diff(energy_uni);
    energy_centers_uni = (energy_uni(1:end-1) + energy_uni(2:end)) / 2;
    
    plot(energy_centers_var, spacing_var, 'b-', 'LineWidth', 2, 'DisplayName', 'Variable Grid');
    hold on;
    plot(energy_centers_uni, spacing_uni, 'r--', 'LineWidth', 2, 'DisplayName', 'Uniform Grid');
    xlabel('Energy (eV)', 'FontSize', 12);
    ylabel('Grid Spacing (eV)', 'FontSize', 12);
    title('Grid Spacing Comparison', 'FontSize', 12);
    legend('Location', 'best');
    grid on;
    
    % Save plot
    saveas(gcf, fullfile(output_dir, 'eedf_comparison.png'));
    fprintf('Comparison plot saved to: %s\n', fullfile(output_dir, 'eedf_comparison.png'));
    
    % Print summary statistics
    fprintf('\n=== Summary Statistics ===\n');
    fprintf('Variable grid points: %d\n', length(energy_var));
    fprintf('Uniform grid points: %d\n', length(energy_uni));
    fprintf('Variable grid energy range: %.2f - %.2f eV\n', min(energy_var), max(energy_var));
    fprintf('Uniform grid energy range: %.2f - %.2f eV\n', min(energy_uni), max(energy_uni));
    fprintf('Max relative difference: %.2f%%\n', max(abs(rel_diff)));
    fprintf('Mean relative difference: %.2f%%\n', mean(abs(rel_diff)));
    
else
    fprintf('Error: EEDF files not found!\n');
    fprintf('Variable grid file: %s\n', variable_eedf_file);
    fprintf('Uniform grid file: %s\n', uniform_eedf_file);
end

fprintf('\nComparison completed!\n');

% Helper function to update input files
function update_input_file(input_file, N, maxEnergy)
    % Read the input file
    fid = fopen(input_file, 'r');
    if fid == -1
        error('Cannot open input file: %s', input_file);
    end
    
    content = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
    fclose(fid);
    lines = content{1};
    
    % Update parameters
    for i = 1:length(lines)
        line = lines{i};
        
        % Update number of points
        if contains(line, 'cellNumber:')
            lines{i} = sprintf('      cellNumber: %d                 %% Number of grid points', N);
        end
        
        % Update maximum energy
        if contains(line, 'maxEnergy:')
            lines{i} = sprintf('      maxEnergy: %.1f                 %% Maximum energy in eV', maxEnergy);
        end
    end
    
    % Write back to file
    fid = fopen(input_file, 'w');
    if fid == -1
        error('Cannot write to input file: %s', input_file);
    end
    
    for i = 1:length(lines)
        fprintf(fid, '%s\n', lines{i});
    end
    fclose(fid);
end 