#user defined variables
set proj  async_fifo
set path_rtl ../src/rtl/
set path_sim ../src/sim/

set f_rtl_list {
                empty_logic.v
                full_logic.v
                r2w_sync.v
                ram.v
                rd_addr_cntl.v
                w2r_sync.v
                wr_addr_cntl.v
                top_asfifo.v
}

set f_sim_list {
                rpt_pkg.sv
                access_pkg.sv
                checker_pkg.sv
                test_pkg.sv
                tb_fifo.sv
}

set tb tb_fifo
set sim_time 1ns/1ps

# string handle
set vlog_command "vlog -novopt -lint -l comp.txt -timescale ${sim_time}  +incdir+${path_rtl}  +indcdir+${path_sim}"
set vsim_command "vsim -i -wlf ${proj}.wlf -default_radix hexadecimal -title ${proj} -novopt work.${tb} -l simlog.txt" 

foreach i ${f_rtl_list} {
    set vlog_command "$vlog_command ${path_rtl}$i "
}

foreach i ${f_sim_list} {
    set vlog_command "$vlog_command ${path_sim}$i "
}

#complier
eval $vlog_command

#sim
eval $vsim_command

#log and signals
log -r /*
add wave /${tb}/dut/*
