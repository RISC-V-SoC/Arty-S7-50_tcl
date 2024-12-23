#!/bin/bash
THIS_DIR=$(dirname "$0")
VIVADO_DIR="/opt/Xilinx/Vivado/2024.2"
source ${VIVADO_DIR}/settings64.sh

rm -rf ${THIS_DIR}/.Xil
rm -f ${THIS_DIR}/clockInfo.txt

BUILDDIR=${1:-"build"}
mkdir -p $BUILDDIR
if [ -f "$BUILDDIR/.hog" ]; then
    echo "Another process is already hogging $BUILDDIR"
    exit 1
fi;

rm -r ${BUILDDIR}/*

touch $BUILDDIR/.hog
${VIVADO_DIR}/bin/vivado -mode tcl -source build.tcl -nolog -nojournal -notrace -tclargs $BUILDDIR
rm $BUILDDIR/.hog
