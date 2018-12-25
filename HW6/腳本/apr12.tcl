saveDesign CHIP/corefiller
saveNetlist CHIP_apr.v
all_hold_analysis_views 
all_setup_analysis_views 
write_sdf CHIP_apr.sdf
set dbgLefDefOutVersion 5.8
global dbgLefDefOutVersion
set dbgLefDefOutVersion 5.8
defOut -floorplan -netlist -scanChain -routing CHIP_apr.def
set dbgLefDefOutVersion 5.8
set dbgLefDefOutVersion 5.8
