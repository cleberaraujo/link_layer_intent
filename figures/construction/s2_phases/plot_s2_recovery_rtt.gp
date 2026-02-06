# ==========================================
# S2 – Recovery: RTT P99 ao longo do tempo
# ==========================================

set terminal pdfcairo size 14cm,8cm font "Helvetica,10"
set output "s2_recovery_rtt.pdf"

set xlabel "Tempo após o evento (s)"
set ylabel "RTT P99 (ms)"

set grid
set key outside right

# Limite da intenção
INTENT_RTT_LIMIT = 40

# Linha do limite
set arrow from graph 0, first INTENT_RTT_LIMIT to graph 1, first INTENT_RTT_LIMIT \
    nohead lw 2 lc rgb "#aa0000"
set label "RTT max (intenção)" at graph 0.02,INTENT_RTT_LIMIT+1 tc rgb "#aa0000"

# Linha vertical no fim do evento (t = 0)
set arrow from 0, graph 0 to 0, graph 1 nohead lw 2 lc rgb "#444444"
set label "Fim do evento" at 0.1, graph 0.95 rotate by 90 tc rgb "#444444"

# Extração:
# start_ms → segundos
plot \
  "< jq -r '.recovery.series[] | [.start_ms/1000, .rtt_p99_ms_B] | @tsv' S2_20260205T175440Z.json" \
      using 1:2 with linespoints lw 2 pt 7 title "Domínio B", \
  "< jq -r '.recovery.series[] | [.start_ms/1000, .rtt_p99_ms_C] | @tsv' S2_20260205T175440Z.json" \
      using 1:2 with linespoints lw 2 pt 5 title "Domínio C"
