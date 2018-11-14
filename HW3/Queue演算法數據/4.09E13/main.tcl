# Import Design
read_file -format verilog  "./CLE.v"

current_design [get_designs CLE]
link

source -echo -verbose ./CLE_DC.sdc

# Compile Design
current_design [get_designs CLE]

set high_fanout_net_threshold 0

uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

compile 

# Output Design
current_design [get_designs CLE]

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]

set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

write -format ddc     -hierarchy -output "CLE_syn.ddc"
write -format verilog -hierarchy -output "CLE_syn.v"
write_sdf -version 2.1  CLE_syn.sdf