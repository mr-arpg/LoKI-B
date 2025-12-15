# Testes EEDF: Grelha Uniform vs Variável

Este conjunto de testes compara EEDFs (Electron Energy Distribution Functions) entre grelhas uniformes e variáveis para diferentes configurações de colisões.

## Configurações de Teste

### 1. CAR ON, E-E OFF
- **Descrição**: Apenas colisões CAR (Cumulative Angular Redistribution) ativas
- **Ficheiros**: 
  - `test_CAR_on_ee_off_uniform.in` - Grelha uniforme (295 pontos)
  - `test_CAR_on_ee_off_variable.in` - Grelha variável (80 pontos)

### 2. CAR OFF, E-E ON
- **Descrição**: Apenas colisões e-e (electron-electron) ativas
- **Ficheiros**:
  - `test_CAR_off_ee_on_uniform.in` - Grelha uniforme (295 pontos)
  - `test_CAR_off_ee_on_variable.in` - Grelha variável (80 pontos)

### 3. CAR ON, E-E ON
- **Descrição**: Ambos CAR e colisões e-e ativos
- **Ficheiros**:
  - `test_CAR_on_ee_on_uniform.in` - Grelha uniforme (295 pontos)
  - `test_CAR_on_ee_on_variable.in` - Grelha variável (80 pontos)

## Características das Grelhas

### Grelha Uniforme
- **Pontos**: 295
- **Espaçamento**: Constante (≈ 0.068 eV)
- **Energia máxima**: 20.0 eV

### Grelha Variável
- **Pontos**: 80 (73% menos pontos)
- **Espaçamento**: Progressão geométrica
- **Primeiro passo**: 0.001 eV
- **Energia máxima**: 20.0 eV
- **Vantagem**: Maior espaçamento no final da grelha

## Como Executar

### Execução Automática
```matlab
run_eedf_tests
```

### Execução Manual
```matlab
% Executar cada teste individualmente
lokibcl test_CAR_on_ee_off_uniform.in
lokibcl test_CAR_on_ee_off_variable.in
lokibcl test_CAR_off_ee_on_uniform.in
lokibcl test_CAR_off_ee_on_variable.in
lokibcl test_CAR_on_ee_on_uniform.in
lokibcl test_CAR_on_ee_on_variable.in
```

### Análise dos Resultados
```matlab
compare_eedf_tests
```

## Saídas

### Ficheiros de Saída
Cada teste gera ficheiros na pasta `Output/`:
- `eedf.txt` - Função de distribuição de energia dos eletrões
- `log.txt` - Log da simulação
- `swarmParameters.txt` - Parâmetros de swarm
- `rateCoefficients.txt` - Coeficientes de taxa
- `powerBalance.txt` - Balanço de potência
- `lookUpTable.txt` - Tabela de lookup

### Gráficos de Comparação
O script `compare_eedf_tests.m` gera:
- Comparação EEDF para cada configuração
- Comparação dos espaçamentos de energia
- Estatísticas de redução de pontos

## Objetivos dos Testes

1. **Eficiência Computacional**: Verificar se a grelha variável consegue reproduzir resultados similares com menos pontos
2. **Precisão**: Comparar EEDFs entre grelhas uniformes e variáveis
3. **Robustez**: Testar diferentes configurações de colisões
4. **Otimização**: Identificar onde a grelha variável é mais eficaz

## Análise dos Resultados

### Métricas Importantes
- **Redução de pontos**: ~73% menos pontos na grelha variável
- **Espaçamento médio**: Comparação entre uniforme e variável
- **Espaçamento máximo/mínimo**: Variação na grelha variável
- **Convergência**: Tempo de execução e precisão

### Interpretação
- Se as EEDFs forem similares, a grelha variável é eficaz
- Maior espaçamento no final da grelha deve reduzir custo computacional
- Diferentes configurações de colisões testam robustez

## Notas Técnicas

### Configurações Específicas
- **Campo reduzido**: 10 Td
- **Pressão**: 133.32 Pa
- **Gás**: H2 puro
- **Temperatura**: 300 K

### Parâmetros de Convergência
- **Erro máximo EEDF**: 1e-9
- **Erro máximo balanço de potência**: 1e-9
- **Algoritmo**: mixingDirectSolutions
- **Parâmetro de mistura**: 0.7

## Troubleshooting

### Problemas Comuns
1. **LoKI-B não encontrado**: Verificar instalação e PATH
2. **Ficheiros não encontrados**: Verificar se os ficheiros de entrada existem
3. **Erro de convergência**: Ajustar parâmetros de tolerância
4. **Memória insuficiente**: Reduzir número de pontos na grelha

### Logs de Debug
- Verificar ficheiros `log.txt` em cada pasta de saída
- Comparar tempos de execução entre uniforme e variável
- Analisar balanço de potência para verificar precisão 