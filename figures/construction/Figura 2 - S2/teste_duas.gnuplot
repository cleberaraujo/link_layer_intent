# Figura composta: plot principal + inset (zoom/intervalos)
# Mantém a ideia: usar o máximo do horizontal sem gastar altura extra.

set terminal pdfcairo enhanced font "Helvetica,10" size 15cm,6cm
#set terminal pdfcairo enhanced font "Helvetica,10" size 16.5cm,6cm
set output "S2_fig2_com_inset.pdf"
set encoding utf8

# -------------------------
# Dados do painel principal (igual ao seu figura_023_essa.gnuplot)
$R << EOD
0   2000  1000
25  5000  2000
50  8000  3000
EOD

# -------------------------
# MULTIPLOT: desenha o principal, depois desenha o inset por cima
set multiplot

# --- Painel principal (ocupa tudo)
unset object; unset label; unset arrow
set key top left
set grid ytics
set xlabel "Contenção (BE, Mbps)"
set ylabel "Tempo até conformidade estável (s)"
set xtics ( "0" 0, "25" 25, "50" 50 )

set tmargin 2
set bmargin 3
set lmargin 8
set rmargin 2

plot \
  $R using 1:($2/1000.0) with linespoints lw 2 title "baseline (real)", \
  $R using 1:($3/1000.0) with linespoints lw 2 title "adapt (real)"

# --- INSET: coordenadas em fração da tela
# Ajustar size/origin até ficar “bonito” sem tampar legenda/curvas.
unset key
set size 0.48,0.55
set origin 0.50,0.38

# Moldura do inset: deixe mais “limpo”
set border lw 1
set grid xtics
unset ylabel
set xlabel "Tempo (s)" offset 0,0.5

set xrange [9:23]
set xtics 8,1,25
set yrange [0.5:2.5]
set ytics ("adapt" 1, "baseline" 2)

# Zona do join (igual sua ideia)
event_start = 10
event_end   = 15
set object 1 rect from event_start, graph 0 to event_end, graph 1 behind \
    fc rgb "#eeeeee" fs solid 0.7 noborder
set label 1 "join" at (event_start+event_end)/2.0,2.35 center font ",9"

baseline_out_start = event_start
baseline_out_end   = 21.5
adapt_out_start = event_start
adapt_out_end   = 18.0

set style line 1 lw 10
set style line 2 lw 10
set arrow 1 from baseline_out_start,2 to baseline_out_end,2 nohead ls 1
set arrow 2 from adapt_out_start,1    to adapt_out_end,1    nohead ls 2
set arrow 3 from baseline_out_end, graph 0 to baseline_out_end, graph 1 nohead dt 2 lw 1
set arrow 4 from adapt_out_end,    graph 0 to adapt_out_end,    graph 1 nohead dt 2 lw 1

set label 2 sprintf("t_rec=%.1fs", baseline_out_end-event_end) at baseline_out_end,2.15 right font ",8"
set label 3 sprintf("t_rec=%.1fs", adapt_out_end-event_end)    at adapt_out_end,1.15 right font ",8"

plot NaN notitle

unset multiplot
set output
