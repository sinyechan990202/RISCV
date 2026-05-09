// ============================================================
// tb_top.sv  —  rv32i_core 최상위 테스트벤치
//
// 구성
//   ┌─────────────┐   imem   ┌────────────┐
//   │             │◄────────►│            │
//   │  rv32i_core │   dmem   │  mem_model │
//   │   (DUT)     │◄────────►│ (IMEM/DMEM │
//   │             │          │  /GPIO)    │
//   └──────┬──────┘          └─────┬──────┘
//          │ dbg_*                 │ gpio_out_obs/wen
//          └──────────────────────►│
//                          ┌───────▼──────┐
//                          │rv32i_checker │
//                          │ (자동 검증)  │
//                          └──────────────┘
// ============================================================
`timescale 1ns/1ps

module tb_top;

    parameter CLK_PERIOD    = 10;
    parameter RST_CYCLES    = 5;
    parameter SIM_TIMEOUT   = 2_000_000;

    logic clk;
    logic rst_n;

    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

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

    logic        ext_irq   = 1'b0;
    logic        timer_irq = 1'b0;

    logic [31:0] dbg_pc;
    logic        dbg_reg_we;
    logic [4:0]  dbg_reg_waddr;
    logic [31:0] dbg_reg_wdata;

    logic [31:0] gpio_in_val = 32'h0000_0000;
    logic [31:0] gpio_out_obs;
    logic        gpio_out_wen;

    rv32i_core #(
        .XLEN        (32),
        .IMEM_DWIDTH (32),
        .DMEM_DWIDTH (32)
    ) u_dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .imem_req       (imem_req),
        .imem_addr      (imem_addr),
        .imem_rdata     (imem_rdata),
        .imem_ready     (imem_ready),
        .dmem_req       (dmem_req),
        .dmem_we        (dmem_we),
        .dmem_be        (dmem_be),
        .dmem_addr      (dmem_addr),
        .dmem_wdata     (dmem_wdata),
        .dmem_rdata     (dmem_rdata),
        .dmem_ready     (dmem_ready),
        .ext_irq        (ext_irq),
        .timer_irq      (timer_irq),
        .dbg_pc         (dbg_pc),
        .dbg_reg_we     (dbg_reg_we),
        .dbg_reg_waddr  (dbg_reg_waddr),
        .dbg_reg_wdata  (dbg_reg_wdata)
    );

    mem_model #(
        .IMEM_DEPTH (16384),
        .DMEM_DEPTH (16384),
        .MEM_DELAY  (1)
    ) u_mem (
        .clk         (clk),
        .rst_n       (rst_n),
        .imem_req    (imem_req),
        .imem_addr   (imem_addr),
        .imem_rdata  (imem_rdata),
        .imem_ready  (imem_ready),
        .dmem_req    (dmem_req),
        .dmem_we     (dmem_we),
        .dmem_be     (dmem_be),
        .dmem_addr   (dmem_addr),
        .dmem_wdata  (dmem_wdata),
        .dmem_rdata  (dmem_rdata),
        .dmem_ready  (dmem_ready),
        .gpio_out_obs(gpio_out_obs),
        .gpio_out_wen(gpio_out_wen),
        .gpio_in_val (gpio_in_val)
    );

    rv32i_checker u_checker (
        .clk           (clk),
        .rst_n         (rst_n),
        .gpio_out_obs  (gpio_out_obs),
        .gpio_out_wen  (gpio_out_wen),
        .dbg_pc        (dbg_pc),
        .dbg_reg_we    (dbg_reg_we),
        .dbg_reg_waddr (dbg_reg_waddr),
        .dbg_reg_wdata (dbg_reg_wdata)
    );

    initial begin
        rst_n = 1'b0;
        repeat (RST_CYCLES) @(posedge clk);
        #1;
        rst_n = 1'b1;
        $display("[TB] Reset released at t=%0t", $time);
    end

    initial begin
        repeat (SIM_TIMEOUT) @(posedge clk);
        $display("[TB] TIMEOUT: simulation ended at t=%0t", $time);
        $finish;
    end

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

    always @(posedge clk) begin
        if (gpio_out_wen)
            $display("[GPIO] t=%0t  PC=0x%08X  GPIO_OUT=0x%08X",
                     $time, dbg_pc, gpio_out_obs);
    end

    integer dbg_reg_cnt;
    initial dbg_reg_cnt = 0;
    always @(posedge clk) begin
        if (dbg_reg_we && dbg_reg_waddr != 5'b0 && dbg_reg_cnt < 80) begin
            $display("[REG] t=%0t  IF_PC=0x%08X  x%02d <= 0x%08X", $time, dbg_pc, dbg_reg_waddr, dbg_reg_wdata);
            dbg_reg_cnt = dbg_reg_cnt + 1;
        end
    end

    logic [31:0] prev_if_pc;
    integer redir_cnt;
    initial begin prev_if_pc = 32'h0; redir_cnt = 0; end
    always @(posedge clk) begin
        if (rst_n && prev_if_pc !== dbg_pc && dbg_pc !== (prev_if_pc + 4) && redir_cnt < 20) begin
            $display("[REDIR] t=%0t  0x%08X → 0x%08X", $time, prev_if_pc, dbg_pc);
            redir_cnt = redir_cnt + 1;
        end
        prev_if_pc <= dbg_pc;
    end

    initial begin
        $display("========================================");
        $display("  rv32i_core Testbench START");
        $display("  CLK  = %0d ns", CLK_PERIOD);
        $display("  RST  = %0d cycles", RST_CYCLES);
        $display("  TOUT = %0d cycles", SIM_TIMEOUT);
        $display("========================================");
    end

endmodule
