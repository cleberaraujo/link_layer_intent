# Architecture — L2i Dynamic L2 Adaptation Framework

## 1. Architectural Overview

The L2i framework implements a **declarative, intent-oriented adaptation layer for the link layer (L2)**, designed to operate across heterogeneous and multi-domain environments. Its primary goal is to decouple **communication requirements expressed by upper layers** from **technology-specific mechanisms** used to enforce them at L2.

At a high level, the architecture is organized around three orthogonal concerns:

1. **Specification** — what the communication requires;
    
2. **Adaptation** — how those requirements are mapped to available capabilities;
    
3. **Execution** — how concrete configurations are applied in each domain.
    

This separation enables:

- portability across L2 technologies,
    
- incremental evolution of the data plane,
    
- and coexistence between legacy and programmable infrastructures.
    

The architecture explicitly avoids exposing low-level configuration details (e.g., `tc` commands, NETCONF RPCs, or P4 tables) to applications or protocols.

---

## 2. Layered Architecture

Conceptually, the framework is positioned **between L2 and L3**, acting as an adaptation stratum that extends traditional L2 functionality without modifying existing protocol stacks.

```
+-------------------------------+
| Applications / Upper Protocols|
+-------------------------------+
               |
               v
+-------------------------------------------+
| Declarative Adaptation Layer (L2i)         |
|                                           |
|  - Intent specification                   |
|  - Capability-aware mapping               |
|  - Policy and conflict handling           |
+-------------------------------------------+
               |
               v
+-------------------------------------------+
| L2 Execution Domains                      |
|                                           |
|  - Linux tc / HTB                         |
|  - NETCONF / YANG-based devices           |
|  - P4 / P4Runtime (bmv2)                  |
+-------------------------------------------+
```

This position allows L2i to:

- enforce QoS, prioritization, and multicast behavior,
    
- react dynamically to changes in traffic or topology,
    
- and remain transparent to upper layers.
    

---

## 3. Core Architectural Components

The architecture is decomposed into three main components:

1. **CED — Camada de Especificações Declarativas**
    
2. **MAD — Mecanismo de Adaptação Dinâmica**
    
3. **AC — Aplicador de Configurações**
    

L2i is the **concrete realization of the CED**, while MAD and AC provide the runtime adaptation and execution pipeline.

---

## 4. Camada de Especificações Declarativas (CED)

### 4.1 Role and Rationale

The CED defines the **semantic interface** between upper layers and the link layer.  
Its responsibility is to express _communication intent_, not configuration procedures.

Instead of specifying _how_ to configure L2 mechanisms, the CED allows entities to declare:

- bandwidth constraints (min / max),
    
- latency and jitter bounds,
    
- relative priorities,
    
- multicast semantics (including source-oriented trees),
    
- and scope of applicability.
    

### 4.2 L2i as the Materialization of the CED

L2i is the **domain-specific declarative language** that implements the CED.

Key design properties of L2i:

- **Technology-agnostic**: no references to VLAN IDs, queue numbers, or P4 tables.
    
- **Flow-oriented**: specifications are bound to communication intents, not protocols.
    
- **Schema-validated**: every specification is validated before execution.
    
- **Extensible**: new attributes can be added without changing execution backends.
    

In the repository, L2i is implemented primarily under:

```
dsl/l2i/
dsl/schemas/
dsl/specs/
```

---

## 5. L2i Internal Architecture

Internally, L2i is structured as a pipeline of semantic processing stages:

### 5.1 Specification Parsing and Validation

- JSON-based specifications are validated against:
    
    - `l2i-v0.json`
        
    - `l2i-capability-v0.json`
        
- Semantic constraints are enforced (e.g., `bw_min ≤ bw_max`).
    

Relevant modules:

- `validator.py`
    
- `schemas.py`
    
- `models.py`
    

Invalid specifications are rejected **before** any network action occurs.

---

### 5.2 Capability Modeling

Each execution domain exposes a **capability profile** describing what it can enforce.

Examples:

- Linux domain: shaping, queuing, priorities.
    
- NETCONF domain: abstract QoS models.
    
- P4 domain: match-action pipelines, multicast groups.
    

Capabilities are described via:

- `profiles/*.json`
    
- `capabilities.py`
    
- `compatibility_map.py`
    

This allows L2i to reason about **what is feasible** in each domain.

---

### 5.3 Intent Composition and Decomposition

When a specification spans multiple domains, L2i:

1. decomposes the global intent,
    
2. maps sub-intents to compatible domains,
    
3. preserves semantic equivalence across heterogeneous mechanisms.
    

Relevant modules:

- `compose.py`
    
- `synth.py`
    
- `topo.py`
    

This step is essential for multi-domain scenarios (S1, S2).

---

## 6. Mecanismo de Adaptação Dinâmica (MAD)

The MAD is responsible for **runtime decision-making**.

Its responsibilities include:

- translating validated intents into execution plans,
    
- selecting execution backends (mock or real),
    
- handling retries and transient failures,
    
- supporting closed-loop operation.
    

Key modules:

- `closed_loop.py`
    
- `fed.py`
    
- `policies.py`
    

MAD can operate in:

- **open-loop** mode (static application),
    
- **closed-loop** mode (feedback-driven reconfiguration).
    

---

## 7. Aplicador de Configurações (AC)

The AC is the **technology-facing execution layer**.

It applies concrete actions using backend-specific adapters:

### 7.1 Backend Abstraction

Backends are isolated under:

```
dsl/l2i/backends/
```

Typical backends include:

- `tc_htb.py` (Linux tc/HTB),
    
- `netconf.py` (sysrepo/Netopeer2),
    
- `p4runtime.py` (bmv2 + P4Runtime),
    
- `mock.py` (instrumented execution without real enforcement).
    

This abstraction ensures that **adding a new L2 technology does not affect the CED or MAD**.

---

### 7.2 Execution Semantics

The AC ensures that:

- actions are idempotent,
    
- partial failures are detectable,
    
- state can be inspected or rolled back,
    
- and enforcement respects declared priorities.
    

Telemetry support is provided via:

- `ac5_telemetry.py`
    

---

## 8. Multicast-Oriented Architecture

L2i includes native support for **source-oriented multicast at L2**.

Architectural highlights:

- multicast is treated as a _first-class intent_,
    
- join/leave dynamics are handled explicitly,
    
- replication is capability-aware and selective.
    

Key modules:

- `mcast.py`
    
- `emit.py`
    

This enables experimentation beyond traditional IGMP snooping, including:

- source-defined trees,
    
- priority-aware replication,
    
- domain-specific multicast strategies.
    

---

## 9. Baseline vs. Adapted Architecture

The architecture explicitly supports comparative experimentation:

- **Baseline**: static L2 configuration, no L2i intervention.
    
- **Adapt**: L2i-driven dynamic adaptation.
    

Similarly, execution can be:

- **Mock**: logical execution with instrumentation,
    
- **Real**: actual enforcement via tc, NETCONF, or P4.
    

This duality is fundamental for scientific validation and reproducibility.

---

## 10. Architectural Guarantees

The architecture guarantees:

- **Separation of concerns** (specification ≠ execution),
    
- **Portability** across L2 technologies,
    
- **Incremental deployability**,
    
- **Extensibility** without redesign,
    
- **Scientific observability** for experimentation.
    

---

## 11. Architectural Scope and Limitations

Current scope:

- Link-layer adaptation (L2),
    
- QoS and multicast semantics,
    
- Multi-domain experimentation.
    

Out of scope (by design):

- end-to-end transport protocols,
    
- centralized SDN control planes,
    
- protocol-specific signaling.
    

These boundaries preserve architectural clarity and focus.

---

## 12. Summary

The L2i architecture establishes a **new abstraction boundary for the link layer**, enabling intent-oriented adaptation without sacrificing performance or deployability.

By grounding declarative specifications in real execution backends, the framework bridges the gap between **network programmability** and **practical multi-domain operation**, positioning L2i as a foundational building block for future L2 architectures.

---
