#!/bin/bash
# Suggest using with this command: watch --color -n 60 ./status
scriptpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scriptpath/main
TIMEFORMAT=%R
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
kmdntrzaddr=RXL3YXG2ceaB6C5hfJcN4fvmLH2C34knhA
gamentrzaddr=Gftmt8hgzgNu6f1o85HMPuwTVBMSV2TYSt
ginntrzaddr=Gftmt8hgzgNu6f1o85HMPuwTVBMSV2TYSt
einsteiniumntrzaddr=EfCkxbDFSn4X1VKMzyckyHaXLf4ithTGoM

checkRepo () {
    if [ -z $1 ] ; then
        return
    fi
    repo=(${repos[$1]})
    prevdir=${PWD}

    cd $repo

    git remote update > /dev/null 2>&1

    localrev=$(git rev-parse HEAD)
    remoterev=$(git rev-parse ${repo[1]})
    cd $prevdir

    if [ $localrev != $remoterev ]; then
        printf "${RED}[U]${NC}"
    fi
}

printf "%-9s" "iguana"
if ps aux | grep -v grep | grep iguana >/dev/null
then 
    printf "${GREEN} Running $(checkRepo dPoW)${NC}\n"
else
    printf "${RED} Not Running $(checkRepo dPoW)${NC}\n"
fi

processlist=(
'komodod'
'chipsd'
'game'
'einst'
'gincoin'
)

count=0
while [ "x${processlist[count]}" != "x" ]
do
    printf "%-9s" ${processlist[count]}
    if ps aux | grep -v grep | grep ${processlist[count]} >/dev/null
    then
        printf "${GREEN} Running ${NC}"
        if [ "$count" = "0" ]
        then
            RESULT="$(komodo-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(komodo-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(komodo-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat --printf="%s" /home/eclips/.komodo/wallet.dat)
            TIME=$((time komodo-cli listunspent) 2>&1 >/dev/null)
            txinfo=$(komodo-cli listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
            checkRepo KMD
        fi
        if [ "$count" = "1" ]
        then
            RESULT="$(chips-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(chips-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(chips-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat --printf="%s" /home/eclips/.chips/wallet.dat)
            TIME=$((time chips-cli listunspent) 2>&1 >/dev/null)
            txinfo=$(chips-cli listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
            checkRepo CHIPS
        fi
        if [ "$count" = "2" ]
        then
            RESULT="$(gamecredits-cli -rpcclienttimeout=15 listunspent | grep .00100000 | wc -l)"
            RESULT1="$(gamecredits-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.001'|wc -l)"
            RESULT2="$(gamecredits-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat --printf="%s" /home/eclips/.gamecredits/wallet.dat)
            TIME=$((time gamecredits-cli listunspent) 2>&1 >/dev/null)
            txinfo=$(gamecredits-cli listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$gamentrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
            checkRepo GAME
        fi
        if [ "$count" = "3" ]
        then
            RESULT="$(einsteinium-cli -rpcclienttimeout=15 listunspent | grep .00100000 | wc -l)"
            RESULT1="$(einsteinium-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.001'|wc -l)"
            RESULT2="$(einsteinium-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat --printf="%s" /home/eclips/.einsteinium/wallet.dat)
            TIME=$((time einsteinium-cli listunspent) 2>&1 >/dev/null)
            txinfo=$(einsteinium-cli listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$einsteiniumntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
            checkRepo EMC2
        fi
        if [ "$count" = "4" ]
        then
            RESULT="$(gincoin-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(gincoin-cli -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(gincoin-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat --printf="%s" /home/eclips/.gincoincore/wallet.dat)
            TIME=$((time gincoin-cli listunspent) 2>&1 >/dev/null)
            txinfo=$(gincoin-cli listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$ginntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
            checkRepo GIN
        fi

        # Check if we have actual results next two lines check for valid number.
        if [[ $RESULT == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [ "$RESULT" -lt "15" ]
            then
                printf  " - UTXOs: ${RED}%3s${NC}" $RESULT
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $RESULT
            fi
        fi

        if [[ $RESULT1 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT1 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [ "$RESULT1" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $RESULT1
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $RESULT1
            fi
        fi

        if [[ $RESULT2 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT2 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if (( $(echo "$RESULT2 > 0.1" | bc -l) ));
            then
                printf " - Funds: ${GREEN}%5.2f${NC}" $RESULT2
            else
                printf " - Funds: ${RED}%5.2f${NC}" $RESULT2
            fi
        else
            printf "\n"
        fi

        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi

        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi

        #if [[ "$lastntrztime" > "0.1" ]]; then
        #    printf " - ${RED}%3ss${NC}" $TIME          
        #else
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #fi

        printf "\n"
        RESULT=""
        RESULT1=""
        RESULT2=""
        SIZE=""
        TIME=""

    else
        printf "Process: ${RED} Not Running ${NC}\n"
    fi
    count=$(( $count +1 ))
done
