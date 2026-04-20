// csr_op: 001=CSRRW, 010=CSRRS, 011=CSRRC, 101=CSRRWI, 110=CSRRSI, 111=CSRRCI
// ZIMM instructions: caller places {27'b0, rs1_addr} in rs1_data
module csr_regfile #(
    parameter XLEN = 32
) (
    input  logic             clk,
    input  logic             rst_n,
    // Instruction interface
    input  logic [2:0]       csr_op,
    input  logic [11:0]      csr_addr,
    input  logic [XLEN-1:0]  rs1_data,
    output logic [XLEN-1:0]  csr_rdata,
    // Trap interface
    input  logic             trap_en,
    input  logic [XLEN-1:0]  mepc_in,
    input  logic [XLEN-1:0]  mcause_in,
    output logic [XLEN-1:0]  mepc_out,
    output logic [XLEN-1:0]  mtvec_out,
    output logic             mie_global,
    // WB stage counter pulse
    input  logic             instret_inc,
    // External interrupts (2-FF synchronized upstream)
    input  logic             ext_irq,
    input  logic             timer_irq
);

    logic [XLEN-1:0] mstatus;
    logic [XLEN-1:0] mie;
    logic [XLEN-1:0] mtvec;
    logic [XLEN-1:0] mscratch;
    logic [XLEN-1:0] mepc;
    logic [XLEN-1:0] mcause;
    logic [XLEN-1:0] mip;
    logic [63:0]     cycle_cnt;
    logic [63:0]     instret_cnt;

    // misa: MXL=01(RV32), I-extension
    localparam logic [XLEN-1:0] MISA_VAL = {2'b01, {(XLEN-28){1'b0}}, 26'h000100};

    assign mepc_out   = mepc;
    assign mtvec_out  = mtvec;
    assign mie_global = mstatus[3]; // MIE bit

    // CSR read (combinational)
    always_comb begin
        unique case (csr_addr)
            12'h300: csr_rdata = mstatus;
            12'h301: csr_rdata = MISA_VAL;
            12'h304: csr_rdata = mie;
            12'h305: csr_rdata = mtvec;
            12'h340: csr_rdata = mscratch;
            12'h341: csr_rdata = mepc;
            12'h342: csr_rdata = mcause;
            12'h344: csr_rdata = mip;
            12'hC00: csr_rdata = cycle_cnt[XLEN-1:0];
            12'hC80: csr_rdata = cycle_cnt[63:XLEN];
            12'hC02: csr_rdata = instret_cnt[XLEN-1:0];
            12'hC82: csr_rdata = instret_cnt[63:XLEN];
            default: csr_rdata = {XLEN{1'b0}};
        endcase
    end

    // Write data calculation
    logic [XLEN-1:0] wdata;
    logic            csr_wen;

    always_comb begin
        csr_wen = (csr_op != 3'b000);
        unique case (csr_op)
            3'b001, 3'b101: wdata = rs1_data;
            3'b010, 3'b110: wdata = csr_rdata | rs1_data;
            3'b011, 3'b111: wdata = csr_rdata & ~rs1_data;
            default:        wdata = {XLEN{1'b0}};
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mstatus     <= {XLEN{1'b0}};
            mie         <= {XLEN{1'b0}};
            mtvec       <= {XLEN{1'b0}};
            mscratch    <= {XLEN{1'b0}};
            mepc        <= {XLEN{1'b0}};
            mcause      <= {XLEN{1'b0}};
            mip         <= {XLEN{1'b0}};
            cycle_cnt   <= 64'b0;
            instret_cnt <= 64'b0;
        end else begin
            cycle_cnt <= cycle_cnt + 64'b1;
            if (instret_inc)
                instret_cnt <= instret_cnt + 64'b1;

            mip[7]  <= timer_irq; // MTIP
            mip[11] <= ext_irq;   // MEIP

            if (trap_en) begin
                mepc       <= mepc_in;
                mcause     <= mcause_in;
                mstatus[7] <= mstatus[3]; // MPIE = MIE
                mstatus[3] <= 1'b0;       // MIE = 0 (disable on trap entry)
            end else if (csr_wen) begin
                unique case (csr_addr)
                    12'h300: mstatus  <= wdata;
                    12'h304: mie      <= wdata;
                    12'h305: mtvec    <= wdata;
                    12'h340: mscratch <= wdata;
                    12'h341: mepc     <= wdata;
                    12'h342: mcause   <= wdata;
                    default: ;
                endcase
            end
        end
    end

endmodule
