PHELMINO_PATH=`cd ../../; pwd`
PHELMINO_LIB=lib_VHDL
HAS_ERROR=0

function compile {
    if [ $HAS_ERROR = 0 ]; then
        vcom -work ${PHELMINO_LIB} $1 > TMP
        cat TMP
        if [ `cat TMP | grep "** Error" | wc -l` != 0 ]; then
            HAS_ERROR=1
        fi
        rm TMP
    fi
}

if [ ! -e $PHELMINO_PATH ]; then
    mkdir -p $PHELMINO_PATH
fi

vdel -lib ${PHELMINO_PATH}/libs/${PHELMINO_LIB} -all

vlib ${PHELMINO_PATH}/libs/${PHELMINO_LIB}

vmap ${PHELMINO_LIB} ${PHELMINO_PATH}/libs/${PHELMINO_LIB}

compile ../include/phelmino_definitions.vhd 
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
