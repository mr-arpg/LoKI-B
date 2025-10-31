%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   COMPARAÇÃO EEDF - UNIFORM vs VARIABLE GRID   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; close all;

% Configurações dos testes
test_cases = {
    'CAR_ON_EE_OFF', 'CAR: on, e-e: off';
    'CAR_OFF_EE_ON', 'CAR: off, e-e: on';
    'CAR_ON_EE_ON', 'CAR: on, e-e: on'
};

% Cores para os gráficos
colors = lines(6);

figure('Position', [100, 100, 1200, 800]);

for i = 1:length(test_cases)
    case_name = test_cases{i, 1};
    case_description = test_cases{i, 2};
    
    % Caminhos dos ficheiros de saída
    uniform_file = sprintf('Output/test_%s_uniform/eedf.txt', case_name);
    variable_file = sprintf('Output/test_%s_variable/eedf.txt', case_name);
    
    % Verificar se os ficheiros existem
    if ~exist(uniform_file, 'file') || ~exist(variable_file, 'file')
        warning('Ficheiros não encontrados para caso: %s', case_name);
        continue;
    end
    
    % Carregar dados
    try
        uniform_data = readmatrix(uniform_file, 'NumHeaderLines', 1);
        variable_data = readmatrix(variable_file, 'NumHeaderLines', 1);
        
        % Extrair energia e EEDF
        energy_uniform = uniform_data(:, 1);
        eedf_uniform = uniform_data(:, 2);
        energy_variable = variable_data(:, 1);
        eedf_variable = variable_data(:, 2);
        
        % Debug: verificar se os dados foram carregados
        fprintf('Debug: %s - Uniform data size: %dx%d, Variable data size: %dx%d\n', ...
            case_name, size(uniform_data,1), size(uniform_data,2), ...
            size(variable_data,1), size(variable_data,2));
        
        % Debug: verificar valores da EEDF
        fprintf('Debug: %s - Uniform EEDF range: [%.2e, %.2e]\n', ...
            case_name, min(eedf_uniform), max(eedf_uniform));
        fprintf('Debug: %s - Variable EEDF range: [%.2e, %.2e]\n', ...
            case_name, min(eedf_variable), max(eedf_variable));
        
        % Subplot para cada caso
        subplot(2, 2, i);
        
        % Plot EEDF
        semilogy(energy_uniform, eedf_uniform, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Uniform (%d points)', length(energy_uniform)));
        hold on;
        semilogy(energy_variable, eedf_variable, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('Variable (%d points)', length(energy_variable)));
        
        % Configurar gráfico
        xlabel('U (eV)', 'FontSize', 12);
        ylabel('EEDF (eV^{-3/2})', 'FontSize', 12);
        title(case_description, 'FontSize', 14);
        legend('Location', 'best');
        grid on;
        
        % Configurar limites do eixo Y para consistência
        ylim_auto = ylim;
        if ylim_auto(1) < 1e-20
            ylim_auto(1) = 1e-20;
        end
        ylim(ylim_auto);
        
        % Forçar ticks do eixo Y para mostrar valores intermédios
        yticks(10.^[-7:0]);
        
        % Adicionar informação sobre delta u
        if length(energy_uniform) > 1 && length(energy_variable) > 1
            delta_u_uniform = mean(diff(energy_uniform));
            delta_u_variable_avg = mean(diff(energy_variable));
            delta_u_variable_max = max(diff(energy_variable));
            delta_u_variable_min = min(diff(energy_variable));
            
            % Verificar se os valores são válidos antes de mostrar
            if ~isnan(delta_u_uniform) && ~isnan(delta_u_variable_avg)
                text(0.02, 0.02, sprintf('Uniform \\Delta u = %.3f eV', delta_u_uniform), ...
                    'Units', 'normalized', 'VerticalAlignment', 'bottom', 'FontSize', 10);
                text(0.02, 0.08, sprintf('Variable \\Delta u_{min} = %.3f eV', delta_u_variable_min), ...
                    'Units', 'normalized', 'VerticalAlignment', 'bottom', 'FontSize', 10);
            else
                text(0.02, 0.02, 'Uniform \\Delta u = N/A', ...
                    'Units', 'normalized', 'VerticalAlignment', 'bottom', 'FontSize', 10);
                text(0.02, 0.08, 'Variable \\Delta u_{min} = N/A', ...
                    'Units', 'normalized', 'VerticalAlignment', 'bottom', 'FontSize', 10);
            end
        else
            text(0.02, 0.02, 'Uniform \\Delta u = N/A', ...
                'Units', 'normalized', 'VerticalAlignment', 'bottom', 'FontSize', 10);
            text(0.02, 0.08, 'Variable \\Delta u_{min} = N/A', ...
                'Units', 'normalized', 'VerticalAlignment', 'bottom', 'FontSize', 10);
        end
        
    catch ME
        warning('Erro ao carregar dados para caso %s: %s', case_name, ME.message);
    end
end

% Adicionar gráfico de comparação dos espaçamentos de energia
subplot(2, 2, 4);

% Carregar dados do primeiro caso para mostrar espaçamentos
case_name = test_cases{1, 1};
uniform_file = sprintf('Output/test_%s_uniform/eedf.txt', case_name);
variable_file = sprintf('Output/test_%s_variable/eedf.txt', case_name);

if exist(uniform_file, 'file') && exist(variable_file, 'file')
    uniform_data = readmatrix(uniform_file, 'NumHeaderLines', 1);
    variable_data = readmatrix(variable_file, 'NumHeaderLines', 1);
    
    energy_uniform = uniform_data(:, 1);
    energy_variable = variable_data(:, 1);
    
    % Calcular espaçamentos
    delta_u_uniform = diff(energy_uniform);
    delta_u_variable = diff(energy_variable);
    
    % Plot espaçamentos
    semilogy(energy_uniform(1:end-1), delta_u_uniform, 'b-', 'LineWidth', 2, 'DisplayName', 'Uniform');
    hold on;
    semilogy(energy_variable(1:end-1), delta_u_variable, 'r--', 'LineWidth', 2, 'DisplayName', 'Variable');
    
    xlabel('U (eV)', 'FontSize', 12);
    ylabel('\Delta u (eV)', 'FontSize', 12);
    title('Energy Spacing Comparison', 'FontSize', 14);
    legend('Location', 'best');
    grid on;
end

% Ajustar layout

% Salvar figura
saveas(gcf, 'plots/eedf_comparison_tests.png');
saveas(gcf, 'plots/eedf_comparison_tests.fig');

fprintf('Análise concluída. Gráficos salvos em plots/eedf_comparison_tests.png\n');

% Mostrar estatísticas resumidas
fprintf('\n=== ESTATÍSTICAS DOS TESTES ===\n');
for i = 1:length(test_cases)
    case_name = test_cases{i, 1};
    uniform_file = sprintf('Output/test_%s_uniform/eedf.txt', case_name);
    variable_file = sprintf('Output/test_%s_variable/eedf.txt', case_name);
    
    if exist(uniform_file, 'file') && exist(variable_file, 'file')
        uniform_data = readmatrix(uniform_file, 'NumHeaderLines', 1);
        variable_data = readmatrix(variable_file, 'NumHeaderLines', 1);
        
        energy_uniform = uniform_data(:, 1);
        energy_variable = variable_data(:, 1);
        
        delta_u_uniform = mean(diff(energy_uniform));
        delta_u_variable_avg = mean(diff(energy_variable));
        delta_u_variable_max = max(diff(energy_variable));
        delta_u_variable_min = min(diff(energy_variable));
        
        fprintf('\n%s:\n', case_name);
        fprintf('  Uniform: %d points, Delta u = %.4f eV\n', length(energy_uniform), delta_u_uniform);
        fprintf('  Variable: %d points, Delta u_avg = %.4f eV\n', length(energy_variable), delta_u_variable_avg);
        fprintf('  Variable: Delta u_max = %.4f eV, Delta u_min = %.4f eV\n', delta_u_variable_max, delta_u_variable_min);
        fprintf('  Point reduction: %.1f%%\n', (1 - length(energy_variable)/length(energy_uniform))*100);
    end
end 