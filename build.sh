#!/bin/bash

source vivado.env

THIS_DIR=$(dirname "$0")

rm -rf ${THIS_DIR}/.Xil
rm -f ${THIS_DIR}/clockInfo.txt

BUILDDIR=${1:-"build"}
mkdir -p $BUILDDIR
if [ -f "$BUILDDIR/.hog" ]; then
    echo "Another process is already hogging $BUILDDIR"
    exit 1
fi;

rm -rf ${BUILDDIR}/*

touch $BUILDDIR/.hog
${VIVADO_DIR}/bin/vivado -mode tcl -source build.tcl -nolog -nojournal -notrace -tclargs $BUILDDIR
rm $BUILDDIR/.hog
