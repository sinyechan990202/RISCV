// ==============================================================
// sim_main.cpp : Verilator 4.x C++ 시뮬레이션 하네스
// ==============================================================
// [클럭 토글 전략]
//   Verilator 4.x 는 --timing 미지원 → initial 블록 #delay 무시
//   해결: clk 를 C++ 에서 직접 토글하여 negedge/posedge 이벤트 생성
//
//   t0 : clk=1, eval() → initial 블록 실행 (벡터 배열 초기화)
//   t1 : clk=0, eval() → negedge : DUT 입력 설정, 조합 논리 안정
//   t2 : clk=1, eval() → posedge : 결과 확인
//   t3 : clk=0, eval() → negedge : 다음 입력 설정
//   ...
//
// [sc_time_stamp()]
//   Verilator 4.x non-SystemC 빌드 시 필수 심볼
//   vl_time_stamp64() 가 내부적으로 참조하므로 직접 정의
// ==============================================================
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtb_ALU.h"

// --------------------------------------------------------------
// 전역 시뮬레이션 타임 (VCD 타임스탬프 + sc_time_stamp 공유)
// --------------------------------------------------------------
static vluint64_t sim_time = 0;

double sc_time_stamp() {
    return static_cast<double>(sim_time);
}

int main(int argc, char** argv, char** env) {

    // ----------------------------------------------------------
    // 1. 런타임 옵션 파싱
    //    +verilator+rand+reset+2 : 미초기화 신호 랜덤값
    // ----------------------------------------------------------
    Verilated::commandArgs(argc, argv);

    // ----------------------------------------------------------
    // 2. DUT 인스턴스 (tb_ALU 가 최상위)
    // ----------------------------------------------------------
    Vtb_ALU* top = new Vtb_ALU;

    // ----------------------------------------------------------
    // 3. VCD 파형 덤프 설정
    //    출력 : build/tb_ALU.vcd  (실행 위치 = ALU/ 기준)
    // ----------------------------------------------------------
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("build/tb_ALU.vcd");

    // ----------------------------------------------------------
    // 4. 시뮬레이션 헤더 출력
    // ----------------------------------------------------------
    printf("========================================\n");
    printf(" tb_ALU : RISC-V RV32I ALU Testbench\n");
    printf("========================================\n");

    // ----------------------------------------------------------
    // 5. t0 : clk=1 초기 eval
    //    - initial 블록 실행 (테스트 벡터 배열 초기화)
    //    - 클럭을 1 로 시작해야 첫 번째 전환이 negedge 가 됨
    // ----------------------------------------------------------
    top->clk = 1;
    top->eval();
    tfp->dump(sim_time++);

    // ----------------------------------------------------------
    // 6. 메인 루프
    //    - negedge (clk=0) : always @(negedge) → 입력 설정
    //    - posedge (clk=1) : always @(posedge) → 결과 확인
    //    - $finish 호출 시 Verilated::gotFinish() == true
    // ----------------------------------------------------------
    while (!Verilated::gotFinish()) {
        // ── negedge : DUT 입력 설정, 조합 논리 안정화 ──────────
        top->clk = 0;
        top->eval();
        tfp->dump(sim_time++);

        if (Verilated::gotFinish()) break;

        // ── posedge : 결과 확인 ─────────────────────────────────
        top->clk = 1;
        top->eval();
        tfp->dump(sim_time++);
    }

    // ----------------------------------------------------------
    // 7. 종료 처리
    // ----------------------------------------------------------
    tfp->close();
    top->final();
    delete top;
    delete tfp;

    return 0;
}
