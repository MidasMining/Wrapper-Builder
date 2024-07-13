#!/usr/bin/env bash
GPU_COUNT=$1
LOG_FILE=$2
cd `dirname $0`
[ -r mmp-external.conf ] && . mmp-external.conf

get_miner_stats() {
    stats_raw=`curl -s 'http://localhost:5959/'`

    if [[ $? -ne 0 || -z $stats_raw ]]; then
        echo -e "${YELLOW}Failed to read $miner from localhost:5959${NOCOLOR}"
    else
    
    stats=
    local hash=
    $(echo $stats_raw | jq -r '.hashrate')
    # A/R shares by pool
    local acc=
    $(echo $stats_raw | jq -r '.accepted')
    # local inv=$(get_miner_shares_inv)
    local rej=
    REJECTED=$(echo $stats_raw | jq -r '.rejected')

    stats=$(jq -nc \
            --argjson hash "$(echo ${hash[@]} | tr " " "\n" | jq -cs '.')" \
            --arg busid "cpu" \
            --arg units "khs" \
            --arg ac "$acc" --arg inv "0" --arg rj "$rej" \
            --arg miner_version "$EXTERNAL_VERSION" \
            --arg miner_name "$EXTERNAL_NAME" \
        '{busid: [$busid], $hash, $units, air: [$ac, $inv, $rj], miner_name: $miner_name, miner_version: $miner_version}')
    echo $stats
}
get_miner_stats
