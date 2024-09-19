#!/bin/bash
BASEDIR="/opt/Xilinx/Vivado/2023.2"
source ${BASEDIR}/settings64.sh
${BASEDIR}/bin/vivado -mode tcl -source upload.tcl -log /tmp/executeTcl.log -journal /tmp/executeTcl.jou
