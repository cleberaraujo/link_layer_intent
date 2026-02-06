# Configuração de saída PDF
set terminal pdfcairo font "sans,10" size 5in,3in
set output 'fases.pdf'

set title "Desempenho por Fase - Cenário S2\n(Impacto do Join Multicast)"
set style data histograms
set style fill solid 0.6 border -1
set boxwidth 0.8
set grid y
set ylabel "RTT p99 (ms)"
set xlabel "Fase do Experimento"
set yrange [0:*]  # Garante que o eixo Y comece no zero

# Plotando RTT de B e C por fase conforme os dados do JSON
plot 'fases.dat' using 4:xtic(1) title "Receptor B (RTT)", \
     '' using 5 title "Receptor C (RTT)"
