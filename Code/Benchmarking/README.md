# 📊 Benchmarking Scripts

Esta pasta contém todos os scripts relacionados com benchmarking e testes de validação do LoKI-B.

## 🚀 Como Usar

**IMPORTANTE:** Execute os scripts a partir da raiz do projeto (`Code/`) para que os paths relativos funcionem corretamente.

### Opção 1: Executar com path completo

```matlab
% A partir da raiz do projeto
Benchmarking/run_all_benchmarks
Benchmarking/analyze_all_benchmarks
```

### Opção 2: Adicionar ao path (recomendado)

```matlab
% A partir da raiz do projeto
addpath('Benchmarking');
run_all_benchmarks
analyze_all_benchmarks
```

## 📁 Estrutura dos Ficheiros

### Scripts Principais
- `run_all_benchmarks.m` - Executa todos os benchmarks
- `analyze_all_benchmarks.m` - Analisa resultados
- `run_comparison_benchmarks.m` - Comparação de grids
- `run_benchmark_simulations.m` - Simulações de benchmark
- `run_efficiency_test.m` - Teste de eficiência

### Scripts de Teste
- `test_benchmark_installation.m` - Verifica instalação
- `test_single.m` - Teste simples
- `test_single_simulation.m` - Teste de simulação única
- `test_car_off.m` - Testes CAR off

### Geração de Cross Sections
- `generate_maxwellian_const_v_cross_section.m` - Cross section nu=const
- `generate_dummy_elastic.m` - Cross section dummy

### Análise e Comparação
- `analyze_benchmark_results.m` - Análise de resultados
- `analyze_grid_comparison.m` - Comparação de grids
- `compare_eedf_tests.m` - Comparação de EEDFs
- `compare_eedf_grids.m` - Comparação de grids EEDF
- `benchmark_grids.m` - Benchmark de grids

### Diagnóstico
- `diagnose_maxwellian_const_v.m` - Diagnóstico cross section

### Funções Analíticas
- `analytical_maxwellian.m` - EEDF Maxwellian
- `analytical_maxwellian_const_v.m` - EEDF Maxwellian (nu=const)

### Scripts Python
- `compare_grids.py` - Comparação de grids (low fields)
- `compare_grids_highfields.py` - Comparação de grids (high fields)

### Resultados/Figuras
- `grid_comparison_analysis.png` - Análise de comparação de grids
- `benchmark_convergence_analysis.png` - Análise de convergência

### Documentação
- `BENCHMARK_EXECUTION_GUIDE.md` - Guia completo de execução
- `README_eedf_tests.md` - Documentação dos testes EEDF

## 📖 Mais Informação

Consulte `BENCHMARK_EXECUTION_GUIDE.md` para instruções detalhadas sobre como executar os benchmarks.

