// MEM Stage — Data memory access, byte-enable generation, load data extension
module mem_stage #(
    parameter XLEN        = 32,
    parameter DMEM_DWIDTH = 32
) (
    // From EX/MEM register
    input  logic [XLEN-1:0]        alu_result_i,  // memory address
    input  logic [XLEN-1:0]        rs2_data_i,    // store data
    input  logic                   mem_ren_i,
    input  logic                   mem_wen_i,
    input  logic [2:0]             mem_size_i,

    // To/from external data memory (direct connection at TOP)
    output logic                   dmem_req,
    output logic                   dmem_we,
    output logic [3:0]             dmem_be,
    output logic [XLEN-1:0]        dmem_addr,
    output logic [DMEM_DWIDTH-1:0] dmem_wdata,
    input  logic [DMEM_DWIDTH-1:0] dmem_rdata,
    input  logic                   dmem_ready,

    // To MEM/WB register
    output logic [XLEN-1:0]        load_data_o,
    output logic                   ready_o
);

    // mem_size encoding
    localparam SZ_B  = 3'b000; // LB  / SB  — signed byte
    localparam SZ_H  = 3'b001; // LH  / SH  — signed halfword
    localparam SZ_W  = 3'b010; // LW  / SW  — word
    localparam SZ_BU = 3'b100; // LBU       — unsigned byte
    localparam SZ_HU = 3'b101; // LHU       — unsigned halfword

    logic [1:0] byte_off;
    logic [3:0] be;
    logic [XLEN-1:0] wdata_shifted;
    logic [XLEN-1:0] rdata_raw;

    assign byte_off = alu_result_i[1:0];
    assign rdata_raw = dmem_rdata;

    // ------------------------------------------------------------------
    // Byte Enable generation (address-offset aware)
    // ------------------------------------------------------------------
    always_comb begin
        unique case (mem_size_i)
            SZ_B, SZ_BU: be = 4'b0001 << byte_off;
            SZ_H, SZ_HU: be = 4'b0011 << byte_off; // byte_off must be 0 or 2
            SZ_W:         be = 4'b1111;
            default:      be = 4'b0000;
        endcase
    end

    // ------------------------------------------------------------------
    // Store data byte-lane alignment
    // ------------------------------------------------------------------
    always_comb begin
        unique case (mem_size_i)
            SZ_B, SZ_BU: wdata_shifted = {4{rs2_data_i[7:0]}};   // replicate byte
            SZ_H, SZ_HU: wdata_shifted = {2{rs2_data_i[15:0]}};  // replicate halfword
            SZ_W:         wdata_shifted = rs2_data_i;
            default:      wdata_shifted = rs2_data_i;
        endcase
    end

    // ------------------------------------------------------------------
    // Load data extraction + sign/zero extension
    // ------------------------------------------------------------------
    logic [7:0]  load_byte;
    logic [15:0] load_half;

    always_comb begin
        // Extract byte/halfword from the correct lane
        load_byte = rdata_raw[byte_off*8 +: 8];
        load_half = rdata_raw[byte_off*8 +: 16]; // byte_off[1] selects upper/lower half

        unique case (mem_size_i)
            SZ_B:  load_data_o = {{(XLEN-8){load_byte[7]}},  load_byte};
            SZ_H:  load_data_o = {{(XLEN-16){load_half[15]}}, load_half};
            SZ_W:  load_data_o = rdata_raw;
            SZ_BU: load_data_o = {{(XLEN-8){1'b0}},  load_byte};
            SZ_HU: load_data_o = {{(XLEN-16){1'b0}}, load_half};
            default: load_data_o = rdata_raw;
        endcase
    end

    // ------------------------------------------------------------------
    // Drive data_mem_if outputs
    // ------------------------------------------------------------------
    assign dmem_req   = mem_ren_i | mem_wen_i;
    assign dmem_we    = mem_wen_i;
    assign dmem_be    = be;
    assign dmem_addr  = alu_result_i;
    assign dmem_wdata = wdata_shifted;
    assign ready_o    = dmem_ready;

endmodule
