read_verilog CLE_syn.v 
current_design CLE
link
check_design

source ./CHIP.sdc

report_constraint -all_violators

report_area > CLE_syn.area_rpt 
report_timing > CLE_syn.timing_rpt
report_power > CLE_syn.power_rpt

set test_default_scan_style multiplexed_flip_flop

set test_default_delay 0
set test_default_bidir_delay 0
set test_default_strobe 40
set test_default_period 100

create_test_protocol -infer_asynch -infer_clock
report_constraint -all_violators
dft_drc


set_scan_configuration -chain_count 28
preview_dft
insert_dft 
report_constraint -all_violators 
dft_drc 
report_scan_path -view existing -chain all > CLE_dft.scan_path
report_scan_path -view existing -cell all > CLE_dft.scan_cell

report_area > CLE_syn_dft.area_rpt 
report_timing > CLE_syn_dft.timing_rpt
report_power > CLE_syn_dft.power_rpt

write_test_protocol -output CLE_dft.spf 
write -hierarchy -format verilog -output CLE_dft.v
write -hierarchy -format ddc -output CLE_dft.ddc
write_sdf -version 2.1 CLE_dft.sdf


