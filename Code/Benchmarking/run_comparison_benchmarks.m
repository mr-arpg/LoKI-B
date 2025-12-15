% LoKI-B Grid Comparison Benchmarking Script
% This script runs benchmarking simulations comparing variable grid vs uniform grid
% performance for LoKI-B

clear all; close all; clc;

fprintf('=== LoKI-B Grid Comparison Benchmarking ===\n\n');

% Define parameter ranges for benchmarking
N_values = [50, 100, 200, 400, 800];  % cellNumber values
delta_u_values = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2];  % firstEnergyStep values

% Create output directory for results
if ~exist('Output/benchmark_comparison', 'dir')
    mkdir('Output/benchmark_comparison');
end

% Test 1: Variable Grid - Fixed delta u, varying N
fprintf('Test 1: Variable Grid - Fixed delta u = 1e-3 eV, varying N\n');
fprintf('==========================================================\n');

for i = 1:length(N_values)
    N = N_values(i);
    fprintf('Running variable grid simulation with N = %d...\n', N);
    
    % Read the template file
    fid = fopen('Input/benchmark/benchmark_fixed_delta_u.in', 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Replace cellNumber with current N value
    content = regexprep(content, 'cellNumber: \d+', sprintf('cellNumber: %d', N));
    
    % Write modified file
    temp_file = sprintf('Input/benchmark/benchmark_variable_fixed_delta_u_N%d.in', N);
    fid = fopen(temp_file, 'w');
    fprintf(fid, '%s', content);
    fclose(fid);
    
    % Run simulation
    try
        tic;
        [~, filename, ext] = fileparts(temp_file);
        lokibcl([filename ext]);
        sim_time = toc;
        
        % Copy results to organized folder
        output_folder = sprintf('Output/benchmark_comparison/variable_fixed_delta_u_N%d', N);
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

% Test 2: Uniform Grid - Fixed delta u, varying N
fprintf('Test 2: Uniform Grid - Fixed delta u, varying N\n');
fprintf('================================================\n');

for i = 1:length(N_values)
    N = N_values(i);
    fprintf('Running uniform grid simulation with N = %d...\n', N);
    
    % Read the template file
    fid = fopen('Input/benchmark/benchmark_uniform_fixed_delta_u.in', 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Replace cellNumber with current N value
    content = regexprep(content, 'cellNumber: \d+', sprintf('cellNumber: %d', N));
    
    % Write modified file
    temp_file = sprintf('Input/benchmark/benchmark_uniform_fixed_delta_u_N%d.in', N);
    fid = fopen(temp_file, 'w');
    fprintf(fid, '%s', content);
    fclose(fid);
    
    % Run simulation
    try
        tic;
        [~, filename, ext] = fileparts(temp_file);
        lokibcl([filename ext]);
        sim_time = toc;
        
        % Copy results to organized folder
        output_folder = sprintf('Output/benchmark_comparison/uniform_fixed_delta_u_N%d', N);
        if exist(output_folder, 'dir')
            rmdir(output_folder, 's');
        end
        movefile('Output/benchmark_uniform_fixed_delta_u', output_folder);
        
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

% Test 3: Variable Grid - Fixed N, varying delta u
fprintf('Test 3: Variable Grid - Fixed N = 200, varying delta u\n');
fprintf('======================================================\n');

for i = 1:length(delta_u_values)
    delta_u = delta_u_values(i);
    fprintf('Running variable grid simulation with delta u = %.1e eV...\n', delta_u);
    
    % Read the template file
    fid = fopen('Input/benchmark/benchmark_fixed_N.in', 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Replace firstEnergyStep with current delta u value
    content = regexprep(content, 'firstEnergyStep: [\d\.e-]+', sprintf('firstEnergyStep: %.1e', delta_u));
    
    % Write modified file
    temp_file = sprintf('Input/benchmark/benchmark_variable_fixed_N_delta_u_%s.in', num2str(delta_u, '%.0e'));
    fid = fopen(temp_file, 'w');
    fprintf(fid, '%s', content);
    fclose(fid);
    
    % Run simulation
    try
        tic;
        [~, filename, ext] = fileparts(temp_file);
        lokibcl([filename ext]);
        sim_time = toc;
        
        % Copy results to organized folder
        output_folder = sprintf('Output/benchmark_comparison/variable_fixed_N_delta_u_%s', num2str(delta_u, '%.0e'));
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

fprintf('\n');

% Test 4: Uniform Grid - Fixed N, varying grid spacing
fprintf('Test 4: Uniform Grid - Fixed N = 200, varying grid spacing\n');
fprintf('==========================================================\n');

for i = 1:length(delta_u_values)
    delta_u = delta_u_values(i);
    fprintf('Running uniform grid simulation with grid spacing = %.1e eV...\n', delta_u);
    
    % Read the template file
    fid = fopen('Input/benchmark/benchmark_uniform_fixed_N.in', 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % For uniform grid, we need to adjust maxEnergy to maintain similar resolution
    % Calculate maxEnergy based on delta_u and N=200
    maxEnergy = delta_u * 200;  % This gives us 200 cells with spacing delta_u
    
    % Replace maxEnergy
    content = regexprep(content, 'maxEnergy: [\d\.]+', sprintf('maxEnergy: %.1e', maxEnergy));
    
    % Write modified file
    temp_file = sprintf('Input/benchmark/benchmark_uniform_fixed_N_spacing_%s.in', num2str(delta_u, '%.0e'));
    fid = fopen(temp_file, 'w');
    fprintf(fid, '%s', content);
    fclose(fid);
    
    % Run simulation
    try
        tic;
        [~, filename, ext] = fileparts(temp_file);
        lokibcl([filename ext]);
        sim_time = toc;
        
        % Copy results to organized folder
        output_folder = sprintf('Output/benchmark_comparison/uniform_fixed_N_spacing_%s', num2str(delta_u, '%.0e'));
        if exist(output_folder, 'dir')
            rmdir(output_folder, 's');
        end
        movefile('Output/benchmark_uniform_fixed_N', output_folder);
        
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

fprintf('\n=== Grid Comparison Benchmarking completed ===\n');
fprintf('Results saved in Output/benchmark_comparison/\n');
fprintf('Run Benchmarking/analyze_grid_comparison.m or Benchmarking/analyze_all_benchmarks.m to analyze the results\n'); 