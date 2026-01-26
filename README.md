# L2i: Adaptação Dinâmica na Camada de Enlace via Linguagem Declarativa

**L2i** é um framework de pesquisa para **adaptação dinâmica na camada de enlace (L2)**, baseado em uma **linguagem declarativa independente de tecnologia**, projetado para operar em **ambientes heterogêneos e multidomínio**.

O projeto investiga como requisitos de comunicação — como **largura de banda, latência, prioridade e multicast orientado à origem** — podem ser expressos de forma abstrata e **materializados dinamicamente** sobre diferentes tecnologias de L2, incluindo:

- Linux Traffic Control (tc / HTB),
- NETCONF/YANG (sysrepo + Netopeer2),
- Data planes programáveis (P4 / bmv2 / P4Runtime).

A proposta foi concebida e avaliada como **pesquisa experimental rigorosa**, com foco em **reprodutibilidade**, **comparação baseline vs. adapt**, e **validação real (mock e real)**.

---

## 🎯 Motivação

Apesar dos avanços em SDN, P4 e hardware programável, a camada de enlace ainda apresenta:

- Forte **acoplamento tecnológico**;
- Configuração **imperativa e de baixo nível**;
- Pouca integração com arquiteturas **intent-based**;
- Dificuldade de evolução incremental em ambientes reais.

O **L2i** ataca esse problema propondo uma **camada declarativa própria para L2**, capaz de:

- Desacoplar *o que* deve ser garantido de *como* isso é implementado;
- Operar simultaneamente sobre tecnologias legadas e programáveis;
- Preservar a intenção original mesmo em cenários multidomínio.

---

## 🧠 Ideia Central

> **Aplicações e protocolos expressam intenções de comunicação;  
> a rede adapta dinamicamente a camada de enlace para satisfazê-las.**

Essa ideia se concretiza por meio de:

- uma **linguagem declarativa (L2i)**,
- um **mecanismo de adaptação dinâmica (MAD)**,
- e um **aplicador de configurações (AC)** capaz de operar sobre múltiplos backends.

---

## 🧩 Arquitetura (Visão Geral)

O framework é organizado em três blocos principais:

1. **CED — Camada de Especificações Declarativas**  
   Onde intenções são expressas via L2i (JSON + gramática validável).

2. **MAD — Mecanismo de Adaptação Dinâmica**  
   Interpreta, valida e traduz intenções em planos de execução.

3. **AC — Aplicador de Configurações**  
   Materializa a intenção sobre domínios reais (tc, NETCONF, P4).

A L2i **não substitui** SDN, P4 ou NETCONF — ela **os complementa**, atuando como camada semântica intermediária.

📄 **Detalhes completos** estão em [`docs/architecture.md`](docs/architecture.md).

---

## 🧪 Avaliação Experimental

O repositório contém **experimentos reais e reproduzíveis**, organizados em dois cenários principais:

- **S1 — Unicast sensível a QoS em ambiente multidomínio**
- **S2 — Multicast orientado à origem na camada de enlace**

Cada cenário é avaliado sob quatro combinações:

| Modo       | Backend | Descrição |
|------------|---------|-----------|
| baseline   | mock    | Sem adaptação, execução simulada |
| baseline   | real    | Sem adaptação, execução real |
| adapt      | mock    | Com L2i, execução simulada |
| adapt      | real    | Com L2i, execução real |

As métricas analisadas incluem:

- Latência média e p99,
- RTT,
- Throughput,
- Jitter,
- Perda de pacotes,
- Tempo de convergência,
- Overhead multicast.

📄 **Passo a passo completo** em [`docs/experiments.md`](docs/experiments.md).

---

## 📁 Estrutura do Repositório

```text
net-dev/
├── dsl/                # Núcleo da L2i e do framework
│   ├── l2i/             # Gramática, validação, modelos e execução
│   ├── schemas/         # JSON Schemas da linguagem
│   ├── specs/           # Especificações válidas e inválidas
│   ├── profiles/        # Perfis de domínio (tc, netconf, p4)
│   ├── scenarios/       # S1, S2 e cenários multidomínio
│   ├── scripts/         # Execução, comparação e plots
│   └── tools/           # Utilitários auxiliares
├── venv/               # Ambiente virtual Python
└── docs/               # Documentação científica
