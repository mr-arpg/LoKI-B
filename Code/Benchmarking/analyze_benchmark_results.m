% LoKI-B Benchmark Results Analysis
% This script analyzes the results from the benchmarking simulations

clear all; close all; clc;

fprintf('=== LoKI-B Benchmark Results Analysis ===\n\n');

% Define parameter ranges used in benchmarking
N_values = [50, 100, 200, 400, 800];
delta_u_values = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2];

% Initialize arrays to store results
fixed_delta_u_results = struct();
fixed_N_results = struct();

% Test 1: Analyze fixed delta u results
fprintf('Analyzing fixed delta u results...\n');
for i = 1:length(N_values)
    N = N_values(i);
    result_folder = sprintf('Output/benchmark_results/fixed_delta_u_N%d', N);
    
    if exist(result_folder, 'dir')
        % Read swarm parameters from lookUpTableSwarm.txt
        swarm_file = fullfile(result_folder, 'lookUpTableSwarm.txt');
        if exist(swarm_file, 'file')
            % Read the tabular data
            data = readtable(swarm_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
            
            % Debug: check the actual number of columns
            if i == 1
                fprintf('Number of columns: %d\n', width(data));
                fprintf('Column names: ');
                for j = 1:width(data)
                    fprintf('%s ', data.Properties.VariableNames{j});
                end
                fprintf('\n');
            end
            
            % Hardcoded column indices based on lookUpTableSwarm.txt structure:
            % 1: RedField(Td), 2: RedDiff((ms)^-1), 3: RedMob((msV)^-1), 4: DriftVelocity(ms^-1)
            % 5: RedTow(m^2), 6: RedAtt(m^2), 7: RedDiffE(eV(ms)^-1), 8: RedMobE(eV(msV)^-1)
            % 9: MeanE(eV), 10: CharE(eV), 11: EleTemp(eV)
            
            % Store key parameters (take the first row since we only have one E/N value)
            fixed_delta_u_results(i).N = N;
            fixed_delta_u_results(i).mean_energy = data{1, 9};  % MeanE(eV) - column 9
            fixed_delta_u_results(i).drift_velocity = data{1, 4};  % DriftVelocity(ms^-1) - column 4
            fixed_delta_u_results(i).diffusion_coeff = data{1, 2};  % RedDiff((ms)^-1) - column 2
            
            fprintf('  N=%d: Mean Energy=%.3f eV, Drift Velocity=%.2e m/s\n', ...
                N, fixed_delta_u_results(i).mean_energy, fixed_delta_u_results(i).drift_velocity);
        end
    end
end

fprintf('\n');

% Test 2: Analyze fixed N results
fprintf('Analyzing fixed N results...\n');
for i = 1:length(delta_u_values)
    delta_u = delta_u_values(i);
    result_folder = sprintf('Output/benchmark_results/fixed_N_delta_u_%s', num2str(delta_u, '%.0e'));
    
    if exist(result_folder, 'dir')
        % Read swarm parameters from lookUpTableSwarm.txt
        swarm_file = fullfile(result_folder, 'lookUpTableSwarm.txt');
        if exist(swarm_file, 'file')
            % Read the tabular data with flexible delimiter
            data = readtable(swarm_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
            
            % Hardcoded column indices based on lookUpTableSwarm.txt structure:
            % 1: RedField(Td), 2: RedDiff((ms)^-1), 3: RedMob((msV)^-1), 4: DriftVelocity(ms^-1)
            % 5: RedTow(m^2), 6: RedAtt(m^2), 7: RedDiffE(eV(ms)^-1), 8: RedMobE(eV(msV)^-1)
            % 9: MeanE(eV), 10: CharE(eV), 11: EleTemp(eV)
            
            % Store key parameters (take the first row since we only have one E/N value)
            fixed_N_results(i).delta_u = delta_u;
            fixed_N_results(i).mean_energy = data{1, 9};  % MeanE(eV) - column 9
            fixed_N_results(i).drift_velocity = data{1, 4};  % DriftVelocity(ms^-1) - column 4
            fixed_N_results(i).diffusion_coeff = data{1, 2};  % RedDiff((ms)^-1) - column 2
            
            fprintf('  delta_u=%.1e: Mean Energy=%.3f eV, Drift Velocity=%.2e m/s\n', ...
                delta_u, fixed_N_results(i).mean_energy, fixed_N_results(i).drift_velocity);
        end
    end
end

% Create comparison plots
figure('Position', [100, 100, 1200, 800]);

% Define all arrays at the beginning
N_array = [fixed_delta_u_results.N];
mean_energy_array = [fixed_delta_u_results.mean_energy];
drift_vel_array = [fixed_delta_u_results.drift_velocity];

delta_u_array = [fixed_N_results.delta_u];
mean_energy_array2 = [fixed_N_results.mean_energy];
drift_vel_array2 = [fixed_N_results.drift_velocity];

% Plot 1: Fixed delta u - Convergence with N
subplot(2,3,1);
plot(N_array, mean_energy_array, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('N (cellNumber)');
ylabel('Mean Energy (eV)');
title('Fixed \Delta u: Mean Energy vs N');
grid on;

subplot(2,3,2);
plot(N_array, drift_vel_array, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('N (cellNumber)');
ylabel('Drift Velocity (m/s)');
title('Fixed \Delta u: Drift Velocity vs N');
grid on;

% Plot 2: Relative differences for convergence analysis
subplot(2,3,3);
if length(mean_energy_array) > 1
    rel_diff_energy = abs(diff(mean_energy_array) ./ mean_energy_array(1:end-1)) * 100;
    semilogy(N_array(1:end-1), rel_diff_energy, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('N (cellNumber)');
    ylabel('Relative Difference (%)');
    title('Fixed \Delta u: Energy Convergence');
    grid on;
end

subplot(2,3,4);
if length(mean_energy_array2) > 1
    rel_diff_energy2 = abs(diff(mean_energy_array2) ./ mean_energy_array2(1:end-1)) * 100;
    semilogy(delta_u_array(1:end-1), rel_diff_energy2, 'mo-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('\Delta u (eV)');
    ylabel('Relative Difference (%)');
    title('Fixed N: Energy Convergence');
    grid on;
end

% Plot 3: Fixed N - Convergence with delta u
subplot(2,3,5);
semilogx(delta_u_array, mean_energy_array2, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('\Delta u (eV)');
ylabel('Mean Energy (eV)');
title('Fixed N: Mean Energy vs \Delta u');
grid on;

subplot(2,3,6);
semilogx(delta_u_array, drift_vel_array2, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('\Delta u (eV)');
ylabel('Drift Velocity (m/s)');
title('Fixed N: Drift Velocity vs \Delta u');
grid on;

% Save figure
saveas(gcf, 'benchmark_convergence_analysis.png');
fprintf('\nAnalysis complete! Figure saved as benchmark_convergence_analysis.png\n');

% Print summary statistics
fprintf('\n=== Summary Statistics ===\n');
fprintf('Fixed delta u (1e-3 eV):\n');
fprintf('  N range: %d to %d\n', min(N_array), max(N_array));
fprintf('  Mean energy range: %.3f to %.3f eV\n', min(mean_energy_array), max(mean_energy_array));
fprintf('  Drift velocity range: %.2e to %.2e m/s\n', min(drift_vel_array), max(drift_vel_array));

fprintf('\nFixed N (200):\n');
fprintf('  delta u range: %.1e to %.1e eV\n', min(delta_u_array), max(delta_u_array));
fprintf('  Mean energy range: %.3f to %.3f eV\n', min(mean_energy_array2), max(mean_energy_array2));
fprintf('  Drift velocity range: %.2e to %.2e m/s\n', min(drift_vel_array2), max(drift_vel_array2)); 