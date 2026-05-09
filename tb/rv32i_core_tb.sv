`timescale 1ns/1ps

// ----------------------------------------------------------------------------
// Test program (assembled RV32I, word-addressed)
//
// [R-type ALU + EX→EX 포워딩]
//  0x00  ADDI  x1,  x0,  5      # x1  = 5
//  0x04  ADDI  x2,  x0,  3      # x2  = 3
//  0x08  ADD   x3,  x1,  x2     # x3  = 8         EX→EX fwd (x1,x2)
//  0x0C  SUB   x4,  x3,  x2     # x4  = 5         EX→EX fwd (x3)
//  0x10  AND   x5,  x3,  x4     # x5  = 0         (8 & 5 = 0)
//  0x14  OR    x6,  x3,  x4     # x6  = 13        (8 | 5 = 13)
//  0x18  XOR   x7,  x1,  x2     # x7  = 6         (5 ^ 3 = 6)
//  0x1C  SLL   x8,  x1,  x2     # x8  = 40        (5 << 3)
//  0x20  SRL   x9,  x8,  x2     # x9  = 5         (40 >> 3)  EX→EX fwd (x8)
//
// [U-type + Store/Load]
//  0x24  LUI   x10, 1            # x10 = 0x0000_1000
//  0x28  SW    x3,  0(x0)        # mem[0] = 8
//  0x2C  LW    x11, 0(x0)        # x11 = 8
//  0x30  ADD   x12, x11, x1     # x12 = 13        ← LOAD-USE STALL (x11)
//
// [Branch: not-taken + taken]
//  0x34  BEQ   x1,  x2,  +8     # NOT taken (5≠3) → fall through 0x38
//  0x38  BNE   x1,  x2,  +8     # TAKEN (5≠3)     → 0x40
//  0x3C  ADDI  x13, x0,  99     # SKIPPED
//
// [JALR]
//  0x40  ADDI  x14, x0,  80     # x14 = 0x50
//  0x44  JALR  x15, x14, 0      # x15 = 0x48,  PC → 0x50  (skip 0x48)
//  0x48  ADDI  x16, x0,  99     # SKIPPED
//  0x4C  NOP
//
// [Post-JALR: AUIPC / SLT / SRA]
//  0x50  ADDI  x17, x0,  42     # x17 = 42
//  0x54  AUIPC x18, 0           # x18 = PC+0 = 0x54
//  0x58  SLT   x19, x2,  x1     # x19 = 1         (3 < 5)
//  0x5C  ADDI  x20, x0,  -1     # x20 = 0xFFFFFFFF
//  0x60  SRA   x21, x20, x2     # x21 = 0xFFFFFFFF (-1 >>a 3 = -1)
//
// [Timing A: MEM→EX forwarding (R-type, 1-NOP gap)]
//  0x64  ADD   x22, x1,  x2     # x22 = 8
//  0x68  NOP                    # gap: x22 in MEM/WB when next instr in EX
//  0x6C  SUB   x23, x22, x2     # x23 = 5         MEM→EX fwd (x22)
//
// [Timing B: SW EX→EX fwd + second load-use stall]
//  0x70  ADD   x24, x1,  x2     # x24 = 8
//  0x74  SW    x24, 8(x0)       # EX→EX fwd on rs2: store x24=8 → dmem[2]
//  0x78  LW    x25, 8(x0)       # x25 = 8
//  0x7C  ADD   x26, x25, x1     # x26 = 13        ← LOAD-USE STALL (x25)
//
// [Timing C: stall → EX→EX chain (stall 중 IF에 있던 명령이 stall 피해자를 바로 EX→EX로 사용)]
//  0x80  ADD   x27, x26, x2     # x27 = 16        EX→EX fwd (x26, stall 피해자)
//  0x84  ADD   x28, x27, x1     # x28 = 21        EX→EX fwd (x27)
//  0x88  ADD   x29, x28, x2     # x29 = 24        EX→EX fwd (x28)
//
// [Timing D: LW→NOP→use  load data MEM→EX fwd, stall 없이 1-gap]
//  0x8C  LW    x30, 0(x0)       # x30 = 8         (load, 1-gap → no stall with next)
//  0x90  NOP
//  0x94  ADD   x31, x30, x1     # x31 = 13        MEM→EX fwd of load data (not ALU result)
//  0x98  JAL   x0,  0           # infinite self-loop (halts simulation)
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

        // ── R-type ALU ───────────────────────────────────────────────────────
        imem[0]  = 32'h0050_0093; // ADDI x1,  x0,  5
        imem[1]  = 32'h0030_0113; // ADDI x2,  x0,  3
        imem[2]  = 32'h0020_81B3; // ADD  x3,  x1,  x2
        imem[3]  = 32'h4021_8233; // SUB  x4,  x3,  x2
        imem[4]  = 32'h0041_F2B3; // AND  x5,  x3,  x4   (8 & 5 = 0)
        imem[5]  = 32'h0041_E333; // OR   x6,  x3,  x4   (8 | 5 = 13)
        imem[6]  = 32'h0020_C3B3; // XOR  x7,  x1,  x2   (5 ^ 3 = 6)
        imem[7]  = 32'h0020_9433; // SLL  x8,  x1,  x2   (5 << 3 = 40)
        imem[8]  = 32'h0024_54B3; // SRL  x9,  x8,  x2   (40 >> 3 = 5)

        // ── U-type + Mem ─────────────────────────────────────────────────────
        imem[9]  = 32'h0000_1537; // LUI  x10, 1          (x10 = 0x1000)
        imem[10] = 32'h0030_2023; // SW   x3,  0(x0)      (mem[0] = 8)
        imem[11] = 32'h0000_2583; // LW   x11, 0(x0)      (x11 = 8)
        imem[12] = 32'h0015_8633; // ADD  x12, x11, x1   (13) ← LOAD-USE STALL

        // ── Branch ───────────────────────────────────────────────────────────
        imem[13] = 32'h0020_8463; // BEQ  x1,  x2,  +8   (NOT taken)
        imem[14] = 32'h0020_9463; // BNE  x1,  x2,  +8   (TAKEN → 0x40)
        imem[15] = 32'h0630_0693; // ADDI x13, x0,  99   (SKIPPED)

        // ── JALR ─────────────────────────────────────────────────────────────
        imem[16] = 32'h0500_0713; // ADDI x14, x0,  80   (x14 = 0x50)
        imem[17] = 32'h0007_07E7; // JALR x15, x14, 0    (x15=0x48, PC→0x50)
        imem[18] = 32'h0630_0813; // ADDI x16, x0,  99   (SKIPPED)
        imem[19] = 32'h0000_0013; // NOP

        // ── Post-JALR: AUIPC / SLT / SRA / halt ─────────────────────────────
        imem[20] = 32'h02A0_0893; // ADDI x17, x0,  42
        imem[21] = 32'h0000_0917; // AUIPC x18, 0        (x18 = PC = 0x54)
        imem[22] = 32'h0011_29B3; // SLT  x19, x2,  x1  (3 < 5 → 1)
        imem[23] = 32'hFFF0_0A13; // ADDI x20, x0,  -1  (0xFFFFFFFF)
        imem[24] = 32'h402A_5AB3; // SRA  x21, x20, x2  (-1 >>a 3 = -1)
        // ── Timing A: MEM→EX forwarding (R-type, 1-NOP gap) ─────────────────
        imem[25] = 32'h0020_8B33; // ADD  x22, x1,  x2   (x22 = 8)
        imem[26] = 32'h0000_0013; // NOP
        imem[27] = 32'h402B_0BB3; // SUB  x23, x22, x2   (x23 = 5  MEM→EX fwd)

        // ── Timing B: SW EX→EX fwd + second load-use stall ──────────────────
        imem[28] = 32'h0020_8C33; // ADD  x24, x1,  x2   (x24 = 8)
        imem[29] = 32'h0180_2423; // SW   x24, 8(x0)     (EX→EX fwd, dmem[2]=8)
        imem[30] = 32'h0080_2C83; // LW   x25, 8(x0)     (x25 = 8)
        imem[31] = 32'h001C_8D33; // ADD  x26, x25, x1   (x26=13 ← LOAD-USE STALL)

        // ── Timing C: stall→EX→EX  stall 피해자를 stall 중 IF에 있던 명령이 EX→EX ──
        imem[32] = 32'h002D_0DB3; // ADD  x27, x26, x2   (x27=16  EX→EX fwd: x26 stall 피해자)
        imem[33] = 32'h001D_8E33; // ADD  x28, x27, x1   (x28=21  EX→EX fwd)
        imem[34] = 32'h002E_0EB3; // ADD  x29, x28, x2   (x29=24  EX→EX fwd)

        // ── Timing D: LW→NOP→use  load data MEM→EX fwd, stall 없이 1-gap ────
        imem[35] = 32'h0000_2F03; // LW   x30, 0(x0)     (x30 = 8)
        imem[36] = 32'h0000_0013; // NOP
        imem[37] = 32'h001F_0FB3; // ADD  x31, x30, x1   (x31=13  load-data MEM→EX fwd)
        imem[38] = 32'h0000_006F; // JAL  x0,  0         (self-loop / halt)
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
    logic [31:0] expected [1:31];
    logic        exp_valid [1:31];

    initial begin
        integer i;
        for (i = 1; i < 32; i++) begin
            expected[i] = 0;
            exp_valid[i] = 0;
        end
        // x13, x16: SKIPPED (분기/JALR로 건너뜀) — exp_valid 설정 안 함
        expected[1]  = 32'd5;          exp_valid[1]  = 1; // ADDI
        expected[2]  = 32'd3;          exp_valid[2]  = 1; // ADDI
        expected[3]  = 32'd8;          exp_valid[3]  = 1; // ADD
        expected[4]  = 32'd5;          exp_valid[4]  = 1; // SUB
        expected[5]  = 32'd0;          exp_valid[5]  = 1; // AND  8&5=0
        expected[6]  = 32'd13;         exp_valid[6]  = 1; // OR   8|5=13
        expected[7]  = 32'd6;          exp_valid[7]  = 1; // XOR  5^3=6
        expected[8]  = 32'd40;         exp_valid[8]  = 1; // SLL  5<<3=40
        expected[9]  = 32'd5;          exp_valid[9]  = 1; // SRL  40>>3=5
        expected[10] = 32'h0000_1000;  exp_valid[10] = 1; // LUI
        expected[11] = 32'd8;          exp_valid[11] = 1; // LW
        expected[12] = 32'd13;         exp_valid[12] = 1; // ADD (load-use 이후)
        expected[14] = 32'd80;         exp_valid[14] = 1; // ADDI  x14=0x50
        expected[15] = 32'h0000_0048;  exp_valid[15] = 1; // JALR 링크 (PC+4=0x48)
        expected[17] = 32'd42;         exp_valid[17] = 1; // ADDI (JALR 착지점)
        expected[18] = 32'h0000_0054;  exp_valid[18] = 1; // AUIPC (PC=0x54)
        expected[19] = 32'd1;          exp_valid[19] = 1; // SLT  3<5=1
        expected[20] = 32'hFFFF_FFFF;  exp_valid[20] = 1; // ADDI -1
        expected[21] = 32'hFFFF_FFFF;  exp_valid[21] = 1; // SRA  -1>>3=-1
        // Timing A: MEM→EX forwarding
        expected[22] = 32'd8;          exp_valid[22] = 1; // ADD  x22=8
        expected[23] = 32'd5;          exp_valid[23] = 1; // SUB  x22-x2=5 (MEM→EX)
        // Timing B: SW forwarding + second load-use
        expected[24] = 32'd8;          exp_valid[24] = 1; // ADD  x24=8
        expected[25] = 32'd8;          exp_valid[25] = 1; // LW   x25=8
        expected[26] = 32'd13;         exp_valid[26] = 1; // ADD  x25+x1=13 (load-use)
        // Timing C: stall→EX→EX chain (x26=13 stall 피해자 → x27 EX→EX → chain)
        expected[27] = 32'd16;         exp_valid[27] = 1; // ADD  x26+x2=16 (stall→EX→EX)
        expected[28] = 32'd21;         exp_valid[28] = 1; // ADD  x27+x1=21 (EX→EX)
        expected[29] = 32'd24;         exp_valid[29] = 1; // ADD  x28+x2=24 (EX→EX)
        // Timing D: load data MEM→EX fwd, 1-gap, no stall
        expected[30] = 32'd8;          exp_valid[30] = 1; // LW   x30=8
        expected[31] = 32'd13;         exp_valid[31] = 1; // ADD  x30+x1=13 (load MEM→EX)
    end

    // Declare at module scope so iverilog does not treat as a static initializer
    int pass_cnt;
    int fail_cnt;
    int wb_rd;

    initial begin
        pass_cnt = 0;
        fail_cnt = 0;
    end

    always @(posedge clk) begin
        if (dbg_reg_we && dbg_reg_waddr != 5'b0) begin
            wb_rd = dbg_reg_waddr;
            $display("[WB  ] clk=%0t  x%0d <= 0x%08X", $time, wb_rd, dbg_reg_wdata);
            if (exp_valid[wb_rd]) begin
                if (dbg_reg_wdata === expected[wb_rd]) begin
                    $display("       PASS  x%0d = 0x%08X", wb_rd, dbg_reg_wdata);
                    pass_cnt++;
                end else begin
                    $display("       FAIL  x%0d : got 0x%08X, want 0x%08X",
                             wb_rd, dbg_reg_wdata, expected[wb_rd]);
                    fail_cnt++;
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Halt detection: JAL x0, 0 writes PC+4 (nonzero) to x0 at WB.
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst_n && dbg_reg_we && dbg_reg_waddr == 5'b0 && dbg_reg_wdata != 32'b0) begin
            $display("\n[HALT] JAL x0 at PC=0x%08X — simulation complete.",
                     dbg_reg_wdata - 4);
            $display("       PASS=%0d / 29  FAIL=%0d", pass_cnt, fail_cnt);
            if (fail_cnt == 0)
                $display("       *** ALL CHECKS PASSED ***");
            else
                $display("       *** %0d CHECK(S) FAILED ***", fail_cnt);
            $finish;
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
