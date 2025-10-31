% Teste específico para CAR_OFF_EE_ON
clear; clc;

fprintf('Testando CAR_OFF_EE_ON...\n');

try
    lokibcl('test_CAR_off_ee_on_uniform.in');
    fprintf('✓ CAR_OFF_EE_ON uniform bem-sucedido!\n');
catch ME
    fprintf('✗ Erro CAR_OFF_EE_ON uniform: %s\n', ME.message);
end

try
    lokibcl('test_CAR_off_ee_on_variable.in');
    fprintf('✓ CAR_OFF_EE_ON variable bem-sucedido!\n');
catch ME
    fprintf('✗ Erro CAR_OFF_EE_ON variable: %s\n', ME.message);
end 