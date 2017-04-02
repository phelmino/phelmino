#!/bin/bash

> phelmino_rom.txt

if [[ $# -lt 2 ]]; then
   echo "Usage: phelmino_compiler.sh [option] [file]";
   echo "  Compile Assembly or C code into hex file for ROM memory intialization";
   echo "  The options are:";
   echo "  -s   when input file is of extension .S (assembly code)";
   echo "  -c   when input file is of extension .c (C code)";
else
   case $1 in
           "-s") riscv32-unknown-elf-as -fPIC -o riscv_raw_elf $2 ;;
           "-c") riscv32-unknown-elf-gcc -fPIC -o riscv_raw_elf $2 -lm
   esac

   elf2hex 4 65536 riscv_raw_elf > phelmino_rom.txt
fi;
