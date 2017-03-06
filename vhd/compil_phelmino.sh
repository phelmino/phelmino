phelmino_path=`cd ../; pwd`
phelmino_lib=lib_VHDL
has_error=0

function compile {
    if [ $has_error = 0 ]; then
        vcom -work ${phelmino_lib} $1 > tmp
        cat tmp
        if [ `cat tmp | grep "** error" | wc -l` != 0 ]; then
            has_error=1
        fi
        rm tmp
    fi
}

if [ ! -e $phelmino_path ]; then
    mkdir -p $phelmino_path
fi

vdel -lib ${phelmino_path}/libs/${phelmino_lib} -all

vlib ${phelmino_path}/libs/${phelmino_lib}

vmap ${phelmino_lib} ${phelmino_path}/libs/${phelmino_lib}

compile phelmino_definitions.vhd 
compile decoder.vhd 
compile general_purpose_registers.vhd
compile fifo.vhd
compile alu.vhd 
compile sign_extender.vhd 
compile if_stage.vhd
compile id_stage.vhd
compile ex_stage.vhd
compile wb_stage.vhd 
compile phelmino_core.vhd 
