module pc_reg #(
    parameter XLEN = 32
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             stall,
    input  logic [XLEN-1:0] pc_next,
    output logic [XLEN-1:0] pc
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= {XLEN{1'b0}};
        else if (!stall)
            pc <= pc_next;
    end

endmodule
