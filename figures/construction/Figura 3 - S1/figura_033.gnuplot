set terminal pdfcairo size 8cm,5cm font ",9"
set output "figura_03_overhead_boxplot.pdf"

set style data boxplot
set style boxplot outliers pointtype 7
set style fill solid 0.6 border -1
set boxwidth 0.55

set grid ytics
set ylabel "Tempo total de execução (s)"
set xlabel ""

# Força o gráfico a mostrar as duas categorias
set xrange [0.5:2.5]
set xtics ("baseline–real" 1, "adapt–real" 2)

# Dados: apenas valores (em segundos), um bloco por modo
$B << EOD
69.28
69.32
69.08
69.50
69.31
EOD

$A << EOD
71.36
70.77
70.58
70.26
70.63
EOD

# Cada bloco vira um boxplot fixado em x=1 e x=2
plot \
  $B using (1):1 notitle, \
  $A using (2):1 notitle
