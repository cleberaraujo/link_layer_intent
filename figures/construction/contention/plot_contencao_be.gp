# Script Gnuplot para CONTENÇÃO TOTAL DO TRÁFEGO BE
# Visualização da contenção agregada (B + C) ao longo do tempo

reset

# Configurações gerais
set terminal pngcairo enhanced font 'Arial,11' size 1600,1000
#set output 'contencao_be_total.png'
set output 'contencao_be_total.png'

# Layout multiplot (2 linhas, 1 coluna)
set multiplot layout 2,1 title "Contenção Total do Tráfego BE - Agregado de Destinos B e C" font ",16"

# Estilo de grid
set grid xtics ytics linestyle 1 linecolor rgb "#cccccc" linewidth 0.5

# Definir fases
event_start = 10.0
event_end = 15.0

# ============================================================
# GRÁFICO 1: RTT (Indicador de Contenção)
# ============================================================
set xlabel "Tempo (s)"
set ylabel "RTT p99 (ms)"
set title "RTT p99 - Indicador de Contenção do Tráfego BE"
set xrange [0:30]
set key top left

# Áreas das fases (backgrounds)
set object 1 rectangle from 0,graph 0 to event_start,graph 1 fillcolor rgb "#90EE90" fillstyle solid 0.1 behind
set object 2 rectangle from event_start,graph 0 to event_end,graph 1 fillcolor rgb "#FFA500" fillstyle solid 0.1 behind
set object 3 rectangle from event_end,graph 0 to 30,graph 1 fillcolor rgb "#87CEEB" fillstyle solid 0.1 behind

# Labels das fases
set label 1 "pre_event" at 5,graph 0.95 center font ",10" textcolor rgb "#006400"
set label 2 "join" at 12.5,graph 0.95 center font ",10" textcolor rgb "#FF8C00"
set label 3 "post_event" at 22.5,graph 0.95 center font ",10" textcolor rgb "#4682B4"

# Plot dos dados
plot 'contencao_be_total.dat' using 1:2 with linespoints linewidth 2.5 pointtype 7 pointsize 0.8 \
     linecolor rgb "#2E5090" title 'RTT Médio (B+C)', \
     '' using 1:3 with linespoints linewidth 2 pointtype 5 pointsize 0.6 \
     linecolor rgb "#8B0000" title 'RTT Máximo (pior caso)', \
     40.0 with lines linewidth 2 linetype 2 linecolor rgb "#D32D41" title 'Limite de Conformidade (40 ms)'

unset label 1
unset label 2
unset label 3

# ============================================================
# GRÁFICO 2: Delivery Ratio e Conformidade
# ============================================================
set ylabel "Delivery Ratio"
set y2label "Conformidade" offset -1,0
set title "Delivery Ratio e Status de Conformidade"
set yrange [0.995:1.005]
set y2range [-0.1:1.1]
set y2tics ("Não Conforme" 0, "Conforme" 1)
set ytics nomirror

# Áreas das fases (redefinir para novo gráfico)
set object 1 rectangle from 0,graph 0 to event_start,graph 1 fillcolor rgb "#90EE90" fillstyle solid 0.1 behind
set object 2 rectangle from event_start,graph 0 to event_end,graph 1 fillcolor rgb "#FFA500" fillstyle solid 0.1 behind
set object 3 rectangle from event_end,graph 0 to 30,graph 1 fillcolor rgb "#87CEEB" fillstyle solid 0.1 behind

# Plot dos dados
plot 'contencao_be_total.dat' using 1:4 with linespoints linewidth 2.5 pointtype 7 pointsize 0.8 \
     linecolor rgb "#006400" title 'Delivery Ratio Médio' axes x1y1, \
     '' using 1:5 with points pointtype 7 pointsize 1.5 \
     linecolor rgb "#06A77D" title 'Status Conforme' axes x1y2, \
     0.99 with lines linewidth 2 linetype 2 linecolor rgb "#D32D41" \
     title 'Limite Mínimo (0.99)' axes x1y1

unset multiplot

# ============================================================
# GRÁFICO ADICIONAL: Análise Detalhada por Fase
# ============================================================
set terminal pngcairo enhanced font 'Arial,10' size 1400,600
set output 'contencao_be_fases.png'

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.8 border -1
set boxwidth 0.9

set title "Estatísticas de Contenção por Fase do Experimento" font ",14"
set ylabel "RTT p99 (ms)"
set xlabel "Fase"
set grid ytics

set key top left

# Dados estatísticos por fase (calculados pelo Python)
$stats << EOD
# Fase          RTT_Medio  RTT_Max_Medio  Pico_RTT
pre_event      0.188      0.260          1.060
join           0.664      1.085          4.700
post_event     0.339      0.524          6.620
EOD

plot '$stats' using 2:xtic(1) title 'RTT Médio' linecolor rgb "#2E5090", \
     ''       using 3:xtic(1) title 'RTT Máx Médio' linecolor rgb "#8B0000", \
     ''       using 4:xtic(1) title 'Pico RTT' linecolor rgb "#D32D41"

print "Gráficos gerados:"
print "  1. contencao_be_total.png - Evolução temporal completa"
print "  2. contencao_be_fases.png - Estatísticas por fase"
