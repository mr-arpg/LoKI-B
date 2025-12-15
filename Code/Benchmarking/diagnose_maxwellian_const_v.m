% ===============================================================
% diagnose_maxwellian_const_v.m
% Diagnóstico do teste Maxwellian (nu=const) - verificar cross section
% ===============================================================

clear; clc; close all;

fprintf('=== DIAGNÓSTICO MAXWELLIAN (nu=const) ===\n\n');

% Verificar se a cross section existe
cs_file = 'Input/Maxwellian_const_v/constant_nu_elastic.txt';
if ~exist(cs_file, 'file')
    error('Cross section não encontrada: %s', cs_file);
end

% Ler cross section
fprintf('1. Lendo cross section customizada...\n');
fid = fopen(cs_file, 'r');
content = char(fread(fid, '*char')');
fclose(fid);

% Extrair dados (pulando cabeçalho até encontrar "----")
lines = strsplit(content, '\n');
data_started = false;
energy_cs = [];
sigma_cs = [];

for i = 1:length(lines)
    line = strtrim(lines{i});
    if contains(line, '----')
        data_started = ~data_started;
        continue;
    end
    if data_started && ~isempty(line)
        vals = sscanf(line, '%e %e');
        if length(vals) == 2
            energy_cs = [energy_cs; vals(1)];
            sigma_cs = [sigma_cs; vals(2)];
        end
    end
end

% Garantir que são vetores linha
energy_cs = energy_cs(:)';
sigma_cs = sigma_cs(:)';

fprintf('   ✓ Lidos %d pontos\n', length(energy_cs));
fprintf('   Energia: %.3e - %.3e eV\n', min(energy_cs), max(energy_cs));
fprintf('   Sigma: %.3e - %.3e m²\n', min(sigma_cs), max(sigma_cs));

% Comparar com H2 real (valores típicos conhecidos)
fprintf('\n2. Comparando com valores típicos de H2...\n');
% H2 elastic cross section típica: ~1e-19 m² a energias baixas (0.1-1 eV)
sigma_h2_typical = 1e-19;  % m²
ratio_typical = sigma_cs / sigma_h2_typical;

fprintf('   H2 típico: ~%.3e m² (0.1-1 eV)\n', sigma_h2_typical);
fprintf('   Maxwellian_const_v: %.3e - %.3e m²\n', min(sigma_cs), max(sigma_cs));
fprintf('   Razão Maxwellian_const_v/H2: %.2f - %.2f\n', min(ratio_typical), max(ratio_typical));

if mean(sigma_cs) > 1e-19
    fprintf('   ⚠ AVISO: Cross section Maxwellian_const_v é %.1fx maior que H2 típico!\n', mean(sigma_cs)/sigma_h2_typical);
    fprintf('   Isto pode causar problemas numéricos.\n');
elseif mean(sigma_cs) < 1e-21
    fprintf('   ⚠ AVISO: Cross section Maxwellian_const_v é %.1fx menor que H2 típico.\n', sigma_h2_typical/mean(sigma_cs));
    fprintf('   Isto pode ser OK se for intencional.\n');
else
    fprintf('   ✓ Cross section Maxwellian_const_v está na ordem de grandeza correta!\n');
end

% Verificar nu = const
fprintf('\n3. Verificando nu = N*sigma*v = constante...\n');
me = 9.10938e-31;  % massa eletrão (kg)
eV_to_J = 1.60218e-19;
N = 3.54e22;  % densidade a 133.32 Pa, 300 K (m^-3)

energy_J = energy_cs * eV_to_J;
velocity = sqrt(2 * energy_J / me);
nu = N * sigma_cs .* velocity;

fprintf('   Nu mín: %.3e s^-1\n', min(nu));
fprintf('   Nu máx: %.3e s^-1\n', max(nu));
fprintf('   Nu médio: %.3e s^-1\n', mean(nu));
fprintf('   Variação relativa: %.2f%%\n', (max(nu)-min(nu))/mean(nu)*100);

if (max(nu)-min(nu))/mean(nu)*100 > 1
    fprintf('   ⚠ AVISO: Nu não é suficientemente constante!\n');
end

% Plot diagnóstico
figure('Position', [100, 100, 1400, 500]);

subplot(1,3,1);
loglog(energy_cs, sigma_cs, 'b-', 'LineWidth', 2, 'DisplayName', 'Maxwellian_const_v (nu=const)');
hold on;
% Linha de referência para H2 típico
plot([1e-3, 1e1], [sigma_h2_typical, sigma_h2_typical], 'r--', 'LineWidth', 1.5, 'DisplayName', 'H2 typical');
xlabel('Energy (eV)');
ylabel('Cross Section (m²)');
title('Cross Section: Maxwellian_const_v vs H2');
legend('Location', 'best');
grid on;
xlim([1e-3, 1e1]);

subplot(1,3,2);
semilogx(energy_cs, nu, 'g-', 'LineWidth', 2);
xlabel('Energy (eV)');
ylabel('Collision Frequency \nu (s^{-1})');
title('Collision Frequency: \nu = N\sigma v');
grid on;
yline(mean(nu), 'k--', 'Mean', 'LineWidth', 1);

subplot(1,3,3);
semilogx(energy_cs, (nu - mean(nu))/mean(nu)*100, 'r-', 'LineWidth', 2);
xlabel('Energy (eV)');
ylabel('Relative Deviation from Mean (%)');
title('\nu Constancy Check');
grid on;
yline(0, 'k--', 'LineWidth', 1);

saveas(gcf, 'Input/Maxwellian_const_v/cross_section_diagnostic.png');
fprintf('\n✓ Gráficos salvos em Input/Maxwellian_const_v/cross_section_diagnostic.png\n');

fprintf('\n=== DIAGNÓSTICO COMPLETO ===\n');

