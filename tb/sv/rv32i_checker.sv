// ============================================================
// rv32i_checker.sv
// 역할 : GPIO_OUT 취득 → 기대값과 자동 비교 → PASS/FAIL 출력
//
// GPIO_OUT 시퀀스 (while루프 1회당):
//   [0] SUM    = counter*2+1
//   [1] DIFF   = 0xFFFF_FFFF
//   [2] AND    = counter & (counter+1)
//   [3] OR     = counter | (counter+1)
//   [4] XOR    = counter ^ (counter+1)
//   [5] SLL    = counter << 2
//   [6] SRL    = counter >> 2
//   [7] MEM    = counter*7
//   [8] BRANCH = 0xAAAA_AAAA or 0x5555_5555
//   WRAP: 0xDEAD_BEEF (counter==0x100)
// ============================================================
`timescale 1ns/1ps

module rv32i_checker (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] gpio_out_obs,
    input  logic        gpio_out_wen,
    input  logic [31:0] dbg_pc,
    input  logic        dbg_reg_we,
    input  logic [4:0]  dbg_reg_waddr,
    input  logic [31:0] dbg_reg_wdata
);

    typedef enum logic [3:0] {
        SEQ_SUM    = 4'd0,
        SEQ_DIFF   = 4'd1,
        SEQ_AND    = 4'd2,
        SEQ_OR     = 4'd3,
        SEQ_XOR    = 4'd4,
        SEQ_SLL    = 4'd5,
        SEQ_SRL    = 4'd6,
        SEQ_MEM    = 4'd7,
        SEQ_BRANCH = 4'd8,
        SEQ_WRAP   = 4'd9
    } seq_t;

    seq_t        seq_idx;
    logic [31:0] counter;
    int unsigned pass_cnt;
    int unsigned fail_cnt;
    logic        wrap_pending;

    function automatic logic [31:0] expected_val(
        input seq_t    s,
        input logic [31:0] cnt
    );
        logic [31:0] a, b;
        a = cnt; b = cnt + 32'd1;
        case (s)
            SEQ_SUM    : return a + b;
            SEQ_DIFF   : return a - b;
            SEQ_AND    : return a & b;
            SEQ_OR     : return a | b;
            SEQ_XOR    : return a ^ b;
            SEQ_SLL    : return a << 2;
            SEQ_SRL    : return a >> 2;
            SEQ_MEM    : return cnt + (cnt<<1) + (cnt<<2);
            SEQ_BRANCH : return (cnt[0]==0) ? 32'hAAAA_AAAA : 32'h5555_5555;
            SEQ_WRAP   : return 32'hDEAD_BEEF;
            default    : return 32'hX;
        endcase
    endfunction

    function automatic string seq_name(input seq_t s);
        case (s)
            SEQ_SUM    : return "SUM   ";
            SEQ_DIFF   : return "DIFF  ";
            SEQ_AND    : return "AND   ";
            SEQ_OR     : return "OR    ";
            SEQ_XOR    : return "XOR   ";
            SEQ_SLL    : return "SLL   ";
            SEQ_SRL    : return "SRL   ";
            SEQ_MEM    : return "MEM   ";
            SEQ_BRANCH : return "BRANCH";
            SEQ_WRAP   : return "WRAP  ";
            default    : return "UNKNOWN";
        endcase
    endfunction

    initial begin
        seq_idx = SEQ_SUM; counter = 32'd0;
        pass_cnt = 0; fail_cnt = 0; wrap_pending = 1'b0;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seq_idx <= SEQ_SUM; counter <= 32'd0; wrap_pending <= 1'b0;
        end else if (gpio_out_wen) begin
            logic [31:0] exp_val;
            string       sname;
            if (gpio_out_obs == 32'hDEAD_BEEF && wrap_pending) begin
                check_result(32'hDEAD_BEEF, gpio_out_obs, "WRAP  ", counter);
                wrap_pending <= 1'b0;
                seq_idx      <= SEQ_SUM;
                counter      <= 32'd0;
            end else begin
                exp_val = expected_val(seq_idx, counter);
                sname   = seq_name(seq_idx);
                check_result(exp_val, gpio_out_obs, sname, counter);
                if (seq_idx == SEQ_BRANCH) begin
                    counter <= counter + 1;
                    seq_idx <= SEQ_SUM;
                    if ((counter + 1) >= 32'h100) wrap_pending <= 1'b1;
                end else begin
                    seq_idx <= seq_t'(seq_idx + 1);
                end
            end
        end
    end

    task automatic check_result(
        input logic [31:0] exp, got,
        input string name,
        input logic [31:0] cnt
    );
        if (exp === got) begin
            pass_cnt++;
            $display("[PASS] t=%0t  cnt=%0d  %s  exp=0x%08X  got=0x%08X",
                     $time, cnt, name, exp, got);
        end else begin
            fail_cnt++;
            $display("[FAIL] t=%0t  cnt=%0d  %s  exp=0x%08X  got=0x%08X  *** MISMATCH ***",
                     $time, cnt, name, exp, got);
        end
    endtask

    final begin
        $display("========================================");
        $display("  CHECKER SUMMARY");
        $display("  PASS : %0d", pass_cnt);
        $display("  FAIL : %0d", fail_cnt);
        $display("  RESULT : %s", (fail_cnt==0) ? "*** ALL PASS ***" : "*** FAILED ***");
        $display("========================================");
    end

    logic [31:0] pc_prev;
    int unsigned stall_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_prev <= 32'h0; stall_cnt <= 0;
        end else begin
            if (dbg_pc === pc_prev) stall_cnt <= stall_cnt + 1;
            else begin stall_cnt <= 0; pc_prev <= dbg_pc; end
            if (stall_cnt >= 50) begin
                $display("[WARN] PC stuck at 0x%08X for %0d cycles (t=%0t)",
                         dbg_pc, stall_cnt, $time);
                stall_cnt <= 0;
            end
        end
    end

endmodule
