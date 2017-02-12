BENCH_PATH=`cd ../../; pwd`
BENCH_LIB=lib_BENCH

if [ ! -e $BENCH_PATH ]; then
    mkdir -p $BENCH_PATH
fi

vdel -lib  ${BENCH_PATH}/libs/${BENCH_LIB} -all

vlib ${BENCH_PATH}/libs/${BENCH_LIB}

vmap ${BENCH_LIB} ${BENCH_PATH}/libs/${BENCH_LIB}

vcom -work ${BENCH_LIB} test_general_purpose_registers.vhd 
