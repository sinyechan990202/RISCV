# ============================================================
# Makefile — rv32i_core 독립 테스트벤치
#
# 디렉토리 구조
#   tb/
#   ├── Makefile          ← 이 파일 (여기서 실행)
#   ├── sv/
#   │   ├── tb_top.sv
#   │   ├── mem_model.sv
#   │   └── rv32i_checker.sv
#   └── mem/
#       ├── test_main.S
#       └── imem_init.hex
#
# RTL 소스
#   ../RISCV/rtl/**/*.sv  (서브모듈, 읽기 전용)
# ============================================================

# ── 경로 설정 ────────────────────────────────────────────────
RTL_DIR  := ../RISCV/rtl
TB_DIR   := sv
MEM_DIR  := mem

# ── RTL 소스 목록 ────────────────────────────────────────────
RTL_SRCS := \
	$(RTL_DIR)/top/rv32i_core.sv     \
	$(RTL_DIR)/if/if_stage.sv        \
	$(RTL_DIR)/if/pc_reg.sv          \
	$(RTL_DIR)/if/instr_mem_if.sv    \
	$(RTL_DIR)/id/id_stage.sv        \
	$(RTL_DIR)/id/reg_file.sv        \
	$(RTL_DIR)/id/imm_gen.sv         \
	$(RTL_DIR)/id/csr_regfile.sv     \
	$(RTL_DIR)/ex/ex_stage.sv        \
	$(RTL_DIR)/ex/alu.sv             \
	$(RTL_DIR)/ex/branch_unit.sv     \
	$(RTL_DIR)/ex/forwarding_unit.sv \
	$(RTL_DIR)/mem/mem_stage.sv      \
	$(RTL_DIR)/mem/data_mem_if.sv    \
	$(RTL_DIR)/wb/wb_stage.sv        \
	$(RTL_DIR)/pipe/if_id_reg.sv     \
	$(RTL_DIR)/pipe/id_ex_reg.sv     \
	$(RTL_DIR)/pipe/ex_mem_reg.sv    \
	$(RTL_DIR)/pipe/mem_wb_reg.sv    \
	$(RTL_DIR)/ctrl/hazard_unit.sv

# ── TB 소스 목록 ─────────────────────────────────────────────
TB_SRCS  := \
	$(TB_DIR)/mem_model.sv      \
	$(TB_DIR)/rv32i_checker.sv  \
	$(TB_DIR)/tb_top.sv

# ── 출력 파일명 ──────────────────────────────────────────────
SIM_OUT  := sim.out
VCD_OUT  := tb_top.vcd

# ── iverilog 플래그 ──────────────────────────────────────────
IVLOG    := iverilog
IVFLAGS  := -g2012 -Wall \
             -I$(RTL_DIR)/top \
             -I$(RTL_DIR)/if  \
             -I$(RTL_DIR)/id  \
             -I$(RTL_DIR)/ex  \
             -I$(RTL_DIR)/mem \
             -I$(RTL_DIR)/wb  \
             -I$(RTL_DIR)/pipe \
             -I$(RTL_DIR)/ctrl \
             -s tb_top

# ── VCS 플래그 ───────────────────────────────────────────────
VCS      := vcs
VCSFLAGS := -full64 -sverilog -timescale=1ns/1ps \
             +incdir+$(RTL_DIR)/top \
             +incdir+$(RTL_DIR)/if  \
             +incdir+$(RTL_DIR)/id  \
             +incdir+$(RTL_DIR)/ex  \
             +incdir+$(RTL_DIR)/mem \
             +incdir+$(RTL_DIR)/wb  \
             +incdir+$(RTL_DIR)/pipe \
             +incdir+$(RTL_DIR)/ctrl \
             -top tb_top

# ============================================================
# 기본 타겟: iverilog 시뮬레이션
# ============================================================
# ── 툴체인 ───────────────────────────────────────────────────
AS       := riscv64-unknown-elf-gcc
OBJCOPY  := riscv64-unknown-elf-objcopy
ASFLAGS  := -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Ttext=0x00000000

.PHONY: sim sim_vcs wave asm clean help

sim: $(SIM_OUT)
	@echo "[RUN] vvp $(SIM_OUT)"
	vvp $(SIM_OUT)

$(SIM_OUT): $(RTL_SRCS) $(TB_SRCS) $(MEM_DIR)/imem_init.hex
	@echo "[COMPILE] iverilog → $(SIM_OUT)"
	$(IVLOG) $(IVFLAGS) -o $(SIM_OUT) $(RTL_SRCS) $(TB_SRCS)

# ── VCS 시뮬레이션 ───────────────────────────────────────────
sim_vcs: $(RTL_SRCS) $(TB_SRCS) $(MEM_DIR)/imem_init.hex
	@echo "[COMPILE] vcs → simv"
	$(VCS) $(VCSFLAGS) $(RTL_SRCS) $(TB_SRCS) -o simv
	@echo "[RUN] ./simv"
	./simv

# ── 어셈블리 → hex 변환 ──────────────────────────────────────
# phony: 항상 실행
asm:
	@echo "[ASM] mem/test_main.S → mem/imem_init.hex"
	$(AS) $(ASFLAGS) -o $(MEM_DIR)/test_main.elf $(MEM_DIR)/test_main.S
	$(OBJCOPY) -O binary $(MEM_DIR)/test_main.elf $(MEM_DIR)/test_main.bin
	python3 $(MEM_DIR)/bin2hex.py $(MEM_DIR)/test_main.bin > $(MEM_DIR)/imem_init.hex
	rm -f $(MEM_DIR)/test_main.elf $(MEM_DIR)/test_main.bin
	@echo "[ASM] done"

# 파일 타겟: make sim 자동 의존성용 (.S가 더 새로울 때만 재빌드)
$(MEM_DIR)/imem_init.hex: $(MEM_DIR)/test_main.S
	@echo "[ASM] $< → $@"
	$(AS) $(ASFLAGS) -o $(MEM_DIR)/test_main.elf $<
	$(OBJCOPY) -O binary $(MEM_DIR)/test_main.elf $(MEM_DIR)/test_main.bin
	python3 $(MEM_DIR)/bin2hex.py $(MEM_DIR)/test_main.bin > $@
	rm -f $(MEM_DIR)/test_main.elf $(MEM_DIR)/test_main.bin
	@echo "[ASM] done → $@"

# ── 파형 확인 (GTKWave) ──────────────────────────────────────
wave: $(VCD_OUT)
	gtkwave $(VCD_OUT) &

# ── 정리 ─────────────────────────────────────────────────────
clean:
	rm -f $(SIM_OUT) $(VCD_OUT) simv simv.daidir csrc *.log *.key
	rm -f $(MEM_DIR)/imem_init.hex $(MEM_DIR)/test_main.elf $(MEM_DIR)/test_main.bin
	rm -rf csrc simv.daidir

# ── 도움말 ───────────────────────────────────────────────────
help:
	@echo ""
	@echo "  make sim       — iverilog 컴파일 + 시뮬레이션 실행"
	@echo "  make sim_vcs   — VCS 컴파일 + 시뮬레이션 실행"
	@echo "  make wave      — GTKWave로 파형 확인 (tb_top.vcd)"
	@echo "  make clean     — 빌드 산출물 삭제"
	@echo ""
