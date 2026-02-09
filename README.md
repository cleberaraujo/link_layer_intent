# 🧩 Uma Abordagem Declarativa e Modular para Adaptação Dinâmica da Camada de Enlace de Redes Heterogêneas

🌎 **Navegação**  
📐 [Arquitetura](/docs/architecture.md) · 🧪 [Experimentos](/docs/experiments.md) · 👩‍💻 [Notas Técnicas](/docs/devs.md) · 📃 [Resultados no artigo](/results/) · 📊 [Figuras no artigo](/figures/) · 📋 [Mais resultados](/misc/results/) · 📈 [Mais figuras](/misc/plots/)

---

O projeto investiga como requisitos de comunicação — como **largura de banda, latência, prioridade e multicast orientado à origem** — podem ser expressos de forma abstrata e **materializados dinamicamente** sobre diferentes tecnologias de L2, incluindo:

- Linux Traffic Control (tc / HTB)
- NETCONF/YANG (sysrepo + Netopeer2)
- Data planes programáveis (P4 / bmv2 / *P4Runtime*)

A proposta foi concebida e avaliada como **pesquisa experimental rigorosa**, com foco em **reprodutibilidade**, **comparação baseline vs. adapt**, e **validação real (mock e real)**.

---

## 🎯 Motivação

Apesar dos avanços em SDN, P4 e hardware programável, a camada de enlace ainda apresenta:

- Forte **acoplamento tecnológico**
- Configuração **imperativa e de baixo nível**
- Pouca integração com arquiteturas **intent-based**
- Dificuldade de evolução incremental em ambientes reais

A proposta ataca esse problema propondo uma **camada declarativa própria para L2**, capaz de:

- Desacoplar *o que* deve ser garantido de *como* isso é implementado
- Operar simultaneamente sobre tecnologias legadas e programáveis
- Preservar a intenção original mesmo em cenários multidomínio

---

## 🧠 Ideia central

> **Aplicações e protocolos expressam intenções de comunicação;  
> a rede adapta dinamicamente a camada de enlace para satisfazê-las.**

Essa ideia se concretiza por meio de:

- uma **linguagem declarativa (L2i)**,
- um **mecanismo de adaptação dinâmica (MAD)**,
- e um **aplicador de configurações (AC)** capaz de operar sobre múltiplos backends.

---

## 🧩 Arquitetura (visão geral)

O framework é organizado em três blocos principais:

1. **CED — Camada de Especificações Declarativas**  
   Onde intenções são expressas via L2i (JSON + gramática validável).

2. **MAD — Mecanismo de Adaptação Dinâmica**  
   Interpreta, valida e traduz intenções em planos de execução.

3. **AC — Aplicador de Configurações**  
   Materializa a intenção sobre domínios reais (tc, NETCONF, P4).

A L2i **não substitui** SDN, P4 ou NETCONF — ela **os complementa**, atuando como camada semântica intermediária.

📄 **Detalhes completos** estão em [`docs/architecture.md`](/docs/architecture.md).

---

## 🧪 Avaliação experimental

O repositório contém **experimentos reais e reproduzíveis**, organizados em dois cenários principais:

- **S1 — *Unicast* sensível a QoS em ambiente multidomínio**
- **S2 — *Multicast* orientado à origem na camada de enlace**

Cada cenário é avaliado sob quatro combinações:

| Modo       | *Backend* | Descrição |
|------------|---------|-----------|
| *baseline*   | *mock*    | Sem adaptação, execução simulada |
| *baseline*   | *real*    | Sem adaptação, execução real |
| *adapt*      | *mock*    | Com L2i, execução simulada |
| *adapt*      | *real*    | Com L2i, execução real |

As métricas analisadas incluem:

- Latência média e p99,
- RTT,
- *Throughput*,
- *Jitter*,
- Perda de pacotes,
- Tempo de convergência,
- *Overhead multicast*.

Foram avaliados dois cenários complementares:
- **S1 – *Unicast* Multidomínio**: valida a aderência semântica da intenção sob tráfego concorrente;
- **S2 – *Multicast* Orientado à Origem**: avalia estabilidade, recuperação e contenção sob eventos dinâmicos de *join multicast*.

Os resultados completos utilizados no artigo estão disponíveis em:
- [`/results/S1/`](/results/S1/)
- [`/results/S2/`](/results/S2/)

Disponibilizamos também diversos outros resultados. Eles estão disponíveis em:
- [`/misc/results/`](/misc/results/)
- [`/misc/plots/`](/misc/plots/)


As Figuras utilizadas no artigo encontram-se em [`/figures/`](/figures/). Os *scripts* e artefatos utilizados para a construção das Figuras estão em [`figures/construction/`](figures/construction/).

📄 **Há um passo a passo completo para realização dos experimentos** em [`/docs/experiments.md`](docs/experiments.md).

---

## 📁 Estrutura do repositório (visão geral)

```
├── README.md
├── docs/
│   ├── architecture.md
│   ├── experiments.md
│   └── devs.md
├── dsl/                    # Núcleo da L2i e do framework
│   ├── p4src/              # P4 mininal (inicialização)
│   ├── profiles/           # Configuração de domínios e tecnologias
│   ├── results/            # Local de saída dos resultados
│   ├── schemas/            # JSON Schemas da linguagem
│   ├── scripts/            # Execução, comparação e plots
│   ├── specs/            
│   │   ├── invalid/        # Especificações inválidas (teste L2i)
│   │   └── valid/          # Especificações válidas (utilizadas)
│   └── tools/              # Compatilidade de specs
├── figures/                # Figuras utilizadas no artigo
│   └── construction/       # Como as Figuras foram criadas (dados + plots)
├── misc/
│   ├── plots/              # Plots gerais
│   └── results/            # Resultados gerais para validação
│       ├── S1/             # Amostra de mais resultados obtidos no S1
│       └── S2/             # Amostra de mais resultados obtidos no S2
└── results/                # Resultados utilizados no artigo
        ├── S1/             # Resultados obtidos no S1 por modos + backends
        └── S2/             # Resultados obtidos no S2 por modos + backends
```

---

## 📌 Observações importantes

- Este repositório **não contém** a implementação completa da linguagem L2i nem dos seus *backends*.
- A versão completa dos artefatos com todos os códigos, 100% reprodutíveis, poderá ser disponibilizada **após a avaliação** ou **mediante solicitação aos autores**.

---

## 🔗 Próximos passos

Consulte:
- 📐 [`/docs/architecture.md`](/docs/architecture.md) para a visão arquitetural
- 🧪 [`/docs/experiments.md`](/docs/experiments.md) para reproduzir conceitualmente os cenários
- 👩‍💻 [`/docs/devs.md`](/docs/devs.md) para notas técnicas adicionais

---

📄 *Este repositório acompanha o artigo submetido ao SBRC e destina-se exclusivamente a fins de avaliação científica.*
