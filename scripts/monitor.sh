#!/usr/bin/env bash
export LC_ALL=C

if [[ $# -ne 1 || ! $1 =~ ^[1-9][0-9]*$ ]]; then
    echo "Usage: $0 PID" >&2
    exit 1
fi

pid="$1"
echo "timestamp,pid,ppid,elapsed_s,cpu_avg_pct,mem_pct,rss_kib,threads,state"

while true; do
    row=$(ps -p "$pid" \
        -o pid=,ppid=,etimes=,pcpu=,pmem=,rss=,nlwp=,stat= \
        2>/dev/null |
        awk '$8 !~ /^Z/ {
            printf "%s,%s,%s,%s,%s,%s,%s,%s", \
                $1,$2,$3,$4,$5,$6,$7,$8
        }')

    [[ -n "$row" ]] || break
    printf '%s,%s\n' "$(date -Iseconds)" "$row"
    sleep 1
done

echo "Monitoring ended: PID $pid is no longer running." >&2
