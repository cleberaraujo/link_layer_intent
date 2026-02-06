# Script Gnuplot para RECOVERY
# Gráfico B: Análise de Recovery - Métricas de Contenção de Tráfego BE (500ms)

reset

# Configurações gerais
set terminal pngcairo enhanced font 'Arial,10' size 1600,1200
set output 'grafico_recovery_gnuplot.png'

# Layout multiplot (3 linhas, 1 coluna)
set multiplot layout 3,1 title "Análise de Recovery - Métricas de Contenção de Tráfego BE (500ms)" font ",16"

# Estilo de grid
set grid xtics ytics linestyle 1 linecolor rgb "#cccccc" linewidth 0.5

# Lê as informações das fases
event_start = 10.0
event_end = 15.0

# ============================================================
# GRÁFICO 1: RTT p99 ao longo do tempo
# ============================================================
set xlabel "Tempo (s)"
set ylabel "RTT p99 (ms)"
set title "Evolução do RTT p99 durante Recovery"
set xrange [0:30]
set key top right

# Definir áreas das fases (backgrounds)
set object 1 rectangle from 0,graph 0 to event_start,graph 1 fillcolor rgb "#90EE90" fillstyle solid 0.1 behind
set object 2 rectangle from event_start,graph 0 to event_end,graph 1 fillcolor rgb "#FFA500" fillstyle solid 0.1 behind
set object 3 rectangle from event_end,graph 0 to 30,graph 1 fillcolor rgb "#87CEEB" fillstyle solid 0.1 behind

# Plot dos dados
plot 'recovery_rtt.dat' using 1:2 with linespoints linewidth 2 pointtype 7 pointsize 0.6 linecolor rgb "#2E86AB" title 'Destino B', \
     ''                 using 1:3 with linespoints linewidth 2 pointtype 5 pointsize 0.6 linecolor rgb "#A23B72" title 'Destino C', \
     ''                 using 1:4 with lines linewidth 2 linetype 2 linecolor rgb "#D32D41" title 'Limite RTT (40 ms)'

# ============================================================
# GRÁFICO 2: Delivery Ratio ao longo do tempo
# ============================================================
set ylabel "Delivery Ratio"
set title "Evolução do Delivery Ratio durante Recovery"
set yrange [0.95:1.01]
set key bottom right

# Manter áreas das fases (backgrounds) - redefinir objetos pois mudamos de gráfico
set object 1 rectangle from 0,graph 0 to event_start,graph 1 fillcolor rgb "#90EE90" fillstyle solid 0.1 behind
set object 2 rectangle from event_start,graph 0 to event_end,graph 1 fillcolor rgb "#FFA500" fillstyle solid 0.1 behind
set object 3 rectangle from event_end,graph 0 to 30,graph 1 fillcolor rgb "#87CEEB" fillstyle solid 0.1 behind

# Plot dos dados
plot 'recovery_delivery.dat' using 1:2 with linespoints linewidth 2 pointtype 7 pointsize 0.6 linecolor rgb "#2E86AB" title 'Destino B', \
     ''                      using 1:3 with linespoints linewidth 2 pointtype 5 pointsize 0.6 linecolor rgb "#A23B72" title 'Destino C', \
     ''                      using 1:4 with lines linewidth 2 linetype 2 linecolor rgb "#D32D41" title 'Limite Delivery (0.99)'

# ============================================================
# GRÁFICO 3: Status de Conformidade (intent_ok) ao longo do tempo
# ============================================================
set ylabel "Conformidade"
set title "Status de Conformidade (Intent OK) - Intervalos de 500ms"
set yrange [-0.1:1.1]
set ytics ("Não Conforme" 0, "Conforme" 1)
set key off

# Manter áreas das fases (backgrounds)
set object 1 rectangle from 0,graph 0 to event_start,graph 1 fillcolor rgb "#90EE90" fillstyle solid 0.1 behind
set object 2 rectangle from event_start,graph 0 to event_end,graph 1 fillcolor rgb "#FFA500" fillstyle solid 0.1 behind
set object 3 rectangle from event_end,graph 0 to 30,graph 1 fillcolor rgb "#87CEEB" fillstyle solid 0.1 behind

# Plot dos dados com área preenchida
plot 'recovery_intent.dat' using 1:2 with filledcurves y1=0 fillcolor rgb "#06A77D" fillstyle solid 0.3 notitle, \
     ''                    using 1:2 with points pointtype 7 pointsize 1.5 linecolor rgb "#06A77D" notitle

unset multiplot

# Adicionar informações sobre recovery (como texto separado)
set terminal pngcairo enhanced font 'Arial,9' size 1600,150
set output 'grafico_recovery_info.png'
unset border
unset tics
unset key
set lmargin 2
set rmargin 2

set label 1 "Informações de Recovery:" at screen 0.02, screen 0.85 font ",11,bold"
set label 2 "• Evento: join (10.0s - 15.0s)" at screen 0.02, screen 0.70
set label 3 "• Tempo até primeira conformidade: 0 ms" at screen 0.02, screen 0.60
set label 4 "• Tempo até conformidade: 0 ms" at screen 0.02, screen 0.50
set label 5 "• Tempo até conformidade estável: 0 ms" at screen 0.02, screen 0.40
set label 6 "• Bins para estabilidade: 3" at screen 0.02, screen 0.30
set label 7 "• Intervalo: 500 ms" at screen 0.02, screen 0.20

plot NaN notitle

print "Gráfico B (recovery) gerado:"
print "  - grafico_recovery_gnuplot.png"
print "  - grafico_recovery_info.png (informações adicionais)"
