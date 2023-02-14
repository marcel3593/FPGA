#############################
# User variables
#############################
TB       = tb1
SEED     = 1
TESTNAME ?= base_test
DFILES   = ./src/simple_fifo.v
VFILES  += ./src/{rpt_pkg.sv,simple_pkg.sv,$(TB).sv}


#############################
# Environment variables
#############################
VCOMP                = vlogan -full64 -sverilog -timescale=1ns/1ps -nc -l comp.log +incdir+./src/
ELAB                 = vcs -full64 -debug_all -l elab.log -sim_res=1ps
RUN                  = $(TB).simv -l run.log -sml

comp:
	$(VCOMP) $(DFILES) $(VFILES)

elab: 
	$(ELAB) -top $(TB) -o $(TB).simv

run:
	$(RUN) 

rung:
	$(RUN) -gui

editcov:
	urg -full64 -format both -dir $(TB).simv.vdb 
	dve -full64 -cov -dir $(TB).simv.vdb

# option for exlucde file given to generate coverage report 
# if there is such a coverage exclusion file
# urg -dir ... -elfile filename.el
viewcov:
	urg -full64 -format both -dir $(TB).simv.vdb 
	firefox urgReport/dashboard.html

clean:
	rm -rf AN.DB DVEfiles csrc *.simv *.simv.daidir *.simv.vdb ucli.key
	rm -rf *.log* *.vpd urgReport

