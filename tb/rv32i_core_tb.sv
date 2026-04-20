`timescale 1ns/1ps

// ----------------------------------------------------------------------------
// Test program (assembled RV32I, word-addressed)
//
//  0x00  ADDI  x1,  x0, 5      # x1  = 5
//  0x04  ADDI  x2,  x0, 3      # x2  = 3
//  0x08  ADD   x3,  x1, x2     # x3  = 8
//  0x0C  SUB   x4,  x3, x2     # x4  = 5
//  0x10  LUI   x5,  1          # x5  = 0x0000_1000
//  0x14  SW    x3,  0(x0)      # mem[0] = 8
//  0x18  LW    x6,  0(x0)      # x6  = 8  (load-use hazard if followed by use)
//  0x1C  BNE   x1,  x2, +8    # taken → 0x24  (x1≠x2)
//  0x20  ADDI  x7,  x0, 99     # SKIPPED
//  0x24  ADDI  x8,  x0, 42     # x8  = 42
//  0x28  JAL   x0,  0          # infinite self-loop (halts simulation)
// ----------------------------------------------------------------------------

module rv32i_core_tb;

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    localparam CLK_PERIOD  = 10;   // ns
    localparam IMEM_DEPTH  = 256;  // words
    localparam DMEM_DEPTH  = 256;  // words
    localparam MAX_CYCLES  = 2000;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    logic        clk, rst_n;
    logic        imem_req;
    logic [31:0] imem_addr;
    logic [31:0] imem_rdata;
    logic        imem_ready;
    logic        dmem_req;
    logic        dmem_we;
    logic [3:0]  dmem_be;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [31:0] dmem_rdata;
    logic        dmem_ready;
    logic        ext_irq, timer_irq;
    logic [31:0] dbg_pc;
    logic        dbg_reg_we;
    logic [4:0]  dbg_reg_waddr;
    logic [31:0] dbg_reg_wdata;

    // -------------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------------
    rv32i_core #(.XLEN(32)) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .imem_req     (imem_req),
        .imem_addr    (imem_addr),
        .imem_rdata   (imem_rdata),
        .imem_ready   (imem_ready),
        .dmem_req     (dmem_req),
        .dmem_we      (dmem_we),
        .dmem_be      (dmem_be),
        .dmem_addr    (dmem_addr),
        .dmem_wdata   (dmem_wdata),
        .dmem_rdata   (dmem_rdata),
        .dmem_ready   (dmem_ready),
        .ext_irq      (ext_irq),
        .timer_irq    (timer_irq),
        .dbg_pc       (dbg_pc),
        .dbg_reg_we   (dbg_reg_we),
        .dbg_reg_waddr(dbg_reg_waddr),
        .dbg_reg_wdata(dbg_reg_wdata)
    );

    // -------------------------------------------------------------------------
    // Clock
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // -------------------------------------------------------------------------
    // Instruction memory model (single-cycle, always ready)
    // -------------------------------------------------------------------------
    logic [31:0] imem [0:IMEM_DEPTH-1];

    initial begin
        integer i;
        for (i = 0; i < IMEM_DEPTH; i++) imem[i] = 32'h0000_0013; // NOP

        // Test program
        imem[0]  = 32'h0050_0093; // ADDI x1,  x0, 5
        imem[1]  = 32'h0030_0113; // ADDI x2,  x0, 3
        imem[2]  = 32'h0020_81B3; // ADD  x3,  x1, x2
        imem[3]  = 32'h4021_8233; // SUB  x4,  x3, x2
        imem[4]  = 32'h0000_12B7; // LUI  x5,  1
        imem[5]  = 32'h0030_2023; // SW   x3,  0(x0)
        imem[6]  = 32'h0000_2303; // LW   x6,  0(x0)
        imem[7]  = 32'h0020_9463; // BNE  x1,  x2, +8  → PC=0x24
        imem[8]  = 32'h0630_0393; // ADDI x7,  x0, 99  (skipped)
        imem[9]  = 32'h02A0_0413; // ADDI x8,  x0, 42
        imem[10] = 32'h0000_006F; // JAL  x0,  0  (self-loop / halt)
    end

    assign imem_rdata = imem[imem_addr[31:2]]; // word-addressed
    assign imem_ready = 1'b1;

    // -------------------------------------------------------------------------
    // Data memory model
    // -------------------------------------------------------------------------
    logic [31:0] dmem [0:DMEM_DEPTH-1];

    initial begin
        integer i;
        for (i = 0; i < DMEM_DEPTH; i++) dmem[i] = 32'h0;
    end

    always_ff @(posedge clk) begin
        if (dmem_req && dmem_we) begin
            if (dmem_be[0]) dmem[dmem_addr[31:2]][7:0]   <= dmem_wdata[7:0];
            if (dmem_be[1]) dmem[dmem_addr[31:2]][15:8]  <= dmem_wdata[15:8];
            if (dmem_be[2]) dmem[dmem_addr[31:2]][23:16] <= dmem_wdata[23:16];
            if (dmem_be[3]) dmem[dmem_addr[31:2]][31:24] <= dmem_wdata[31:24];
        end
    end

    assign dmem_rdata = dmem[dmem_addr[31:2]];
    assign dmem_ready = 1'b1;

    // -------------------------------------------------------------------------
    // Interrupt stimulus (inactive for basic test)
    // -------------------------------------------------------------------------
    assign ext_irq   = 1'b0;
    assign timer_irq = 1'b0;

    // -------------------------------------------------------------------------
    // Reset sequence
    // -------------------------------------------------------------------------
    initial begin
        rst_n = 1'b0;
        repeat(4) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
    end

    // -------------------------------------------------------------------------
    // WB-stage register write monitor & checker
    // -------------------------------------------------------------------------
    // Expected results keyed on rd address.
    // Writes are checked when dbg_reg_we asserts.
    logic [31:0] expected [1:31];
    logic        exp_valid [1:31];

    initial begin
        integer i;
        for (i = 1; i < 32; i++) begin
            expected[i] = 0;
            exp_valid[i] = 0;
        end
        // x7 is deliberately NOT expected (instruction at 0x20 is skipped)
        expected[1] = 32'd5;       exp_valid[1] = 1;
        expected[2] = 32'd3;       exp_valid[2] = 1;
        expected[3] = 32'd8;       exp_valid[3] = 1;
        expected[4] = 32'd5;       exp_valid[4] = 1;
        expected[5] = 32'h0000_1000; exp_valid[5] = 1;
        expected[6] = 32'd8;       exp_valid[6] = 1;
        expected[8] = 32'd42;      exp_valid[8] = 1;
    end

    int pass_cnt = 0, fail_cnt = 0;

    always @(posedge clk) begin
        if (dbg_reg_we && dbg_reg_waddr != 5'b0) begin
            int rd = dbg_reg_waddr;
            $display("[WB  ] clk=%0t  x%0d <= 0x%08X", $time, rd, dbg_reg_wdata);
            if (exp_valid[rd]) begin
                if (dbg_reg_wdata === expected[rd]) begin
                    $display("       PASS  x%0d = 0x%08X", rd, dbg_reg_wdata);
                    pass_cnt++;
                end else begin
                    $display("       FAIL  x%0d : got 0x%08X, want 0x%08X",
                             rd, dbg_reg_wdata, expected[rd]);
                    fail_cnt++;
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Halt detection: JAL x0, 0 loops forever at same PC
    // -------------------------------------------------------------------------
    logic [31:0] prev_pc;
    int          same_pc_cnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            prev_pc      <= 32'hFFFF_FFFF;
            same_pc_cnt  <= 0;
        end else begin
            if (dbg_pc === prev_pc)
                same_pc_cnt <= same_pc_cnt + 1;
            else begin
                same_pc_cnt <= 0;
                prev_pc     <= dbg_pc;
            end
            if (same_pc_cnt >= 4) begin
                $display("\n[HALT] PC stuck at 0x%08X — simulation complete.", dbg_pc);
                $display("       PASS=%0d  FAIL=%0d", pass_cnt, fail_cnt);
                if (fail_cnt == 0)
                    $display("       *** ALL CHECKS PASSED ***");
                else
                    $display("       *** %0d CHECK(S) FAILED ***", fail_cnt);
                $finish;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Timeout guard
    // -------------------------------------------------------------------------
    initial begin
        repeat(MAX_CYCLES) @(posedge clk);
        $display("[TIMEOUT] %0d cycles elapsed without halt. FAIL=%0d", MAX_CYCLES, fail_cnt);
        $finish;
    end

    // -------------------------------------------------------------------------
    // VCD waveform dump
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("rv32i_core_tb.vcd");
        $dumpvars(0, rv32i_core_tb);
    end

endmodule
