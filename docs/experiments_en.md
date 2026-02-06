# Experimental Methodology and Reproducibility Guide

This document describes how to reproduce the experimental evaluation of the L2i framework.
It details the experimental dimensions, execution modes, scenarios (S1/S2), parameters, scripts,
and the exact workflow required to obtain the results presented in the paper.

The goal is to ensure **full experimental transparency and reproducibility**, following SBRC
best practices.

---

## 1. Experimental Dimensions

The evaluation of L2i is structured along **two orthogonal experimental axes**:

### 1.1 Control Plane Behavior
- **baseline**: traditional L2 behavior, without declarative adaptation.
- **adapt**: L2i enabled, with declarative specifications driving dynamic adaptation.

### 1.2 Backend Realism
- **mock**: emulated backends (logic-only, no kernel or dataplane enforcement).
- **real**: actual enforcement using Linux `tc/HTB`, NETCONF/sysrepo, or P4/bmv2.

This results in four experimental modes:

| Mode | Control | Backend | Purpose |
|-----|--------|---------|--------|
| baseline + mock | Static | Emulated | Logical reference |
| baseline + real | Static | Real | Traditional L2 baseline |
| adapt + mock | Adaptive | Emulated | DSL validation |
| adapt + real | Adaptive | Real | End-to-end evaluation |

---

## 2. Scenarios Overview

### 2.1 Scenario S1 — Multidomain Unicast with QoS Constraints

**Objective:**  
Evaluate how L2i adapts unicast flows across multiple L2 domains under congestion.

**Key properties:**
- Three domains (A, B, C)
- Competing best-effort and priority flows
- Declarative constraints on:
  - Minimum bandwidth
  - Maximum latency
  - Priority level

**Relevant files:**
- `dsl/scenarios/multidomain_s1.py`
- `dsl/specs/valid/s1_unicast_qos.json`

---

### 2.2 Scenario S2 — Source-Oriented Multicast

**Objective:**  
Evaluate L2i’s ability to manage multicast trees dynamically based on source-oriented
requirements and receiver heterogeneity.

**Key properties:**
- Dynamic join/leave events
- Receiver-specific QoS constraints
- Selective replication and pruning

**Relevant files:**
- `dsl/scenarios/multicast_s2.py`
- `dsl/specs/valid/s2_multicast_source_oriented.json`

---

## 3. Experimental Parameters

### 3.1 Common Parameters

| Parameter | Description | Default |
|--------|------------|---------|
| `--spec` | Path to L2i specification (JSON) | required |
| `--duration` | Experiment duration (seconds) | 60 |
| `--mode` | `baseline` or `adapt` | baseline |
| `--backend` | `mock` or `real` | mock |
| `--retries` | Retry count for setup | 3 |
| `--pause` | Cooldown between runs (s) | 2 |

---

### 3.2 Traffic Parameters

| Parameter | Description | Typical Values |
|--------|------------|---------------|
| `--bwA` | Bandwidth for flow A | 3–6 Mbps |
| `--bwB` | Bandwidth for flow B | 3–5 Mbps |
| `--bwC` | Bandwidth for flow C | 2–4 Mbps |
| `--be-mbps` | Best-effort aggregate | 5–8 Mbps |
| `--delay-ms` | Link delay | 5–20 ms |

These parameters are intentionally configurable to explore:
- Saturation thresholds
- Sensitivity to congestion
- Stability of adaptation decisions

---

## 4. Execution Modes and Examples

### 4.1 Baseline + Mock

```bash
python3 dsl/cli.py \
  --scenario s1 \
  --spec dsl/specs/valid/s1_unicast_qos.json \
  --mode baseline \
  --backend mock \
  --duration 60
````
