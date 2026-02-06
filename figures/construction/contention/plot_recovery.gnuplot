set terminal pdfcairo font "sans,10" size 6in,4in
set output 'recovery.pdf'

set title "Recuperação e Contenção BE (Intervalos 500ms)"
set xlabel "Tempo (ms)"
set ylabel "RTT p99 (ms)"
set y2label "Taxa de Entrega"
set y2range [0.95:1.02]
set ytics nomirror
set y2tics
set grid
set key outside bottom center horizontal
set datafile separator "\t"

# Linha de limite de conformidade (40ms)
set arrow from graph 0, first 40 to graph 1, first 40 nohead lc rgb "red" dt 2

# Plotagem corrigida (certifique-se de que não há espaços após a \)
plot 'recovery.dat' using 1:2 with lines lw 1.5 title "RTT B" lc rgb "#1f77b4", \
     'recovery.dat' using 1:3 with lines lw 1.5 title "RTT C" lc rgb "#ff7f0e", \
     'recovery.dat' using 1:4 with points pt 7 ps 0.4 axes x1y2 title "Entrega B" lc rgb "#2ca02c"
