# Script Gnuplot standalone: Evolução do RTT p99 durante Recovery
# Altere os parâmetros conforme necessário

reset

# ============================================================
# PARÂMETROS DE PERSONALIZAÇÃO
# ============================================================

# Formato de saída: 'pdfcairo' ou 'pngcairo'
formato = 'pdfcairo'
# formato = 'pngcairo'

# Nome do arquivo de saída (sem extensão)
arquivo_saida = 'rtt_recovery_standalone'

# Tamanho da figura
# Para PDF: em centímetros (ex: 16cm,6cm)
# Para PNG: em pixels (ex: 1600,600)
if (formato eq 'pdfcairo') {
    tamanho = '16cm,6cm'
    extensao = '.pdf'
} else {
    tamanho = '1600,600'
    extensao = '.png'
}

# Títulos e rótulos
titulo_principal = "Análise de Recovery - Métricas de Contenção de Tráfego BE (500ms)"
titulo_grafico = "Evolução do RTT p99 durante Recovery"
rotulo_eixo_x = "Tempo (s)"
rotulo_eixo_y = "RTT p99 (ms)"

# Labels da legenda
label_destino_b = "Destino B"
label_destino_c = "Destino C"
label_limite = "Limite RTT (40 ms)"

# Posição da legenda
# Opções: top left, top right, bottom left, bottom right, center left, center right, etc.
posicao_legenda = "top right"

# Tamanho das fontes
tamanho_fonte_titulo = 14
tamanho_fonte_eixos = 11
tamanho_fonte_legenda = 10

# Cores (formato RGB hexadecimal)
cor_destino_b = "#2E86AB"
cor_destino_c = "#A23B72"
cor_limite = "#D32D41"
cor_area_pre_event = "#90EE90"
cor_area_join = "#FFA500"
cor_area_post_event = "#87CEEB"

# Estilo das linhas
largura_linha = 2
largura_linha_limite = 2
tamanho_marcador = 0.6

# Tipo de marcador (pointtype)
# 1=+, 2=x, 4=quadrado vazio, 5=quadrado preenchido, 6=círculo vazio, 7=círculo preenchido, etc.
tipo_marcador_b = 7  # círculo preenchido
tipo_marcador_c = 5  # quadrado preenchido

# Limites do eixo X
limite_x_min = 0
limite_x_max = 30

# Fases do experimento (em segundos)
event_start = 10.0
event_end = 15.0
limite_rtt = 40.0

# Mostrar grid?
mostrar_grid = 1  # 1=sim, 0=não

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
set autoscale y

# Legenda
set key @posicao_legenda font ",".tamanho_fonte_legenda

# Grid
if (mostrar_grid == 1) {
    set grid xtics ytics linestyle 1 linecolor rgb "#cccccc" linewidth 0.5
}

# ============================================================
# ÁREAS DAS FASES (BACKGROUNDS)
# ============================================================

set object 1 rectangle from 0,graph 0 to event_start,graph 1 \
    fillcolor rgb cor_area_pre_event fillstyle solid 0.1 behind

set object 2 rectangle from event_start,graph 0 to event_end,graph 1 \
    fillcolor rgb cor_area_join fillstyle solid 0.1 behind

set object 3 rectangle from event_end,graph 0 to limite_x_max,graph 1 \
    fillcolor rgb cor_area_post_event fillstyle solid 0.1 behind

# Labels opcionais para as fases (descomente se desejar)
# set label 1 "pre_event" at 5,graph 0.95 center font ",9" textcolor rgb "#006400"
# set label 2 "join" at 12.5,graph 0.95 center font ",9" textcolor rgb "#FF8C00"
# set label 3 "post_event" at 22.5,graph 0.95 center font ",9" textcolor rgb "#4682B4"

# ============================================================
# PLOTAR DADOS
# ============================================================

plot 'recovery_rtt.dat' using 1:2 with linespoints \
     linewidth largura_linha \
     pointtype tipo_marcador_b \
     pointsize tamanho_marcador \
     linecolor rgb cor_destino_b \
     title label_destino_b, \
     '' using 1:3 with linespoints \
     linewidth largura_linha \
     pointtype tipo_marcador_c \
     pointsize tamanho_marcador \
     linecolor rgb cor_destino_c \
     title label_destino_c, \
     limite_rtt with lines \
     linewidth largura_linha_limite \
     linetype 2 \
     linecolor rgb cor_limite \
     title label_limite

# ============================================================
# FINALIZAR
# ============================================================

print sprintf("✓ Gráfico gerado: %s%s", arquivo_saida, extensao)
print ""
print "PERSONALIZAÇÃO:"
print "  - Edite as variáveis na seção 'PARÂMETROS DE PERSONALIZAÇÃO'"
print "  - Para mudar formato: altere a variável 'formato'"
print "  - Para mudar cores: use códigos RGB hexadecimais"
print "  - Para mudar posição da legenda: altere 'posicao_legenda'"
