# Arquitetura — Framework de Adaptação Dinâmica em L2 (CED/L2i)
  
## 1. Visão Geral da Arquitetura

O framework implementa uma **camada de adaptação declarativa e orientada a intenções para a camada de enlace (L2)**, projetada para operar em ambientes heterogêneos e multidomínio. Seu objetivo principal é desacoplar **os requisitos de comunicação expressos pelas camadas superiores** dos **mecanismos específicos de tecnologia** utilizados para aplicá-los em L2.

O elemento central é a linguagem **L2i (Layer‑2 Intent)**, utilizada para declarar *intenções de comunicação* sem impor como essas intenções devem ser implementadas.

Em alto nível, a arquitetura é organizada em torno de três preocupações ortogonais:

1. **Especificação** — o que a comunicação requer;
2. **Adaptação** — como esses requisitos são mapeados para as capacidades disponíveis;
3. **Execução** — como configurações concretas são aplicadas em cada domínio.

Essa separação permite:

- portabilidade entre tecnologias de L2,
- evolução incremental do plano de dados,
- coexistência entre infraestruturas legadas e programáveis.

A arquitetura evita explicitamente expor detalhes de configuração de baixo nível (por exemplo, comandos `tc`, RPCs NETCONF ou tabelas P4) para aplicações ou protocolos.


---

## 2. Arquitetura em Camadas

Conceitualmente, o framework é posicionado **entre L2 e L3**, atuando como um estrato de adaptação que estende as funcionalidades tradicionais da camada de enlace sem modificar as pilhas de protocolos existentes.

```
+-------------------------------+
| Aplicações / Protocolos Superiores |
+-------------------------------+
               |
               v
+-------------------------------------------+
| Camada de Adaptação Declarativa (L2i)      |
|                                           |
|  - Especificação de intenções              |
|  - Mapeamento orientado a capacidades      |
|  - Políticas e tratamento de conflitos     |
+-------------------------------------------+
               |
               v
+-------------------------------------------+
| Domínios de Execução em L2                 |
|                                           |
|  - Linux tc / HTB                          |
|  - Dispositivos NETCONF / YANG             |
|  - P4 / P4Runtime (bmv2)                   |
+-------------------------------------------+
```

Essa posição permite ao L2i:

- impor QoS, priorização e comportamento multicast,
- reagir dinamicamente a mudanças de tráfego ou topologia,
- permanecer transparente às camadas superiores.

---

## 3. Componentes Arquiteturais Principais

A arquitetura é decomposta em três componentes centrais:

1. **CED — Camada de Especificações Declarativas**
2. **MAD — Mecanismo de Adaptação Dinâmica**
3. **AC — Aplicador de Configurações**

O L2i é a **materialização concreta da CED**, enquanto MAD e AC fornecem o pipeline de adaptação e execução em tempo de execução.

---

## 4. Camada de Especificações Declarativas (CED)

### 4.1 Papel e Fundamentação

A CED define a **interface semântica** entre as camadas superiores e a camada de enlace. Sua responsabilidade é expressar a _intenção de comunicação_, e não procedimentos de configuração.

Em vez de especificar _como_ configurar mecanismos de L2, a CED permite declarar:

- restrições de largura de banda (mín./máx.),
- limites de latência e jitter,
- prioridades relativas,
- semânticas de multicast (incluindo árvores orientadas à origem),
- escopo de aplicabilidade.

### 4.2 L2i como Materialização da CED

O L2i é a **linguagem declarativa específica de domínio** que implementa a CED.

Principais propriedades de projeto do L2i:

- **Agnóstico à tecnologia**: não há referências a VLANs, filas ou tabelas P4.
- **Orientado a fluxos**: especificações são vinculadas a intenções de comunicação, não a protocolos.
- **Validado por esquema**: toda especificação é validada antes da execução.
- **Extensível**: novos atributos podem ser adicionados sem alterar os backends de execução.


---

## 5. Arquitetura Interna do L2i

Internamente, o L2i é estruturado como um pipeline de estágios de processamento semântico.

Especificações inválidas são rejeitadas **antes** de qualquer ação na rede.

---

### 5.1 Modelagem de Capacidades

Cada domínio de execução expõe um **perfil de capacidades** descrevendo o que ele é capaz de aplicar.

Exemplos:

- Domínio Linux: modelagem de tráfego, filas e prioridades.
- Domínio NETCONF: modelos abstratos de QoS.
- Domínio P4: pipelines match-action e grupos multicast.

As capacidades são descritas por meio de:

- `dsl/profiles/*.json`

Isso permite ao framework "raciocinar" sobre **o que é viável** em cada domínio.

---

### 5.2 Composição e Decomposição de Intenções

Quando uma especificação abrange múltiplos domínios, o L2i:

1. decompõe a intenção global,
2. mapeia subintenções para domínios compatíveis,
3. preserva equivalência semântica entre mecanismos heterogêneos.

Essa etapa é essencial para cenários multidomínio (S1, S2).

---

## 6. Mecanismo de Adaptação Dinâmica (MAD)

O MAD é responsável pela **tomada de decisão em tempo de execução**.

Suas responsabilidades incluem:

- traduzir intenções validadas em planos de execução,
- selecionar backends de execução (mock ou real),
- lidar com falhas transitórias e tentativas de reaplicação,
- suportar operação em malha fechada.

O MAD pode operar em:

- modo **open-loop** (aplicação estática),
- modo **closed-loop** (reconfiguração orientada por feedback).

---

## 7. Aplicador de Configurações (AC)

O AC é a **camada de execução orientada à tecnologia**.

Ele aplica ações concretas por meio de adaptadores específicos de backend.

### 7.1 Abstração de Backends

Os típicos incluem:

- `tc_htb.py` (Linux tc/HTB),
- `netconf.py` (sysrepo/Netopeer2),
- `p4runtime.py` (bmv2 + P4Runtime),
- `mock.py` (execução instrumentada sem aplicação real).

Essa abstração garante que **a adição de uma nova tecnologia de L2 não afete a CED ou o MAD**.

---

### 7.2 Semântica de Execução

O AC garante que:

- ações sejam idempotentes,
- falhas parciais sejam detectáveis,
- o estado possa ser inspecionado ou revertido,
- a aplicação respeite as prioridades declaradas.

O suporte a telemetria é fornecido por:

- `ac5_telemetry.py`

---

## 8. Arquitetura Orientada a Multicast

O L2i inclui suporte nativo a **multicast orientado à origem em L2**.

Destaques arquiteturais:

- multicast é tratado como uma intenção de primeira classe,
- dinâmicas de join/leave são tratadas explicitamente,
- replicação é seletiva e orientada a capacidades.

Isso viabiliza experimentação além do IGMP snooping tradicional, incluindo:

- árvores definidas pela origem,
- replicação sensível a prioridades,
- estratégias multicast específicas por domínio.

---

## 9. Arquitetura Baseline vs. Adaptada

A arquitetura oferece suporte explícito a experimentação comparativa:

- **Baseline**: configuração estática de L2, sem intervenção do L2i.
- **Adapt**: adaptação dinâmica conduzida pelo L2i.

Da mesma forma, a execução pode ser:

- **Mock**: execução lógica com instrumentação,
- **Real**: aplicação efetiva via tc, NETCONF ou P4.

Essa dualidade é fundamental para validação científica e reprodutibilidade.

---

## 10. Garantias Arquiteturais

A arquitetura garante:

- **Separação de responsabilidades** (especificação ≠ execução),
- **Portabilidade** entre tecnologias de L2,
- **Implantação incremental**,
- **Extensibilidade** sem reprojeto,
- **Observabilidade científica** para experimentação.

---

## 11. Escopo e Limitações Arquiteturais

Escopo atual:

- adaptação na camada de enlace (L2),
- semânticas de QoS e multicast,
- experimentação multidomínio.

Fora do escopo (por projeto):

- protocolos de transporte fim a fim,
- planos de controle SDN centralizados,
- sinalização específica de protocolos.

Esses limites preservam a clareza e o foco arquitetural.

---

## 12. Síntese

A arquitetura da proposta estabelece um **novo limite de abstração para a camada de enlace**, permitindo adaptação orientada a intenções sem sacrificar desempenho ou implantabilidade.

Ao fundamentar especificações declarativas em backends reais de execução, o framework reduz a lacuna entre **programabilidade de redes** e **operação prática em ambientes multidomínio**, posicionando o L2i como um bloco fundamental para futuras arquiteturas de L2.
