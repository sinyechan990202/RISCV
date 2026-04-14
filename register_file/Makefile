# ==============================================================
# Makefile : RISC-V Register File 시뮬레이션 (Verilator / Vivado xsim)
# 위치     : RISCV/register_file/Makefile
#
# [디렉토리 구조]
#   register_file/
#   ├── Makefile
#   ├── sim_main.cpp
#   ├── src/
#   │   └── register_file.sv
#   └── testbench/
#       └── tb_register_file.sv
#
# [Verilator 타겟]
#   make              → 빌드 + 시뮬레이션 (기본)
#   make build        → Verilator 컴파일만
#   make sim          → 시뮬레이션 실행만
#   make wave         → GTKWave 파형 열기
#   make lint         → Verilator 린트
#   make clean        → Verilator 빌드 삭제
#
# [Vivado xsim 타겟]
#   make xsim         → xsim 빌드 + 실행
#   make xsim-build   → xvlog + xelab 컴파일만
#   make xsim-run     → xsim 실행만
#   make xsim-wave    → Vivado GUI 파형 열기
#   make xsim-clean   → xsim 빌드 삭제
#
# [요구 사항]
#   - Verilator 4.x + g++ (build-essential)
#   - Vivado 2025.2 : /media/ubuntu/hard/Xilnx/2025.2/Vivado
# ==============================================================

SRC_DIR   := src
TB_DIR    := testbench
BUILD_DIR := build

TOP_MODULE := tb_register_file
DUT_SV     := $(SRC_DIR)/register_file.sv
TB_SV      := $(TB_DIR)/tb_register_file.sv
HARNESS    := $(abspath sim_main.cpp)

SIM_EXE   := $(BUILD_DIR)/V$(TOP_MODULE)
WAVE_FILE := $(BUILD_DIR)/tb_register_file.vcd

VERILATOR       := verilator
VERILATOR_FLAGS := \
    --cc              \
    --exe             \
    --build           \
    --sv              \
    --assert          \
    --trace           \
    --trace-structs   \
    -Wall             \
    -Wno-TIMESCALEMOD \
    -Wno-STMTDLY     \
    -Wno-UNOPTFLAT   \
    -Wno-BLKSEQ      \
    --top-module $(TOP_MODULE) \
    -I$(SRC_DIR)      \
    -Mdir $(BUILD_DIR)

# --------------------------------------------------------------
# 기본 타겟
# --------------------------------------------------------------
.PHONY: all
all: build sim

.PHONY: build
build: $(SIM_EXE)

$(SIM_EXE): $(DUT_SV) $(TB_SV) $(HARNESS)
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) $(TB_SV) $(DUT_SV) $(HARNESS)
	@echo "[build] 완료 → $(SIM_EXE)"

.PHONY: sim
sim: $(SIM_EXE)
	@echo "[sim] 시뮬레이션 시작"
	$(SIM_EXE)
	@echo "[sim] 완료"

.PHONY: wave
wave: sim
	@if [ ! -f $(WAVE_FILE) ]; then \
	    echo "[wave] VCD 파일 없음"; \
	    exit 1; \
	fi
	gtkwave $(WAVE_FILE) &
	@echo "[wave] GTKWave 실행"

.PHONY: lint
lint:
	$(VERILATOR) --lint-only --sv -Wall -I$(SRC_DIR) $(DUT_SV)
	@echo "[lint] 완료"

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	@echo "[clean] $(BUILD_DIR) 삭제 완료"

# ==============================================================
# Vivado xsim 타겟
# ==============================================================
VIVADO_BIN := /media/ubuntu/hard/Xilnx/2025.2/Vivado/bin
XSIM_DIR   := xsim_build

.PHONY: xsim
xsim: xsim-build xsim-run

.PHONY: xsim-build
xsim-build: $(DUT_SV) $(TB_SV)
	@mkdir -p $(XSIM_DIR)
	cd $(XSIM_DIR) && $(VIVADO_BIN)/xvlog --sv \
	    -work xwork \
	    ../$(DUT_SV) ../$(TB_SV)
	cd $(XSIM_DIR) && $(VIVADO_BIN)/xelab \
	    xwork.$(TOP_MODULE) \
	    --debug all \
	    -s $(TOP_MODULE)_snap
	@echo "[xsim-build] 완료 → $(XSIM_DIR)/$(TOP_MODULE)_snap"

.PHONY: xsim-run
xsim-run:
	@echo "[xsim-run] 시뮬레이션 시작"
	cd $(XSIM_DIR) && $(VIVADO_BIN)/xsim $(TOP_MODULE)_snap \
	    --runall \
	    --log xsim_run.log
	@echo "[xsim-run] 완료 (로그 → $(XSIM_DIR)/xsim_run.log)"

.PHONY: xsim-wave
xsim-wave: xsim-build
	cd $(XSIM_DIR) && $(VIVADO_BIN)/xsim $(TOP_MODULE)_snap \
	    --gui &
	@echo "[xsim-wave] Vivado 파형 창 실행"

.PHONY: xsim-clean
xsim-clean:
	rm -rf $(XSIM_DIR)
	@echo "[xsim-clean] $(XSIM_DIR) 삭제 완료"

# --------------------------------------------------------------
# help
# --------------------------------------------------------------
.PHONY: help
help:
	@echo ""
	@echo "사용법 : make [타겟]"
	@echo ""
	@echo "── Verilator ───────────────────────────"
	@echo "  all       (기본) 빌드 + 시뮬레이션"
	@echo "  build            Verilator 컴파일만"
	@echo "  sim              시뮬레이션 실행만"
	@echo "  wave             GTKWave 파형 열기"
	@echo "  lint             Verilator 린트"
	@echo "  clean            빌드 산출물 삭제"
	@echo ""
	@echo "── Vivado xsim ─────────────────────────"
	@echo "  xsim             빌드 + 실행"
	@echo "  xsim-build       xvlog + xelab 컴파일만"
	@echo "  xsim-run         xsim 실행만"
	@echo "  xsim-wave        Vivado GUI 파형 열기"
	@echo "  xsim-clean       xsim 빌드 삭제"
	@echo ""
