#!/usr/bin/env python3
"""
Gráfico standalone: Linha do Tempo das Fases do Experimento
Altere os parâmetros de personalização conforme necessário
"""

import json
import matplotlib.pyplot as plt

# ============================================================
# CARREGAR DADOS
# ============================================================
with open('S2_20260205T175440Z.json', 'r') as f:
    data = json.load(f)

phases = data['phases_metrics']

# Extrair dados das fases
phase_names = [p['name'] for p in phases]
start_times = [p['start_ms']/1000 for p in phases]
durations = [(p['end_ms'] - p['start_ms'])/1000 for p in phases]

# ============================================================
# PARÂMETROS DE PERSONALIZAÇÃO
# ============================================================

# Títulos e rótulos
#TITULO_GRAFICO = "Linha do Tempo das Fases do Experimento"
TITULO_GRAFICO = ""
ROTULO_EIXO_X = "Tempo (s)"
ROTULO_EIXO_Y = "Fase"

# Nome das fases (para exibição no eixo Y)
# Pode alterar para português ou outros nomes:
NOMES_FASES = {
    'pre_event': 'pre_event',      # ou 'Pré-evento'
    'join': 'join',                # ou 'Junção'
    'post_event': 'post_event'     # ou 'Pós-evento'
}

# Posição da legenda (se houver)
# 'upper right', 'upper left', 'lower right', 'lower left', etc.
# Pode deixar None para não mostrar legenda
MOSTRAR_LEGENDA = False
POSICAO_LEGENDA = 'upper right'

# Tamanho da fonte
TAMANHO_FONTE_TITULO = 14
TAMANHO_FONTE_EIXOS = 12
TAMANHO_FONTE_LABELS_BARRAS = 10  # Texto dentro das barras (ex: "10s")

# Tamanho da figura (largura, altura em polegadas)
LARGURA_FIGURA = 12
ALTURA_FIGURA = 6

# Cores das fases (formato hexadecimal)
CORES_FASES = {
    'pre_event': '#F18F01',    # Laranja
    'join': '#C73E1D',          # Vermelho
    'post_event': '#06A77D'     # Verde
}

# Opacidade das barras (0.0 a 1.0)
OPACIDADE_BARRAS = 0.8

# Altura das barras (0.0 a 1.0, sendo 1.0 = altura máxima)
ALTURA_BARRAS = 0.6

# Mostrar duração dentro das barras?
MOSTRAR_DURACAO_NAS_BARRAS = True
COR_TEXTO_BARRAS = 'white'
PESO_TEXTO_BARRAS = 'bold'  # 'normal' ou 'bold'

# Grid
MOSTRAR_GRID = True
OPACIDADE_GRID = 0.3
EIXO_GRID = 'x'  # 'x', 'y', ou 'both'

# Limites do eixo X
LIMITE_X_MIN = 0
LIMITE_X_MAX = 30

# Formato de saída: 'png' ou 'pdf'
FORMATO_SAIDA = 'pdf'  # Altere para 'png' se preferir
NOME_ARQUIVO_SAIDA = 'timeline_fases_standalone'

# Resolução (apenas para PNG)
DPI = 300

# Borda ao redor das barras
MOSTRAR_BORDA = True
COR_BORDA = 'black'
LARGURA_BORDA = 1

# ============================================================
# CRIAR GRÁFICO
# ============================================================

fig, ax = plt.subplots(figsize=(LARGURA_FIGURA, ALTURA_FIGURA))

# Mapear nomes das fases
display_names = [NOMES_FASES.get(name, name) for name in phase_names]
colors = [CORES_FASES.get(name, '#999999') for name in phase_names]

# Criar barras horizontais
edgecolor = COR_BORDA if MOSTRAR_BORDA else 'none'
linewidth = LARGURA_BORDA if MOSTRAR_BORDA else 0

bars = ax.barh(display_names, durations, left=start_times, 
               alpha=OPACIDADE_BARRAS, 
               color=colors,
               edgecolor=edgecolor,
               linewidth=linewidth,
               height=ALTURA_BARRAS)

# Adicionar duração dentro das barras
if MOSTRAR_DURACAO_NAS_BARRAS:
    for i, (bar, duration, start) in enumerate(zip(bars, durations, start_times)):
        # Posição central da barra
        x_pos = start + duration / 2
        y_pos = i
        
        # Texto
        texto = f'{duration:.0f}s'
        ax.text(x_pos, y_pos, texto,
                ha='center', va='center', 
                fontweight=PESO_TEXTO_BARRAS, 
                fontsize=TAMANHO_FONTE_LABELS_BARRAS, 
                color=COR_TEXTO_BARRAS)

# Rótulos dos eixos
ax.set_xlabel(ROTULO_EIXO_X, fontsize=TAMANHO_FONTE_EIXOS)
ax.set_ylabel(ROTULO_EIXO_Y, fontsize=TAMANHO_FONTE_EIXOS)

# Título do gráfico
ax.set_title(TITULO_GRAFICO, fontsize=TAMANHO_FONTE_TITULO, fontweight='bold')

# Legenda (se habilitada)
if MOSTRAR_LEGENDA:
    ax.legend(loc=POSICAO_LEGENDA)

# Grid
if MOSTRAR_GRID:
    ax.grid(True, alpha=OPACIDADE_GRID, axis=EIXO_GRID)

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
print(f"  - Fases: {', '.join(display_names)}")
print(f"\nPara personalizar, edite as variáveis na seção 'PARÂMETROS DE PERSONALIZAÇÃO'")
