module reg_file #(
    parameter XLEN = 32
) (
    input  logic            clk,
    input  logic [4:0]      rs1_addr,
    input  logic [4:0]      rs2_addr,
    input  logic [4:0]      rd_addr,
    input  logic [XLEN-1:0] rd_wdata,
    input  logic            rd_wen,
    output logic [XLEN-1:0] rs1_rdata,
    output logic [XLEN-1:0] rs2_rdata
);

    logic [XLEN-1:0] regs [32];

    always_ff @(posedge clk) begin
        if (rd_wen && rd_addr != 5'b0)
            regs[rd_addr] <= rd_wdata;
    end

    // Asynchronous read with same-cycle RAW bypass
    assign rs1_rdata = (rs1_addr == 5'b0)             ? {XLEN{1'b0}} :
                       (rd_wen && rd_addr == rs1_addr) ? rd_wdata     :
                       regs[rs1_addr];

    assign rs2_rdata = (rs2_addr == 5'b0)             ? {XLEN{1'b0}} :
                       (rd_wen && rd_addr == rs2_addr) ? rd_wdata     :
                       regs[rs2_addr];

endmodule
