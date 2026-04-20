// Instruction Memory Interface
// Bridges IF stage to external instruction memory.
// Checks 4-byte alignment; asserts misalign_fault_o on violation.
module instr_mem_if #(
    parameter XLEN        = 32,
    parameter IMEM_DWIDTH = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // From IF stage
    input  logic                   req_i,
    input  logic [XLEN-1:0]        addr_i,

    // To external instruction memory
    output logic                   imem_req_o,
    output logic [XLEN-1:0]        imem_addr_o,

    // From external instruction memory
    input  logic [IMEM_DWIDTH-1:0] imem_rdata_i,
    input  logic                   imem_ready_i,

    // To IF stage
    output logic [IMEM_DWIDTH-1:0] rdata_o,
    output logic                   ready_o,
    output logic                   misalign_fault_o
);

    logic misalign;

    always_comb begin
        misalign         = req_i & (addr_i[1:0] != 2'b00);
        misalign_fault_o = misalign;

        if (misalign) begin
            imem_req_o  = 1'b0;
            imem_addr_o = {XLEN{1'b0}};
            rdata_o     = {IMEM_DWIDTH{1'b0}};
            ready_o     = 1'b0;
        end else begin
            imem_req_o  = req_i;
            imem_addr_o = addr_i;
            rdata_o     = imem_rdata_i;
            ready_o     = imem_ready_i;
        end
    end

endmodule
