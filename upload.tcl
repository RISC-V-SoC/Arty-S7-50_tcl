set outputDir [lindex $argv 0]
open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE $outputDir/finalDesign/project.bit [get_hw_devices]
program_hw_device [get_hw_devices]
close_hw_target
disconnect_hw_server
close_hw_manager
exit
