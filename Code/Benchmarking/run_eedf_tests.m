%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   EXECUTAR TESTES EEDF - UNIFORM vs VARIABLE GRID   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;

fprintf('=== INICIANDO TESTES EEDF ===\n');

test_files = {
    'Input/test_CAR_on_ee_off_uniform.in';
    'Input/test_CAR_on_ee_off_variable.in';
    'Input/test_CAR_off_ee_on_uniform.in';
    'Input/test_CAR_off_ee_on_variable.in';
    'Input/test_CAR_on_ee_on_uniform.in';
    'Input/test_CAR_on_ee_on_variable.in'
};

% % Verificar se o LoKI-B está disponível
% loki_command = 'lokibcl'; % Comando correto para LoKI-B
% [status, result] = system('lokibcl --version');
% if status ~= 0
%     fprintf('AVISO: Comando "lokibcl" não encontrado. Verifique se o LoKI-B está instalado e no PATH.\n');
%     error('LoKI-B não encontrado. Verifique a instalação.');
% end

fprintf('LoKI-B encontrado. Iniciando simulações...\n\n');

% Executar cada teste
for i = 1:length(test_files)
    input_file = test_files{i};
    
    % Verificar se o ficheiro existe
    if ~exist(input_file, 'file')
        fprintf('ERRO: Ficheiro %s não encontrado!\n', input_file);
        continue;
    end
    
    fprintf('Executando: %s\n', input_file);
    
    % Comando para executar LoKI-B
    % Extract just the filename without the Input/ prefix
    [~, filename, ext] = fileparts(input_file);
    tic;
    try
        lokibcl([filename ext]);
        execution_time = toc;
    catch ME
        execution_time = toc;
        fprintf('✗ ERRO na execução: %s\n', ME.message);
        continue;
    end
    
    fprintf('✓ Concluído em %.2f segundos\n', execution_time);
    
    fprintf('\n');
end

fprintf('=== TODOS OS TESTES CONCLUÍDOS ===\n');
fprintf('Executando análise de comparação...\n\n');

% Executar script de comparação
try
    compare_eedf_tests;
    fprintf('✓ Análise de comparação concluída!\n');
catch ME
    fprintf('✗ Erro na análise: %s\n', ME.message);
end

try
    fprintf('\n=== RESUMO ===\n');
    fprintf('Ficheiros de teste criados:\n');
    for i = 1:length(test_files)
        fprintf('  - %s\n', test_files{i});
    end
catch ME
    fprintf('Erro ao mostrar o resumo: %s\n', ME.message);
end

fprintf('\nPara executar manualmente:\n');
fprintf('  lokibcl test_CAR_on_ee_off_uniform.in\n');
fprintf('  lokibcl test_CAR_on_ee_off_variable.in\n');
fprintf('  lokibcl test_CAR_off_ee_on_uniform.in\n');
fprintf('  lokibcl test_CAR_off_ee_on_variable.in\n');
fprintf('  lokibcl test_CAR_on_ee_on_uniform.in\n');
fprintf('  lokibcl test_CAR_on_ee_on_variable.in\n');
fprintf('\nPara comparar resultados:\n');
fprintf('  compare_eedf_tests\n'); 