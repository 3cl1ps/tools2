#!/usr/bin/env bash
# Find out the size of KMD and other KMD assetchains

# Credits decker, jeezy

RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

function show_walletsize () {
  if [ "$1" = "KMD" ]; then
    SIZE=$(stat ~/.komodo/wallet.dat | grep -Po "\d+" | head -1)
  elif [ "$1" = "CHIPS" ]; then
    SIZE=$(stat ~/.chips/wallet.dat | grep -Po "\d+" | head -1)
  elif [ "$1" = "GAME" ]; then
    SIZE=$(stat ~/.gamecredits/wallet.dat | grep -Po "\d+" | head -1)
  elif [ "$1" = "EMC2" ]; then
    SIZE=$(stat ~/.einsteinium/wallet.dat | grep -Po "\d+" | head -1)
  elif [ "$1" = "GIN" ]; then
    SIZE=$(stat ~/.gincoincore/wallet.dat | grep -Po "\d+" | head -1)
  fi

  OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)

  if [ "$SIZE" -gt "4222944" ]; then
    OUTSTR=${RED}$OUTSTR${RESET}
    printf "[%8s] %16b\n" $1 $OUTSTR
  else
    OUTSTR=${GREEN}$OUTSTR${RESET}
    printf "[%8s] %16b\n" $1 $OUTSTR
  fi
}

show_walletsize KMD
show_walletsize CHIPS
show_walletsize GAME
show_walletsize EMC2
show_walletsize GIN
show_walletsize VRSC
