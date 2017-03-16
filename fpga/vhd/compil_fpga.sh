fpga_path=`cd ../../; pwd`
fpga_lib=lib_FPGA
has_error=0

function compile {
    if [ $has_error = 0 ]; then
        vcom -work ${fpga_lib} $1 > tmp
        cat tmp
        if [ `cat tmp | grep "** Error" | wc -l` != 0 ]; then
            has_error=1
        fi
        if [ `cat tmp | grep "** Warning:" | wc -l` != 0 ]; then
            has_error=1
        fi
        rm tmp
    fi
}

if [ ! -e $fpga_path ]; then
    mkdir -p $fpga_path
fi

vdel -lib ${fpga_path}/libs/${fpga_lib} -all

vlib ${fpga_path}/libs/${fpga_lib}

vmap ${fpga_lib} ${fpga_path}/libs/${fpga_lib}

compile memory_definitions.vhd 
compile rom.vhd
