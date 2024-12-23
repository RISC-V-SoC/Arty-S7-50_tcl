#!/bin/bash
THIS_DIR=$(dirname "$0")
VIVADO_DIR="/opt/Xilinx/Vivado/2024.2"
source ${VIVADO_DIR}/settings64.sh

BUILDDIR=${1:-"build"}

if [ ! -d "$BUILDDIR" ]; then
    echo "Directory $BUILDDIR does not exist"
    exit 1
fi

if [ -f "$BUILDDIR/.hog" ]; then
    echo "Another process is already hogging $BUILDDIR"
    exit 1
fi;

touch $BUILDDIR/.hog
${VIVADO_DIR}/bin/vivado -mode tcl -source upload.tcl -log /tmp/executeTcl.log -journal /tmp/executeTcl.jou -tclargs $BUILDDIR
rm $BUILDDIR/.hog
