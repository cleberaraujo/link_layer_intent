# Figura 2 — Recovery como intervalos (Gantt-like)
# Mostra duração de NÃO conformidade após join.
# Zoom 8–25s, BE=50, 1 painel.

set terminal pdfcairo enhanced font "Helvetica,10" size 10.5cm,4.8cm
set output "S2_fig2C_intervals_BE50_zoom_8_25.pdf"
set encoding utf8

set xrange [8:25]
set xtics 8,1,25
set xlabel "Tempo (s)"

# eixo Y com duas "faixas" (baseline/adapt)
set yrange [0.5:2.5]
set ytics ("adapt (real)" 1, "baseline (real)" 2)
set ylabel ""

# Evento join
event_start = 10
event_end   = 15
set object 1 rect from event_start, graph 0 to event_end, graph 1 behind \
    fc rgb "#eeeeee" fs solid 0.7 noborder
set label 1 "join" at (event_start+event_end)/2.0,2.35 center font ",9"

# Intervalos de NÃO conformidade (exemplo coerente com o protótipo anterior)
# Substitua apenas os tempos abaixo quando tiver os valores reais:
# - baseline: fora de conformidade do join até t=21.5
# - adapt: fora de conformidade do join até t=18.0 (por exemplo)
baseline_out_start = event_start
baseline_out_end   = 21.5

adapt_out_start = event_start
adapt_out_end   = 18.0

# Desenha barras grossas (linhas com largura alta) como intervalos
set style line 1 lw 10
set style line 2 lw 10

# Barras horizontais (x1,x2) em y fixo usando set arrow (mais simples e limpo)
set arrow 1 from baseline_out_start,2 to baseline_out_end,2 nohead ls 1
set arrow 2 from adapt_out_start,1    to adapt_out_end,1    nohead ls 2

# Marcadores discretos de "recovery"
set arrow 3 from baseline_out_end, graph 0 to baseline_out_end, graph 1 nohead dt 2 lw 1
set arrow 4 from adapt_out_end,    graph 0 to adapt_out_end,    graph 1 nohead dt 2 lw 1

set label 2 sprintf("t_rec=%.1fs", baseline_out_end-event_end) at baseline_out_end,2.15 right font ",8"
set label 3 sprintf("t_rec=%.1fs", adapt_out_end-event_end)    at adapt_out_end,1.15 right font ",8"

# Plot vazio (só para renderizar eixos/objetos)
plot NaN notitle
