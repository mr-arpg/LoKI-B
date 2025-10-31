function benchmark_grids()
    % Benchmark script to compare variable geometric grid vs uniform grid performance
    % in solving the Boltzmann equation
    
    % Initialize results storage
    results = struct();
    
    % Test 1: Accuracy vs N (Convergence Study)
    results.convergence = run_convergence_study();
    
    % Test 2: Performance for Target Accuracy
    results.performance = run_performance_test();
    
    % Test 3: Accuracy at Fixed N
    results.fixed_n = run_fixed_n_test();
    
    % Test 4: Sensitivity to Plasma Conditions
    results.plasma_conditions = run_plasma_conditions_test();
    
    % Test 5: Impact of Grid Parameters
    results.grid_params = run_grid_params_test();
    
    % Save results
    save('benchmark_results.mat', 'results');
    
    % Generate plots
    plot_results(results);
end

function results = run_convergence_study()
    % Test 1: Accuracy vs N (Convergence Study)
    
    % Define test parameters
    N_values = [50, 100, 200, 400, 800, 1600];
    E_N = 100; % Td
    gas = 'Ar';
    pressure = 133.32; % Pa
    
    % Initialize results structure
    results = struct();
    results.N_values = N_values;
    results.uniform = struct();
    results.variable = struct();
    
    % Run tests for each N value
    for i = 1:length(N_values)
        N = N_values(i);
        
        % Run uniform grid test
        [uniform_time, uniform_eedf, uniform_params] = run_single_test(N, E_N, gas, pressure, false);
        
        % Run variable grid test
        [variable_time, variable_eedf, variable_params] = run_single_test(N, E_N, gas, pressure, true);
        
        % Store results
        results.uniform.time(i) = uniform_time;
        results.uniform.eedf{i} = uniform_eedf;
        results.uniform.params(i) = uniform_params;
        
        results.variable.time(i) = variable_time;
        results.variable.eedf{i} = variable_eedf;
        results.variable.params(i) = variable_params;
    end
    
    % Calculate convergence metrics
    results.uniform.convergence = calculate_convergence_metrics(results.uniform);
    results.variable.convergence = calculate_convergence_metrics(results.variable);
end

function results = run_performance_test()
    % Test 2: Performance for Target Accuracy
    
    % Define target accuracy (e.g., 0.5% error in mean energy)
    target_error = 0.005;
    
    % Get reference solution (high N)
    N_ref = 1600;
    [~, ref_eedf, ref_params] = run_single_test(N_ref, 100, 'Ar', 133.32, false);
    
    % Find minimum N for each grid type to achieve target accuracy
    N_values = [50, 100, 200, 400, 800];
    results = struct();
    
    for i = 1:length(N_values)
        N = N_values(i);
        
        % Test uniform grid
        [uniform_time, uniform_eedf, uniform_params] = run_single_test(N, 100, 'Ar', 133.32, false);
        uniform_error = calculate_error_metrics(uniform_params, ref_params);
        
        % Test variable grid
        [variable_time, variable_eedf, variable_params] = run_single_test(N, 100, 'Ar', 133.32, true);
        variable_error = calculate_error_metrics(variable_params, ref_params);
        
        % Store results
        results.uniform.N(i) = N;
        results.uniform.time(i) = uniform_time;
        results.uniform.error(i) = uniform_error;
        
        results.variable.N(i) = N;
        results.variable.time(i) = variable_time;
        results.variable.error(i) = variable_error;
    end
end

function results = run_fixed_n_test()
    % Test 3: Accuracy at Fixed N
    
    % Use moderate N value
    N = 200;
    E_N = 100; % Td
    gas = 'Ar';
    pressure = 133.32; % Pa
    
    % Get reference solution
    [~, ref_eedf, ref_params] = run_single_test(1600, E_N, gas, pressure, false);
    
    % Run tests
    [uniform_time, uniform_eedf, uniform_params] = run_single_test(N, E_N, gas, pressure, false);
    [variable_time, variable_eedf, variable_params] = run_single_test(N, E_N, gas, pressure, true);
    
    % Calculate errors
    uniform_error = calculate_error_metrics(uniform_params, ref_params);
    variable_error = calculate_error_metrics(variable_params, ref_params);
    
    % Store results
    results = struct();
    results.uniform.time = uniform_time;
    results.uniform.eedf = uniform_eedf;
    results.uniform.params = uniform_params;
    results.uniform.error = uniform_error;
    
    results.variable.time = variable_time;
    results.variable.eedf = variable_eedf;
    results.variable.params = variable_params;
    results.variable.error = variable_error;
end

function results = run_plasma_conditions_test()
    % Test 4: Sensitivity to Plasma Conditions
    
    % Define test conditions
    E_N_values = [10, 100, 1000]; % Td
    gases = {'Ar', 'H2', 'NH3'};
    N = 200;
    
    results = struct();
    results.E_N_values = E_N_values;
    results.gases = gases;
    
    for i = 1:length(E_N_values)
        for j = 1:length(gases)
            E_N = E_N_values(i);
            gas = gases{j};
            
            % Run tests
            [uniform_time, uniform_eedf, uniform_params] = run_single_test(N, E_N, gas, 133.32, false);
            [variable_time, variable_eedf, variable_params] = run_single_test(N, E_N, gas, 133.32, true);
            
            % Store results
            results.uniform.time(i,j) = uniform_time;
            results.uniform.eedf{i,j} = uniform_eedf;
            results.uniform.params(i,j) = uniform_params;
            
            results.variable.time(i,j) = variable_time;
            results.variable.eedf{i,j} = variable_eedf;
            results.variable.params(i,j) = variable_params;
        end
    end
end

function results = run_grid_params_test()
    % Test 5: Impact of Grid Parameters
    
    % Define test parameters
    N = 200;
    E_N = 100; % Td
    gas = 'Ar';
    pressure = 133.32; % Pa
    
    % Test different grid parameters
    umin_values = [0, 0.1, 0.5];
    umax_values = [20, 30, 40];
    first_step_values = [0.1, 0.2, 0.5];
    
    results = struct();
    results.umin_values = umin_values;
    results.umax_values = umax_values;
    results.first_step_values = first_step_values;
    
    % Run tests for each parameter combination
    for i = 1:length(umin_values)
        for j = 1:length(umax_values)
            for k = 1:length(first_step_values)
                umin = umin_values(i);
                umax = umax_values(j);
                first_step = first_step_values(k);
                
                % Run variable grid test with these parameters
                [time, eedf, params] = run_single_test(N, E_N, gas, pressure, true, ...
                    'umin', umin, 'umax', umax, 'first_step', first_step);
                
                % Store results
                results.time(i,j,k) = time;
                results.eedf{i,j,k} = eedf;
                results.params(i,j,k) = params;
            end
        end
    end
end

function [time, eedf, params] = run_single_test(N, E_N, gas, pressure, is_variable, varargin)
    % Helper function to run a single test case
    
    % Create setup structure
    setup = struct();
    setup.workingConditions = struct();
    setup.workingConditions.reducedField = E_N;
    setup.workingConditions.gasPressure = pressure;
    setup.workingConditions.gasTemperature = 300;
    setup.workingConditions.electronDensity = 1e19;
    
    setup.electronKinetics = struct();
    setup.electronKinetics.isOn = true;
    setup.electronKinetics.eedfType = 'boltzmann';
    setup.electronKinetics.ionizationOperatorType = 'conservative';
    setup.electronKinetics.growthModelType = 'temporal';
    setup.electronKinetics.includeEECollisions = false;
    
    setup.electronKinetics.numerics = struct();
    setup.electronKinetics.numerics.energyGrid = struct();
    setup.electronKinetics.numerics.energyGrid.cellNumber = N;
    setup.electronKinetics.numerics.energyGrid.maxEnergy = 45;
    setup.electronKinetics.numerics.energyGrid.variableGrid = is_variable;
    
    if is_variable
        % Set variable grid parameters
        p = inputParser;
        addParameter(p, 'umin', 0);
        addParameter(p, 'umax', 45);
        addParameter(p, 'first_step', 0.1);
        parse(p, varargin{:});
        
        setup.electronKinetics.numerics.energyGrid.minEnergy = p.Results.umin;
        setup.electronKinetics.numerics.energyGrid.maxEnergy = p.Results.umax;
        setup.electronKinetics.numerics.energyGrid.firstEnergyStep = p.Results.first_step;
    end
    
    % Add gas properties
    setup.electronKinetics.gasProperties = struct();
    setup.electronKinetics.gasProperties.fraction = struct();
    setup.electronKinetics.gasProperties.fraction.(gas) = 1;
    
    % Create setup object
    setup_obj = Setup(setup);
    
    % Run simulation and measure time
    tic;
    setup_obj.run();
    time = toc;
    
    % Extract results
    eedf = setup_obj.electronKinetics.eedf;
    params = struct();
    params.meanEnergy = setup_obj.electronKinetics.meanEnergy;
    params.driftVelocity = setup_obj.electronKinetics.driftVelocity;
    params.diffusionCoefficient = setup_obj.electronKinetics.diffusionCoefficient;
    params.ionizationRate = setup_obj.electronKinetics.ionizationRate;
end

function metrics = calculate_convergence_metrics(results)
    % Calculate convergence metrics for a set of results
    
    % Use highest N result as reference
    ref_params = results.params(end);
    
    % Calculate relative errors for each N
    metrics = struct();
    metrics.meanEnergyError = zeros(size(results.N_values));
    metrics.driftVelocityError = zeros(size(results.N_values));
    metrics.diffusionError = zeros(size(results.N_values));
    metrics.ionizationRateError = zeros(size(results.N_values));
    
    for i = 1:length(results.N_values)
        metrics.meanEnergyError(i) = abs(results.params(i).meanEnergy - ref_params.meanEnergy) / ref_params.meanEnergy;
        metrics.driftVelocityError(i) = abs(results.params(i).driftVelocity - ref_params.driftVelocity) / ref_params.driftVelocity;
        metrics.diffusionError(i) = abs(results.params(i).diffusionCoefficient - ref_params.diffusionCoefficient) / ref_params.diffusionCoefficient;
        metrics.ionizationRateError(i) = abs(results.params(i).ionizationRate - ref_params.ionizationRate) / ref_params.ionizationRate;
    end
end

function error = calculate_error_metrics(params, ref_params)
    % Calculate error metrics between test parameters and reference parameters
    
    error = struct();
    error.meanEnergy = abs(params.meanEnergy - ref_params.meanEnergy) / ref_params.meanEnergy;
    error.driftVelocity = abs(params.driftVelocity - ref_params.driftVelocity) / ref_params.driftVelocity;
    error.diffusion = abs(params.diffusionCoefficient - ref_params.diffusionCoefficient) / ref_params.diffusionCoefficient;
    error.ionizationRate = abs(params.ionizationRate - ref_params.ionizationRate) / ref_params.ionizationRate;
end

function plot_results(results)
    % Generate plots from benchmark results
    
    % Plot convergence study results
    figure('Name', 'Convergence Study');
    
    % Mean energy convergence
    subplot(2,2,1);
    semilogx(results.convergence.N_values, results.convergence.uniform.convergence.meanEnergyError, 'b-o');
    hold on;
    semilogx(results.convergence.N_values, results.convergence.variable.convergence.meanEnergyError, 'r-o');
    xlabel('Number of Grid Points (N)');
    ylabel('Relative Error in Mean Energy');
    legend('Uniform Grid', 'Variable Grid');
    title('Mean Energy Convergence');
    
    % Drift velocity convergence
    subplot(2,2,2);
    semilogx(results.convergence.N_values, results.convergence.uniform.convergence.driftVelocityError, 'b-o');
    hold on;
    semilogx(results.convergence.N_values, results.convergence.variable.convergence.driftVelocityError, 'r-o');
    xlabel('Number of Grid Points (N)');
    ylabel('Relative Error in Drift Velocity');
    legend('Uniform Grid', 'Variable Grid');
    title('Drift Velocity Convergence');
    
    % Diffusion coefficient convergence
    subplot(2,2,3);
    semilogx(results.convergence.N_values, results.convergence.uniform.convergence.diffusionError, 'b-o');
    hold on;
    semilogx(results.convergence.N_values, results.convergence.variable.convergence.diffusionError, 'r-o');
    xlabel('Number of Grid Points (N)');
    ylabel('Relative Error in Diffusion Coefficient');
    legend('Uniform Grid', 'Variable Grid');
    title('Diffusion Coefficient Convergence');
    
    % Ionization rate convergence
    subplot(2,2,4);
    semilogx(results.convergence.N_values, results.convergence.uniform.convergence.ionizationRateError, 'b-o');
    hold on;
    semilogx(results.convergence.N_values, results.convergence.variable.convergence.ionizationRateError, 'r-o');
    xlabel('Number of Grid Points (N)');
    ylabel('Relative Error in Ionization Rate');
    legend('Uniform Grid', 'Variable Grid');
    title('Ionization Rate Convergence');
    
    % Plot performance results
    figure('Name', 'Performance Comparison');
    
    % Time vs Error
    subplot(1,2,1);
    semilogx(results.performance.uniform.error.meanEnergy, results.performance.uniform.time, 'b-o');
    hold on;
    semilogx(results.performance.variable.error.meanEnergy, results.performance.variable.time, 'r-o');
    xlabel('Relative Error in Mean Energy');
    ylabel('Computation Time (s)');
    legend('Uniform Grid', 'Variable Grid');
    title('Performance vs Accuracy');
    
    % N vs Time
    subplot(1,2,2);
    semilogx(results.performance.uniform.N, results.performance.uniform.time, 'b-o');
    hold on;
    semilogx(results.performance.variable.N, results.performance.variable.time, 'r-o');
    xlabel('Number of Grid Points (N)');
    ylabel('Computation Time (s)');
    legend('Uniform Grid', 'Variable Grid');
    title('Performance vs Grid Size');
    
    % Plot plasma conditions results
    figure('Name', 'Plasma Conditions Sensitivity');
    
    % Time vs E/N
    subplot(2,2,1);
    semilogx(results.plasma_conditions.E_N_values, mean(results.plasma_conditions.uniform.time, 2), 'b-o');
    hold on;
    semilogx(results.plasma_conditions.E_N_values, mean(results.plasma_conditions.variable.time, 2), 'r-o');
    xlabel('E/N (Td)');
    ylabel('Average Computation Time (s)');
    legend('Uniform Grid', 'Variable Grid');
    title('Performance vs E/N');
    
    % Time vs Gas
    subplot(2,2,2);
    bar([mean(results.plasma_conditions.uniform.time, 1); mean(results.plasma_conditions.variable.time, 1)]');
    xlabel('Gas');
    ylabel('Average Computation Time (s)');
    legend('Uniform Grid', 'Variable Grid');
    title('Performance vs Gas');
    
    % Plot grid parameters results
    figure('Name', 'Grid Parameters Impact');
    
    % Time vs Grid Parameters
    subplot(2,2,1);
    surf(results.grid_params.umin_values, results.grid_params.umax_values, ...
        mean(results.grid_params.time, 3));
    xlabel('Minimum Energy (eV)');
    ylabel('Maximum Energy (eV)');
    zlabel('Average Computation Time (s)');
    title('Performance vs Energy Range');
    
    % Time vs First Step
    subplot(2,2,2);
    plot(results.grid_params.first_step_values, squeeze(mean(mean(results.grid_params.time, 1), 2)), 'o-');
    xlabel('First Energy Step (eV)');
    ylabel('Average Computation Time (s)');
    title('Performance vs First Step Size');
end 