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
einntrzaddr=EfCkxbDFSn4X1VKMzyckyHaXLf4ithTGoM
ayantrzaddr=Adpj7WENLyRkq9vVknHa82rf3cVHjYvzCG
mclntrzaddr=RXL3YXG2ceaB6C5hfJcN4fvmLH2C34knhA
txscanamount=2000
if ps aux | grep -v grep | grep iguana | grep -v force >/dev/null
then 
    printf "${GREEN}%-9s${NC}" "iguana"
else
    printf "${RED}%-20s${NC}" "iguana Not Running"
fi
printf "\n"

if ps aux | grep -v grep | grep "src/komodod" | grep -v walletreset | grep -v MCL | grep -v TXSCLZ3 > /dev/null; then
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

if ps aux | grep -v grep | grep aryacoind | grep -v walletreset >/dev/null; then
    balance="$(aryacoin-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "AYA"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(aryacoin-cli -rpcclienttimeout=15 listunspent | grep .00100000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(aryacoin-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.aryacoin/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time aryacoin-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(aryacoin-cli listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$ayantrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$ayantrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 1 )); then
            printf " - Speed3: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed3: ${GREEN}%2s${NC}" $speed
        fi
    else
        printf "${YELLOW}AYA Loading${NC}"
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
    printf "${RED}AYA Not Running${NC}"
fi
printf "\n"
if ps aux | grep -v grep |grep komodod | grep MCL | grep -v walletreset >/dev/null; then
    balance="$(komodo-cli -ac_name=MCL -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "MCL"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(komodo-cli -ac_name=MCL -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(komodo-cli -ac_name=MCL -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.komodo/MCL/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time komodo-cli -ac_name=MCL listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(komodo-cli -ac_name=MCL listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$mclntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$mclntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if (( $speed < 1 )); then
            printf " - Speed3: ${RED}%2s${NC}" $speed  
        else
            printf " - Speed3: ${GREEN}%2s${NC}" $speed
        fi
    else
        printf "${YELLOW}MCL Loading${NC}"
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
    printf "${RED}MCL Not Running${NC}"
fi
printf "\n"
if ps aux | grep -v grep | grep verusd | grep -v walletreset >/dev/null; then
    balance="$(komodo-cli -ac_name=VRSC -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "VRSC"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(komodo-cli -ac_name=VRSC -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(komodo-cli -ac_name=VRSC -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.00010000'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.komodo/VRSC/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time komodo-cli -ac_name=VRSC listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(komodo-cli -ac_name=VRSC listtransactions "" $txscanamount)
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
        printf "${YELLOW}VRSC Loading${NC}"
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
    printf "${RED}VRSC Not Running${NC}"
fi
printf "\n"
if ps aux | grep -v grep |grep gleecbtc | grep -v walletreset >/dev/null; then
    balance="$(gleecbtc-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "GLEEC"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(gleecbtc-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(gleecbtc-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.00009850'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.gleecbtc/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        #TIME=$((time gleecbtc-cli listunspent) 2>&1 >/dev/null)
        #if [[ "$TIME" > "0.05" ]]; then
         #   printf " - Time: ${RED}%3ss${NC}" $TIME          
        #else
        #    printf " - Time: ${GREEN}%3ss${NC}" $TIME
        #fi
        #txinfo=$(gleecbtc-cli listtransactions "" $txscanamount)
        #lastntrztime=$(echo $txinfo | jq -r --arg address "$gleecntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        #printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        #now=$(date +%s)
        #window=$(echo "$now - 3*3600" | bc -l)
       # speed=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        #if (( $speed < 1 )); then
        #    printf " - Speed3: ${RED}%2s${NC}" $speed  
        #else
        #    printf " - Speed3: ${GREEN}%2s${NC}" $speed
        #fi
    else
        printf "${YELLOW}MCL Loading${NC}"
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
    printf "${RED}TXSCLZ3 Not Running${NC}"
fi
printf "\n"
if ps aux | grep -v grep |grep powerblockcoin | grep -v walletreset >/dev/null; then
    balance="$(powerblockcoin-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance =~ $isNumber ]]; then
        printf "${GREEN}%-11s${NC}" "PBC"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%5.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%5.2f${NC}" $balance
        fi
        listunspent="$(powerblockcoin-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent =~ $isNumber ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(powerblockcoin-cli -rpcclienttimeout=15 listunspent|grep amount |awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent =~ $isNumber ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.komodo/MCL/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time powerblockcoin-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(powerblockcoin-cli listtransactions "" $txscanamount)
        #lastntrztime=$(echo $txinfo | jq -r --arg address "$pwrntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        #printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        #now=$(date +%s)
        #window=$(echo "$now - 3*3600" | bc -l)
        #speed=$(echo $txinfo | jq -r --arg address "$pwrntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        #if (( $speed < 1 )); then
        #    printf " - Speed3: ${RED}%2s${NC}" $speed  
        #else
         #   printf " - Speed3: ${GREEN}%2s${NC}" $speed
        #fi
    else
        printf "${YELLOW}PBC Loading${NC}"
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
    printf "${RED}PBC Not Running${NC}"
fi
printf "\n"
