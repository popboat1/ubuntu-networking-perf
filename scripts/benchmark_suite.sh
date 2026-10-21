set -euo pipefail

MODE="${1:-}"
TARGET_IP="${2:-}"
RUNS=30
DURATION=5
SLEEP_INTERVAL=1

if [[ -z "$MODE" || -z "$TARGET_IP" ]]; then
    echo "error: missing required arguments"
    echo "usage: $0 <mode: nat|hostonly|bridged> <target_ip>"
    exit 1
fi

IPERF_OUT="${MODE}_iperf.txt"
PING_OUT="${MODE}_ping.txt"

# backup existing outputs rather than blind overwriting
[[ -f "$IPERF_OUT" ]] && mv "$IPERF_OUT" "${IPERF_OUT}.bak"
[[ -f "$PING_OUT" ]] && mv "$PING_OUT" "${PING_OUT}.bak"

echo "=== starting ${RUNS}-run benchmark: mode=${MODE}, target=${TARGET_IP} ==="

for i in $(seq 1 "$RUNS"); do
    echo "--- run ${i}/${RUNS} ---"
    
    # capture ping summary line (rtt min/avg/max/mdev)
    ping -c 5 "$TARGET_IP" | tail -1 | tee -a "$PING_OUT"
    
    # capture receiver summary line from iperf3
    iperf3 -c "$TARGET_IP" -t "$DURATION" | grep receiver | tee -a "$IPERF_OUT"
    
    sleep "$SLEEP_INTERVAL"
done

echo "=== benchmark complete for ${MODE}. outputs: ${IPERF_OUT}, ${PING_OUT} ==="
