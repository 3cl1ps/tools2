#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="KMD"
daemon="/home/eclips/komodo/src/komodod -pubkey=${PUBKEY} -minrelaytxfee=0.000035 -opretmintxfee=0.004"
daemon_process_regex="komodod.*\-pubkey.*\-minrelaytxfee"
cli="komodo-cli"
wallet_file="${HOME}/.komodo/wallet.dat"
nn_address=$KMDADDRESS

/home/eclips/install/walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
