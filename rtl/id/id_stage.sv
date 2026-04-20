// wb_sel encoding: 00=ALU, 01=Load, 10=PC+4(JAL/JALR), 11=CSR
// alu_src_a:       0=rs1,  1=PC (AUIPC)
// alu_src_b:       0=rs2,  1=imm
module id_stage #(
    parameter XLEN = 32
) (
    input  logic             clk,
    input  logic             rst_n,
    // From IF/ID pipeline register
    input  logic [XLEN-1:0]  instr_i,
    input  logic [XLEN-1:0]  pc_i,
    // Write-back feedback for register file
    input  logic [4:0]       wb_rd,
    input  logic [XLEN-1:0]  wb_wdata,
    input  logic             wb_wen,
    // Trap interface (forwarded to CSR)
    input  logic             trap_en,
    input  logic [XLEN-1:0]  mepc_in,
    input  logic [XLEN-1:0]  mcause_in,
    // Counter (from WB stage)
    input  logic             instret_inc,
    // External interrupts (2-FF synchronized upstream)
    input  logic             ext_irq,
    input  logic             timer_irq,
    // Register data
    output logic [XLEN-1:0]  rs1_data_o,
    output logic [XLEN-1:0]  rs2_data_o,
    output logic [4:0]       rs1_addr_o,
    output logic [4:0]       rs2_addr_o,
    output logic [XLEN-1:0]  imm_o,
    output logic [4:0]       rd_o,
    // Control signals
    output logic [4:0]       alu_op_o,
    output logic             alu_src_a_o,
    output logic             alu_src_b_o,
    output logic             mem_ren_o,
    output logic             mem_wen_o,
    output logic [2:0]       mem_size_o,
    output logic [1:0]       wb_sel_o,
    output logic             reg_wen_o,
    output logic             branch_o,
    output logic             jal_o,
    output logic             jalr_o,
    // CSR
    output logic [2:0]       csr_op_o,
    output logic [11:0]      csr_addr_o,
    output logic [XLEN-1:0]  csr_rdata_o,
    output logic [XLEN-1:0]  mepc_out,
    output logic [XLEN-1:0]  mtvec_out,
    output logic             mie_global
);

    // Instruction fields
    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr_i[6:0];
    assign rd     = instr_i[11:7];
    assign funct3 = instr_i[14:12];
    assign rs1    = instr_i[19:15];
    assign rs2    = instr_i[24:20];
    assign funct7 = instr_i[31:25];

    assign rs1_addr_o = rs1;
    assign rs2_addr_o = rs2;
    assign rd_o       = rd;
    assign csr_addr_o = instr_i[31:20];

    // Opcode constants
    localparam logic [6:0] OP_R      = 7'b0110011;
    localparam logic [6:0] OP_I      = 7'b0010011;
    localparam logic [6:0] OP_LOAD   = 7'b0000011;
    localparam logic [6:0] OP_STORE  = 7'b0100011;
    localparam logic [6:0] OP_BRANCH = 7'b1100011;
    localparam logic [6:0] OP_JAL    = 7'b1101111;
    localparam logic [6:0] OP_JALR   = 7'b1100111;
    localparam logic [6:0] OP_LUI    = 7'b0110111;
    localparam logic [6:0] OP_AUIPC  = 7'b0010111;
    localparam logic [6:0] OP_SYSTEM = 7'b1110011;
    localparam logic [6:0] OP_FENCE  = 7'b0001111;

    // ALU op constants (5-bit, per spec)
    localparam logic [4:0] ALU_ADD   = 5'b00000;
    localparam logic [4:0] ALU_AND   = 5'b00010;
    localparam logic [4:0] ALU_OR    = 5'b00011;
    localparam logic [4:0] ALU_XOR   = 5'b00100;
    localparam logic [4:0] ALU_SLL   = 5'b00101;
    localparam logic [4:0] ALU_SRL   = 5'b00110;
    localparam logic [4:0] ALU_SRA   = 5'b00111;
    localparam logic [4:0] ALU_SLT   = 5'b01000;
    localparam logic [4:0] ALU_SLTU  = 5'b01001;
    localparam logic [4:0] ALU_LUI   = 5'b01010;
    localparam logic [4:0] ALU_AUIPC = 5'b01011;

    // -------------------------------------------------------------------------
    // Register file
    // -------------------------------------------------------------------------
    logic [XLEN-1:0] rs1_rdata, rs2_rdata;

    reg_file #(.XLEN(XLEN)) u_reg_file (
        .clk      (clk),
        .rs1_addr (rs1),
        .rs2_addr (rs2),
        .rd_addr  (wb_rd),
        .rd_wdata (wb_wdata),
        .rd_wen   (wb_wen),
        .rs1_rdata(rs1_rdata),
        .rs2_rdata(rs2_rdata)
    );

    assign rs1_data_o = rs1_rdata;
    assign rs2_data_o = rs2_rdata;

    // -------------------------------------------------------------------------
    // Immediate generator
    // -------------------------------------------------------------------------
    logic [2:0] imm_type;

    imm_gen #(.XLEN(XLEN)) u_imm_gen (
        .instr   (instr_i),
        .imm_type(imm_type),
        .imm     (imm_o)
    );

    // -------------------------------------------------------------------------
    // CSR register file
    // ZIMM instructions (csr_op[2]=1): pass {27'b0, rs1_addr} as operand
    // -------------------------------------------------------------------------
    logic [2:0]      csr_op_int;
    logic [XLEN-1:0] csr_rs1_data;

    assign csr_op_int   = (opcode == OP_SYSTEM) ? funct3 : 3'b000;
    assign csr_op_o     = csr_op_int;
    assign csr_rs1_data = csr_op_int[2] ? {{(XLEN-5){1'b0}}, rs1} : rs1_rdata;

    csr_regfile #(.XLEN(XLEN)) u_csr_regfile (
        .clk        (clk),
        .rst_n      (rst_n),
        .csr_op     (csr_op_int),
        .csr_addr   (instr_i[31:20]),
        .rs1_data   (csr_rs1_data),
        .csr_rdata  (csr_rdata_o),
        .trap_en    (trap_en),
        .mepc_in    (mepc_in),
        .mcause_in  (mcause_in),
        .mepc_out   (mepc_out),
        .mtvec_out  (mtvec_out),
        .mie_global (mie_global),
        .instret_inc(instret_inc),
        .ext_irq    (ext_irq),
        .timer_irq  (timer_irq)
    );

    // -------------------------------------------------------------------------
    // ALU op decode helpers
    // -------------------------------------------------------------------------
    function automatic logic [4:0] alu_op_from_funct(
        input logic [2:0] f3,
        input logic       is_sub_or_sra // funct7[5]
    );
        case (f3)
            3'b000: alu_op_from_funct = is_sub_or_sra ? 5'b00001 : ALU_ADD; // SUB or ADD
            3'b001: alu_op_from_funct = ALU_SLL;
            3'b010: alu_op_from_funct = ALU_SLT;
            3'b011: alu_op_from_funct = ALU_SLTU;
            3'b100: alu_op_from_funct = ALU_XOR;
            3'b101: alu_op_from_funct = is_sub_or_sra ? ALU_SRA : ALU_SRL;
            3'b110: alu_op_from_funct = ALU_OR;
            3'b111: alu_op_from_funct = ALU_AND;
            default: alu_op_from_funct = ALU_ADD;
        endcase
    endfunction

    // -------------------------------------------------------------------------
    // Control decoder
    // -------------------------------------------------------------------------
    always_comb begin
        alu_op_o    = ALU_ADD;
        alu_src_a_o = 1'b0;
        alu_src_b_o = 1'b0;
        imm_type    = 3'b000;
        mem_ren_o   = 1'b0;
        mem_wen_o   = 1'b0;
        mem_size_o  = funct3;
        wb_sel_o    = 2'b00;
        reg_wen_o   = 1'b0;
        branch_o    = 1'b0;
        jal_o       = 1'b0;
        jalr_o      = 1'b0;

        case (opcode)
            OP_R: begin
                alu_op_o    = alu_op_from_funct(funct3, funct7[5]);
                reg_wen_o   = 1'b1;
            end
            OP_I: begin
                // SLLI/SRLI/SRAI: funct7[5] distinguishes SRA; SUB encoding absent in I-type
                alu_op_o    = alu_op_from_funct(funct3, (funct3 == 3'b101) ? funct7[5] : 1'b0);
                alu_src_b_o = 1'b1;
                imm_type    = 3'b000;
                reg_wen_o   = 1'b1;
            end
            OP_LOAD: begin
                alu_src_b_o = 1'b1;
                imm_type    = 3'b000;
                mem_ren_o   = 1'b1;
                reg_wen_o   = 1'b1;
                wb_sel_o    = 2'b01;
            end
            OP_STORE: begin
                alu_src_b_o = 1'b1;
                imm_type    = 3'b001;
                mem_wen_o   = 1'b1;
            end
            OP_BRANCH: begin
                imm_type    = 3'b010;
                branch_o    = 1'b1;
            end
            OP_JAL: begin
                imm_type    = 3'b100;
                jal_o       = 1'b1;
                reg_wen_o   = 1'b1;
                wb_sel_o    = 2'b10;
            end
            OP_JALR: begin
                alu_src_b_o = 1'b1;
                imm_type    = 3'b000;
                jalr_o      = 1'b1;
                reg_wen_o   = 1'b1;
                wb_sel_o    = 2'b10;
            end
            OP_LUI: begin
                alu_op_o    = ALU_LUI;
                alu_src_b_o = 1'b1;
                imm_type    = 3'b011;
                reg_wen_o   = 1'b1;
            end
            OP_AUIPC: begin
                alu_op_o    = ALU_AUIPC;
                alu_src_a_o = 1'b1; // PC as operand A
                alu_src_b_o = 1'b1;
                imm_type    = 3'b011;
                reg_wen_o   = 1'b1;
            end
            OP_SYSTEM: begin
                if (funct3 != 3'b000) begin // CSR instructions
                    imm_type  = csr_op_int[2] ? 3'b101 : 3'b000;
                    reg_wen_o = (rd != 5'b0);
                    wb_sel_o  = 2'b11; // CSR read data
                end
                // ECALL/EBREAK (funct3==000): trap handled externally via trap_en
            end
            OP_FENCE: ; // Treated as NOP in single-issue in-order pipeline
            default: ;
        endcase
    end

endmodule
