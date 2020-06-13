#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just get the cli for a single coin
# e.g "KMD"
specific_coin=$1

if [[ "${specific_coin}" = "CHIPS" ]]; then
  echo chips-cli
fi
if [[ "${specific_coin}" = "GAME" ]]; then
  echo gamecredits-cli
fi
if [[ "${specific_coin}" = "EMC2" ]]; then
  echo einsteinium-cli
fi
if [[ "${specific_coin}" = "GIN" ]]; then
  echo gincoin-cli
fi
if [[ "${specific_coin}" = "KMD" ]]; then
  echo komodo-cli
fi
if [[ "${specific_coin}" = "HUSH3" ]]; then
  echo hush-cli
fi
if [[ "${specific_coin}" = "AYA" ]]; then
  echo aryacoin-cli
fi
if [[ "${specific_coin}" = "MCL" ]]; then
  echo komodo-cli -ac_name=MCL
fi
if [[ "${specific_coin}" = "VRSC" ]]; then
  echo komodo-cli -ac_name=VRSC
fi
