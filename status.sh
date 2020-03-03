#!/bin/bash
source /home/eclips/tools2/main
TIMEFORMAT=%R
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
isNumber='^[+-]?([0-9]+\.?|[0-9]*\.[0-9]+)$'
kmdntrzaddr=RXL3YXG2ceaB6C5hfJcN4fvmLH2C34knhA
gamentrzaddr=Gftmt8hgzgNu6f1o85HMPuwTVBMSV2TYSt
ginntrzaddr=Gftmt8hgzgNu6f1o85HMPuwTVBMSV2TYSt
einntrzaddr=EfCkxbDFSn4X1VKMzyckyHaXLf4ithTGoM
txscanamount=2000
if ps aux | grep -v grep | grep iguana >/dev/null
then 
    printf "${GREEN}%-9s${NC}" "iguana"
else
    printf "${RED}%-20s${NC}" "iguana Not Running"
    /home/eclips/tools2/force_iguana.sh
fi
printf "\n"

if ps aux | grep -v grep | grep "src/komodod" | grep -v walletreset > /dev/null; then
    balance="$(komodo-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "komodo"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent=$(komodo-cli listunspent | grep .00010000 | wc -l)
        # Check if we have actual results next two lines check for valid number.
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(komodo-cli -rpcclienttimeout=15 listunspent 2>&1|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.komodo/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time komodo-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(komodo-cli listtransactions "" $txscanamount 2>&1)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 10 )); then
            printf " - Speed1: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed1: ${GREEN}%2s${NC}" $speed
        fi
        #graph
        echo "$(date +%T)" ";" "$listunspent" ";" "$SIZE" ";" "$TIME" ";" "$speed" >> /tmp/graph
    else
        printf "${YELLOW}Komodo Loading${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
else
    printf "${RED}Komodo Not Running${NC}"
fi
printf "\n"

if ps aux | grep -v grep | grep chipsd | grep -v walletreset >/dev/null; then
    balance="$(chips-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "Chips"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(chips-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(chips-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.chips/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time chips-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(chips-cli listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 1 )); then
            printf " - Speed3: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed3: ${GREEN}%2s${NC}" $speed
        fi
    else
        printf "${YELLOW}Chips Loading${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
else
    printf "${RED}CHips Not Running${NC}"
fi
printf "\n"

if ps aux | grep -v grep | grep gamecreditsd | grep -v walletreset >/dev/null; then
    balance="$(gamecredits-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "GameCredits"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(gamecredits-cli -rpcclienttimeout=15 listunspent | grep .00100000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(gamecredits-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.gamecredits/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time gamecredits-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(gamecredits-cli listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$gamentrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$gamentrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 1 )); then
            printf " - Speed3: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed3: ${GREEN}%2s${NC}" $speed
        fi
    else
        printf "${YELLOW}GameCredits Loading${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
else
    printf "${RED}GameCredits Not Running${NC}"
fi
printf "\n"

if ps aux | grep -v grep | grep einsteiniumd | grep -v walletreset >/dev/null; then
    balance="$(einsteinium-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "Einsteinium"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(einsteinium-cli -rpcclienttimeout=15 listunspent | grep .00100000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(einsteinium-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.einsteinium/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time einsteinium-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(einsteinium-cli listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$einntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$einntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 1 )); then
            printf " - Speed3: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed3: ${GREEN}%2s${NC}" $speed
        fi
    else
        printf "${YELLOW}Einsteinium Loading${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
else
    printf "${RED}Einsteinium Not Running${NC}"
fi
printf "\n"


if ps aux | grep -v grep | grep gincoind | grep -v walletreset >/dev/null; then
    balance="$(gincoin-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "Gincoin"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(gincoin-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(gincoin-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.gincoincore/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time gincoin-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(gincoin-cli listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$ginntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$ginntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 1 )); then
            printf " - Speed3: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed3: ${GREEN}%2s${NC}" $speed
        fi
    else
        printf "${YELLOW}Gincoin Loading${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
else
    printf "${RED}Gincoin Not Running${NC}"
fi
printf "\n"


if ps aux | grep -v grep | grep "HUSH3" | grep -v walletreset >/dev/null; then
    balance="$(hush-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "Hush"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(hush-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(hush-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.komodo/HUSH3/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time hush-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(hush-cli listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 1 )); then
            printf " - Speed3: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed3: ${GREEN}%2s${NC}" $speed
        fi
    else
        printf "${YELLOW}Hush Loading${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
else
    printf "${RED}Hush Not Running${NC}"
fi
printf "\n"
