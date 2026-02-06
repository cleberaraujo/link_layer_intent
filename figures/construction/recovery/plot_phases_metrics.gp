# Script Gnuplot para PHASES_METRICS
# Gráfico A: Análise de Métricas por Fase do Experimento S2

reset

# Configurações gerais
set terminal pngcairo enhanced font 'Arial,10' size 1500,1000
set output 'grafico_phases_metrics_gnuplot.png'

# Layout multiplot (2x2)
set multiplot layout 2,2 title "Análise de Métricas por Fase do Experimento S2" font ",16"

# Estilo de grid
set grid ytics linestyle 1 linecolor rgb "#cccccc" linewidth 0.5

# ============================================================
# GRÁFICO 1: RTT p99 (ms) - B e C
# ============================================================
set style data histogram
set style histogram cluster gap 1
set style fill solid 0.8 border -1
set boxwidth 0.9

set xlabel "Fase do Experimento"
set ylabel "RTT p99 (ms)"
set title "RTT p99 - Comparação entre Destinos B e C"
set key top right

# Dados inline
$data_rtt << EOD
# Fase        B      C
pre_event    0.4    0.2
join         0.6    2.0
post_event   0.6    0.3
EOD

plot '$data_rtt' using 2:xtic(1) title 'Destino B' linecolor rgb "#2E86AB", \
     ''          using 3:xtic(1) title 'Destino C' linecolor rgb "#A23B72"

# ============================================================
# GRÁFICO 2: Delivery Ratio - B e C
# ============================================================
set ylabel "Delivery Ratio"
set title "Delivery Ratio - Comparação entre Destinos B e C"
set yrange [0.94:1.0]
set key top right

# Linha de conformidade
set arrow from 0.5,0.99 to 3.5,0.99 nohead linetype 2 linecolor rgb "#D32D41" linewidth 2

# Dados inline
$data_delivery << EOD
# Fase        B       C
pre_event    0.970   0.970
join         0.960   0.960
post_event   0.973   0.973
EOD

plot '$data_delivery' using 2:xtic(1) title 'Destino B' linecolor rgb "#2E86AB", \
     ''               using 3:xtic(1) title 'Destino C' linecolor rgb "#A23B72", \
     0.99 title 'Limite Mínimo (0.99)' with lines linetype 2 linecolor rgb "#D32D41" linewidth 2

# ============================================================
# GRÁFICO 3: Status de Conformidade (intent_ok)
# ============================================================
set ylabel "Conformidade"
set title "Status de Conformidade (Intent OK)"
set yrange [-0.2:1.2]
set ytics ("Não Conforme" 0, "Conforme" 1)
set key off

# Dados inline
$data_intent << EOD
# Fase        Status  Color
pre_event    0       1
join         0       1
post_event   0       1
EOD

# Nota: No gnuplot, representamos não-conforme como 0 (vermelho)
plot '$data_intent' using 2:xtic(1):($3==1?0xD32D41:0x06A77D) with boxes linecolor rgb variable

# ============================================================
# GRÁFICO 4: Linha do Tempo das Fases
# ============================================================
set xlabel "Tempo (s)"
set ylabel "Fase"
set title "Linha do Tempo das Fases do Experimento"
set xrange [0:30]
set yrange [-0.5:2.5]
set style fill solid 0.8
set ytics ("pre_event" 0, "join" 1, "post_event" 2)
set key off

# Dados inline para barras horizontais
$data_timeline << EOD
# Fase  Y  Start  Duration  Color
0      0   0      10        0xF18F01
1      1   10     5         0xC73E1D
2      2   15     15        0x06A77D
EOD

# Barras horizontais com rótulos
plot '$data_timeline' using 3:2:4:(0.6):5 with boxxyerrorbars linecolor rgb variable, \
     ''               using ($3+$4/2):2:(sprintf("%ds", int($4))) with labels font ",10" textcolor rgb "white"

unset multiplot

print "Gráfico A (phases_metrics) gerado: grafico_phases_metrics_gnuplot.png"
