
set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
set ::TimeLib::tsgMarkCellLatchConstructFlag 1
set conf_qxconf_file NULL
set conf_qxlib_file NULL
set defHierChar /
set distributed_client_message_echo 1
set distributed_mmmc_disable_reports_auto_redirection 0
set eco_post_client_restore_command {update_timing ; write_eco_opt_db ;}
set enc_enable_print_mode_command_reset_options 1
set init_gnd_net VSS
set init_io_file design_data/CHIP.ioc
set init_lef_file {library/lef/tsmc13fsg_8lm_cic.lef library/lef/tpz013g3_8lm_cic.lef library/lef/RF2SH64x16.vclef library/lef/antenna_8.lef library/lef/sram_1024x8_t13_ant.lef library/lef/sram_1024x8_t13.vclef}
set init_mmmc_file mmmc.view
set init_pwr_net VDD
set init_top_cell CHIP
set init_verilog design_data/CHIP.v
set latch_time_borrow_mode max_borrow
set pegDefaultResScaleFactor 1
set pegDetailResScaleFactor 1
set report_inactive_arcs_format {from to when arc_type sense reason}
set soft_stack_size_limit 96
set tso_post_client_restore_command {update_timing ; write_eco_opt_db ;}
init_design
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site TSM13SITE -r 1 0.1 80 80 80 80
uiSetTool select
getIoFlowFlag
fit
saveDesign CHIP/init
::mp::clearAllSeed
setPlanDesignMode -effort high -incremental false -boundaryPlace true -fixPlacedMacros false -noColorize false
planDesign
selectInst CLE/u_sram
addHaloToBlock {30 30 30 30} -allBlock
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -prePlace -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_prePlace -outDir timingReports
saveDesign CHIP/floorplan


# deselectAll
# uiSetTool move
# selectInst CLE/u_sram
# setObjFPlanBox Instance CLE/u_sram 376.957 362.8155 648.467 588.7455
# uiSetTool move
# uiSetTool select

