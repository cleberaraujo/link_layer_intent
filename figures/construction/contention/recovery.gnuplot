set terminal pdfcairo font "sans,10" size 6in,4in
set output 'recovery.pdf'

set title "Série Temporal de Recuperação (Bins 500ms)"
set xlabel "Tempo (ms)"
set ylabel "RTT p99 (ms)"
set y2label "Taxa de Entrega"
set y2range [0:1.1]
set ytics nomirror
set y2tics
set grid
set key outside top center horizontal

# Definindo o limite de conformidade (40ms conforme seu JSON)
set arrow from graph 0, first 40 to graph 1, first 40 nohead lc rgb "red" dt 2

plot 'recovery.dat' using 1:2 with linespoints title "RTT B" pt 7, \
     'recovery.dat' using 1:3 with linespoints title "RTT C" pt 5, \
     'recovery.dat' using 1:4 with impulses axes x1y2 title "Entrega (Y2)" lc rgb "green"
