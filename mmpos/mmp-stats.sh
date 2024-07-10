#!/usr/bin/env bash
GPU_COUNT=$1
LOG_FILE=$2
cd `dirname $0`
[ -r mmp-external.conf ] && . mmp-external.conf

get_cpu_hashes() {
    hash=''
    local hs=$(cat $LOG_FILE |grep -oP "HASHRATE \K\d+.\d+"|tail -n1)
    if [[ -z "$hs" ]]; then
        local hs="0"
    fi
    if [[ ${hs} > 0 ]]; then
        hash=$(echo $hs)
    fi
}

get_miner_shares_acc() {
    acc=''
    local ac=$(cat $LOG_FILE |grep -oP "ACCEPTED \K\d+"|tail -n1)
    if [[ -z "$ac" ]]; then
        local ac="0"
    fi
    if [[ ${ac} > 0 ]]; then
        acc=$(echo $ac)
    fi
}

get_miner_shares_rej() {
    rej=''
    local rj=$(cat $LOG_FILE |grep -oP "REJECTED \K\d+"|tail -n1)
    if [[ -z "$rj" ]]; then
        local rj="0"
    fi
    if [[ ${rj} > 0 ]]; then
        rej=$(echo $rj)
    fi
}

get_miner_stats() {
    stats=
    local hash=
    get_cpu_hashes
    # A/R shares by pool
    local acc=
    get_miner_shares_acc
    # local inv=$(get_miner_shares_inv)
    local rej=
    get_miner_shares_rej

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
