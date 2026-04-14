// ============================================================
// Testbench : tb_register_file.sv
// DUT       : register_file (RISC-V RV32I)
//
// [듀얼 시뮬레이터 지원] — ALU 테스트벤치와 동일 구조
//   `ifdef VERILATOR  : clk 을 input port 로 선언
//                       sim_main.cpp 에서 negedge/posedge 토글
//   `else             : clk 을 always #5 로 자체 생성 (xsim/iverilog)
//
// [테스트 시나리오]
//   0. x0 쓰기 무시 검증
//   1. 기본 쓰기 → 읽기 (rs1/rs2 양쪽)
//   2. Write-Through 포워딩 (동일 사이클 쓰기+읽기)
//   3. 동기 리셋 (rst_n=0 → 전체 0)
//   4. wen=0 일 때 쓰기 비활성화
//   5. x0 읽기 항상 0
//   6. 서로 다른 두 레지스터 동시 읽기
//
// [클럭 타이밍]
//   negedge : 입력 설정 (sim_main.cpp 또는 always #5)
//   posedge : 동기 쓰기 + 결과 확인
//   → ALU 와 동일한 2-phase 구조
// ============================================================
`timescale 1ns / 1ps

`ifdef VERILATOR
// clk 은 sim_main.cpp 가 직접 토글 (Verilator 4.x --timing 미지원 대체)
module tb_register_file (
    input logic clk
);
`else
// xsim / iverilog : always #5 로 클럭 자체 생성
module tb_register_file;
    logic clk = 1'b1;
    always #5 clk = ~clk;   // 10 ns (100 MHz)
`endif

    // ==========================================================
    // DUT 포트 신호
    // ==========================================================
    logic        rst_n;
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [31:0] rs1_rdata;
    logic [31:0] rs2_rdata;
    logic [4:0]  rd_addr;
    logic [31:0] rd_wdata;
    logic        wen;

    // ==========================================================
    // t0 posedge 스킵 플래그
    //   sim_main.cpp 에서 clk=1 로 시작 → 첫 eval() 에서
    //   posedge 이벤트가 발생하지만, 아직 negedge 에서 입력을
    //   설정하지 않은 상태임 → init_done=0 동안 posedge 체크 스킵
    // ==========================================================
    logic init_done;

    // ==========================================================
    // DUT 인스턴스
    // ==========================================================
    register_file dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .rs1_addr  (rs1_addr),
        .rs2_addr  (rs2_addr),
        .rs1_rdata (rs1_rdata),
        .rs2_rdata (rs2_rdata),
        .rd_addr   (rd_addr),
        .rd_wdata  (rd_wdata),
        .wen       (wen)
    );

    // ==========================================================
    // 테스트 벡터 구조
    //   각 테스트는 2 사이클 소요
    //     negedge : 입력 설정
    //     posedge : 결과 확인 (동기 쓰기 반영 후)
    //
    //   단, Write-Through 테스트(tv_fwd)는 negedge 에서 즉시 확인
    //   → negedge_check 플래그로 구분
    // ==========================================================
    localparam int NUM_TESTS = 13;

    // 입력 벡터
    logic        tv_rst_n   [NUM_TESTS];
    logic [4:0]  tv_rs1_addr[NUM_TESTS];
    logic [4:0]  tv_rs2_addr[NUM_TESTS];
    logic [4:0]  tv_rd_addr [NUM_TESTS];
    logic [31:0] tv_rd_wdata[NUM_TESTS];
    logic        tv_wen     [NUM_TESTS];

    // 기대값 벡터
    logic [31:0] tv_rs1_exp [NUM_TESTS];  // rs1_rdata 기대값
    logic [31:0] tv_rs2_exp [NUM_TESTS];  // rs2_rdata 기대값

    // 확인 시점 : 1=negedge 직후 (포워딩), 0=posedge 에서
    logic        tv_neg_chk [NUM_TESTS];

    // ==========================================================
    // 테스트 벡터 초기화
    //   t0 실행 : 벡터 배열 초기화 + DUT 입력 기본값 설정
    //   init_done=0 으로 초기화하여 t0 posedge 체크를 스킵함
    // ==========================================================
    initial begin
        // -- 플래그 및 입력 기본값 (t0 posedge 안전 초기화) ------
        init_done = 1'b0;
        rst_n     = 1'b1;
        rs1_addr  = 5'd0;
        rs2_addr  = 5'd0;
        rd_addr   = 5'd0;
        rd_wdata  = 32'd0;
        wen       = 1'b0;
        // -------------------------------------------------------
        // [0] 리셋 : rst_n=0 → 다음 posedge 에서 전체 초기화
        //   posedge 에서 reg_file 모두 0 확인 → x1, x2 읽기
        // -------------------------------------------------------
        tv_rst_n   [0] = 1'b0;
        tv_rs1_addr[0] = 5'd1;   tv_rs1_exp[0] = 32'd0;
        tv_rs2_addr[0] = 5'd2;   tv_rs2_exp[0] = 32'd0;
        tv_rd_addr [0] = 5'd0;   tv_rd_wdata[0] = 32'hDEAD_BEEF;
        tv_wen     [0] = 1'b1;   tv_neg_chk [0] = 1'b0;

        // -------------------------------------------------------
        // [1] x0 쓰기 무시 : wen=1, rd=x0, wdata=0xFFFFFFFF
        //   posedge 후 x0 읽으면 여전히 0
        // -------------------------------------------------------
        tv_rst_n   [1] = 1'b1;
        tv_rs1_addr[1] = 5'd0;   tv_rs1_exp[1] = 32'd0;
        tv_rs2_addr[1] = 5'd0;   tv_rs2_exp[1] = 32'd0;
        tv_rd_addr [1] = 5'd0;   tv_rd_wdata[1] = 32'hFFFF_FFFF;
        tv_wen     [1] = 1'b1;   tv_neg_chk [1] = 1'b0;

        // -------------------------------------------------------
        // [2] x1 에 0xABCD_1234 쓰기
        //   posedge 후 rs1=x1 → 0xABCD_1234
        // -------------------------------------------------------
        tv_rst_n   [2] = 1'b1;
        tv_rs1_addr[2] = 5'd1;   tv_rs1_exp[2] = 32'hABCD_1234;
        tv_rs2_addr[2] = 5'd0;   tv_rs2_exp[2] = 32'd0;
        tv_rd_addr [2] = 5'd1;   tv_rd_wdata[2] = 32'hABCD_1234;
        tv_wen     [2] = 1'b1;   tv_neg_chk [2] = 1'b0;

        // -------------------------------------------------------
        // [3] x2 에 0x5555_AAAA 쓰기
        //   posedge 후 rs2=x2 → 0x5555_AAAA
        // -------------------------------------------------------
        tv_rst_n   [3] = 1'b1;
        tv_rs1_addr[3] = 5'd1;   tv_rs1_exp[3] = 32'hABCD_1234; // x1 이전 값 유지
        tv_rs2_addr[3] = 5'd2;   tv_rs2_exp[3] = 32'h5555_AAAA;
        tv_rd_addr [3] = 5'd2;   tv_rd_wdata[3] = 32'h5555_AAAA;
        tv_wen     [3] = 1'b1;   tv_neg_chk [3] = 1'b0;

        // -------------------------------------------------------
        // [4] rs1=x1, rs2=x2 동시 읽기
        //   이번 사이클에는 쓰기 없음 (wen=0)
        // -------------------------------------------------------
        tv_rst_n   [4] = 1'b1;
        tv_rs1_addr[4] = 5'd1;   tv_rs1_exp[4] = 32'hABCD_1234;
        tv_rs2_addr[4] = 5'd2;   tv_rs2_exp[4] = 32'h5555_AAAA;
        tv_rd_addr [4] = 5'd0;   tv_rd_wdata[4] = 32'd0;
        tv_wen     [4] = 1'b0;   tv_neg_chk [4] = 1'b0;

        // -------------------------------------------------------
        // [5] wen=0 → 쓰기 비활성화 : x3 에 쓰기 시도 → 실패해야 함
        //   다음 사이클에서 x3 읽으면 0 (이전에 쓴 적 없음)
        //   [6] 에서 확인
        // -------------------------------------------------------
        tv_rst_n   [5] = 1'b1;
        tv_rs1_addr[5] = 5'd3;   tv_rs1_exp[5] = 32'd0;   // x3 아직 0
        tv_rs2_addr[5] = 5'd0;   tv_rs2_exp[5] = 32'd0;
        tv_rd_addr [5] = 5'd3;   tv_rd_wdata[5] = 32'hCAFE_BABE;
        tv_wen     [5] = 1'b0;   tv_neg_chk [5] = 1'b0;

        // -------------------------------------------------------
        // [6] x3 읽기 → wen=0 이었으므로 여전히 0
        // -------------------------------------------------------
        tv_rst_n   [6] = 1'b1;
        tv_rs1_addr[6] = 5'd3;   tv_rs1_exp[6] = 32'd0;
        tv_rs2_addr[6] = 5'd0;   tv_rs2_exp[6] = 32'd0;
        tv_rd_addr [6] = 5'd0;   tv_rd_wdata[6] = 32'd0;
        tv_wen     [6] = 1'b0;   tv_neg_chk [6] = 1'b0;

        // -------------------------------------------------------
        // [7] Write-Through 포워딩 (rs1 side)
        //   같은 사이클 : rd=x5, wdata=0x1234_5678, rs1=x5
        //   wen=1 && rs1==rd → always_comb 포워딩 경로 활성
        //   posedge 에서 확인 : Verilator 는 negedge 핸들러 내부
        //   blocking 할당 후 조합 논리를 즉시 settle 하지 않으므로
        //   posedge eval() 후 settle 된 값을 읽음
        // -------------------------------------------------------
        tv_rst_n   [7] = 1'b1;
        tv_rs1_addr[7] = 5'd5;   tv_rs1_exp[7] = 32'h1234_5678;
        tv_rs2_addr[7] = 5'd0;   tv_rs2_exp[7] = 32'd0;
        tv_rd_addr [7] = 5'd5;   tv_rd_wdata[7] = 32'h1234_5678;
        tv_wen     [7] = 1'b1;   tv_neg_chk [7] = 1'b0;   // posedge 확인

        // -------------------------------------------------------
        // [8] Write-Through 포워딩 (rs2 side)
        //   rd=x6, wdata=0xFEDC_BA98, rs2=x6
        //   wen=1 && rs2==rd → always_comb 포워딩 경로 활성
        // -------------------------------------------------------
        tv_rst_n   [8] = 1'b1;
        tv_rs1_addr[8] = 5'd0;   tv_rs1_exp[8] = 32'd0;
        tv_rs2_addr[8] = 5'd6;   tv_rs2_exp[8] = 32'hFEDC_BA98;
        tv_rd_addr [8] = 5'd6;   tv_rd_wdata[8] = 32'hFEDC_BA98;
        tv_wen     [8] = 1'b1;   tv_neg_chk [8] = 1'b0;   // posedge 확인

        // -------------------------------------------------------
        // [9] x5, x6 이전 쓰기 결과 확인 (포워딩 없이 배열 직접 읽기)
        //   wen=0 이므로 포워딩 없음
        // -------------------------------------------------------
        tv_rst_n   [9] = 1'b1;
        tv_rs1_addr[9] = 5'd5;   tv_rs1_exp[9] = 32'h1234_5678;
        tv_rs2_addr[9] = 5'd6;   tv_rs2_exp[9] = 32'hFEDC_BA98;
        tv_rd_addr [9] = 5'd0;   tv_rd_wdata[9] = 32'd0;
        tv_wen     [9] = 1'b0;   tv_neg_chk [9] = 1'b0;

        // -------------------------------------------------------
        // [10] x31 (최대 주소) 쓰기/읽기
        // -------------------------------------------------------
        tv_rst_n   [10] = 1'b1;
        tv_rs1_addr[10] = 5'd31;  tv_rs1_exp[10] = 32'hFFFF_0000;
        tv_rs2_addr[10] = 5'd0;   tv_rs2_exp[10] = 32'd0;
        tv_rd_addr [10] = 5'd31;  tv_rd_wdata[10] = 32'hFFFF_0000;
        tv_wen     [10] = 1'b1;   tv_neg_chk [10] = 1'b0;

        // -------------------------------------------------------
        // [11] 리셋 적용 : rst_n=0 → 이 posedge 에서 always_ff
        //      가 reg_file 을 0 으로 NBA 예약
        //      NBA 커밋은 posedge 이후 delta cycle 에 완료되므로
        //      이 posedge check 에서는 x0(항상 0)만 읽어 안전하게 pass
        //      실제 리셋 결과는 [12] 에서 검증
        // -------------------------------------------------------
        tv_rst_n   [11] = 1'b0;
        tv_rs1_addr[11] = 5'd0;   tv_rs1_exp[11] = 32'd0;  // x0 → 항상 0
        tv_rs2_addr[11] = 5'd0;   tv_rs2_exp[11] = 32'd0;
        tv_rd_addr [11] = 5'd0;   tv_rd_wdata[11] = 32'd0;
        tv_wen     [11] = 1'b0;   tv_neg_chk [11] = 1'b0;

        // -------------------------------------------------------
        // [12] 리셋 결과 검증 : rst_n=1, wen=0 으로 x31, x5 읽기
        //      [11] posedge 의 NBA 가 커밋되어 reg_file[31]=0,
        //      reg_file[5]=0 이어야 함
        // -------------------------------------------------------
        tv_rst_n   [12] = 1'b1;
        tv_rs1_addr[12] = 5'd31;  tv_rs1_exp[12] = 32'd0;
        tv_rs2_addr[12] = 5'd5;   tv_rs2_exp[12] = 32'd0;
        tv_rd_addr [12] = 5'd0;   tv_rd_wdata[12] = 32'd0;
        tv_wen     [12] = 1'b0;   tv_neg_chk [12] = 1'b0;
    end

    // ==========================================================
    // 시뮬레이션 카운터
    // ==========================================================
    int test_idx;
    int pass_cnt;
    int fail_cnt;

    // ==========================================================
    // 결과 비교 태스크
    //   negedge / posedge 양쪽에서 공통 사용
    //   phase_str : "negedge" or "posedge" (로그용)
    // ==========================================================
    task automatic check_result (
        input string phase_str,
        input int    idx
    );
        logic mismatch;
        mismatch = (rs1_rdata !== tv_rs1_exp[idx]) ||
                   (rs2_rdata !== tv_rs2_exp[idx]);

        if (mismatch) begin
            $error("[FAIL] test[%02d] @%s | rs1:0x%08X(exp:0x%08X)  rs2:0x%08X(exp:0x%08X)",
                   idx, phase_str,
                   rs1_rdata, tv_rs1_exp[idx],
                   rs2_rdata, tv_rs2_exp[idx]);
            fail_cnt = fail_cnt + 1;
        end else begin
            $display("[PASS] test[%02d] @%s | rs1=0x%08X  rs2=0x%08X",
                     idx, phase_str,
                     rs1_rdata, rs2_rdata);
            pass_cnt = pass_cnt + 1;
        end
    endtask

    // ==========================================================
    // Phase 1 : negedge → DUT 입력 설정 + 포워딩 즉시 확인
    //   첫 번째 negedge 에서 init_done=1 로 설정
    //   → 이후 posedge 에서 체크 허용
    // ==========================================================
    always @(negedge clk) begin
        init_done = 1'b1;   // t1 이후부터 posedge 체크 활성화
        if (test_idx < NUM_TESTS) begin
            rst_n    = tv_rst_n   [test_idx];
            rs1_addr = tv_rs1_addr[test_idx];
            rs2_addr = tv_rs2_addr[test_idx];
            rd_addr  = tv_rd_addr [test_idx];
            rd_wdata = tv_rd_wdata[test_idx];
            wen      = tv_wen     [test_idx];

            // 포워딩 테스트 : 조합 논리 즉시 반영 여부 확인
            if (tv_neg_chk[test_idx]) begin
                check_result("negedge", test_idx);
            end
        end
    end

    // ==========================================================
    // Phase 2 : posedge → 동기 쓰기 반영 후 결과 확인
    //   init_done=0 (t0) 이면 스킵 → 첫 번째 negedge 이후부터 유효
    // ==========================================================
    always @(posedge clk) begin
        if (!init_done) begin
            // t0 posedge : 아직 입력이 설정되지 않았으므로 스킵
        end else if (test_idx < NUM_TESTS) begin
            // 포워딩 테스트가 아닌 경우에만 posedge 에서 확인
            if (!tv_neg_chk[test_idx]) begin
                check_result("posedge", test_idx);
            end
            test_idx = test_idx + 1;

        end else if (init_done) begin
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
