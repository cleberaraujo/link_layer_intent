set terminal pdfcairo font "sans,10" size 6in,3.5in
set output 'contencao_be.pdf'

set title "Comportamento da Contenção Total (Tráfego BE: 80 Mbps)"
set xlabel "Tempo do Experimento (ms)"
set ylabel "RTT Médio Agregado (ms)"
set grid
set style fill transparent solid 0.2 noborder

# Marcar a fase de 'Join' (10000ms a 15000ms) para contexto
set obj 1 rect from 10000, graph 0 to 15000, graph 1 fc rgb "yellow" fs alpha 0.15
set label "Janela de Join" at 12500, graph 0.9 center font ",9"

# Plotagem da contenção
plot 'contencao_total.dat' using 1:2 with lines lw 2 lc rgb "#8b0000" title "Contenção (RTT Médio)", \
     'contencao_total.dat' using 1:2 with points pt 7 ps 0.3 lc rgb "#8b0000" notitle
