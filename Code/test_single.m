% Teste simples para verificar se o ficheiro funciona
clear; clc;

fprintf('Testando ficheiro...\n');

try
    lokibcl('test_CAR_on_ee_off_uniform.in');
    fprintf('✓ Teste bem-sucedido!\n');
catch ME
    fprintf('✗ Erro: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s:%d\n', ME.stack(i).name, ME.stack(i).line);
    end
end 