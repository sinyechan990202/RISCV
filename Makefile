TOP      = rv32i_core
TB       = tb/rv32i_core_tb.sv
SIM_OUT  = sim.out

SRCS = \
	rtl/top/rv32i_core.sv \
	rtl/if/if_stage.sv \
	rtl/if/pc_reg.sv \
	rtl/if/instr_mem_if.sv \
	rtl/id/id_stage.sv \
	rtl/id/reg_file.sv \
	rtl/id/imm_gen.sv \
	rtl/id/csr_regfile.sv \
	rtl/ex/ex_stage.sv \
	rtl/ex/alu.sv \
	rtl/ex/branch_unit.sv \
	rtl/ex/forwarding_unit.sv \
	rtl/mem/mem_stage.sv \
	rtl/mem/data_mem_if.sv \
	rtl/wb/wb_stage.sv \
	rtl/pipe/if_id_reg.sv \
	rtl/pipe/id_ex_reg.sv \
	rtl/pipe/ex_mem_reg.sv \
	rtl/pipe/mem_wb_reg.sv \
	rtl/ctrl/hazard_unit.sv

.PHONY: all sim clean wave

all: sim

$(SIM_OUT): $(SRCS) $(TB)
	iverilog -g2012 -o $(SIM_OUT) $(SRCS) $(TB)

sim: $(SIM_OUT)
	vvp $(SIM_OUT)

wave: $(SIM_OUT)
	vvp $(SIM_OUT) -lxt2
	gtkwave dump.vcd &

clean:
	rm -f $(SIM_OUT) *.vcd *.lxt