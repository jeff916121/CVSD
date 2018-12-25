
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


deselectAll
uiSetTool move
selectInst CLE/u_sram
setObjFPlanBox Instance CLE/u_sram 376.957 362.8155 648.467 588.7455
uiSetTool move
uiSetTool select


set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer METAL8 -stacked_via_bottom_layer METAL1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top METAL7 bottom METAL7 left METAL6 right METAL6} -width {top 2 bottom 2 left 2 right 2} -spacing {top 0.24 bottom 0.24 left 0.24 right 0.24} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None -use_wire_group 1 -use_wire_group_bits 15 -use_interleaving_wire_group 1
setSrouteMode -viaConnectToShape { ring }
sroute -connect { padPin } -layerChangeRange { METAL1(1) METAL8(8) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort allGeom } -padPinTarget { nearestTarget } -allowJogging 1 -crossoverViaLayerRange { METAL1(1) METAL8(8) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { METAL1(1) METAL8(8) }
panPage 1 0
panPage 1 0
panPage -1 0
panPage -1 0
panPage 1 0
panPage 0 1
panPage 1 0
panPage -1 0
panPage 0 -1
panPage 0 1
panPage 0 -1
panPage 0 -1
panPage 0 -1
saveDesign CHIP/powerring
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length 0 -stacked_via_top_layer METAL8 -stacked_via_bottom_layer METAL1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring }
addStripe -nets {VDD VSS} -layer METAL6 -direction vertical -width 1 -spacing 0.24 -set_to_set_distance 100 -start_from left -start_offset 250 -stop_offset 100 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit METAL8 -padcore_ring_bottom_layer_limit METAL1 -block_ring_top_layer_limit METAL8 -block_ring_bottom_layer_limit METAL1 -use_wire_group 1 -use_interleaving_wire_group 1 -use_wire_group_bits 3 -snap_wire_center_to_grid None -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
deselectAll
zoomOut
zoomOut
panPage 0 1
panPage 0 -1
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
saveDesign CHIP/powerplan
setSrouteMode -viaConnectToShape { ring }
sroute -connect { corePin } -layerChangeRange { METAL1(1) METAL8(8) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { METAL1(1) METAL8(8) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { METAL1(1) METAL8(8) }
setLayerPreference net -isVisible 0
setLayerPreference power -isVisible 0
setLayerPreference pgPower -isVisible 0
setLayerPreference pgGround -isVisible 0
setLayerPreference clock -isVisible 0
setLayerPreference net -isVisible 1
setLayerPreference power -isVisible 1
setLayerPreference pgPower -isVisible 1
setLayerPreference pgGround -isVisible 1
setLayerPreference clock -isVisible 1
setLayerPreference net -isVisible 0
setLayerPreference power -isVisible 0
setLayerPreference pgPower -isVisible 0
setLayerPreference pgGround -isVisible 0
setLayerPreference clock -isVisible 0
setLayerPreference net -isVisible 1
setLayerPreference power -isVisible 1
setLayerPreference pgPower -isVisible 1
setLayerPreference pgGround -isVisible 1
setLayerPreference clock -isVisible 1
setLayerPreference net -isSelectable 0
setLayerPreference power -isSelectable 0
setLayerPreference pgPower -isSelectable 0
setLayerPreference pgGround -isSelectable 0
setLayerPreference clock -isSelectable 0
setLayerPreference net -isSelectable 1
setLayerPreference power -isSelectable 1
setLayerPreference pgPower -isSelectable 1
setLayerPreference pgGround -isSelectable 1
setLayerPreference clock -isSelectable 1
addIoFiller -cell PFEED20Z -prefix IOFILLER
addIoFiller -cell PFEED10Z -prefix IOFILLER
addIoFiller -cell PFEED5Z -prefix IOFILLER
addIoFiller -cell PFEED1Z -prefix IOFILLER
addIoFiller -cell PFEED0_1Z -prefix IOFILLER
addIoFiller -cell PFEED0_01Z -prefix IOFILLER
addIoFiller -cell PFEED0_005Z -prefix IOFILLER -fillAnyGap
redraw
panPage -1 0
panPage 0 1
panPage 0 -1
verifyConnectivity -type all -noUnroutedNet -error 1000 -warning 50
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
saveDesign CHIP/powerroute
createBasicPathGroups -expanded
place_opt_design
checkPlace CHIP.checkPlace
setDrawView place
fit
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports
saveDesign CHIP/placed
update_constraint_mode -name func_mode -sdc_files 
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
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -postCTS
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
saveDesign CHIP/cts.enc
addTieHiLo -cell {TIEHI TIELO} -prefix LTIE
setNanoRouteMode -quiet -routeInsertAntennaDiode 1
setNanoRouteMode -quiet -routeAntennaCellName ANTENNA
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeWithSiPostRouteFix 1
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail -viaOpt -wireOpt
setAnalysisMode -analysisType onChipVariation
saveDesign CHIP/routed
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postRoute -outDir timingReports
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postRoute -outDir timingReports
getFillerMode -quiet
addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 -prefix FILLER
saveDesign CHIP/routed9.6
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
verifyProcessAntenna -reportfile CHIP.antenna.rpt -error 1000
verifyConnectivity -type all -error 1000 -warning 50
saveNetlist CHIP.v
saveDesign CHIP/corefiller
all_hold_analysis_views 
all_setup_analysis_views 
write_sdf CHIP.sdf
set dbgLefDefOutVersion 5.8
global dbgLefDefOutVersion
set dbgLefDefOutVersion 5.8
defOut -floorplan -netlist -scanChain -routing CHIP.def
set dbgLefDefOutVersion 5.8
set dbgLefDefOutVersion 5.8
