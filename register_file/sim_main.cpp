// ==============================================================
// sim_main.cpp : Verilator 4.x C++ 시뮬레이션 하네스
// DUT          : register_file (RISC-V RV32I)
// ==============================================================
// [클럭 전략 - ALU 와 동일]
//   t0 : clk=1, eval() → initial 블록 실행 (벡터 초기화)
//   t1 : clk=0, eval() → negedge : 입력 설정, 포워딩 확인
//   t2 : clk=1, eval() → posedge : 동기 쓰기 + 결과 확인
//   t3 : clk=0, eval() → 다음 입력 설정 ...
// ==============================================================
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtb_register_file.h"

static vluint64_t sim_time = 0;

double sc_time_stamp() {
    return static_cast<double>(sim_time);
}

int main(int argc, char** argv, char** env) {

    Verilated::commandArgs(argc, argv);

    Vtb_register_file* top = new Vtb_register_file;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("build/tb_register_file.vcd");

    printf("========================================\n");
    printf(" tb_register_file : RV32I Register File\n");
    printf("========================================\n");

    // t0 : clk=1 → initial 블록 실행
    top->clk = 1;
    top->eval();
    tfp->dump(sim_time++);

    // 메인 루프
    while (!Verilated::gotFinish()) {
        // negedge : 입력 설정
        top->clk = 0;
        top->eval();
        tfp->dump(sim_time++);

        if (Verilated::gotFinish()) break;

        // posedge : 결과 확인
        top->clk = 1;
        top->eval();
        tfp->dump(sim_time++);
    }

    tfp->close();
    top->final();
    delete top;
    delete tfp;

    return 0;
}
