update_constraint_mode -name func_mode -sdc_files design_data/CHIP_cts.sdc 
update_constraint_mode -name scan_mode -sdc_files design_data/CHIP_scan_ideal_cts.sdc 
create_ccopt_clock_tree_spec -file ./ccopt.spec
ccopt_check_and_flatten_ilms_no_restore
create_ccopt_clock_tree -name clk -source clk -no_skew_group
set_ccopt_property clock_period -pin clk 10
create_ccopt_skew_group -name clk/func_mode -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/func_mode true
set_ccopt_property extracted_from_clock_name -skew_group clk/func_mode clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/func_mode func_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk/func_mode {Delay_Corner_max Delay_Corner_min}
check_ccopt_clock_tree_convergence
get_ccopt_property auto_design_state_for_ilms
ccopt_design -cts
saveDesign CHIP/cts
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
