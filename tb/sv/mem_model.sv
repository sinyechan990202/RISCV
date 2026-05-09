// ============================================================
// mem_model.sv
// 역할 : IMEM / DMEM / GPIO MMIO 통합 슬레이브 모델
//
// 메모리 맵
//   0x0000_0000 ~ 0x0000_FFFF  → IMEM  (64KB, read-only)
//   0x0001_0000 ~ 0x0001_FFFF  → DMEM  (64KB, read/write)
//   0x1000_0000                → GPIO_OUT (write capture)
//   0x1000_0004                → GPIO_IN  (read, tb 주입)
// ============================================================
`timescale 1ns/1ps

module mem_model #(
    parameter IMEM_DEPTH = 16384,
    parameter DMEM_DEPTH = 16384,
    parameter MEM_DELAY  = 1
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        imem_req,
    input  logic [31:0] imem_addr,
    output logic [31:0] imem_rdata,
    output logic        imem_ready,
    input  logic        dmem_req,
    input  logic        dmem_we,
    input  logic [3:0]  dmem_be,
    input  logic [31:0] dmem_addr,
    input  logic [31:0] dmem_wdata,
    output logic [31:0] dmem_rdata,
    output logic        dmem_ready,
    output logic [31:0] gpio_out_obs,
    output logic        gpio_out_wen,
    input  logic [31:0] gpio_in_val
);

    logic [31:0] imem [0:IMEM_DEPTH-1];
    logic [31:0] dmem [0:DMEM_DEPTH-1];

    initial begin
        for (int i = 0; i < IMEM_DEPTH; i++)
            imem[i] = 32'h0000_0013;
        $readmemh("mem/imem_init.hex", imem);
        $display("[MEM] IMEM loaded from imem_init.hex");
    end

    initial begin
        for (int i = 0; i < DMEM_DEPTH; i++)
            dmem[i] = 32'h0;
    end

    // ── IMEM ─────────────────────────────────────────────────
    // imem_ready is only asserted when the data presented matches
    // the address currently being requested (address-tracking fix).
    logic        imem_ready_r;
    logic [31:0] imem_rdata_r;
    logic [31:0] imem_sampled_addr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            imem_ready_r      <= 1'b0;
            imem_rdata_r      <= 32'h0;
            imem_sampled_addr <= 32'h0;
        end else begin
            imem_sampled_addr <= imem_addr;
            imem_ready_r      <= imem_req;
            if (imem_req)
                imem_rdata_r <= imem[imem_addr[31:2]];
        end
    end

    assign imem_ready = (MEM_DELAY == 0)
                        ? imem_req
                        : (imem_ready_r && (imem_addr == imem_sampled_addr));
    assign imem_rdata = (MEM_DELAY == 0) ? imem[imem_addr[31:2]] : imem_rdata_r;

    // ── DMEM decode ──────────────────────────────────────────
    logic is_gpio_out, is_gpio_in, is_dmem;
    assign is_gpio_out = (dmem_addr == 32'h1000_0000);
    assign is_gpio_in  = (dmem_addr == 32'h1000_0004);
    assign is_dmem     = (dmem_addr[31:16] == 16'h0001);

    // ── GPIO capture ─────────────────────────────────────────
    logic [31:0] gpio_out_r;
    logic        gpio_wen_r;

    // ── DMEM ready (address-tracking, same as IMEM fix) ─────
    logic        dmem_ready_r;
    logic [31:0] dmem_rdata_r;
    logic [31:0] dmem_sampled_addr;
    // dmem_ready_q: previous-cycle dmem_ready for rising-edge detection.
    // Prevents GPIO double-fire when IMEM stall keeps a store in MEM while
    // dmem_ready stays asserted across multiple cycles.
    logic        dmem_ready_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_out_r        <= 32'h0;
            gpio_wen_r        <= 1'b0;
            dmem_ready_r      <= 1'b0;
            dmem_rdata_r      <= 32'h0;
            dmem_sampled_addr <= 32'h0;
            dmem_ready_q      <= 1'b0;
        end else begin
            gpio_wen_r        <= 1'b0;
            dmem_sampled_addr <= dmem_addr;
            dmem_ready_r      <= dmem_req & (is_dmem | is_gpio_in | is_gpio_out);
            dmem_ready_q      <= dmem_ready;  // register dmem_ready for edge detect

            if (dmem_req) begin
                // Fire GPIO write only on the rising edge of dmem_ready so that
                // a store held in MEM by an IMEM stall does not write twice.
                if (dmem_we && is_gpio_out && dmem_ready && !dmem_ready_q) begin
                    gpio_out_r <= dmem_wdata;
                    gpio_wen_r <= 1'b1;
                end
                if (dmem_we && is_dmem) begin
                    logic [13:0] widx;
                    widx = dmem_addr[15:2];
                    if (dmem_be[0]) dmem[widx][ 7: 0] <= dmem_wdata[ 7: 0];
                    if (dmem_be[1]) dmem[widx][15: 8] <= dmem_wdata[15: 8];
                    if (dmem_be[2]) dmem[widx][23:16] <= dmem_wdata[23:16];
                    if (dmem_be[3]) dmem[widx][31:24] <= dmem_wdata[31:24];
                end
                if (!dmem_we) begin
                    if      (is_dmem)     dmem_rdata_r <= dmem[dmem_addr[15:2]];
                    else if (is_gpio_in)  dmem_rdata_r <= gpio_in_val;
                    else if (is_gpio_out) dmem_rdata_r <= gpio_out_r;
                    else                  dmem_rdata_r <= 32'hDEAD_BEEF;
                end
            end
        end
    end

    assign gpio_out_obs = gpio_out_r;
    assign gpio_out_wen = gpio_wen_r;

    assign dmem_ready = (MEM_DELAY == 0)
                        ? (dmem_req & (is_dmem | is_gpio_in | is_gpio_out))
                        : (dmem_ready_r && (dmem_addr == dmem_sampled_addr));
    assign dmem_rdata = dmem_rdata_r;

endmodule
