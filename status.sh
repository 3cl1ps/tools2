#!/bin/bash
# Suggest using with this command: watch --color -n 60 ./status
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -n -e "iguana \t\t"
if ps aux | grep -v grep | grep iguana >/dev/null
then 
    printf "${GREEN} Running ${NC}\n"
else
    printf "${RED} Not Running ${NC}\n"
fi

processlist=(
#'iguana'
'komodod'
'chipsd'
'gamecredits'
'einsteinium'
'gincoin'
)

count=0
while [ "x${processlist[count]}" != "x" ]
do
  echo -n "${processlist[count]}"
  #fixes formating issues
  size=${#processlist[count]}
  if [ "$size" -lt "8" ]
  then
    echo -n -e "\t\t"
  else
    echo -n -e "\t"
  fi
  if ps aux | grep -v grep | grep ${processlist[count]} >/dev/null
  then
    printf "Process: ${GREEN} Running ${NC}"
    if [ "$count" = "1" ]
    then
            RESULT="$(komodo-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(komodo-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(komodo-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat /home/eclips/.komodo/wallet.dat | grep -Po "\d+" | head -1)
    fi
    if [ "$count" = "2" ]
    then
            RESULT="$(chips-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(chips-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(chips-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat /home/eclips/.chips/wallet.dat | grep -Po "\d+" | head -1)
    fi
    if [ "$count" = "3" ]
    then
            RESULT="$(gamecredits-cli -rpcclienttimeout=15 listunspent | grep .00100000 | wc -l)"
            RESULT1="$(gamecredits-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.001'|wc -l)"
            RESULT2="$(gamecredits-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat /home/eclips/.game/wallet.dat | grep -Po "\d+" | head -1)
    fi
    if [ "$count" = "4" ]
    then
            RESULT="$(einsteinium-cli -rpcclienttimeout=15 listunspent | grep .00100000 | wc -l)"
            RESULT1="$(einsteinium-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.001'|wc -l)"
            RESULT2="$(einsteinium-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat /home/eclips/.einsteinium/wallet.dat | grep -Po "\d+" | head -1)
    fi
    if [ "$count" = "5" ]
    then
            RESULT="$(gincoin-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(gincoin-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(gincoin-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat /home/eclips/.gincoincore/wallet.dat | grep -Po "\d+" | head -1)
    fi
#    if [ "$count" -gt "5" ]
#    then
#            RESULT="$(komodo-cli -rpcclienttimeout=15 -ac_name=${processlist[count]} listunspent | grep .00010000 | wc -l)"
#            RESULT1="$(komodo-cli -ac_name=${processlist[count]} -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
#            RESULT2="$(komodo-cli -rpcclienttimeout=15 -ac_name=${processlist[count]} getbalance)"
#    fi
        # Check if we have actual results next two lines check for valid number.
        if [[ $RESULT == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [ "$RESULT" -lt "30" ]
            then
                printf  " - UTXOs: ${RED}$RESULT\t${NC}"
            else
                printf  " - UTXOs: ${GREEN}$RESULT\t${NC}"
            fi
        fi

        if [[ $RESULT1 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT1 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [ "$RESULT1" -gt "0" ]
            then
                printf  " - Dust: ${RED}$RESULT1\t${NC}"
            else
                printf  " - Dust: ${GREEN}$RESULT1\t${NC}"
            fi
        fi

        if [[ $RESULT2 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT2 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if (( $(echo "$RESULT2 > 0.1" | bc -l) ));
            then
                printf  " - Funds: ${GREEN}$RESULT2\t${NC}"
            else
                printf  " - Funds: ${RED}$RESULT2\t${NC}"
            fi
        else
            printf "\n"
        fi

        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - ${RED}$OUTSTR${NC}\n"            
        else
            printf " - ${GREEN}$OUTSTR${NC}\n"
        fi

        RESULT=""
        RESULT2=""
  else
    printf "Process: ${RED} Not Running ${NC}\n"
    echo "Not Running"
  fi
  count=$(( $count +1 ))
done
