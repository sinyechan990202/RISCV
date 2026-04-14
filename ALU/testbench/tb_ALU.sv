// ============================================================
// Testbench : tb_ALU.sv
// DUT       : ALU (RISC-V RV32I)
//
// [듀얼 시뮬레이터 지원]
//   VERILATOR 매크로 유무로 클럭 소스를 분기
//
//   `ifdef VERILATOR  (Verilator 4.x)
//     - clk 를 input port 로 선언
//     - sim_main.cpp 에서 negedge/posedge 토글
//     - negedge : 입력 설정, posedge : 결과 확인
//
//   `else             (Vivado xsim / iverilog 등)
//     - clk 를 내부 always #5 로 자체 생성
//     - initial 블록의 #delay 가 정상 동작
//     - always @(negedge/posedge clk) 타이밍 구조는 동일
// ============================================================
`timescale 1ns / 1ps

`ifdef VERILATOR
// Verilator : clk 은 sim_main.cpp 가 토글
module tb_ALU (
    input logic clk
);
`else
// xsim / iverilog : 내부에서 클럭 자체 생성
module tb_ALU;
    logic clk = 1'b1;          // 초기값 1 → 첫 전환이 negedge
    always #5 clk = ~clk;      // 10 ns 주기 (100 MHz)
`endif

    // ==========================================================
    // ALU 제어 코드 (DUT localparam 과 동일)
    // ==========================================================
    localparam [3:0] ALU_ADD  = 4'b0000;
    localparam [3:0] ALU_SUB  = 4'b0001;
    localparam [3:0] ALU_AND  = 4'b0010;
    localparam [3:0] ALU_OR   = 4'b0011;
    localparam [3:0] ALU_XOR  = 4'b0100;
    localparam [3:0] ALU_SLL  = 4'b0101;
    localparam [3:0] ALU_SRL  = 4'b0110;
    localparam [3:0] ALU_SRA  = 4'b0111;
    localparam [3:0] ALU_SLT  = 4'b1000;
    localparam [3:0] ALU_SLTU = 4'b1001;
    localparam [3:0] ALU_LUI  = 4'b1010;

    // ==========================================================
    // DUT 포트 신호
    // ==========================================================
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [ 3:0] alu_ctrl;
    logic [31:0] result;
    logic        zero;
    logic        negative;
    logic        overflow;
    logic        carry_out;

    // ==========================================================
    // DUT 인스턴스
    // ==========================================================
    ALU dut (
        .operand_a  (operand_a),
        .operand_b  (operand_b),
        .alu_ctrl   (alu_ctrl),
        .result     (result),
        .zero       (zero),
        .negative   (negative),
        .overflow   (overflow),
        .carry_out  (carry_out)
    );

    // ==========================================================
    // 테스트 벡터 배열
    //   tv_flags[i] = {zero, negative, overflow, carry_out}
    // ==========================================================
    localparam int NUM_TESTS = 27;

    logic [31:0] tv_a    [NUM_TESTS];
    logic [31:0] tv_b    [NUM_TESTS];
    logic [ 3:0] tv_ctrl [NUM_TESTS];
    logic [31:0] tv_res  [NUM_TESTS];
    logic [ 3:0] tv_flags[NUM_TESTS];   // {Z, N, OV, C}

    // ==========================================================
    // 벡터 초기화 (initial 블록 : t0 eval 에서 1회 실행)
    // ==========================================================
    initial begin
        // -- ADD ------------------------------------------------
        // [0]  3 + 4 = 7
        tv_a[0]=32'd3;         tv_b[0]=32'd4;         tv_ctrl[0]=ALU_ADD;
        tv_res[0]=32'h0000_0007; tv_flags[0]=4'b0000;

        // [1]  0 + 0 = 0  (zero=1)
        tv_a[1]=32'd0;         tv_b[1]=32'd0;         tv_ctrl[1]=ALU_ADD;
        tv_res[1]=32'h0000_0000; tv_flags[1]=4'b1000;

        // [2]  FFFF_FFFF + 1 = 0  (zero=1, carry=1)
        tv_a[2]=32'hFFFF_FFFF; tv_b[2]=32'd1;         tv_ctrl[2]=ALU_ADD;
        tv_res[2]=32'h0000_0000; tv_flags[2]=4'b1001;

        // [3]  7FFF_FFFF + 1 = 8000_0000  (neg=1, overflow=1)
        tv_a[3]=32'h7FFF_FFFF; tv_b[3]=32'd1;         tv_ctrl[3]=ALU_ADD;
        tv_res[3]=32'h8000_0000; tv_flags[3]=4'b0110;

        // -- SUB ------------------------------------------------
        // [4]  10 - 3 = 7  (carry=1 : borrow 없음)
        tv_a[4]=32'd10;        tv_b[4]=32'd3;         tv_ctrl[4]=ALU_SUB;
        tv_res[4]=32'h0000_0007; tv_flags[4]=4'b0001;

        // [5]  5 - 5 = 0  (zero=1, carry=1)
        tv_a[5]=32'd5;         tv_b[5]=32'd5;         tv_ctrl[5]=ALU_SUB;
        tv_res[5]=32'h0000_0000; tv_flags[5]=4'b1001;

        // [6]  0 - 1 = -1 = FFFF_FFFF  (neg=1, carry=0 : borrow 발생)
        tv_a[6]=32'd0;         tv_b[6]=32'd1;         tv_ctrl[6]=ALU_SUB;
        tv_res[6]=32'hFFFF_FFFF; tv_flags[6]=4'b0100;

        // [7]  8000_0000 - 1 = 7FFF_FFFF  (overflow=1, carry=1)
        tv_a[7]=32'h8000_0000; tv_b[7]=32'd1;         tv_ctrl[7]=ALU_SUB;
        tv_res[7]=32'h7FFF_FFFF; tv_flags[7]=4'b0011;

        // -- AND ------------------------------------------------
        // [8]  F0F0_F0F0 & 0F0F_0F0F = 0  (zero=1)
        tv_a[8]=32'hF0F0_F0F0; tv_b[8]=32'h0F0F_0F0F; tv_ctrl[8]=ALU_AND;
        tv_res[8]=32'h0000_0000; tv_flags[8]=4'b1000;

        // [9]  FFFF_FFFF & A5A5_A5A5 = A5A5_A5A5  (neg=1, carry=1: FFFFFFFF+A5A5A5A5 overflows)
        tv_a[9]=32'hFFFF_FFFF; tv_b[9]=32'hA5A5_A5A5; tv_ctrl[9]=ALU_AND;
        tv_res[9]=32'hA5A5_A5A5; tv_flags[9]=4'b0101;

        // -- OR -------------------------------------------------
        // [10] F0F0_F0F0 | 0F0F_0F0F = FFFF_FFFF  (neg=1)
        tv_a[10]=32'hF0F0_F0F0; tv_b[10]=32'h0F0F_0F0F; tv_ctrl[10]=ALU_OR;
        tv_res[10]=32'hFFFF_FFFF; tv_flags[10]=4'b0100;

        // [11] 0 | 0 = 0  (zero=1)
        tv_a[11]=32'h0;         tv_b[11]=32'h0;         tv_ctrl[11]=ALU_OR;
        tv_res[11]=32'h0000_0000; tv_flags[11]=4'b1000;

        // -- XOR ------------------------------------------------
        // [12] DEAD_BEEF ^ DEAD_BEEF = 0  (zero=1, carry=1: DEADBEEF*2 overflows)
        tv_a[12]=32'hDEAD_BEEF; tv_b[12]=32'hDEAD_BEEF; tv_ctrl[12]=ALU_XOR;
        tv_res[12]=32'h0000_0000; tv_flags[12]=4'b1001;

        // [13] AAAA_AAAA ^ 5555_5555 = FFFF_FFFF  (neg=1)
        tv_a[13]=32'hAAAA_AAAA; tv_b[13]=32'h5555_5555; tv_ctrl[13]=ALU_XOR;
        tv_res[13]=32'hFFFF_FFFF; tv_flags[13]=4'b0100;

        // -- SLL ------------------------------------------------
        // [14] 1 << 4 = 0x10
        tv_a[14]=32'h0000_0001; tv_b[14]=32'd4;          tv_ctrl[14]=ALU_SLL;
        tv_res[14]=32'h0000_0010; tv_flags[14]=4'b0000;

        // [15] 1 << 31 = 8000_0000  (neg=1)
        tv_a[15]=32'h0000_0001; tv_b[15]=32'd31;         tv_ctrl[15]=ALU_SLL;
        tv_res[15]=32'h8000_0000; tv_flags[15]=4'b0100;

        // -- SRL ------------------------------------------------
        // [16] 8000_0000 >> 4 = 0800_0000
        tv_a[16]=32'h8000_0000; tv_b[16]=32'd4;          tv_ctrl[16]=ALU_SRL;
        tv_res[16]=32'h0800_0000; tv_flags[16]=4'b0000;

        // [17] FFFF_FFFF >> 31 = 1  (carry=1: FFFFFFFF+1F overflows)
        tv_a[17]=32'hFFFF_FFFF; tv_b[17]=32'd31;         tv_ctrl[17]=ALU_SRL;
        tv_res[17]=32'h0000_0001; tv_flags[17]=4'b0001;

        // -- SRA ------------------------------------------------
        // [18] 8000_0000 >>> 4 = F800_0000  (neg=1 : 부호 비트 유지)
        tv_a[18]=32'h8000_0000; tv_b[18]=32'd4;          tv_ctrl[18]=ALU_SRA;
        tv_res[18]=32'hF800_0000; tv_flags[18]=4'b0100;

        // [19] 7FFF_FFFF >>> 4 = 07FF_FFFF
        tv_a[19]=32'h7FFF_FFFF; tv_b[19]=32'd4;          tv_ctrl[19]=ALU_SRA;
        tv_res[19]=32'h07FF_FFFF; tv_flags[19]=4'b0000;

        // -- SLT (signed) ---------------------------------------
        // [20] -1 < 0 = 1  (carry=1: FFFFFFFF - 0 = FFFFFFFF+FFFFFFFF+1 overflows)
        tv_a[20]=32'hFFFF_FFFF; tv_b[20]=32'h0000_0000;  tv_ctrl[20]=ALU_SLT;
        tv_res[20]=32'h0000_0001; tv_flags[20]=4'b0001;

        // [21] 0 < -1 = 0  (zero=1)
        tv_a[21]=32'h0000_0000; tv_b[21]=32'hFFFF_FFFF;  tv_ctrl[21]=ALU_SLT;
        tv_res[21]=32'h0000_0000; tv_flags[21]=4'b1000;

        // -- SLTU (unsigned) ------------------------------------
        // [22] 1 < FFFF_FFFF = 1  (unsigned)
        tv_a[22]=32'h0000_0001; tv_b[22]=32'hFFFF_FFFF;  tv_ctrl[22]=ALU_SLTU;
        tv_res[22]=32'h0000_0001; tv_flags[22]=4'b0000;

        // [23] FFFF_FFFF < 1 = 0  (zero=1, carry=1: FFFFFFFF-1 2's complement overflows)
        tv_a[23]=32'hFFFF_FFFF; tv_b[23]=32'h0000_0001;  tv_ctrl[23]=ALU_SLTU;
        tv_res[23]=32'h0000_0000; tv_flags[23]=4'b1001;

        // -- LUI ------------------------------------------------
        // [24] pass B = ABCD_E000  (neg=1, carry=1: DEADBEEF+ABCDE000 overflows)
        tv_a[24]=32'hDEAD_BEEF; tv_b[24]=32'hABCD_E000;  tv_ctrl[24]=ALU_LUI;
        tv_res[24]=32'hABCD_E000; tv_flags[24]=4'b0101;

        // -- 플래그 집중 테스트 ---------------------------------
        // [25] ADD FFFF_FFFF + 1 = 0  (zero=1, carry=1)
        tv_a[25]=32'hFFFF_FFFF; tv_b[25]=32'h0000_0001;  tv_ctrl[25]=ALU_ADD;
        tv_res[25]=32'h0000_0000; tv_flags[25]=4'b1001;

        // [26] SUB 1 - 2 = FFFF_FFFF  (neg=1)
        tv_a[26]=32'h0000_0001; tv_b[26]=32'h0000_0002;  tv_ctrl[26]=ALU_SUB;
        tv_res[26]=32'hFFFF_FFFF; tv_flags[26]=4'b0100;
    end

    // ==========================================================
    // 시뮬레이션 상태 카운터
    //   int 형은 SV 기본값 0 이므로 별도 초기화 불필요
    // ==========================================================
    int test_idx;   // 현재 테스트 인덱스
    int pass_cnt;
    int fail_cnt;

    // ==========================================================
    // Phase 1 : negedge → DUT 입력 설정
    //   - 이 블록이 끝나면 Verilator eval() 내부 settle 루프가
    //     always_comb / assign 을 재평가 → result 갱신됨
    // ==========================================================
    always @(negedge clk) begin
        if (test_idx < NUM_TESTS) begin
            operand_a = tv_a    [test_idx];
            operand_b = tv_b    [test_idx];
            alu_ctrl  = tv_ctrl [test_idx];
        end
    end

    // ==========================================================
    // Phase 2 : posedge → 결과 확인 및 카운터 증가
    //   - negedge eval() 에서 조합 논리가 이미 안정화됨
    //   - result / flags 는 최신 입력에 대한 정상 출력값
    // ==========================================================
    always @(posedge clk) begin
        if (test_idx < NUM_TESTS) begin
            // ── 결과 비교 ──────────────────────────────────────
            if (result !== tv_res[test_idx] ||
                {zero, negative, overflow, carry_out} !== tv_flags[test_idx]) begin

                $error("[FAIL] test[%02d] | result:0x%08X(exp:0x%08X) flags:%b(exp:%b)",
                       test_idx,
                       result,           tv_res[test_idx],
                       {zero, negative, overflow, carry_out}, tv_flags[test_idx]);
                fail_cnt = fail_cnt + 1;
            end else begin
                $display("[PASS] test[%02d] | result=0x%08X flags=%b",
                         test_idx, result,
                         {zero, negative, overflow, carry_out});
                pass_cnt = pass_cnt + 1;
            end

            test_idx = test_idx + 1;

        end else begin
            // ── 전체 결과 요약 ─────────────────────────────────
            $display("========================================");
            $display(" RESULT : PASS=%0d  FAIL=%0d  TOTAL=%0d",
                     pass_cnt, fail_cnt, pass_cnt + fail_cnt);
            if (fail_cnt == 0)
                $display(" ALL TESTS PASSED");
            else
                $display(" *** %0d TEST(S) FAILED ***", fail_cnt);
            $display("========================================");
            $finish;
        end
    end

endmodule
