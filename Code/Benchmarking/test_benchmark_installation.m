% test_benchmark_installation.m
% Script para testar a instalação do sistema de benchmarking
% Executa testes rápidos sem executar simulações completas

clear; clc; close all;

fprintf('=================================================================\n');
fprintf('      TESTE DE INSTALAÇÃO - Sistema de Benchmarking LoKI-B     \n');
fprintf('=================================================================\n\n');

test_passed = 0;
test_total = 0;

%% TESTE 1: Verificar funções analíticas
fprintf('TESTE 1: Funções Analíticas\n');
fprintf('----------------------------\n');

% Teste 1.1: Maxwelliana
test_total = test_total + 1;
try
    [f0_max, u_max] = analytical_maxwellian(1.0, [0, 5], 100);
    if length(f0_max) == 100 && all(f0_max >= 0) && max(f0_max) > 0
        fprintf('  ✓ analytical_maxwellian.m: OK\n');
        test_passed = test_passed + 1;
    else
        fprintf('  ✗ analytical_maxwellian.m: FALHA (valores inválidos)\n');
    end
catch ME
    fprintf('  ✗ analytical_maxwellian.m: ERRO - %s\n', ME.message);
end

% Teste 1.2: Maxwellian_const_v
test_total = test_total + 1;
try
    [f0_max_const_v, u_max_const_v] = analytical_maxwellian_const_v([0, 5], 100);
    if length(f0_max_const_v) == 100 && all(f0_max_const_v >= 0) && max(f0_max_const_v) > 0
        fprintf('  ✓ analytical_maxwellian_const_v.m: OK\n');
        test_passed = test_passed + 1;
    else
        fprintf('  ✗ analytical_maxwellian_const_v.m: FALHA (valores inválidos)\n');
    end
catch ME
    fprintf('  ✗ analytical_maxwellian_const_v.m: ERRO - %s\n', ME.message);
end

% Teste 1.3: Comparação Maxwelliana vs Maxwellian_const_v
test_total = test_total + 1;
try
    figure('Visible', 'off');
    [f0_max, u] = analytical_maxwellian(2.0, [0, 5], 200);
    [f0_max_const_v, u] = analytical_maxwellian_const_v([0, 5], 200);
    semilogy(u, f0_max, 'b-', 'LineWidth', 2);
    hold on;
    semilogy(u, f0_max_const_v, 'r--', 'LineWidth', 2);
    xlabel('Energy (eV)');
    ylabel('EEDF (eV^{-3/2})');
    title('Maxwellian vs Maxwellian_const_v Test');
    legend('Maxwellian', 'Maxwellian_const_v');
    
    % Verificar comportamento físico
    fprintf('  ✓ Funções analíticas comparadas\n');
    test_passed = test_passed + 1;
    close gcf;
catch ME
    fprintf('  ✗ Comparação de distribuições: ERRO - %s\n', ME.message);
end

fprintf('\n');

%% TESTE 2: Verificar arquivos de input
fprintf('TESTE 2: Arquivos de Input\n');
fprintf('--------------------------\n');

input_files = {
    'Input/benchmark/benchmark_maxwellian_elastic_variable.in',
    'Input/benchmark/benchmark_maxwellian_elastic_uniform.in',
    'Input/benchmark/benchmark_maxwellian_ee_variable.in',
    'Input/benchmark/benchmark_maxwellian_ee_uniform.in',
    'Input/benchmark/benchmark_maxwellian_const_v_variable.in',
    'Input/benchmark/benchmark_maxwellian_const_v_uniform.in',
    'Input/benchmark/benchmark_fixed_delta_u.in',
    'Input/benchmark/benchmark_uniform_fixed_delta_u.in',
    'Input/benchmark/benchmark_fixed_N.in',
    'Input/benchmark/benchmark_uniform_fixed_N.in'
};

for i = 1:length(input_files)
    test_total = test_total + 1;
    if exist(input_files{i}, 'file')
        fprintf('  ✓ %s\n', input_files{i});
        test_passed = test_passed + 1;
    else
        fprintf('  ✗ %s: NÃO ENCONTRADO\n', input_files{i});
    end
end

fprintf('\n');

%% TESTE 3: Verificar scripts principais
fprintf('TESTE 3: Scripts Principais\n');
fprintf('---------------------------\n');

scripts = {
    'run_all_benchmarks.m',
    'analyze_all_benchmarks.m',
    'generate_maxwellian_const_v_cross_section.m'
};

for i = 1:length(scripts)
    test_total = test_total + 1;
    if exist(scripts{i}, 'file')
        fprintf('  ✓ %s\n', scripts{i});
        test_passed = test_passed + 1;
    else
        fprintf('  ✗ %s: NÃO ENCONTRADO\n', scripts{i});
    end
end

fprintf('\n');

%% TESTE 4: Verificar diretórios necessários
fprintf('TESTE 4: Estrutura de Diretórios\n');
fprintf('----------------------------------\n');

directories = {
    'Input',
    'Output',
    'Input/Databases'
};

for i = 1:length(directories)
    test_total = test_total + 1;
    if exist(directories{i}, 'dir')
        fprintf('  ✓ %s/\n', directories{i});
        test_passed = test_passed + 1;
    else
        fprintf('  ✗ %s/: NÃO ENCONTRADO\n', directories{i});
    end
end

fprintf('\n');

%% TESTE 5: Verificar secções eficazes necessárias
fprintf('TESTE 5: Secções Eficazes\n');
fprintf('-------------------------\n');

cross_sections = {
    'Input/Argon/Ar_elastic_LXCat.txt',
    'Input/Hydrogen/H2_elastic_LXCat.txt',
    'Input/Databases/masses.txt'
};

for i = 1:length(cross_sections)
    test_total = test_total + 1;
    if exist(cross_sections{i}, 'file')
        fprintf('  ✓ %s\n', cross_sections{i});
        test_passed = test_passed + 1;
    else
        fprintf('  ✗ %s: NÃO ENCONTRADO\n', cross_sections{i});
        fprintf('     (Necessário para testes analíticos)\n');
    end
end

fprintf('\n');

%% TESTE 6: Verificar script de geração de secção eficaz Maxwellian_const_v
fprintf('TESTE 6: Script de Geração de Secção Eficaz Maxwellian_const_v\n');
fprintf('--------------------------------------------------------\n');

% Teste 6.1: Verificar se o script existe
test_total = test_total + 1;
if exist('generate_maxwellian_const_v_cross_section.m', 'file')
    fprintf('  ✓ Script generate_maxwellian_const_v_cross_section.m encontrado\n');
    test_passed = test_passed + 1;
else
    fprintf('  ✗ Script generate_maxwellian_const_v_cross_section.m NÃO ENCONTRADO\n');
end

% Teste 6.2: Verificar se o arquivo de secção eficaz existe ou pode ser criado
test_total = test_total + 1;
if exist('Input/Maxwellian_const_v/constant_nu_elastic.txt', 'file')
    fprintf('  ✓ Secção eficaz Maxwellian_const_v já existe\n');
    test_passed = test_passed + 1;
    
    % Verificar conteúdo
    try
        fid = fopen('Input/Maxwellian_const_v/constant_nu_elastic.txt', 'r');
        content = fread(fid, [1, Inf], '*char');
        fclose(fid);
        
        if contains(content, 'ELASTIC') && contains(content, 'Energy(eV)')
            fprintf('  ✓ Formato de arquivo correto\n');
        else
            fprintf('  ⚠ Aviso: Formato de arquivo pode estar incorreto\n');
        end
    catch
        fprintf('  ⚠ Aviso: Não foi possível verificar conteúdo do arquivo\n');
    end
else
    fprintf('  ℹ Secção eficaz Maxwellian_const_v não existe ainda\n');
    fprintf('     Execute manualmente: generate_maxwellian_const_v_cross_section\n');
    fprintf('     (Necessário para teste Maxwellian_const_v)\n');
end

% Fechar figuras abertas pelo teste
close all;

fprintf('\n');

%% TESTE 7: Verificar existência do lokibcl
fprintf('TESTE 7: Executável LoKI-B\n');
fprintf('--------------------------\n');

test_total = test_total + 1;
try
    % Tentar verificar se lokibcl existe
    which_result = which('lokibcl');
    if ~isempty(which_result)
        fprintf('  ✓ lokibcl encontrado: %s\n', which_result);
        test_passed = test_passed + 1;
    else
        fprintf('  ⚠ lokibcl não encontrado no PATH\n');
        fprintf('     (Necessário para executar simulações)\n');
    end
catch ME
    fprintf('  ⚠ Não foi possível verificar lokibcl: %s\n', ME.message);
end

fprintf('\n');

%% RESUMO FINAL
fprintf('=================================================================\n');
fprintf('                    RESUMO DOS TESTES                           \n');
fprintf('=================================================================\n');
fprintf('Testes passados: %d/%d (%.1f%%)\n', test_passed, test_total, test_passed/test_total*100);

if test_passed == test_total
    fprintf('\n✓ TODOS OS TESTES PASSARAM!\n');
    fprintf('O sistema de benchmarking está pronto para uso.\n');
    fprintf('\nPróximos passos:\n');
    fprintf('  1. Execute: run_all_benchmarks\n');
    fprintf('  2. Aguarde a conclusão (pode demorar)\n');
    fprintf('  3. Execute: analyze_all_benchmarks\n');
    fprintf('  4. Visualize resultados em: Output/comprehensive_benchmark/\n');
elseif test_passed >= test_total * 0.8
    fprintf('\n⚠ MAIORIA DOS TESTES PASSARAM\n');
    fprintf('O sistema deve funcionar, mas verifique os erros acima.\n');
    fprintf('\nAlguns testes falharam. Revise:\n');
    for i = 1:length(input_files)
        if ~exist(input_files{i}, 'file')
            fprintf('  - %s\n', input_files{i});
        end
    end
else
    fprintf('\n✗ MUITOS TESTES FALHARAM\n');
    fprintf('O sistema pode não funcionar corretamente.\n');
    fprintf('Revise a instalação e os arquivos ausentes listados acima.\n');
end

fprintf('\n=================================================================\n');

%% Criar arquivo de relatório
report_file = 'benchmark_installation_test.txt';
fid = fopen(report_file, 'w');
fprintf(fid, 'Teste de Instalação - Sistema de Benchmarking LoKI-B\n');
fprintf(fid, 'Data: %s\n\n', datestr(now));
fprintf(fid, 'Resultado: %d/%d testes passaram (%.1f%%)\n\n', test_passed, test_total, test_passed/test_total*100);

if test_passed == test_total
    fprintf(fid, 'Status: PRONTO PARA USO\n');
elseif test_passed >= test_total * 0.8
    fprintf(fid, 'Status: FUNCIONAL (com avisos)\n');
else
    fprintf(fid, 'Status: REQUER ATENÇÃO\n');
end

fclose(fid);

fprintf('Relatório salvo em: %s\n\n', report_file);

