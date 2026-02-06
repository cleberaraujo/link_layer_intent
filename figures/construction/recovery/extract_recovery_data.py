#!/usr/bin/env python3
import json

# Carregar dados do JSON
with open('S2_20260205T175440Z.json', 'r') as f:
    data = json.load(f)

recovery = data['recovery']
series = recovery['series']

# Gerar arquivo de dados para RTT
with open('recovery_rtt.dat', 'w') as f:
    f.write("# Time_s RTT_B_ms RTT_C_ms RTT_Limit_ms\n")
    for s in series:
        time_s = (s['start_ms'] + s['end_ms']) / 2 / 1000
        rtt_b = s['rtt_p99_ms_B']
        rtt_c = s['rtt_p99_ms_C']
        rtt_limit = recovery['rtt_limit_ms']
        f.write(f"{time_s:.3f} {rtt_b:.3f} {rtt_c:.3f} {rtt_limit:.1f}\n")

# Gerar arquivo de dados para Delivery Ratio
with open('recovery_delivery.dat', 'w') as f:
    f.write("# Time_s Delivery_B Delivery_C Delivery_Limit\n")
    for s in series:
        time_s = (s['start_ms'] + s['end_ms']) / 2 / 1000
        delivery_b = s['delivery_ratio_B']
        delivery_c = s['delivery_ratio_C']
        delivery_limit = recovery['delivery_limit']
        f.write(f"{time_s:.3f} {delivery_b:.3f} {delivery_c:.3f} {delivery_limit:.2f}\n")

# Gerar arquivo de dados para Intent OK
with open('recovery_intent.dat', 'w') as f:
    f.write("# Time_s Intent_OK\n")
    for s in series:
        time_s = (s['start_ms'] + s['end_ms']) / 2 / 1000
        intent_value = 1 if s['intent_ok'] else 0
        f.write(f"{time_s:.3f} {intent_value}\n")

# Informações das fases
event_start = recovery['event_start_ms'] / 1000
event_end = recovery['event_end_ms'] / 1000

with open('recovery_phases.dat', 'w') as f:
    f.write(f"# event_start event_end\n")
    f.write(f"{event_start:.1f} {event_end:.1f}\n")

print("Arquivos de dados gerados com sucesso!")
print("- recovery_rtt.dat")
print("- recovery_delivery.dat")
print("- recovery_intent.dat")
print("- recovery_phases.dat")
