#!/usr/bin/env python3
"""
Gráfico standalone: Evolução do RTT p99 durante Recovery
Altere os parâmetros de personalização conforme necessário
"""

import json
import matplotlib.pyplot as plt

# ============================================================
# CARREGAR DADOS
# ============================================================
with open('S2_20260205T175440Z.json', 'r') as f:
    data = json.load(f)

recovery = data['recovery']
series = recovery['series']

# Extrair dados das séries
time_intervals = [(s['start_ms'] + s['end_ms']) / 2 / 1000 for s in series]
rtt_b_series = [s['rtt_p99_ms_B'] for s in series]
rtt_c_series = [s['rtt_p99_ms_C'] for s in series]

# Informações das fases
event_start = recovery['event_start_ms'] / 1000
event_end = recovery['event_end_ms'] / 1000

# ============================================================
# PARÂMETROS DE PERSONALIZAÇÃO
# ============================================================

# Títulos e rótulos
#TITULO_PRINCIPAL = "Análise de Recovery - Métricas de Contenção de Tráfego BE (500ms)"
TITULO_PRINCIPAL = ""
TITULO_GRAFICO = ""
#TITULO_GRAFICO = "Evolução do RTT p99 durante Recovery"
ROTULO_EIXO_X = "Tempo (s)"
ROTULO_EIXO_Y = "RTT p99 (ms)"

# Labels da legenda
LABEL_DESTINO_B = "Destino B"
LABEL_DESTINO_C = "Destino C"
LABEL_LIMITE = f"Limite RTT ({recovery['rtt_limit_ms']} ms)"
LABEL_PRE_EVENT = "pre_event"
LABEL_JOIN = "join (evento)"
LABEL_POST_EVENT = "post_event"

# Posição da legenda: 'upper right', 'upper left', 'lower right', 'lower left', 
#                     'upper center', 'lower center', 'center left', 'center right', 'center', 'best'
#POSICAO_LEGENDA = 'upper right'
POSICAO_LEGENDA = 'center right'

# Tamanho da fonte
TAMANHO_FONTE_TITULO_PRINCIPAL = 16
TAMANHO_FONTE_TITULO_GRAFICO = 13
TAMANHO_FONTE_EIXOS = 12
TAMANHO_FONTE_LEGENDA = 10

# Tamanho da figura (largura, altura em polegadas)
LARGURA_FIGURA = 16
ALTURA_FIGURA = 6

# Cores (formato hexadecimal)
COR_DESTINO_B = '#2E86AB'
COR_DESTINO_C = '#A23B72'
COR_LIMITE = '#D32D41'
COR_AREA_PRE_EVENT = 'green'
COR_AREA_JOIN = 'orange'
COR_AREA_POST_EVENT = 'blue'

# Opacidade das áreas de fase (0.0 a 1.0)
OPACIDADE_AREAS = 0.1

# Estilo das linhas
LARGURA_LINHA = 2
TAMANHO_MARCADOR = 4
TIPO_MARCADOR_B = 'o'  # círculo
TIPO_MARCADOR_C = 's'  # quadrado

# Largura da linha de limite
LARGURA_LINHA_LIMITE = 2

# Limites do eixo X
LIMITE_X_MIN = 0
LIMITE_X_MAX = 30


# Limites do eixo Y
LIMITE_Y_MIN = 0
LIMITE_Y_MAX = 30

# Grid
MOSTRAR_GRID = True
OPACIDADE_GRID = 0.4

# Formato de saída: 'png' ou 'pdf'
FORMATO_SAIDA = 'pdf'  # Altere para 'png' se preferir
NOME_ARQUIVO_SAIDA = 'rtt_recovery_standalone'

# Resolução (apenas para PNG)
DPI = 300

# ============================================================
# CRIAR GRÁFICO
# ============================================================

fig, ax = plt.subplots(figsize=(LARGURA_FIGURA, ALTURA_FIGURA))

# Título principal (opcional, pode comentar esta linha se não quiser)
fig.suptitle(TITULO_PRINCIPAL, fontsize=TAMANHO_FONTE_TITULO_PRINCIPAL, fontweight='bold')

# Áreas das fases (backgrounds)
ax.axvspan(0, event_start, alpha=OPACIDADE_AREAS, color=COR_AREA_PRE_EVENT, label=LABEL_PRE_EVENT)
ax.axvspan(event_start, event_end, alpha=OPACIDADE_AREAS, color=COR_AREA_JOIN, label=LABEL_JOIN)
ax.axvspan(event_end, LIMITE_X_MAX, alpha=OPACIDADE_AREAS, color=COR_AREA_POST_EVENT, label=LABEL_POST_EVENT)

# Linha de limite de conformidade
ax.axhline(y=recovery['rtt_limit_ms'], color=COR_LIMITE, linestyle='--', 
           linewidth=LARGURA_LINHA_LIMITE, label=LABEL_LIMITE, alpha=0.7)

# Dados: Destino B
ax.plot(time_intervals, rtt_b_series, 
        marker=TIPO_MARCADOR_B, 
        linewidth=LARGURA_LINHA, 
        markersize=TAMANHO_MARCADOR, 
        label=LABEL_DESTINO_B, 
        color=COR_DESTINO_B, 
        alpha=0.8)

# Dados: Destino C
ax.plot(time_intervals, rtt_c_series, 
        marker=TIPO_MARCADOR_C, 
        linewidth=LARGURA_LINHA, 
        markersize=TAMANHO_MARCADOR, 
        label=LABEL_DESTINO_C, 
        color=COR_DESTINO_C, 
        alpha=0.8)

# Rótulos dos eixos
ax.set_xlabel(ROTULO_EIXO_X, fontsize=TAMANHO_FONTE_EIXOS)
ax.set_ylabel(ROTULO_EIXO_Y, fontsize=TAMANHO_FONTE_EIXOS)

# Título do gráfico
ax.set_title(TITULO_GRAFICO, fontsize=TAMANHO_FONTE_TITULO_GRAFICO)

# Legenda
ax.legend(loc=POSICAO_LEGENDA, fontsize=TAMANHO_FONTE_LEGENDA)

# Grid
if MOSTRAR_GRID:
    ax.grid(True, alpha=OPACIDADE_GRID)

# Limites do eixo X
ax.set_xlim([LIMITE_X_MIN, LIMITE_X_MAX])

# Ajuste de layout
plt.tight_layout()

# Salvar figura
nome_completo = f'{NOME_ARQUIVO_SAIDA}.{FORMATO_SAIDA}'
if FORMATO_SAIDA == 'png':
    plt.savefig(f'{nome_completo}', dpi=DPI, bbox_inches='tight')
else:
    plt.savefig(f'{nome_completo}', bbox_inches='tight')

print(f"✓ Gráfico gerado: {nome_completo}")
print(f"\nParâmetros utilizados:")
print(f"  - Formato: {FORMATO_SAIDA.upper()}")
print(f"  - Tamanho: {LARGURA_FIGURA}x{ALTURA_FIGURA} polegadas")
print(f"  - Posição da legenda: {POSICAO_LEGENDA}")
print(f"\nPara personalizar, edite as variáveis na seção 'PARÂMETROS DE PERSONALIZAÇÃO'")
