#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just split UTXOs for a single coin
# e.g "KMD"
coin=$1

kmd_target_utxo_count=30
kmd_split_threshold=10

btc_target_utxo_count=30
btc_split_threshold=10

other_target_utxo_count=30
other_split_threshold=10

date=$(date +%Y-%m-%d:%H:%M:%S)

calc() {
    awk "BEGIN { print "$*" }"
}

if [[ -z "${coin}" ]]; then
    /home/eclips/tools2/listcoins.sh | while read coin; do
    /home/eclips/tools2/utxosplitter.sh $coin &
done;
exit;
fi

cli=$(./listclis.sh ${coin})

if [[ "${coin}" = "KMD" ]]; then
    target_utxo_count=$kmd_target_utxo_count
    split_threshold=$kmd_split_threshold
elif [[ "${coin}" = "BTC" ]]; then
    target_utxo_count=$btc_target_utxo_count
    split_threshold=$btc_split_threshold
else
    target_utxo_count=$other_target_utxo_count
    split_threshold=$other_split_threshold
fi

satoshis=10000
if [[ ${coin} = "GAME" || ${coin} = "EMC2" ||  ${coin} = "AYA"]]; then
    satoshis=100000
fi
amount=$(calc $satoshis/100000000)

unlocked_utxos=$(${cli} listunspent | jq -r '.[].amount' | grep ${amount} | wc -l)
locked_utxos=$(${cli} listlockunspent | jq -r length)
utxo_count=$(calc ${unlocked_utxos}+${locked_utxos})

utxo_required=$(calc ${target_utxo_count}-${utxo_count})

if [[ ${utxo_count} -le ${split_threshold} ]]; then
    echo "[${coin}] Splitting ${utxo_required} extra UTXOs"
    json=$(/home/eclips/tools2/acsplit ${coin} ${utxo_required})
    txid=$(echo ${json} | jq -r '.txid')
    if [[ ${txid} != "null" ]]; then
        echo "[${coin}] Split TXID: ${txid}"
    else
        echo "[${coin}] Error: $(echo ${json} | jq -r '.error')"
    fi
fi
