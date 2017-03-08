#!/bin/bash
HAS_ERROR=0

function compile {
    if [ $HAS_ERROR = 0 ]; then
        ./${1} > TMP2
        cat TMP2
        if [ `cat TMP2 | grep "** Error" | wc -l` != 0 ]; then
            HAS_ERROR=1
        fi
        if [ `cat TMP2 | grep "** Warning:" | wc -l` != 0 ]; then
            HAS_ERROR=1
        fi
        rm TMP2
    fi
}

cd vhd/
compile compil_phelmino.sh
cd ../testbench/
compile compil_bench.sh
cd ..
