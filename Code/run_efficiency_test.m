% ===============================================================
% run_efficiency_test.m
% Teste de eficiência da malha variável:
% Manter N fixo na malha uniforme, reduzir N na variável
% até encontrar o ponto onde a variável diverge da uniforme
% ===============================================================

clear; clc; close all;

fprintf('=================================================================\n');
fprintf('      TESTE DE EFICIÊNCIA: Variable vs Uniform Grid             \n');
fprintf('=================================================================\n\n');

% Configuração de referência (uniforme)
N_uniform = 1000;           % Número de pontos na malha uniforme (fixo)
maxEnergy = 5;              % Energia máxima (eV)
firstEnergyStep = 1e-3;     % Para malha variável

% Redução percentual de pontos na malha variável
% Testar de 100% (mesmo número) até 20% (80% menos pontos)
reduction_percentages = [100, 80, 60, 40, 30, 25, 20];

% Template para teste (usar benchmark_fixed_delta_u como base)
template_variable = 'Input/benchmark_fixed_delta_u.in';
template_uniform = 'Input/benchmark_uniform_fixed_delta_u.in';

% Diretório de saída
output_base = 'Output/efficiency_test';
if ~exist(output_base, 'dir')
    mkdir(output_base);
end

fprintf('Configuração:\n');
fprintf('  Malha UNIFORME: N = %d pontos (fixo)\n', N_uniform);
fprintf('  Malha VARIÁVEL: N = %d até %d pontos (%.0f%% até %.0f%%)\n', ...
    N_uniform, round(N_uniform * reduction_percentages(end)/100), ...
    reduction_percentages(1), reduction_percentages(end));
fprintf('  maxEnergy = %.1f eV, firstEnergyStep = %.1e eV\n\n', maxEnergy, firstEnergyStep);

% Executar malha uniforme de referência (apenas uma vez)
fprintf('=== REFERÊNCIA: Malha UNIFORME (N=%d) ===\n', N_uniform);
ref_folder = sprintf('%s/uniform_reference_N%d', output_base, N_uniform);
run_single_test(template_uniform, 'uniform', N_uniform, maxEnergy, 0, ref_folder);
fprintf('✓ Referência executada\n\n');

% Executar testes com malha variável em diferentes resoluções
fprintf('=== TESTES: Malha VARIÁVEL com pontos reduzidos ===\n\n');
results = struct();
results.N_uniform = N_uniform;
results.N_variable = [];
results.reduction_pct = [];
results.mean_energy_var = [];
results.drift_velocity_var = [];
results.power_balance_var = [];

for i = 1:length(reduction_percentages)
    pct = reduction_percentages(i);
    N_variable = round(N_uniform * pct / 100);
    
    fprintf('Teste %d/%d: Malha VARIÁVEL com N=%d (%.0f%% de pontos)...\n', ...
        i, length(reduction_percentages), N_variable, pct);
    
    output_folder = sprintf('%s/variable_N%d_pct%.0f', output_base, N_variable, pct);
    
    try
        run_single_test(template_variable, 'variable', N_variable, maxEnergy, firstEnergyStep, output_folder);
        
        % Ler resultados
        swarm_file = fullfile(output_folder, 'lookUpTableSwarm.txt');
        if exist(swarm_file, 'file')
            tbl = readtable(swarm_file, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
            results.N_variable(end+1) = N_variable;
            results.reduction_pct(end+1) = pct;
            results.mean_energy_var(end+1) = tbl{1, 9};
            results.drift_velocity_var(end+1) = tbl{1, 4};
            
            % Ler power balance
            pb_file = fullfile(output_folder, 'powerBalance.txt');
            if exist(pb_file, 'file')
                pb_data = readmatrix(pb_file, 'NumHeaderLines', 1);
                results.power_balance_var(end+1) = pb_data(1, 6);  % Relative error
            else
                results.power_balance_var(end+1) = NaN;
            end
        end
        
        fprintf('  ✓ OK - Mean E: %.4f eV, Drift v: %.2e m/s\n', ...
            results.mean_energy_var(end), results.drift_velocity_var(end));
    catch ME
        fprintf('  ✗ ERRO: %s\n', ME.message);
    end
end

% Ler resultados da referência uniforme
fprintf('\n=== Carregando resultados da referência ===\n');
swarm_file_ref = fullfile(ref_folder, 'lookUpTableSwarm.txt');
if exist(swarm_file_ref, 'file')
    tbl_ref = readtable(swarm_file_ref, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    results.mean_energy_uni = tbl_ref{1, 9};
    results.drift_velocity_uni = tbl_ref{1, 4};
    fprintf('  Uniforme: Mean E = %.4f eV, Drift v = %.2e m/s\n', ...
        results.mean_energy_uni, results.drift_velocity_uni);
else
    error('Resultados da referência não encontrados!');
end

% Calcular erros relativos
results.error_mean_energy = abs(results.mean_energy_var - results.mean_energy_uni) / results.mean_energy_uni * 100;
results.error_drift_velocity = abs(results.drift_velocity_var - results.drift_velocity_uni) / results.drift_velocity_uni * 100;

% Salvar resultados
save(fullfile(output_base, 'efficiency_test_results.mat'), 'results');

% Plot resultados
fprintf('\n=== Gerando gráficos ===\n');

figure('Position', [100, 100, 1400, 900]);

% Plot 1: Mean Energy vs N
subplot(2,3,1);
plot([N_uniform, N_uniform], [min(results.mean_energy_var)*0.95, max(results.mean_energy_var)*1.05], ...
    'k--', 'LineWidth', 1.5, 'DisplayName', 'Uniform Reference');
hold on;
plot(results.N_variable, results.mean_energy_var, 'bo-', 'LineWidth', 2, 'MarkerSize', 8, ...
    'DisplayName', 'Variable Grid');
yline(results.mean_energy_uni, 'r--', 'LineWidth', 2, 'DisplayName', 'Uniform Value');
xlabel('Number of Grid Points');
ylabel('Mean Energy (eV)');
title('Mean Energy vs Grid Resolution');
legend('Location', 'best');
grid on;

% Plot 2: Relative Error in Mean Energy
subplot(2,3,2);
semilogx(results.reduction_pct, results.error_mean_energy, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Variable Grid Points (% of Uniform)');
ylabel('Relative Error (%)');
title('Error in Mean Energy');
grid on;
yline(1, 'r--', '1% threshold', 'LineWidth', 1);
yline(5, 'r:', '5% threshold', 'LineWidth', 1);

% Plot 3: Drift Velocity vs N
subplot(2,3,4);
plot([N_uniform, N_uniform], [min(results.drift_velocity_var)*0.95, max(results.drift_velocity_var)*1.05], ...
    'k--', 'LineWidth', 1.5, 'DisplayName', 'Uniform Reference');
hold on;
plot(results.N_variable, results.drift_velocity_var, 'bo-', 'LineWidth', 2, 'MarkerSize', 8, ...
    'DisplayName', 'Variable Grid');
yline(results.drift_velocity_uni, 'r--', 'LineWidth', 2, 'DisplayName', 'Uniform Value');
xlabel('Number of Grid Points');
ylabel('Drift Velocity (m/s)');
title('Drift Velocity vs Grid Resolution');
legend('Location', 'best');
grid on;

% Plot 4: Relative Error in Drift Velocity
subplot(2,3,5);
semilogx(results.reduction_pct, results.error_drift_velocity, 'mo-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Variable Grid Points (% of Uniform)');
ylabel('Relative Error (%)');
title('Error in Drift Velocity');
grid on;
yline(1, 'r--', '1% threshold', 'LineWidth', 1);
yline(5, 'r:', '5% threshold', 'LineWidth', 1);

% Plot 5: Points reduction benefit
subplot(2,3,3);
point_reduction = (1 - results.N_variable / N_uniform) * 100;
plot(results.error_mean_energy, point_reduction, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Relative Error in Mean Energy (%)');
ylabel('Point Reduction (%)');
title('Efficiency: Error vs Point Reduction');
grid on;
xlim([0, max(results.error_mean_energy)*1.1]);

% Plot 6: Power balance
subplot(2,3,6);
if ~all(isnan(results.power_balance_var))
    semilogy(results.N_variable, abs(results.power_balance_var), 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('Number of Grid Points');
    ylabel('Power Balance Relative Error');
    title('Power Balance Convergence');
    grid on;
end

sgtitle('Variable Grid Efficiency Test', 'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, fullfile(output_base, 'efficiency_test_analysis.png'));
savefig(gcf, fullfile(output_base, 'efficiency_test_analysis.fig'));

fprintf('  ✓ Figuras salvas em: %s\n', output_base);

% Gerar relatório
fprintf('\n=== RELATÓRIO DE EFICIÊNCIA ===\n\n');
fprintf('Malha UNIFORME (referência): N = %d pontos\n', N_uniform);
fprintf('  Mean Energy: %.4f eV\n', results.mean_energy_uni);
fprintf('  Drift Velocity: %.4e m/s\n\n', results.drift_velocity_uni);

fprintf('Malha VARIÁVEL:\n');
fprintf('%-10s %-10s %-15s %-20s %-15s %-20s\n', ...
    'N', '% Uniform', 'Mean E (eV)', 'Error Mean E (%)', 'Drift v (m/s)', 'Error Drift v (%)');
fprintf('%-10s %-10s %-15s %-20s %-15s %-20s\n', ...
    repmat('-', 1, 10), repmat('-', 1, 10), repmat('-', 1, 15), ...
    repmat('-', 1, 20), repmat('-', 1, 15), repmat('-', 1, 20));

for i = 1:length(results.N_variable)
    fprintf('%-10d %-10.0f %-15.4f %-20.2f %-15.4e %-20.2f\n', ...
        results.N_variable(i), results.reduction_pct(i), ...
        results.mean_energy_var(i), results.error_mean_energy(i), ...
        results.drift_velocity_var(i), results.error_drift_velocity(i));
end

% Encontrar ponto ótimo (< 1% erro com máxima redução de pontos)
idx_good = find(results.error_mean_energy < 1 & results.error_drift_velocity < 1);
if ~isempty(idx_good)
    optimal_idx = idx_good(end);  % Menor N com erro < 1%
    fprintf('\n✓ PONTO ÓTIMO encontrado:\n');
    fprintf('  N = %d pontos (%.0f%% do uniforme)\n', ...
        results.N_variable(optimal_idx), results.reduction_pct(optimal_idx));
    fprintf('  Redução de pontos: %.1f%%\n', ...
        (1 - results.N_variable(optimal_idx)/N_uniform)*100);
    fprintf('  Erro em Mean Energy: %.2f%%\n', results.error_mean_energy(optimal_idx));
    fprintf('  Erro em Drift Velocity: %.2f%%\n', results.error_drift_velocity(optimal_idx));
else
    fprintf('\n⚠ Nenhum teste atingiu erro < 1%% em ambos os parâmetros\n');
end

fprintf('\n=================================================================\n');

% ===============================================================
% FUNÇÃO AUXILIAR
% ===============================================================

function run_single_test(template, grid_type, N, maxE, firstStep, output_folder)
    % Executa um teste individual
    
    % Ler template
    fid = fopen(template, 'r');
    if fid == -1
        error('Template não encontrado: %s', template);
    end
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Modificar parâmetros
    content = regexprep(content, 'cellNumber: \d+', sprintf('cellNumber: %d', N));
    content = regexprep(content, 'maxEnergy: [\d\.]+', sprintf('maxEnergy: %.1f', maxE));
    
    if strcmp(grid_type, 'variable')
        content = regexprep(content, 'firstEnergyStep: [\d\.e-]+', sprintf('firstEnergyStep: %.1e', firstStep));
    end
    
    % Modificar output folder
    content = regexprep(content, 'folder: \S+', sprintf('folder: %s', output_folder));
    
    % Criar arquivo temporário
    temp_file = sprintf('Input/temp_efficiency_%s_N%d.in', grid_type, N);
    fid = fopen(temp_file, 'w');
    fprintf(fid, '%s', content);
    fclose(fid);
    
    % Executar
    [~, filename, ext] = fileparts(temp_file);
    lokibcl([filename ext]);
    
    % Limpar
    delete(temp_file);
end

