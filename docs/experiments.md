# Metodologia Experimental e Guia de Reprodutibilidade

Este documento descreve como reproduzir a avaliação experimental do framework L2i. São detalhadas as dimensões experimentais, modos de execução, cenários (S1/S2), parâmetros, scripts e o fluxo exato necessário para obter os resultados apresentados no artigo.

O objetivo é garantir **transparência experimental total e reprodutibilidade**, em conformidade com as boas práticas do SBRC.

---

## 1. Dimensões Experimentais

A avaliação do L2i é estruturada ao longo de **dois eixos experimentais ortogonais**.

### 1.1 Comportamento do Plano de Controle

- **baseline**: comportamento tradicional de L2, sem adaptação declarativa.
- **adapt**: L2i habilitado, com especificações declarativas conduzindo a adaptação dinâmica.

### 1.2 Realismo do Backend

- **mock**: backends emulados (execução lógica, sem aplicação no kernel ou plano de dados).
- **real**: aplicação efetiva usando Linux `tc/HTB`, NETCONF/sysrepo ou P4/bmv2.

Isso resulta em quatro modos experimentais:

| Modo | Controle | Backend | Propósito |
|------|----------|---------|-----------|
| baseline + mock | Estático | Emulado | Referência lógica |
| baseline + real | Estático | Real | Baseline tradicional de L2 |
| adapt + mock | Adaptativo | Emulado | Validação da DSL |
| adapt + real | Adaptativo | Real | Avaliação fim a fim |

---

## 2. Visão Geral dos Cenários

### 2.1 Cenário S1 — Unicast Multidomínio com Restrições de QoS

**Objetivo:**
Avaliar como o L2i adapta fluxos unicast em múltiplos domínios de L2 sob condições de congestionamento.

**Propriedades principais:**

- Três domínios (A, B, C)
- Fluxos concorrentes de melhor esforço e prioritários
- Restrições declarativas sobre:
  - Largura de banda mínima
  - Latência máxima
  - Nível de prioridade

**Arquivos relevantes:**

- `dsl/scenarios/multidomain_s1.py`
- `dsl/specs/valid/s1_unicast_qos.json`

---

### 2.2 Cenário S2 — Multicast Orientado à Origem

**Objetivo:**
Avaliar a capacidade do L2i de gerenciar árvores multicast dinamicamente com base em requisitos orientados à origem e heterogeneidade dos receptores.

**Propriedades principais:**

- Eventos dinâmicos de join/leave
- Restrições de QoS específicas por receptor
- Replicação seletiva e poda dinâmica

**Arquivos relevantes:**

- `dsl/scenarios/multicast_s2.py`
- `dsl/specs/valid/s2_multicast_source_oriented.json`

---

## 3. Parâmetros Experimentais

### 3.1 Parâmetros Comuns

| Parâmetro | Descrição | Padrão |
|-----------|------------|--------|
| `--spec` | Caminho para a especificação L2i (JSON) | obrigatório |
| `--duration` | Duração do experimento (segundos) | 60 |
| `--mode` | `baseline` ou `adapt` | baseline |
| `--backend` | `mock` ou `real` | mock |
| `--retries` | Número de tentativas na configuração | 3 |
| `--pause` | Intervalo entre execuções (s) | 2 |

---

### 3.2 Parâmetros de Tráfego

| Parâmetro | Descrição | Valores típicos |
|-----------|------------|----------------|
| `--bwA` | Largura de banda do fluxo A | 3–6 Mbps |
| `--bwB` | Largura de banda do fluxo B | 3–5 Mbps |
| `--bwC` | Largura de banda do fluxo C | 2–4 Mbps |
| `--be-mbps` | Agregado de melhor esforço | 5–8 Mbps |
| `--delay-ms` | Atraso do enlace | 5–20 ms |

Esses parâmetros são propositalmente configuráveis para explorar:

- limiares de saturação,
- sensibilidade ao congestionamento,
- estabilidade das decisões de adaptação.

---

## 4. Modos de Execução e Exemplos

### 4.1 Baseline + Mock

```bash
python3 dsl/cli.py \
  --scenario s1 \
  --spec dsl/specs/valid/s1_unicast_qos.json \
  --mode baseline \
  --backend mock \
  --duration 60
```

Esse modo fornece uma referência lógica, sem aplicação real de mecanismos de L2, sendo útil para validação funcional e comparação conceitual.

---

## 5. Considerações sobre Reprodutibilidade

Para garantir a reprodutibilidade dos resultados:

- todos os parâmetros relevantes são explicitamente configuráveis,
- os cenários são executados de forma determinística sempre que possível,
- o código-fonte, especificações e scripts são versionados no repositório,
- modos *mock* e *real* permitem separar lógica de execução e efeitos de implementação.

Essa abordagem assegura que os resultados obtidos possam ser verificados, comparados e estendidos por outros pesquisadores.

---

## 6. Síntese

A metodologia experimental do L2i foi concebida para equilibrar **rigor científico**, **flexibilidade experimental** e **viabilidade prática**. Ao combinar múltiplos cenários, modos de execução e níveis de realismo, o framework oferece uma base sólida para avaliação comparativa e para a exploração de novas abordagens de adaptação na camada de enlace.

