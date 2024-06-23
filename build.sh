#!/bin/bash
BASEDIR="${HOME}/opt/Xilinx/Vivado/2024.1"
source ${BASEDIR}/settings64.sh

BUILDDIR=${1:-"build"}
mkdir -p $BUILDDIR
if [ -f "$BUILDDIR/.hog" ]; then
    echo "Another process is already hogging $BUILDDIR"
    exit 1
fi;
touch $BUILDDIR/.hog
${BASEDIR}/bin/vivado -mode tcl -source build.tcl -nolog -nojournal -notrace -tclargs $BUILDDIR
rm $BUILDDIR/.hog
