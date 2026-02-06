## Guia de Desenvolvimento, Execução e Reprodutibilidade do Framework L2i

---

## 1. Visão geral para desenvolvedores

Este repositório contém a **implementação completa do framework de adaptação dinâmica na camada de enlace**, cuja materialização prática da **Camada de Especificações Declarativas (CED)** é a **DSL L2i**.

O código implementa:

- Uma **linguagem declarativa de L2 (L2i)**, com gramática validável;
    
- Um **pipeline de validação → adaptação → materialização**;
    
- Execução **multidomínio real**, envolvendo:
    
    - Linux `tc/HTB`,
        
    - NETCONF (`sysrepo` / `Netopeer2`),
        
    - P4 (`bmv2` + `P4Runtime`);
        
- Um **testbed experimental real**, com cenários:
    
    - **S1 (unicast multidomínio)**,
        
    - **S2 (multicast orientado à origem)**;
        
- Modos experimentais **baseline vs adapt** e **mock vs real**;
    
- Scripts de **execução, varredura, agregação e visualização científica**.
    

Este documento descreve **como desenvolver, executar, reproduzir e estender** o framework.

---

## 2. Estrutura geral do repositório

```
net-dev/
├── dsl/                 # Núcleo da L2i e dos experimentos
│   ├── cli.py            # Interface de linha de comando
│   ├── compatibility_map.py
│   ├── l2i/              # Núcleo semântico da L2i
│   ├── profiles/         # Perfis de capacidades por domínio
│   ├── results/          # Resultados brutos e agregados
│   ├── scenarios/        # Cenários S1 e S2 (Mininet)
│   ├── schemas/          # Gramática e esquemas JSON
│   ├── scripts/          # Execução, automação e plots
│   ├── specs/            # Especificações declarativas (válidas/inválidas)
│   ├── tools/            # Ferramentas auxiliares
│   └── yang/             # Modelos YANG (NETCONF)
│
├── venv/                 # Ambiente virtual Python
└── v0/                   # Artefatos legados/experimentais
```

---

## 3. Estrutura lógica do framework e da L2i

### 3.1 Pipeline conceitual

```
Especificação Declarativa (JSON)
        ↓
Validação sintática e semântica (schemas/)
        ↓
Modelo intermediário (l2i/models.py)
        ↓
Adaptação por domínio (l2i/capabilities.py)
        ↓
Backends (l2i/backends/)
        ↓
Materialização (tc | NETCONF | P4)
```

A **L2i é a materialização concreta da CED**, oferecendo:

- Gramática explícita (`schemas/l2i-v0.json`);
    
- Validação forte (`l2i/validator.py`);
    
- Independência de tecnologia;
    
- Preservação semântica da intenção.
    

---

## 4. Núcleo L2i (`dsl/l2i/`)

### Arquivos principais

- `models.py`  
    Define os **modelos semânticos internos** (fluxos, requisitos, domínios).
    
- `schemas.py`  
    Carrega e organiza os **JSON Schemas** da linguagem.
    
- `validator.py`  
    Validação sintática **e semântica** das especificações.
    
- `capabilities.py`  
    Mapeia **capacidades declaradas dos domínios** → operações possíveis.
    
- `compose.py`  
    Composição multidomínio de uma intenção única.
    
- `policies.py`  
    Regras de priorização e resolução de conflitos.
    
- `emit.py`  
    Geração de artefatos específicos para cada backend.
    
- `mcast.py`  
    Lógica de multicast orientado à origem (S2).
    
- `closed_loop.py`  
    Suporte a adaptação dinâmica (feedback).
    
- `backends/`  
    Implementações específicas:
    
    - `tc_htb.py`
        
    - `netconf.py`
        
    - `p4runtime.py`
        
    - `_shim_*` (mock)
        

---

## 5. Gramática e especificações (`dsl/schemas` e `dsl/specs`)

### Gramática

- `schemas/l2i-v0.json`  
    Define:
    
    - `bw_min`, `bw_max`
        
    - `latency`
        
    - `priority`
        
    - `multicast`
        
    - `domains`
        
- `schemas/l2i-capability-v0.json`  
    Define o **modelo de capacidades** por domínio.
    

### Especificações de exemplo

- Válidas (`specs/valid/`)
    
    - `s1_unicast_qos.json`
        
    - `s2_multicast_source_oriented.json`
        
- Inválidas (`specs/invalid/`)
    
    - `bw_min > bw_max`
        
    - multicast sem grupo
        
    - multicast não suportado
        

Esses arquivos são usados **diretamente nos experimentos**.

---

## 6. Modos experimentais: baseline, adapt, mock, real

### Baseline vs Adapt

- **baseline**  
    A rede é configurada **estaticamente**.  
    A L2i **não aplica adaptações dinâmicas**.
    
- **adapt**  
    A L2i:
    
    - interpreta a especificação,
        
    - valida,
        
    - adapta por domínio,
        
    - aplica dinamicamente.
        

### Mock vs Real

- **mock**  
    Backends simulados (`_shim_*`):
    
    - valida semântica,
        
    - gera artefatos,
        
    - **não altera a rede real**.
        
- **real**  
    Backends reais:
    
    - `tc/HTB`,
        
    - `NETCONF`,
        
    - `P4Runtime`.
        

Esses quatro modos permitem **análise científica controlada**.

---

## 7. Cenários experimentais

### S1 – Unicast multidomínio

Arquivo:

```
scenarios/multidomain_s1.py
```

Características:

- Tráfego unicast;
    
- Domínios A (tc), B (NETCONF), C (P4);
    
- Avalia QoS, latência, vazão.
    

### S2 – Multicast orientado à origem

Arquivo:

```
scenarios/multicast_s2.py
```

Características:

- Árvore multicast orientada à origem;
    
- Priorização por grupo;
    
- Reconfiguração dinâmica.
    

---

## 8. Execução dos experimentos (comandos)

### Pós-reboot – passos obrigatórios

```bash
cd ~/net-dev
source venv/bin/activate
sudo ./dsl/scripts/cleanup_net.sh
```

Para P4:

```bash
cd dsl/scripts
sudo ./p4_build_and_run.sh
```

---

### e.1) Baseline + Mock

```bash
python3 dsl/cli.py \
  --scenario s1 \
  --spec specs/valid/s1_unicast_qos.json \
  --mode baseline \
  --backend mock
```

### e.2) Baseline + Real

```bash
sudo python3 dsl/cli.py \
  --scenario s1 \
  --spec specs/valid/s1_unicast_qos.json \
  --mode baseline \
  --backend real
```

### e.3) Adapt + Mock

```bash
python3 dsl/cli.py \
  --scenario s1 \
  --spec specs/valid/s1_unicast_qos.json \
  --mode adapt \
  --backend mock
```

### e.4) Adapt + Real

```bash
sudo python3 dsl/cli.py \
  --scenario s1 \
  --spec specs/valid/s1_unicast_qos.json \
  --mode adapt \
  --backend real
```

O mesmo vale para `--scenario s2`.

---

## 9. Parâmetros experimentais

### Parâmetros principais

|Parâmetro|Significado|
|---|---|
|`--spec`|Especificação L2i|
|`--duration`|Duração do experimento (s)|
|`--be-mbps`|Tráfego best-effort|
|`--bwA/B/C`|Banda por domínio|
|`--delay-ms`|Latência artificial|
|`--mode`|baseline / adapt|
|`--backend`|mock / real|
|`--retries`|Tentativas de aplicação|
|`--pause`|Intervalo entre execuções|

### Valores típicos (S1)

- `bwA=10`, `bwB=10`, `bwC=10`
    
- `be-mbps=12`
    
- `duration=60`
    

---

## 10. Scripts (`dsl/scripts/`)

### Execução

- `run_batch.py`  
    Executa múltiplos experimentos.
    
- `run_s1_batch.py`  
    Batch específico S1.
    
- `sweep_s1.py`, `sweep_s2.py`  
    Varredura paramétrica.
    

### Comparação

- `s1_compare.py`
    
- `s2_compare.py`
    

Comparam:

- baseline vs adapt
    
- mock vs real
    

### Agregação

- `aggregate_results.py`  
    Consolida resultados brutos.
    

### Visualização

- `plot_p99.py`
    
- `plot_s1_heatmap.py`
    
- `plot_s1_pivots.py`
    
- `plot_s2_cdfs.py`
    
- `plot_s2_curves.py`
    
- `plot_s2_facets.py`
    
- `plot_s2_heatmaps.py`
    
- `plot_s2_improvement_map.py`
    
- `plot_s2_multicast_tree.py`
    
- `plot_s2_pareto.py`
    

Esses scripts geram **figuras diretamente publicáveis**.

---

## 11. Dependências (Ubuntu Server 24.04 LTS)

```bash
sudo add-apt-repository universe -y
sudo apt update
sudo apt install -y \
  fping graphviz iperf3 iproute2 iputils-ping \
  mininet net-tools \
  python3 python3-pip python3-venv \
  python3-grpcio python3-protobuf \
  python3-jsonschema python3-matplotlib \
  python3-yaml python3-thrift
```

NETCONF:

```bash
sudo apt install -y sysrepo netopeer2-server libnetconf2
```

---

## 12. Ambiente virtual (venv)

```bash
python3 -m venv venv
source venv/bin/activate
pip install grpcio protobuf jsonschema matplotlib pyyaml
```

---

## 13. Observações finais para desenvolvedores

- **Não execute backends reais sem `cleanup_net.sh`**
    
- **Sempre diferencie mock vs real**
    
- **Resultados só são comparáveis se parâmetros forem iguais**
    
- **S1 e S2 têm semânticas diferentes**
    

---
