#!/bin/sh
# run updatemem

exe=$1
mmi=$2
bit=$3
elf=$4
out=$5
procfile=$6

proc=$(cat ${procfile})

"$exe" -meminfo "$mmi" -bit "$bit" -proc "$proc" -data "$elf" -out "$out"
