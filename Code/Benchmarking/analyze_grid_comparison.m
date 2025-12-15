% LoKI-B Grid Comparison Analysis
% This script analyzes and compares variable grid vs uniform grid performance

clear all; close all; clc;

fprintf('=== LoKI-B Grid Comparison Analysis ===\n\n');

% Define parameter ranges used in benchmarking
N_values = [50, 100, 200, 400, 800];
delta_u_values = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2];

% Initialize arrays to store results
variable_fixed_delta_u_results = struct();
uniform_fixed_delta_u_results = struct();
variable_fixed_N_results = struct();
uniform_fixed_N_results = struct();

% Test 1: Analyze variable grid fixed delta u results
fprintf('Analyzing variable grid fixed delta u results...\n');
for i = 1:length(N_values)
    N = N_values(i);
    result_folder = sprintf('Output/benchmark_comparison/variable_fixed_delta_u_N%d', N);
    
    if exist(result_folder, 'dir')
        % Read swarm parameters from lookUpTableSwarm.txt
        swarm_file = fullfile(result_folder, 'lookUpTableSwarm.txt');
        if exist(swarm_file, 'file')
            % Read the tabular data with flexible delimiter
            data = readtable(swarm_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
            
            % Store key parameters (take the first row since we only have one E/N value)
            variable_fixed_delta_u_results(i).N = N;
            variable_fixed_delta_u_results(i).mean_energy = data{1, 9};  % MeanE(eV) - column 9
            variable_fixed_delta_u_results(i).drift_velocity = data{1, 4};  % DriftVelocity(ms^-1) - column 4
            variable_fixed_delta_u_results(i).diffusion_coeff = data{1, 2};  % RedDiff((ms)^-1) - column 2
            
            fprintf('  N=%d: Mean Energy=%.3f eV, Drift Velocity=%.2e m/s\n', ...
                N, variable_fixed_delta_u_results(i).mean_energy, variable_fixed_delta_u_results(i).drift_velocity);
        end
    end
end

fprintf('\n');

% Test 2: Analyze uniform grid fixed delta u results
fprintf('Analyzing uniform grid fixed delta u results...\n');
for i = 1:length(N_values)
    N = N_values(i);
    result_folder = sprintf('Output/benchmark_comparison/uniform_fixed_delta_u_N%d', N);
    
    if exist(result_folder, 'dir')
        % Read swarm parameters from lookUpTableSwarm.txt
        swarm_file = fullfile(result_folder, 'lookUpTableSwarm.txt');
        if exist(swarm_file, 'file')
            % Read the tabular data with flexible delimiter
            data = readtable(swarm_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
            
            % Store key parameters (take the first row since we only have one E/N value)
            uniform_fixed_delta_u_results(i).N = N;
            uniform_fixed_delta_u_results(i).mean_energy = data{1, 9};  % MeanE(eV) - column 9
            uniform_fixed_delta_u_results(i).drift_velocity = data{1, 4};  % DriftVelocity(ms^-1) - column 4
            uniform_fixed_delta_u_results(i).diffusion_coeff = data{1, 2};  % RedDiff((ms)^-1) - column 2
            
            fprintf('  N=%d: Mean Energy=%.3f eV, Drift Velocity=%.2e m/s\n', ...
                N, uniform_fixed_delta_u_results(i).mean_energy, uniform_fixed_delta_u_results(i).drift_velocity);
        end
    end
end

fprintf('\n');

% Test 3: Analyze variable grid fixed N results
fprintf('Analyzing variable grid fixed N results...\n');
for i = 1:length(delta_u_values)
    delta_u = delta_u_values(i);
    result_folder = sprintf('Output/benchmark_comparison/variable_fixed_N_delta_u_%s', num2str(delta_u, '%.0e'));
    
    if exist(result_folder, 'dir')
        % Read swarm parameters from lookUpTableSwarm.txt
        swarm_file = fullfile(result_folder, 'lookUpTableSwarm.txt');
        if exist(swarm_file, 'file')
            % Read the tabular data with flexible delimiter
            data = readtable(swarm_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
            
            % Store key parameters (take the first row since we only have one E/N value)
            variable_fixed_N_results(i).delta_u = delta_u;
            variable_fixed_N_results(i).mean_energy = data{1, 9};  % MeanE(eV) - column 9
            variable_fixed_N_results(i).drift_velocity = data{1, 4};  % DriftVelocity(ms^-1) - column 4
            variable_fixed_N_results(i).diffusion_coeff = data{1, 2};  % RedDiff((ms)^-1) - column 2
            
            fprintf('  delta_u=%.1e: Mean Energy=%.3f eV, Drift Velocity=%.2e m/s\n', ...
                delta_u, variable_fixed_N_results(i).mean_energy, variable_fixed_N_results(i).drift_velocity);
        end
    end
end

fprintf('\n');

% Test 4: Analyze uniform grid fixed N results
fprintf('Analyzing uniform grid fixed N results...\n');
for i = 1:length(delta_u_values)
    delta_u = delta_u_values(i);
    result_folder = sprintf('Output/benchmark_comparison/uniform_fixed_N_spacing_%s', num2str(delta_u, '%.0e'));
    
    if exist(result_folder, 'dir')
        % Read swarm parameters from lookUpTableSwarm.txt
        swarm_file = fullfile(result_folder, 'lookUpTableSwarm.txt');
        if exist(swarm_file, 'file')
            % Read the tabular data with flexible delimiter
            data = readtable(swarm_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
            
            % Store key parameters (take the first row since we only have one E/N value)
            uniform_fixed_N_results(i).delta_u = delta_u;
            uniform_fixed_N_results(i).mean_energy = data{1, 9};  % MeanE(eV) - column 9
            uniform_fixed_N_results(i).drift_velocity = data{1, 4};  % DriftVelocity(ms^-1) - column 4
            uniform_fixed_N_results(i).diffusion_coeff = data{1, 2};  % RedDiff((ms)^-1) - column 2
            
            fprintf('  spacing=%.1e: Mean Energy=%.3f eV, Drift Velocity=%.2e m/s\n', ...
                delta_u, uniform_fixed_N_results(i).mean_energy, uniform_fixed_N_results(i).drift_velocity);
        end
    end
end

% Create comparison plots
figure('Position', [100, 100, 1400, 1000]);

% Define all arrays
N_array = [variable_fixed_delta_u_results.N];
variable_mean_energy_array = [variable_fixed_delta_u_results.mean_energy];
variable_drift_vel_array = [variable_fixed_delta_u_results.drift_velocity];
uniform_mean_energy_array = [uniform_fixed_delta_u_results.mean_energy];
uniform_drift_vel_array = [uniform_fixed_delta_u_results.drift_velocity];

delta_u_array = [variable_fixed_N_results.delta_u];
variable_mean_energy_array2 = [variable_fixed_N_results.mean_energy];
variable_drift_vel_array2 = [variable_fixed_N_results.drift_velocity];
uniform_mean_energy_array2 = [uniform_fixed_N_results.mean_energy];
uniform_drift_vel_array2 = [uniform_fixed_N_results.drift_velocity];

% Plot 1: Fixed delta u - Mean Energy comparison
subplot(2,3,1);
plot(N_array, variable_mean_energy_array, 'bo-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Variable Grid');
hold on;
plot(N_array, uniform_mean_energy_array, 'rs-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Uniform Grid');
xlabel('N (cellNumber)');
ylabel('Mean Energy (eV)');
title('Fixed \Delta u: Mean Energy vs N');
legend('Location', 'best');
grid on;

% Plot 2: Fixed delta u - Drift Velocity comparison
subplot(2,3,2);
plot(N_array, variable_drift_vel_array, 'bo-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Variable Grid');
hold on;
plot(N_array, uniform_drift_vel_array, 'rs-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Uniform Grid');
xlabel('N (cellNumber)');
ylabel('Drift Velocity (m/s)');
title('Fixed \Delta u: Drift Velocity vs N');
legend('Location', 'best');
grid on;

% Plot 3: Fixed delta u - Relative difference comparison
subplot(2,3,3);
if length(variable_mean_energy_array) > 1
    variable_rel_diff = abs(diff(variable_mean_energy_array) ./ variable_mean_energy_array(1:end-1)) * 100;
    uniform_rel_diff = abs(diff(uniform_mean_energy_array) ./ uniform_mean_energy_array(1:end-1)) * 100;
    
    semilogy(N_array(1:end-1), variable_rel_diff, 'go-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Variable Grid');
    hold on;
    semilogy(N_array(1:end-1), uniform_rel_diff, 'ms-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Uniform Grid');
    xlabel('N (cellNumber)');
    ylabel('Relative Difference (%)');
    title('Fixed \Delta u: Energy Convergence');
    legend('Location', 'best');
    grid on;
end

% Plot 4: Fixed N - Mean Energy comparison
subplot(2,3,4);
semilogx(delta_u_array, variable_mean_energy_array2, 'bo-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Variable Grid');
hold on;
semilogx(delta_u_array, uniform_mean_energy_array2, 'rs-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Uniform Grid');
xlabel('\Delta u (eV)');
ylabel('Mean Energy (eV)');
title('Fixed N: Mean Energy vs \Delta u');
legend('Location', 'best');
grid on;

% Plot 5: Fixed N - Drift Velocity comparison
subplot(2,3,5);
semilogx(delta_u_array, variable_drift_vel_array2, 'bo-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Variable Grid');
hold on;
semilogx(delta_u_array, uniform_drift_vel_array2, 'rs-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Uniform Grid');
xlabel('\Delta u (eV)');
ylabel('Drift Velocity (m/s)');
title('Fixed N: Drift Velocity vs \Delta u');
legend('Location', 'best');
grid on;

% Plot 6: Fixed N - Relative difference comparison
subplot(2,3,6);
if length(variable_mean_energy_array2) > 1
    variable_rel_diff2 = abs(diff(variable_mean_energy_array2) ./ variable_mean_energy_array2(1:end-1)) * 100;
    uniform_rel_diff2 = abs(diff(uniform_mean_energy_array2) ./ uniform_mean_energy_array2(1:end-1)) * 100;
    
    semilogy(delta_u_array(1:end-1), variable_rel_diff2, 'go-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Variable Grid');
    hold on;
    semilogy(delta_u_array(1:end-1), uniform_rel_diff2, 'ms-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Uniform Grid');
    xlabel('\Delta u (eV)');
    ylabel('Relative Difference (%)');
    title('Fixed N: Energy Convergence');
    legend('Location', 'best');
    grid on;
end

% Save figure
saveas(gcf, 'grid_comparison_analysis.png');
fprintf('\nAnalysis complete! Figure saved as grid_comparison_analysis.png\n');

% Print summary statistics
fprintf('\n=== Grid Comparison Summary ===\n');
fprintf('Variable Grid - Fixed delta u (1e-3 eV):\n');
fprintf('  N range: %d to %d\n', min(N_array), max(N_array));
fprintf('  Mean energy range: %.3f to %.3f eV\n', min(variable_mean_energy_array), max(variable_mean_energy_array));
fprintf('  Drift velocity range: %.2e to %.2e m/s\n', min(variable_drift_vel_array), max(variable_drift_vel_array));

fprintf('\nUniform Grid - Fixed delta u:\n');
fprintf('  N range: %d to %d\n', min(N_array), max(N_array));
fprintf('  Mean energy range: %.3f to %.3f eV\n', min(uniform_mean_energy_array), max(uniform_mean_energy_array));
fprintf('  Drift velocity range: %.2e to %.2e m/s\n', min(uniform_drift_vel_array), max(uniform_drift_vel_array));

fprintf('\nVariable Grid - Fixed N (200):\n');
fprintf('  delta u range: %.1e to %.1e eV\n', min(delta_u_array), max(delta_u_array));
fprintf('  Mean energy range: %.3f to %.3f eV\n', min(variable_mean_energy_array2), max(variable_mean_energy_array2));
fprintf('  Drift velocity range: %.2e to %.2e m/s\n', min(variable_drift_vel_array2), max(variable_drift_vel_array2));

fprintf('\nUniform Grid - Fixed N (200):\n');
fprintf('  spacing range: %.1e to %.1e eV\n', min(delta_u_array), max(delta_u_array));
fprintf('  Mean energy range: %.3f to %.3f eV\n', min(uniform_mean_energy_array2), max(uniform_mean_energy_array2));
fprintf('  Drift velocity range: %.2e to %.2e m/s\n', min(uniform_drift_vel_array2), max(uniform_drift_vel_array2)); 