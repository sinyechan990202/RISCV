# ==============================================================
# Makefile : RISC-V ALU 시뮬레이션 (Verilator / Vivado xsim)
# 위치     : RISCV/ALU/Makefile
#
# [디렉토리 구조]
#   ALU/
#   ├── Makefile          ← 이 파일
#   ├── sim_main.cpp      ← C++ 하네스 (Verilator 전용)
#   ├── src/
#   │   └── ALU.sv
#   └── testbench/
#       └── tb_ALU.sv     ← 듀얼 지원 (VERILATOR ifdef 분기)
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

# --------------------------------------------------------------
# 경로 설정
#   SRC_DIR      : DUT 소스 디렉토리
#   TB_DIR       : 테스트벤치 디렉토리
#   BUILD_DIR    : Verilator 빌드 출력 디렉토리
# --------------------------------------------------------------
SRC_DIR   := src
TB_DIR    := testbench
BUILD_DIR := build

# --------------------------------------------------------------
# 소스 파일
#   TOP_MODULE : Verilator가 최상위로 인식할 테스트벤치 모듈명
#   DUT_SV     : 합성 대상 DUT
#   TB_SV      : 테스트벤치 (--top-module 로 지정)
# --------------------------------------------------------------
TOP_MODULE := tb_ALU
DUT_SV     := $(SRC_DIR)/ALU.sv
TB_SV      := $(TB_DIR)/tb_ALU.sv
HARNESS    := $(abspath sim_main.cpp)   # C++ 시뮬레이션 진입점 (절대경로 필수)

# --------------------------------------------------------------
# 실행 파일 경로
#   SIM_EXE  : Verilator --build 가 생성하는 시뮬레이션 바이너리
#   WAVE_FILE: 파형 덤프 파일 (sim_main.cpp 에서 build/ 하위에 저장)
# --------------------------------------------------------------
SIM_EXE   := $(BUILD_DIR)/V$(TOP_MODULE)
WAVE_FILE := $(BUILD_DIR)/tb_ALU.vcd

# --------------------------------------------------------------
# Verilator 옵션 (Verilator 4.x 호환)
#   --cc           : C++ 모델 생성 (--binary 대체, 4.x 방식)
#   --exe          : 외부 C++ 파일을 빌드에 포함
#   --build        : C++ 컴파일까지 자동 완료
#   --sv           : SystemVerilog 모드 활성화
#   --assert       : SVA assert 활성화
#   --trace        : VCD 파형 덤프 활성화 (VerilatedVcdC 연동)
#   --trace-structs: 구조체 내부도 파형에 포함
#   -Wall          : 모든 경고 활성화
#   -Wno-TIMESCALEMOD : timescale 경고 억제 (tb에서 선언)
#   --top-module   : 최상위 모듈 지정 (테스트벤치)
#   -I$(SRC_DIR)   : DUT include 경로 추가
#   -Mdir          : 빌드 출력 디렉토리
#
#   ※ --timing 은 Verilator 5.x 전용 → 제거
#      initial 블록의 #delay 는 4.x 에서 무시되나,
#      순수 조합 논리 ALU 는 eval() 한 번으로 즉시 반영되므로 무방함
# --------------------------------------------------------------
VERILATOR      := verilator
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
# 기본 타겟 : 빌드 후 시뮬레이션 실행
# --------------------------------------------------------------
.PHONY: all
all: build sim

# --------------------------------------------------------------
# build : Verilator로 컴파일 → 실행 파일 생성
#   - $(BUILD_DIR) 없으면 자동 생성
#   - DUT + 테스트벤치를 함께 전달
# --------------------------------------------------------------
.PHONY: build
build: $(SIM_EXE)

$(SIM_EXE): $(DUT_SV) $(TB_SV) $(HARNESS)
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) $(TB_SV) $(DUT_SV) $(HARNESS)
	@echo "[build] 완료 → $(SIM_EXE)"

# --------------------------------------------------------------
# sim : 시뮬레이션 실행
#   - SIM_EXE 없으면 먼저 build 실행
#   - +verilator+rand+reset+2 : 초기화되지 않은 신호를 랜덤값으로 설정
#     (X-prop 문제 조기 발견)
# --------------------------------------------------------------
.PHONY: sim
sim: $(SIM_EXE)
	@echo "[sim] 시뮬레이션 시작"
	$(SIM_EXE) +verilator+rand+reset+2
	@echo "[sim] 완료"

# --------------------------------------------------------------
# wave : GTKWave로 VCD 파형 파일 열기
#   - 시뮬레이션 미실행 시 자동으로 sim 먼저 수행
#   - sim_main.cpp 의 tfp->open("build/tb_ALU.vcd") 에서 자동 저장됨
# --------------------------------------------------------------
.PHONY: wave
wave: sim
	@if [ ! -f $(WAVE_FILE) ]; then \
	    echo "[wave] VCD 파일 없음 : tb_ALU.sv의 dumpfile 블록을 주석 해제하세요"; \
	    exit 1; \
	fi
	gtkwave $(WAVE_FILE) &
	@echo "[wave] GTKWave 실행"

# --------------------------------------------------------------
# lint : 시뮬레이션 없이 Verilator 린트만 실행
#   --lint-only : 컴파일 없이 정적 분석만 수행
#   DUT만 대상으로 검사 (테스트벤치 제외)
# --------------------------------------------------------------
.PHONY: lint
lint:
	$(VERILATOR) --lint-only --sv -Wall -I$(SRC_DIR) $(DUT_SV)
	@echo "[lint] 완료"

# --------------------------------------------------------------
# clean : 빌드 산출물 전체 삭제
# --------------------------------------------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	@echo "[clean] $(BUILD_DIR) 삭제 완료"

# ==============================================================
# Vivado xsim 타겟
# ==============================================================

# --------------------------------------------------------------
# Vivado 경로 설정
# --------------------------------------------------------------
VIVADO_BIN := /media/ubuntu/hard/Xilnx/2025.2/Vivado/bin
XSIM_DIR   := xsim_build

# --------------------------------------------------------------
# xsim : xsim 빌드 + 실행 (기본 xsim 타겟)
# --------------------------------------------------------------
.PHONY: xsim
xsim: xsim-build xsim-run

# --------------------------------------------------------------
# xsim-build : xvlog(컴파일) + xelab(합성/정교화)
#   xvlog : SV 파일 → xsim.dir 라이브러리로 컴파일
#     --sv        : SystemVerilog 모드
#     -work xwork : 작업 라이브러리 이름
#   xelab : 최상위 모듈 정교화 → 시뮬레이션 스냅샷 생성
#     --debug all : 모든 신호 파형 기록 가능하도록 설정
#     -s          : 스냅샷 이름 지정
# --------------------------------------------------------------
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

# --------------------------------------------------------------
# xsim-run : 시뮬레이션 실행
#   --runall : $finish 까지 자동 실행
#   --log    : 로그 파일 저장
# --------------------------------------------------------------
.PHONY: xsim-run
xsim-run:
	@echo "[xsim-run] 시뮬레이션 시작"
	cd $(XSIM_DIR) && $(VIVADO_BIN)/xsim $(TOP_MODULE)_snap \
	    --runall \
	    --log xsim_run.log
	@echo "[xsim-run] 완료 (로그 → $(XSIM_DIR)/xsim_run.log)"

# --------------------------------------------------------------
# xsim-wave : Vivado GUI 로 파형 열기
#   xsim 을 --gui 모드로 실행하면 Vivado 파형 창이 열림
#   --tclbatch 로 파형 자동 추가 가능 (향후 wave.tcl 작성 시 활용)
# --------------------------------------------------------------
.PHONY: xsim-wave
xsim-wave: xsim-build
	cd $(XSIM_DIR) && $(VIVADO_BIN)/xsim $(TOP_MODULE)_snap \
	    --gui &
	@echo "[xsim-wave] Vivado 파형 창 실행"

# --------------------------------------------------------------
# xsim-clean : xsim 빌드 산출물 삭제
# --------------------------------------------------------------
.PHONY: xsim-clean
xsim-clean:
	rm -rf $(XSIM_DIR)
	@echo "[xsim-clean] $(XSIM_DIR) 삭제 완료"

# --------------------------------------------------------------
# help : 사용 가능한 타겟 목록 출력
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
