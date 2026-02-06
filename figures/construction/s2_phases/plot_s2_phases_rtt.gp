# ===============================
# S2 – RTT P99 por fase
# ===============================

set terminal pdfcairo size 12cm,8cm font "Helvetica,10"
set output "s2_phases_rtt.pdf"

set style data histograms
set style histogram clustered gap 1
set style fill solid 0.8 border -1
set boxwidth 0.9

set xlabel "Fase do experimento"
set ylabel "RTT P99 (ms)"

set grid ytics
set key outside right

# Limite da intenção (ajuste se necessário)
INTENT_RTT_LIMIT = 40

set arrow from -0.5,INTENT_RTT_LIMIT to 2.5,INTENT_RTT_LIMIT \
    nohead lw 2 lc rgb "#aa0000"
set label "RTT max (intenção)" at 2.55,INTENT_RTT_LIMIT tc rgb "#aa0000"

# Extração on-the-fly do JSON
plot \
  "< jq -r '.phases_metrics[] | [.name, .rtt_p99_ms_B, .rtt_p99_ms_C] | @tsv' S2_20260205T175440Z.json" \
    using 2:xtic(1) title "Domínio B" lc rgb "#1f77b4", \
  "" using 3 title "Domínio C" lc rgb "#ff7f0e"
