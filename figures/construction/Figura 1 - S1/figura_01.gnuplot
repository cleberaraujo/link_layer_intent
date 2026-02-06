# Figura 1 — Taxa de conformidade da intenção (S1)
# Robustez: já entra com dados agregados por categoria.
# Saída: PDF

set terminal pdfcairo enhanced font "Helvetica,10" size 12cm,7cm
set output "S1_fig1_conformance_rate.pdf"

set encoding utf8
set key outside right top
set style data histograms
set style histogram clustered gap 1
set style fill solid 0.85 border -1
set boxwidth 0.9

set ylabel "Taxa de conformidade (%)"
set yrange [0:110]
set ytics 0,20,100
set grid ytics

# Tabela agregada:
# Col1 = categoria (xtic)
# Col2 = baseline (real) em %
# Col3 = adapt (real) em %
#
# Preencha com 0 ou 100 (ou 0..100 se você estiver calculando taxa em N repetições).
#$T << EOD
#"bwB=10, BE=0"   100  100
#"bwB=10, BE=20"    0  100
#"bwB=25, BE=0"   100  100
#"bwB=25, BE=50"    0  100
#EOD

$T << EOD
"bwB=10, BE=0"   100  100
"bwB=10, BE=20"    0  100
"bwB=25, BE=0"   100  100
"bwB=25, BE=50"    0  100
EOD

plot \
  $T using 2:xtic(1) title "baseline (real)", \
  '' using 3 title "adapt (real)"
