#!/bin/bash

source /home/eclips/tools2:/main
# Coin we're resetting
coin=$1

daemon="komodod $(/home/eclips/tools2/listassetchainparams ${coin}) -pubkey=$PUBKEY"
daemon_process_regex="komodod.*\-ac_name=${coin} -"
cli="komodo-cli -ac_name=${coin}"
wallet_file="${HOME}/.komodo/${coin}/wallet.dat"

/home/eclips/install/walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${KMDADDRESS}"
