# Script Gnuplot standalone: Linha do Tempo das Fases do Experimento
# Altere os parâmetros conforme necessário

reset

# ============================================================
# PARÂMETROS DE PERSONALIZAÇÃO
# ============================================================

# Formato de saída: 'pdfcairo' ou 'pngcairo'
formato = 'pdfcairo'
# formato = 'pngcairo'

# Nome do arquivo de saída (sem extensão)
arquivo_saida = 'timeline_fases_standalone'

# Tamanho da figura
# Para PDF: em centímetros (ex: 12cm,6cm)
# Para PNG: em pixels (ex: 1200,600)
if (formato eq 'pdfcairo') {
    tamanho = '12cm,6cm'
    extensao = '.pdf'
} else {
    tamanho = '1200,600'
    extensao = '.png'
}

# Títulos e rótulos
titulo_grafico = "Linha do Tempo das Fases do Experimento"
rotulo_eixo_x = "Tempo (s)"
rotulo_eixo_y = "Fase"

# Tamanho das fontes
tamanho_fonte_titulo = 14
tamanho_fonte_eixos = 12
tamanho_fonte_labels = 10

# Cores das fases (formato RGB hexadecimal)
cor_pre_event = 0xF18F01    # Laranja
cor_join = 0xC73E1D          # Vermelho
cor_post_event = 0x06A77D    # Verde

# Opacidade das barras (0.0 a 1.0)
opacidade = 0.8

# Altura das barras (valor entre 0 e 1)
altura_barras = 0.6

# Limites do eixo X
limite_x_min = 0
limite_x_max = 30

# Mostrar grid?
mostrar_grid = 1  # 1=sim, 0=não
eixo_grid = 'x'   # 'x', 'y', ou 'xy'

# Dados das fases (extraídos do JSON)
# Formato: start_time, duration, y_position, cor
# Y position: 0=pre_event, 1=join, 2=post_event

# ============================================================
# CONFIGURAÇÃO DO TERMINAL
# ============================================================

set terminal @formato enhanced font 'Arial,'.tamanho_fonte_eixos size @tamanho
set output arquivo_saida.extensao

# ============================================================
# CONFIGURAÇÃO DO GRÁFICO
# ============================================================

# Título
set title titulo_grafico font ",".tamanho_fonte_titulo

# Rótulos dos eixos
set xlabel rotulo_eixo_x font ",".tamanho_fonte_eixos
set ylabel rotulo_eixo_y font ",".tamanho_fonte_eixos

# Limites
set xrange [limite_x_min:limite_x_max]
set yrange [-0.5:2.5]

# Configurar eixo Y com nomes das fases
set ytics ("pre_event" 0, "join" 1, "post_event" 2) font ",".tamanho_fonte_eixos

# Estilo de preenchimento
set style fill solid opacidade

# Desabilitar legenda
set key off

# Grid
if (mostrar_grid == 1) {
    if (eixo_grid eq 'x') {
        set grid xtics linestyle 1 linecolor rgb "#cccccc" linewidth 0.5
    }
    if (eixo_grid eq 'y') {
        set grid ytics linestyle 1 linecolor rgb "#cccccc" linewidth 0.5
    }
    if (eixo_grid eq 'xy') {
        set grid xtics ytics linestyle 1 linecolor rgb "#cccccc" linewidth 0.5
    }
}

# ============================================================
# PREPARAR DADOS
# ============================================================

# Dados das fases: Y Start Duration Color
$fases << EOD
0  0   10  0xF18F01
1  10  5   0xC73E1D
2  15  15  0x06A77D
EOD

# ============================================================
# PLOTAR BARRAS HORIZONTAIS
# ============================================================

# Plotar barras usando boxxyerrorbars
# Formato: x_center:y:x_delta:y_delta:color
plot '$fases' using ($2+$3/2):1:($3/2):(altura_barras/2):4 \
     with boxxyerrorbars linecolor rgb variable fillstyle solid opacidade notitle, \
     '' using ($2+$3/2):1:(sprintf("%ds", int($3))) \
     with labels font ",".tamanho_fonte_labels textcolor rgb "white" notitle

# ============================================================
# FINALIZAR
# ============================================================

print sprintf("✓ Gráfico gerado: %s%s", arquivo_saida, extensao)
print ""
print "PERSONALIZAÇÃO:"
print "  - Edite as variáveis na seção 'PARÂMETROS DE PERSONALIZAÇÃO'"
print "  - Para mudar cores das fases: altere cor_pre_event, cor_join, cor_post_event"
print "  - Para mudar tamanho: altere 'tamanho'"
print "  - Para mudar formato: altere 'formato' (pdfcairo ou pngcairo)"
