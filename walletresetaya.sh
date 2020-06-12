
#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="AYA"
daemon="aryacoind -pubkey=$PUBKEY"
daemon_process_regex="aryacoind.*\-pubkey"
cli="aryacoin-cli"
wallet_file="${HOME}/.aryacoin/wallet.dat"
nn_address=$AYAADDRESS

/home/eclips/install/walletreset2.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
