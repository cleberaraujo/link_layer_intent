# 👩‍💻 Guia de Desenvolvimento, Execução e Reprodutibilidade do Framework L2i

🏠 [README](../README.md) · 📐 [Arquitetura](architecture.md) · 🧪 [Experimentos](experiments.md) · 📃 [Resultados no artigo](/results/) · 📊 [Figuras no artigo](/figures/) · 📋 [Mais resultados](/misc/results/) · 📈 [Mais figuras](/misc/plots/) · 📂 [Pasta de Desenvolvimento](/dsl/)

---

## 🧪 Natureza do testbed

- Os experimentos utilizam **recursos reais do sistema operacional** (Linux)
- A topologia é construída dinamicamente com *network namespaces*
- O isolamento e a contenção são aplicados via `tc`
- As medições são feitas com ferramentas padrão (`iperf`, `ping`)

---

## 📈 Métricas e conformidade

Os experimentos avaliam:

- Latência (percentis configuráveis, ex.: P99)
- Vazão do fluxo sob intenção
- Impacto do tráfego concorrente (BE)
- Conformidade semântica (booleanos e componentes)
- Tempo até conformidade estável (cenário S2)

---

## 🗂️ Artefatos gerados

Cada execução gera:

- Sumários em JSON
- Séries temporais (CSV)
- Dumps de configuração (`tc`, P4, etc.)
- Arquivos auxiliares para auditoria

Esses artefatos são suficientes para:

- Validar a existência dos experimentos
- Compreender o comportamento observado
- Reconstruir figuras e análises

---

## 🔗 Implementação completa e reprodutibilidade

Este repositório concentra os artefatos necessários para compreensão da proposta e análise dos resultados apresentados no artigo.

A implementação completa do framework L2i — incluindo:

- código-fonte integral,
- backends de execução,
- automação experimental,
- ambiente reproduzível,
- instruções completas de execução,

foi disponibilizada separadamente em um repositório dedicado à avaliação do Comitê Técnico de Artefatos (CTA) do SBRC.

---

### 🏅 Repositório avaliado pelo CTA

🔗: https://github.com/cleberaraujo/l2i-dsl

O repositório recebeu os selos de avaliação do CTA:

* ✅ **SeloD** — ArtefatoDisponível
* ✅ **SeloF** — Artefato Funcional
* ✅ **SeloS** — Artefato Sustentável
* ✅ **SeloR** — Artefato Reprodutível (**objetivo principal**)

Esse repositório contém a versão integral dos artefatos científicos da proposta, preparada especificamente para reprodução experimental e validação independente.

---

📌 *Estas notas visam apoiar a leitura crítica do artigo e a avaliação dos resultados apresentados.*
