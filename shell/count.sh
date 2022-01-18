#/usr/env bash

awk '{cnt[$2]=$1;i+=1;s+=$1;od[i]=$2;} END{for (i in od) {printf "%d\t%s\t%d\t%.2f%%\n", i, od[i], cnt[od[i]], cnt[od[i]] / s * 100;}}'
