fpga_path=`cd ../../; pwd`
fpga_lib=lib_FPGA
has_error=0

vlib ${fpga_path}/libs/altera_mf
vmap altera_mf ${fpga_path}/libs/altera_mf
vcom -work altera_mf -2002 -explicit /opt/intelfpga_lite/16.1/quartus/eda/sim_lib/altera_mf_components.vhd
vcom -work altera_mf -2002 -explicit /opt/intelfpga_lite/16.1/quartus/eda/sim_lib/altera_mf.vhd

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
compile ram.vhd
compile seven_segments.vhd 
compile memory_controller.vhd 
compile phelmino.vhd 
compile system.vhd 
