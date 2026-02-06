#!/usr/bin/env python3
import json
import statistics

# Carregar dados
with open('S2_20260205T175440Z.json', 'r') as f:
    data = json.load(f)

recovery = data['recovery']
series = recovery['series']

print("="*80)
print("CONTENÇÃO DO TRÁFEGO BE AO LONGO DO TEMPO")
print("="*80)
print(f"\nConfiguração:")
print(f"  - Tráfego BE configurado: {data['environment']['be_mbps']} Mbps")
print(f"  - Throughput total medido: {data['metrics']['throughput_B_mbps'] + data['metrics']['throughput_C_mbps']:.3f} Mbps")
print(f"  - Intervalo de medição: {recovery['bin_ms']} ms")
print(f"  - Total de amostras: {len(series)}")
print(f"\nLimites de conformidade:")
print(f"  - RTT máximo: {recovery['rtt_limit_ms']} ms")
print(f"  - Delivery Ratio mínimo: {recovery['delivery_limit']}")

print("\n" + "="*80)
print("DADOS DE CONTENÇÃO (agregado B + C)")
print("="*80)
print(f"{'Tempo(s)':<12} {'RTT_Médio(ms)':<15} {'RTT_Máx(ms)':<15} {'Delivery_Médio':<15} {'Conforme':<10}")
print("-"*80)

# Gerar arquivo de dados para análise
with open('contencao_be_total.dat', 'w') as f:
    f.write("# Tempo_s RTT_Medio_ms RTT_Max_ms Delivery_Medio Conforme Fase\n")
    f.write("# Contenção total do tráfego BE (agregado de B e C)\n")
    f.write("# Fase: 0=pre_event, 1=join, 2=post_event\n")
    
    for s in series:
        time_s = (s['start_ms'] + s['end_ms']) / 2 / 1000
        
        # Métricas agregadas
        rtt_medio = (s['rtt_p99_ms_B'] + s['rtt_p99_ms_C']) / 2
        rtt_max = max(s['rtt_p99_ms_B'], s['rtt_p99_ms_C'])
        delivery_medio = (s['delivery_ratio_B'] + s['delivery_ratio_C']) / 2
        conforme = 1 if s['intent_ok'] else 0
        
        # Determinar fase
        if s['start_ms'] < recovery['event_start_ms']:
            fase = 0  # pre_event
        elif s['start_ms'] < recovery['event_end_ms']:
            fase = 1  # join
        else:
            fase = 2  # post_event
        
        f.write(f"{time_s:.3f} {rtt_medio:.3f} {rtt_max:.3f} {delivery_medio:.4f} {conforme} {fase}\n")
        
        # Imprimir na tela (apenas alguns pontos para não sobrecarregar)
        if len(series) <= 20 or time_s % 5 < 0.5:  # Imprimir a cada ~5s
            conforme_str = "SIM" if conforme else "NÃO"
            print(f"{time_s:>11.2f}  {rtt_medio:>14.3f}  {rtt_max:>14.3f}  {delivery_medio:>14.4f}  {conforme_str:<10}")

print("-"*80)

# Estatísticas por fase
print("\n" + "="*80)
print("ESTATÍSTICAS POR FASE")
print("="*80)

phases_data = {
    'pre_event': {'rtt_medio': [], 'rtt_max': [], 'delivery': []},
    'join': {'rtt_medio': [], 'rtt_max': [], 'delivery': []},
    'post_event': {'rtt_medio': [], 'rtt_max': [], 'delivery': []}
}

for s in series:
    rtt_medio = (s['rtt_p99_ms_B'] + s['rtt_p99_ms_C']) / 2
    rtt_max = max(s['rtt_p99_ms_B'], s['rtt_p99_ms_C'])
    delivery_medio = (s['delivery_ratio_B'] + s['delivery_ratio_C']) / 2
    
    if s['start_ms'] < recovery['event_start_ms']:
        fase_nome = 'pre_event'
    elif s['start_ms'] < recovery['event_end_ms']:
        fase_nome = 'join'
    else:
        fase_nome = 'post_event'
    
    phases_data[fase_nome]['rtt_medio'].append(rtt_medio)
    phases_data[fase_nome]['rtt_max'].append(rtt_max)
    phases_data[fase_nome]['delivery'].append(delivery_medio)

for fase_nome, dados in phases_data.items():
    if dados['rtt_medio']:
        print(f"\n{fase_nome.upper()}:")
        print(f"  RTT Médio: {statistics.mean(dados['rtt_medio']):.3f} ± {statistics.stdev(dados['rtt_medio']) if len(dados['rtt_medio']) > 1 else 0:.3f} ms")
        print(f"  RTT Máximo: {statistics.mean(dados['rtt_max']):.3f} ± {statistics.stdev(dados['rtt_max']) if len(dados['rtt_max']) > 1 else 0:.3f} ms")
        print(f"  Delivery: {statistics.mean(dados['delivery']):.4f} ± {statistics.stdev(dados['delivery']) if len(dados['delivery']) > 1 else 0:.4f}")
        print(f"  Pico RTT: {max(dados['rtt_max']):.3f} ms")
        print(f"  Amostras: {len(dados['rtt_medio'])}")

print("\n" + "="*80)
print("ARQUIVO GERADO: contencao_be_total.dat")
print("="*80)
print("\nColunas do arquivo:")
print("  1. Tempo_s          - Tempo em segundos")
print("  2. RTT_Medio_ms     - RTT médio entre B e C (indicador de contenção)")
print("  3. RTT_Max_ms       - RTT máximo entre B e C (pior caso)")
print("  4. Delivery_Medio   - Delivery ratio médio")
print("  5. Conforme         - 1=conforme, 0=não conforme")
print("  6. Fase             - 0=pre_event, 1=join, 2=post_event")
print("\nInterpretação:")
print("  • RTT baixo (<1ms) = baixa contenção / boa qualidade")
print("  • RTT alto (>5ms) = alta contenção / congestionamento")
print("  • Delivery próximo a 1.0 = boa entrega de pacotes")
print("="*80)
