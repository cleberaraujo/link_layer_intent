# L2i — Link Layer Intent DSL

A **L2i (Link Layer Intent)** é uma linguagem declarativa projetada para capturar intenções de comunicação na **camada de enlace (L2)**.  
Seu objetivo é tornar **transparente** para protocolos das camadas superiores (como QUIC, NDN, etc.) a complexidade de mecanismos de L2 — filas, priorização, multicast, controle de tráfego — permitindo que aplicações expressem requisitos de forma **abstrata, portável e independente de tecnologia**.

O projeto foi desenvolvido como parte de uma pesquisa strictu sensu em Ciência da Computação, explorando a lacuna entre **redes orientadas a intenções (IBN)** e a **camada de enlace**, e propondo uma DSL que atua como **elo declarativo** entre requisitos de alto nível e mecanismos concretos de rede.

---

## Objetivos

- Definir uma **gramática mínima porém expressiva** para intenções de L2.  
- Prover uma arquitetura modular baseada em três blocos:  
  - **CED** (Componente de Especificações Declarativas) — validação e normalização.  
  - **MAD** (Mecanismo de Adaptação Dinâmica) — aplicação de políticas e capacidades, composição de intenções.  
  - **AC** (Aplicador de Configurações) — síntese IR, emissão e execução em dispositivos.  
- Permitir execução em múltiplos backends:  
  - **Legacy**: comandos Linux `tc/htb`.  
  - **NETCONF-like**: emissão de XML abstrato.  
  - **P4Runtime-like**: emissão de batch JSON.  
- Assegurar **adaptação dinâmica** via laço fechado (detecção de violações → reemissão de planos).  
- Oferecer **reprodutibilidade científica**, com scripts para execução em lote, coleta de métricas e geração de gráficos.

---

## Gramática da L2i (v0)

A versão inicial (v0) suporta quatro classes de requisitos: **latência, largura de banda, prioridade e multicast**.  
A especificação é descrita em JSON e validada por esquema formal (`schemas/l2i-v0.json`).

Exemplo:

```json
{
  "l2i_version": "0.1",
  "tenant": "insert.ufba",
  "scope": "teste01",
  "flow": { "id": "VideoHD_A" },
  "requirements": {
    "latency": { "max_ms": 30, "percentile": "P99" },
    "bandwidth": { "min_mbps": 5, "max_mbps": 8 },
    "priority": { "level": "high" },
    "multicast": { "enabled": false }
  }
}

