% LoKI-B Benchmarking Script
% This script runs benchmarking simulations for variable grid performance
% comparing fixed delta u with varying N, and fixed N with varying delta u

clear all; close all; clc;

fprintf('=== LoKI-B Benchmarking Simulations ===\n\n');

% Define parameter ranges for benchmarking
N_values = [50, 100, 200, 400, 800];  % cellNumber values
delta_u_values = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2];  % firstEnergyStep values

% Create output directory for results
if ~exist('Output/benchmark_results', 'dir')
    mkdir('Output/benchmark_results');
end

% Test 1: Fixed delta u, varying N
fprintf('Test 1: Fixed delta u = 1e-3 eV, varying N\n');
fprintf('==========================================\n');

for i = 1:length(N_values)
    N = N_values(i);
    fprintf('Running simulation with N = %d...\n', N);
    
    % Read the template file
    fid = fopen('Input/benchmark_fixed_delta_u.in', 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Replace cellNumber with current N value
    content = regexprep(content, 'cellNumber: \d+', sprintf('cellNumber: %d', N));
    
    % Write modified file
    temp_file = sprintf('Input/benchmark_fixed_delta_u_N%d.in', N);
    fid = fopen(temp_file, 'w');
    fprintf(fid, '%s', content);
    fclose(fid);
    
    % Run simulation
    try
        tic;
        % Extract just the filename without the Input/ prefix
        [~, filename, ext] = fileparts(temp_file);
        lokibcl([filename ext]);
        sim_time = toc;
        
        % Copy results to organized folder
        output_folder = sprintf('Output/benchmark_results/fixed_delta_u_N%d', N);
        if exist(output_folder, 'dir')
            rmdir(output_folder, 's');
        end
        movefile('Output/benchmark_fixed_delta_u', output_folder);
        
        fprintf('  Completed in %.2f seconds\n', sim_time);
        
        % Clean up temporary file
        delete(temp_file);
        
    catch ME
        fprintf('  ERROR: %s\n', ME.message);
        if exist(temp_file, 'file')
            delete(temp_file);
        end
    end
end

fprintf('\n');

% Test 2: Fixed N, varying delta u
fprintf('Test 2: Fixed N = 200, varying delta u\n');
fprintf('======================================\n');

for i = 1:length(delta_u_values)
    delta_u = delta_u_values(i);
    fprintf('Running simulation with delta u = %.1e eV...\n', delta_u);
    
    % Read the template file
    fid = fopen('Input/benchmark_fixed_N.in', 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Replace firstEnergyStep with current delta u value
    content = regexprep(content, 'firstEnergyStep: [\d\.e-]+', sprintf('firstEnergyStep: %.1e', delta_u));
    
    % Write modified file
    temp_file = sprintf('Input/benchmark_fixed_N_delta_u_%s.in', num2str(delta_u, '%.0e'));
    fid = fopen(temp_file, 'w');
    fprintf(fid, '%s', content);
    fclose(fid);
    
    % Run simulation
    try
        tic;
        % Extract just the filename without the Input/ prefix
        [~, filename, ext] = fileparts(temp_file);
        lokibcl([filename ext]);
        sim_time = toc;
        
        % Copy results to organized folder
        output_folder = sprintf('Output/benchmark_results/fixed_N_delta_u_%s', num2str(delta_u, '%.0e'));
        if exist(output_folder, 'dir')
            rmdir(output_folder, 's');
        end
        movefile('Output/benchmark_fixed_N', output_folder);
        
        fprintf('  Completed in %.2f seconds\n', sim_time);
        
        % Clean up temporary file
        delete(temp_file);
        
    catch ME
        fprintf('  ERROR: %s\n', ME.message);
        if exist(temp_file, 'file')
            delete(temp_file);
        end
    end
end

fprintf('\n=== Benchmarking completed ===\n');
fprintf('Results saved in Output/benchmark_results/\n'); 