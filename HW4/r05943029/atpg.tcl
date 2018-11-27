

read_netlist FAS_dft.v 
read_netlist /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v

run_build_model FAS
report_violations -all

run_drc FAS_dft.spf


set_faults -model stuck
add_faults -all

 
set_atpg -abort_limit 100 -merge high
run_atpg -auto_compression


report_summaries 
set_faults -report collapsed  
set_faults -fault_coverage  
report_patterns -all  
report_summaries 

 
write_patterns FAS_atpg.wgl -format WGL
write_patterns FAS_atpg.stil -format STIL -vcs  

report_summaries 
