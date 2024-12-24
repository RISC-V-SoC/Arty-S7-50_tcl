proc run_phys_opt {output_dir design_stage_name dont_repeat} {
    set phys_opt_directives "AddRetime \
                            AggressiveExplore \
                            AggressiveFanoutOpt \
                            AlternateReplication \
                            AlternateFlowWithRetiming \
                            ExploreWithAggressiveHoldFix"
    set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
    set prevWNS -1000
    while { $WNS > $prevWNS && $WNS < 0} {
        puts "phys_opt $design_stage_name current WNS: $WNS"
        set prevWNS $WNS
        foreach directive $phys_opt_directives {
            phys_opt_design -directive $directive >> $output_dir/physOpt.log
        }
        set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
        if {$dont_repeat} {
            break
        }
    }
    puts "phys_opt $design_stage_name final WNS: $WNS"
}

proc generate_clk_100_mhz {outputDir} {
    create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name main_clock_gen -dir $outputDir -force
    set_property -dict [list \
        CONFIG.CLKIN1_JITTER_PS {833.33} \
        CONFIG.CLKOUT1_DRIVES {BUFGCE} \
        CONFIG.CLKOUT1_JITTER {479.872} \
        CONFIG.CLKOUT1_PHASE_ERROR {668.310} \
        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100} \
        CONFIG.CLKOUT2_DRIVES {BUFGCE} \
        CONFIG.CLKOUT3_DRIVES {BUFGCE} \
        CONFIG.CLKOUT4_DRIVES {BUFGCE} \
        CONFIG.CLKOUT5_DRIVES {BUFGCE} \
        CONFIG.CLKOUT6_DRIVES {BUFGCE} \
        CONFIG.CLKOUT7_DRIVES {BUFGCE} \
        CONFIG.CLK_OUT1_PORT {CLKSYS} \
        CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
        CONFIG.MMCM_CLKFBOUT_MULT_F {62.500} \
        CONFIG.MMCM_CLKIN1_PERIOD {83.333} \
        CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
        CONFIG.MMCM_CLKOUT0_DIVIDE_F {7.500} \
        CONFIG.PRIMARY_PORT {CLK12MHZ} \
        CONFIG.PRIM_IN_FREQ {12} \
        CONFIG.PRIM_SOURCE {No_buffer} \
        CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
    ] [get_ips main_clock_gen]
    generate_target all [get_files $outputDir/main_clock_gen/main_clock_gen.xci] > $outputDir/main_clock_gen/gen.log
    synth_ip [get_files $outputDir/main_clock_gen/main_clock_gen.xci] > $outputDir/main_clock_gen/synth.log
}

proc generate_clk_125_mhz {outputDir} {
    create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name main_clock_gen -dir $outputDir -force
    set_property -dict [list \
      CONFIG.CLKIN1_JITTER_PS {833.33} \
      CONFIG.CLKOUT1_DRIVES {BUFGCE} \
      CONFIG.CLKOUT1_JITTER {467.172} \
      CONFIG.CLKOUT1_PHASE_ERROR {668.310} \
      CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
      CONFIG.CLKOUT2_DRIVES {BUFGCE} \
      CONFIG.CLKOUT3_DRIVES {BUFGCE} \
      CONFIG.CLKOUT4_DRIVES {BUFGCE} \
      CONFIG.CLKOUT5_DRIVES {BUFGCE} \
      CONFIG.CLKOUT6_DRIVES {BUFGCE} \
      CONFIG.CLKOUT7_DRIVES {BUFGCE} \
      CONFIG.CLK_OUT1_PORT {CLKSYS} \
      CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
      CONFIG.MMCM_CLKFBOUT_MULT_F {62.500} \
      CONFIG.MMCM_CLKIN1_PERIOD {83.333} \
      CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
      CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} \
      CONFIG.PRIMARY_PORT {CLK12MHZ} \
      CONFIG.PRIM_IN_FREQ {12} \
      CONFIG.PRIM_SOURCE {No_buffer} \
      CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
    ] [get_ips main_clock_gen]
    generate_target all [get_files $outputDir/main_clock_gen/main_clock_gen.xci] > $outputDir/main_clock_gen/gen.log
    synth_ip [get_files $outputDir/main_clock_gen/main_clock_gen.xci] > $outputDir/main_clock_gen/synth.log
}

set outputDir [lindex $argv 0]
set synthesisDir $outputDir/synthesis
set optDesignDir $outputDir/optDesign
set placeDesignDir $outputDir/placeDesign
set routeDesignDir $outputDir/routeDesign
set finalDesignDir $outputDir/finalDesign
set home $env(HOME)
file delete -force -- $synthesisDir
file delete -force -- $optDesignDir
file delete -force -- $placeDesignDir
file delete -force -- $routeDesignDir
file delete -force -- $finalDesignDir
file mkdir $synthesisDir
file mkdir $optDesignDir
file mkdir $placeDesignDir
file mkdir $routeDesignDir
file mkdir $finalDesignDir

set_part xc7s50csga324-1
set_property TARGET_LANGUAGE VHDL [current_project]
set_property BOARD_PART_REPO_PATHS $home/.Xilinx/Vivado/2024.2/xhub/board_store/xilinx_board_store [current_project]
set_property BOARD_PART digilentinc.com:arty-s7-50:part0:1.1 [current_project]
set_property DEFAULT_LIB work [current_project]
# generate the clock core
puts "Step 1/5: Creation and synthesis of clock gen module"
generate_clk_100_mhz $outputDir

read_vhdl -vhdl2008 [ glob toplevel.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/main_file.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/common/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/bus/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/bus/bus_cache/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/riscv32_processor/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/riscv32_processor/icache/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/riscv32_processor/pipeline/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/riscv32_processor/utils/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/riscv32_processor/write_back_dcache/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/riscv32_processor/memToBus/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/triple_23lc1024_controller/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/uart_bus_master/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/uart_bus_slave/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/spi_master_device/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/static_soc_info/*.vhd ]
read_vhdl -vhdl2008 [ glob RISC-V-SoC/gpio_controller/*.vhd ]
read_xdc ./Arty-S7-50.xdc

# Synthesis
puts "Step 2/5: Synthesis of our modules"
set SYNTH_ARGS ""
append SYNTH_ARGS " " -flatten_hierarchy " " none " "
append SYNTH_ARGS " " -gated_clock_conversion " " off " "
append SYNTH_ARGS " " -bufg " {" 12 "} "
append SYNTH_ARGS " " -directive " " AlternateRoutability " "
append SYNTH_ARGS " " -keep_equivalent_registers " "
append SYNTH_ARGS " " -fsm_extraction " " auto " "
append SYNTH_ARGS " " -resource_sharing " " off " "
append SYNTH_ARGS " " -control_set_opt_threshold " " 16 " "
append SYNTH_ARGS " " -no_lc " "
append SYNTH_ARGS " " -shreg_min_size " {" 5 "} "
append SYNTH_ARGS " " -max_bram " {" -1 "} "
append SYNTH_ARGS " " -max_dsp " {" -1 "} "
append SYNTH_ARGS " " -cascade_dsp " " auto " "
set_msg_config -id {[Synth 8-327]} -new_severity ERROR
set_msg_config -id {[Synth 8-614]} -new_severity ERROR
set_msg_config -id {[Synth 8-7129]} -suppress
set_msg_config -id {[Synth 8-7080]} -new_severity INFO
set sysclk_freq_mhz [ get_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ [get_ips main_clock_gen] ]
synth_design -top toplevel -generic clk_freq_mhz=$sysclk_freq_mhz {*}$SYNTH_ARGS > $synthesisDir/log

# Optimize design
puts "Step 3/5: Optimize design"
set OPT_ARGS ""
append OPT_ARGS " " -retarget " "
append OPT_ARGS " " -propconst " "
append OPT_ARGS " " -sweep " "
append OPT_ARGS " " -aggressive_remap " "
append OPT_ARGS " " -resynth_remap " "
append OPT_ARGS " " -muxf_remap " "
append OPT_ARGS " " -hier_fanout_limit " " 512 " "
append OPT_ARGS " " -bufg_opt " "
append OPT_ARGS " " -mbufg_opt " "
append OPT_ARGS " " -shift_register_opt " "
append OPT_ARGS " " -dsp_register_opt " "
append OPT_ARGS " " -control_set_opt " "
opt_design {*}$OPT_ARGS > $optDesignDir/log

#Place design
puts "Step 4/5: Place design"
set_clock_uncertainty 0.700 [get_clocks CLKSYS_main_clock_gen]
place_design -directive ExtraTimingOpt > $placeDesignDir/log
set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
set best_WNS $WNS
set iteration 0
set maxIterations 5
report_timing_summary -file $placeDesignDir/timing_summary_initial.rpt -delay_type max -max_paths 50 -quiet
while { $WNS < 0 && $iteration < $maxIterations} {
    puts "Iteration [expr $iteration + 1] / $maxIterations"
    run_phys_opt $placeDesignDir place_design 0
    set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
    report_timing_summary -file $placeDesignDir/timing_summary_$iteration.rpt -delay_type max -max_paths 50 -quiet
    if { $WNS > $best_WNS && $WNS < 0} {
        set best_WNS $WNS
        write_checkpoint -force $placeDesignDir/best_place_design.dcp > /dev/null
        puts "New best WNS: $WNS, checkpoint saved."
    }
    incr iteration
    if {$WNS < 0 && $iteration < $maxIterations} {
        puts "WNS below zero, rerunning place_design with post_place_opt.."
        place_design -post_place_opt >> $placeDesignDir/post_place_place_opt.log
    }
}

if {$WNS < 0} {
    puts "WNS remains below zero, using best checkpoint.."
    read_checkpoint $placeDesignDir/best_place_design.dcp
    link_design > /dev/null
}
set_clock_uncertainty 0 [get_clocks CLKSYS_main_clock_gen]
set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
puts "Place design final WNS (excludes user uncertainty): $WNS"

# Route design
puts "Step 5/5: Route design"
set WNS -1
set iteration 0
while { $WNS < 0} {
    route_design -directive MoreGlobalIterations -tns_cleanup >> $routeDesignDir/log
    run_phys_opt $routeDesignDir route_design 1
    set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
    report_timing_summary -file $routeDesignDir/timing_summary_$iteration.rpt -delay_type max -max_paths 50 -quiet
    incr iteration
    if {$WNS < 0} {
        puts "WNS below zero, rerunning place_design with post_place_opt.."
        place_design -post_place_opt >> $routeDesignDir/post_route_place_opt.log
    }
}

# Finalization
puts "Finishing up, generating reports.."
report_timing_summary -file $finalDesignDir/timing_summary.rpt -quiet
report_timing -sort_by group -max_paths 100 -path_type summary -file $finalDesignDir/timing.rpt -quiet
report_clock_utilization -file $finalDesignDir/clock_utilization.rpt -quiet
report_utilization -file $finalDesignDir/utilization.rpt -quiet
report_power -file $finalDesignDir/power.rpt -quiet
report_drc -file $finalDesignDir/drc.rpt -quiet

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property config_mode SPIx4 [current_design]
write_bitstream -force $finalDesignDir/project.bit > $finalDesignDir/bitgen.log

set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
if {$WNS < 0} {
    puts "Implementation failed, WNS: $WNS"
} else {
    puts "Implementation succesful!"
}
exit
