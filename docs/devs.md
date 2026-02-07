## Guia de Desenvolvimento, Execução e Reprodutibilidade do Framework L2i

👩‍💻 **Informações Técnicas Complementares**

Este documento reúne observações úteis para revisores e desenvolvedores interessados na proposta.

---

## 🧪 Natureza do Testbed

- Os experimentos utilizam **recursos reais do sistema operacional** (Linux)
- A topologia é construída dinamicamente com *network namespaces*
- O isolamento e a contenção são aplicados via `tc`
- As medições são feitas com ferramentas padrão (`iperf`, `ping`)

---

## 📈 Métricas e Conformidade

Os experimentos avaliam:

- Latência (percentis configuráveis, ex.: P99)
- Vazão do fluxo sob intenção
- Impacto do tráfego concorrente (BE)
- Conformidade semântica (booleanos e componentes)
- Tempo até conformidade estável (cenário S2)

---

## 🗂️ Artefatos Gerados

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

## 🔒 Código Completo Não Incluído

Nesta versão pública:

- A implementação completa da linguagem L2i não está disponível.

📩 O acesso pode ser concedido **após a avaliação** ou **mediante solicitação aos seus autores**.

---
📌 *Estas notas visam apoiar a leitura crítica do artigo e a avaliação dos resultados apresentados.*
