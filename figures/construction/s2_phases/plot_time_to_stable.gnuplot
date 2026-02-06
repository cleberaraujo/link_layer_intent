# ==========================================
# S2 – Recovery exemplar: RTT p99 vs tempo
# Marca time_to_stable_conformance_ms
# ==========================================

# ----- entrada -----
JSON="S2_20260205T175440Z.json"

# Se você quiser fixar manualmente (como nos valores que você colou):
T_STABLE_MS = 0

# Se preferir ler do JSON, descomente a linha abaixo e comente a anterior:
# T_STABLE_MS = system(sprintf("jq -r '.recovery.time_to_stable_conformance_ms' %s", JSON))

# Converte para segundos
T_STABLE_S = T_STABLE_MS/1000.0

# Limite de RTT (opcional). Se não quiser, deixe como -1.
INTENT_RTT_LIMIT = -1
# Ex.: INTENT_RTT_LIMIT = 40

# ----- saída -----
set terminal pdfcairo size 14cm,8cm font "Helvetica,10"
set output "s2_recovery_time_to_stable_rtt_p99.pdf"

set title "S2 — RTT p99 (ms) vs tempo (bins de 500 ms)"
set xlabel "Tempo (s)"
set ylabel "RTT p99 (ms)"

set grid
set key outside right

# Linha vertical: time_to_stable_conformance
set arrow 10 from T_STABLE_S, graph 0 to T_STABLE_S, graph 1 nohead lw 2
set label 10 sprintf("time_to_stable = %.3fs", T_STABLE_S) at T_STABLE_S, graph 0.95 rotate by 90

# Linha horizontal: limite da intenção (opcional)
if (INTENT_RTT_LIMIT > 0) {
    set arrow 11 from graph 0, first INTENT_RTT_LIMIT to graph 1, first INTENT_RTT_LIMIT nohead lw 2
    set label 11 "RTT max (intenção)" at graph 0.02, first (INTENT_RTT_LIMIT+0.02)
}

# ----- plot -----
# Usamos start_ms como x (s), e rtt_p99_ms_B / rtt_p99_ms_C como y
plot \
  "< jq -r '.recovery.series[] | [.start_ms/1000, .rtt_p99_ms_B] | @tsv' ".JSON \
     using 1:2 with linespoints lw 2 pt 7 title "rtt_p99_ms_B", \
  "< jq -r '.recovery.series[] | [.start_ms/1000, .rtt_p99_ms_C] | @tsv' ".JSON \
     using 1:2 with linespoints lw 2 pt 5 title "rtt_p99_ms_C"
