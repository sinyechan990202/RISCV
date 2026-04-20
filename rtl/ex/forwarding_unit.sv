// Pure combinational Forwarding Unit
// Resolves RAW hazards via EX-EX and MEM-EX forwarding.
// EX→EX (MEM stage result) takes priority over MEM→EX (WB stage data).
module forwarding_unit (
    // Current EX stage source registers
    input  logic [4:0] ex_rs1_i,
    input  logic [4:0] ex_rs2_i,

    // MEM stage (EX→EX forwarding source)
    input  logic [4:0] mem_rd_i,
    input  logic       mem_reg_wen_i,

    // WB stage (MEM→EX forwarding source)
    input  logic [4:0] wb_rd_i,
    input  logic       wb_reg_wen_i,

    // fwd_sel encoding:
    //   2'b00 = register file (no forwarding)
    //   2'b01 = WB stage data (MEM→EX)
    //   2'b10 = MEM stage ALU result (EX→EX)
    output logic [1:0] fwd_a_sel_o,
    output logic [1:0] fwd_b_sel_o
);

    always_comb begin
        // RS1 forwarding
        if (mem_reg_wen_i && (mem_rd_i != 5'b0) && (mem_rd_i == ex_rs1_i))
            fwd_a_sel_o = 2'b10;
        else if (wb_reg_wen_i && (wb_rd_i != 5'b0) && (wb_rd_i == ex_rs1_i))
            fwd_a_sel_o = 2'b01;
        else
            fwd_a_sel_o = 2'b00;

        // RS2 forwarding
        if (mem_reg_wen_i && (mem_rd_i != 5'b0) && (mem_rd_i == ex_rs2_i))
            fwd_b_sel_o = 2'b10;
        else if (wb_reg_wen_i && (wb_rd_i != 5'b0) && (wb_rd_i == ex_rs2_i))
            fwd_b_sel_o = 2'b01;
        else
            fwd_b_sel_o = 2'b00;
    end

endmodule
