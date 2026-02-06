# Figura 2 — Tempo até conformidade estável após JOIN (S2)
# 1 painel, muito legível.

set terminal pdfcairo enhanced font "Helvetica,10" size 10.5cm,6cm
set output "S2_fig2_recovery_time_vs_BE.pdf"
set encoding utf8

set key top left
set grid ytics
set xlabel "Contenção (BE, Mbps)"
set ylabel "Tempo até conformidade estável (s)"
set xtics ( "0" 0, "25" 25, "50" 50 )

# Dados: BE  baseline_ms  adapt_ms
# Preencher com seus valores finais (ou medianas, se houver repetições).
$R << EOD
0   2000  1000
25  5000  2000
50  8000  3000
EOD

# Converter ms -> s
plot \
  $R using 1:($2/1000.0) with linespoints lw 2 title "baseline (real)", \
  $R using 1:($3/1000.0) with linespoints lw 2 title "adapt (real)"
