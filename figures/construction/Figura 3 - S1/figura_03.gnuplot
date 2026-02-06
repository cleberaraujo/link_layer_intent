set terminal pdfcairo size 8cm,5cm font ",9"
set output "figura_03_overhead_cycle.pdf"

set style data boxplot
set style boxplot outliers pointtype 7
set style fill solid 0.6 border -1
set boxwidth 0.5

set grid ytics
set ylabel "Tempo total de execução (s)"
set xlabel ""

set xtics ("baseline–real" 1, "adapt–real" 2)

# Dados: coluna 1 = categoria, coluna 2 = duration_ms em segundos
$D << EOD
1 69.28
1 69.32
1 69.08
1 69.50
1 69.31
2 71.36
2 70.77
2 70.58
2 70.26
2 70.63
EOD

plot $D using 1:2 notitle
