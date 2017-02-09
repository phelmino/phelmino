#!/bin/bash

PHELMINO_PATH=`pwd`/..
PHELMINO_LIB=lib_VHDL

if [ ! -e $PHELMINO_PATH ]; then
    mkdir -p $PHELMINO_PATH
fi

vdel -lib ${PHELMINO_PATH}/libs/${PHELMINO_LIB}

vlib ${PHELMINO_PATH}/libs/${PHELMINO_LIB}
vmap LIB_VHDL ${PHELMINO_PATH}/libs/${PHELMINO_LIB}

vcom -work ${PHELMINO_LIB} phelmino_core.vhd 
vcom -work ${PHELMINO_LIB} general_purpose_registers.vhd 
vcom -work ${PHELMINO_LIB} if_stage.vhd
vcom -work ${PHELMINO_LIB} id_stage.vhd
vcom -work ${PHELMINO_LIB} ex_stage.vhd
vcom -work ${PHELMINO_LIB} wb_stage.vhd 
