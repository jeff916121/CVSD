source /usr/cadence/cshrc
source /usr/spring_soft/CIC/verdi.cshrc
ncverilog +ncmaxdelays testfixture_b_pre.v CLE_syn.v -v tsmc13.v +define+SDF +access+rw

