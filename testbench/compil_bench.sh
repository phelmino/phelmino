bench_path=`cd ../; pwd`
bench_lib=lib_BENCH
has_error=0

function compile {
    if [ $has_error = 0 ]; then
        vcom -work ${bench_lib} $1 > tmp
        cat tmp
        if [ `cat tmp | grep "** error" | wc -l` != 0 ]; then
            has_error=1
        fi
        rm tmp
    fi
}

if [ ! -e $bench_path ]; then
    mkdir -p $bench_path
fi

vdel -lib  ${bench_path}/libs/${bench_lib} -all

vlib ${bench_path}/libs/${bench_lib}

vmap ${bench_lib} ${bench_path}/libs/${bench_lib}

compile test_general_purpose_registers.vhd
compile test_if_stage.vhd
compile test_id_stage.vhd 
compile test_fifo.vhd 
compile test_phelmino_core.vhd 
