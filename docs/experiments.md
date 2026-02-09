# 🧪 Metodologia Experimental e Guia de Reprodutibilidade

🏠 [README](../README.md) · 📐 [Arquitetura](architecture.md) · 👩‍💻 [Notas Técnicas](devs.md) · 📃 [Resultados no artigo](/results/) · 📊 [Figuras no artigo](/figures/) · 📋 [Mais resultados](/misc/results/) · 📈 [Mais figuras](/misc/plots/)

---

Este documento descreve como reproduzir a avaliação experimental do framework L2i. São detalhadas as dimensões experimentais, modos de execução, cenários (S1/S2), parâmetros, scripts e o fluxo exato necessário para obter os resultados apresentados no artigo.

O objetivo é garantir **transparência experimental total e reprodutibilidade**, em conformidade com as boas práticas do SBRC.

---

## 🔬 1. Dimensões experimentais

A avaliação da proposta é estruturada ao longo de **dois eixos experimentais ortogonais**.

### 🎛️ 1.1 Comportamento do plano de controle

- **baseline**: comportamento tradicional de L2, sem adaptação declarativa
- **adapt**: L2i habilitado, com especificações declarativas conduzindo a adaptação dinâmica

### 🧪 1.2 Realismo do backend

- **mock**: backends emulados (execução lógica, sem aplicação no kernel ou plano de dados)
- **real**: aplicação efetiva usando Linux `tc/HTB`, NETCONF/sysrepo ou P4/bmv2

Isso resulta em quatro modos experimentais:


| Modo | Controle | Backend | Propósito |
|------|----------|---------|-----------|
| *baseline + mock* | Estático | Emulado | Referência lógica |
| *baseline + real* | Estático | Real | *Baseline* tradicional de L2 |
| *adapt + mock* | Adaptativo | Emulado | Validação da DSL |
| *adapt + real* | Adaptativo | Real | Avaliação fim a fim |

Os experimentos foram executados em um **testbed real/emulado**, construído com:

- *Linux network namespaces*
- Controle de tráfego (`tc`)
- Ferramentas de medição (`iperf`, `ping`)
- (Quando aplicável) *switches* programáveis via P4

❗ **Não utilizamos Mininet ou controladores centralizados**. A topologia é criada diretamente via *scripts* e *namespaces*.


---

## 🌐 2. Visão geral dos cenários

### 🔀 2.1 Cenário S1 — Unicast Multidomínio com Restrições de QoS

**Objetivo:**  
Avaliar como o L2i adapta fluxos unicast em múltiplos domínios de L2 sob condições de congestionamento.

**Propriedades principais:**

- Três domínios (A, B, C)
- Fluxos concorrentes de melhor esforço e prioritários
- Restrições declarativas sobre:
  - Largura de banda mínima
  - Latência máxima
  - Nível de prioridade

---

### 🌳 2.2 Cenário S2 — Multicast Orientado à Origem

**Objetivo:**  
Avaliar a capacidade do L2i de gerenciar árvores multicast dinamicamente com base em requisitos orientados à origem e heterogeneidade dos receptores.

**Propriedades principais:**

- Eventos dinâmicos de join/leave
- Restrições de QoS específicas por receptor
- Replicação seletiva e poda dinâmica

---

### 📐 2.3 Topologias

As topologias dos cenários S1 e S2 estão ilustradas em:


📄 [`/figures/topologias_cenarios.pdf`](/figures/topologias_cenarios.pdf)

A criação das topologias é feita por scripts específicos:

- **Cenário S1**: [`/dsl/scripts/s1_topology_setup.sh`](/dsl/scripts/s1_topology_setup.sh)
- **Cenário S2**: [`/dsl/scripts/s2_topology_setup.sh`](/dsl/scripts/s2_topology_setup.sh)

---

### 2.4 📄 Especificações Declarativas

### Cenário S1 – Unicast com QoS

Arquivo: [`/dsl/specs/valid/s1_unicast_qos.json`](/dsl/specs/valid/s1_unicast_qos.json)

```json
{
  "l2i_version": "0.1",
  "tenant": "sbrc.2026",
  "scope": "multidomain-A-B-C",
  "flow": { "id": "S1_UnicastQoS" },
  "requirements": {
    "latency": { "max_ms": 30, "percentile": "P99" },
    "bandwidth": { "min_mbps": 4, "max_mbps": 7 },
    "priority": { "level": "high" },
    "multicast": { "enabled": false }
  }
}
```

---

### Cenário S2 – Multicast Orientado à Origem

Arquivo: [`/dsl/specs/valid/s2_multicast_source_oriented.json`](/dsl/specs/valid/s2_multicast_source_oriented.json)

```json
{
  "flow_id": "S2_SourceOrientedMulticast",
  "endpoints": {
    "source": {"domain": "A", "host": "h1"},
    "receivers": [
      {"domain": "B", "host": "h3"},
      {"domain": "C", "host": "h4"}
    ]
  },
  "multicast": {
    "enabled": true,
    "group": "G1",
    "tree": "SPT"
  },
  "bandwidth": {
    "min_mbps": 2,
    "max_mbps": 5
  },
  "priority": "medium",
  "latency": {
    "max_ms": 40,
    "percentile": "P99"
  }
}
```
---

## ▶️ 3. Execução dos experimentos

### Cenário S1

```bash
sudo python -m scenarios.multidomain_s1 \
  --spec specs/valid/s1_unicast_qos.json \
  --duration 30 \
  --bwA 100 --bwB 50 --bwC 100 \
  --delay-ms 1 \
  --be-mbps 60 \
  --mode {baseline|adapt} \
  --backend {mock|real}
```

**Parâmetros principais**:
- `bwA/bwB/bwC`: capacidades dos domínios
- `be-mbps`: tráfego concorrente de melhor esforço
- `mode`: execução sem (`baseline`) ou com adaptação (`adapt`)

---

### Cenário S2

```bash
sudo python -m scenarios.multicast_s2 \
  --spec specs/valid/s2_multicast_source_oriented.json \
  --duration 30 \
  --be-mbps 80 \
  --bwA 40 --bwB 100 --bwC 100 \
  --delay-ms 1 \
  --mode {baseline|adapt} \
  --backend {mock|real} \
  --phase-splits 10 15 \
  --event-name join \
  --rtt-interval-ms 50 \
  --recovery-bin-ms 500 \
  --stable-k-bins 3
```
**Parâmetros adicionais (S2)**:
- `phase-splits`: define janelas (em segundos) para delimitar fases pre-event (0–10s), join (10–15s), post-event (15–30s)
- `event-name`: nome do evento dinâmico (ex.: join).
- `rtt-interval-ms`: periodicidade de amostragem de RTT (ms).
- `recovery-bin-ms`: granularidade das janelas para série temporal de recuperação (ms).
- `stable-k-bins`: define como conformidade estável como K janelas consecutivas em conformidade

---

## 📊 4. Resultados

Os resultados experimentais estão disponíveis em:

- 📁 [`/results/S1/`](/results/S1/)
- 📁 [`/results/S2/`](/results/S2/)

Cada execução gera arquivos JSON, CSV e dumps auxiliares utilizados para análise e construção das figuras do artigo.

---

📌 *Este documento descreve os experimentos no nível necessário para compreensão metodológica e avaliação científica.*
