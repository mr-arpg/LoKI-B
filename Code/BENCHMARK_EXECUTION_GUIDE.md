# 🚀 Guia de Execução - Benchmarking LoKI-B

## 📋 Ordem de Execução

### 1️⃣ **Instalação e Verificação** (executar uma vez)

```matlab
test_benchmark_installation
```

Verifica se todos os ficheiros necessários existem.

---

### 2️⃣ **Gerar Cross Sections** (executar uma vez, ou quando alterar parâmetros)

```matlab
% Cross section Druyvesteyn (nu = const)
generate_druyvesteyn_cross_section

% Cross section Dummy (sigma ≈ 0, para teste e-e)
generate_dummy_elastic
```

**Saídas:**
- `Input/Druyvesteyn/constant_nu_elastic.txt`
- `Input/Dummy/H2_dummy_elastic.txt`

---

### 3️⃣ **Diagnóstico Druyvesteyn** (opcional, mas recomendado)

```matlab
diagnose_druyvesteyn
```

**Verifica:**
- ✓ Cross section tem ordem de grandeza correta
- ✓ Colision frequency ν é constante
- ✓ Gera gráficos de verificação

**Saída:** `Input/Druyvesteyn/cross_section_diagnostic.png`

---

### 4️⃣ **Executar Benchmarks Completos**

```matlab
run_all_benchmarks
```

**Executa 4 tipos de testes:**

1. **Grid Comparison** (14 testes)
   - Delta u fixo, N variável: 50, 100, 200, 400
   - N fixo, delta u variável: 5e-4, 1e-3, 5e-3

2. **Maxwellian Elastic** (2 testes)
   - E/N = 0, apenas colisões elásticas
   - Solução: Maxwellian a Tg = 300 K ≈ 0.0259 eV

3. **Maxwellian e-e** (2 testes)
   - E/N = 10 Td, apenas colisões e-e (gás ≈ 0)
   - Solução: Maxwellian a Te ≈ 1-2 eV

4. **Druyvesteyn** (2 testes)
   - E/N = 100 Td, colisões elásticas com nu=const
   - Solução: Druyvesteyn a Teff

**Saída:** `Output/Output/comprehensive_benchmark/`

---

### 5️⃣ **Analisar Resultados**

```matlab
analyze_all_benchmarks
```

**Gera:**
- Gráficos de convergência
- Comparações com soluções analíticas
- Erros relativos
- Relatório em texto

**Saídas:**
- `Output/comprehensive_benchmark/figures/*.png`
- `Output/comprehensive_benchmark/benchmark_report.txt`

---

### 6️⃣ **Teste de Eficiência** (opcional)

```matlab
run_efficiency_test
```

**Objetivo:** Encontrar o número mínimo de pontos na malha variável que mantém erro < 1% vs uniforme.

**Testa:**
- Uniforme: N = 1000 (fixo, referência)
- Variável: N = 1000, 800, 600, 400, 300, 250, 200 (100% → 20%)

**Saída:** `Output/efficiency_test/efficiency_test_analysis.png`

---

## 📊 Estrutura dos Testes

### Diferenças entre Testes Maxwellian

| Teste | E/N | Colisões Gás | Colisões e-e | Solução |
|-------|-----|--------------|--------------|---------|
| **Elastic** | 0 Td | **SIM** (H2_elastic) | NÃO | Maxwellian a **Tg ≈ 0.026 eV** |
| **e-e** | 10 Td | **NÃO** (dummy ≈ 0) | **SIM** | Maxwellian a **Te ≈ 1-2 eV** |

### Diferenças entre Soluções Analíticas

| Solução | Fórmula | Decaimento |
|---------|---------|------------|
| **Maxwellian** | `f₀ ∝ √u × exp(-u/T)` | Exponencial |
| **Druyvesteyn** | `f₀ ∝ √u × exp(-B×u²)` | Super-exponencial (mais rápido) |

---

## 🎯 Resultados Esperados

### Maxwellian Elastic (E/N=0)
- EEDF decai **exponencialmente** a partir de baixa energia
- Te ≈ Tg ≈ 0.026 eV (300 K)

### Maxwellian e-e (E/N=10 Td)
- EEDF decai **exponencialmente** mas com energia MAIOR
- Te ≈ 1-2 eV (aquecimento por campo + e-e collisions)
- **Diferente** do teste elastic!

### Druyvesteyn (E/N=100 Td)
- EEDF decai **super-exponencialmente** (cauda fina)
- Teff ≈ 2-3 eV
- **Diferente** de Maxwellian!

---

## ⚠️ Troubleshooting

### EEDFs aparecem como linhas horizontais
→ **Problema:** Cross section muito grande ou configuração errada  
→ **Solução:** Regenerar cross sections com parâmetros corretos

### Erro: "Vibrational distribution not normalized"
→ **Problema:** Usando `H2_LXCat.txt` (tem vibracionais) sem definir populações  
→ **Solução:** Usar `H2_elastic_LXCat.txt` (apenas elásticas)

### Testes Maxwellian dão resultados idênticos
→ **Problema:** Ambos configurados com E/N=0 e colisões elásticas  
→ **Solução:** Teste e-e deve ter E/N≠0 e cross section dummy

### "Zero found in interval [1, 3]"
→ **Não é erro!** É sucesso do `fzero` em encontrar o ratio 'a'

---

## 📁 Ficheiros Importantes

### Scripts de Execução
- `run_all_benchmarks.m` - Executa todos os benchmarks
- `analyze_all_benchmarks.m` - Analisa resultados
- `run_efficiency_test.m` - Teste de eficiência

### Scripts de Geração
- `generate_druyvesteyn_cross_section.m` - Cross section nu=const
- `generate_dummy_elastic.m` - Cross section dummy (≈0)

### Diagnóstico
- `test_benchmark_installation.m` - Verificação inicial
- `diagnose_druyvesteyn.m` - Diagnóstico cross section

### Funções Analíticas
- `analytical_maxwellian.m` - EEDF Maxwellian
- `analytical_druyvesteyn.m` - EEDF Druyvesteyn

### Input Files
- `Input/benchmark_maxwellian_elastic_*.in` - Teste Maxwellian elastic
- `Input/benchmark_maxwellian_ee_*.in` - Teste Maxwellian e-e
- `Input/benchmark_druyvesteyn_*.in` - Teste Druyvesteyn
- `Input/benchmark_fixed_*.in` - Grid comparison

---

## 🔬 Parâmetros Críticos

### Grid.m Restrições
```
firstEnergyStep × cellNumber < maxEnergy
```

Exemplo válido:
```yaml
firstEnergyStep: 1e-3
cellNumber: 1000
maxEnergy: 5
# 1e-3 × 1000 = 1 < 5 ✓
```

### Cross Section Values
- **H2 real**: ~1×10⁻¹⁹ m²
- **Druyvesteyn**: ~1×10⁻²¹ - 1×10⁻²⁰ m² (menor, OK)
- **Dummy**: ~1×10⁻³⁰ m² (desprezável)

---

**Última atualização:** 29 outubro 2025

