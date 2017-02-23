BENCH_PATH=`cd ../../; pwd`
BENCH_LIB=lib_BENCH
HAS_ERROR=0

function compile {
    if [ $HAS_ERROR = 0 ]; then
        vcom -work ${BENCH_LIB} $1 > TMP
        cat TMP
        if [ `cat TMP | grep "** Error" | wc -l` != 0 ]; then
            HAS_ERROR=1
        fi
        rm TMP
    fi
}

if [ ! -e $BENCH_PATH ]; then
    mkdir -p $BENCH_PATH
fi

vdel -lib  ${BENCH_PATH}/libs/${BENCH_LIB} -all

vlib ${BENCH_PATH}/libs/${BENCH_LIB}

vmap ${BENCH_LIB} ${BENCH_PATH}/libs/${BENCH_LIB}

compile test_general_purpose_registers.vhd
compile test_if_stage.vhd
compile test_fifo.vhd 
