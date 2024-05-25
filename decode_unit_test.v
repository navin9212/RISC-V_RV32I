module decode_unit_test;
    // regs
    reg clk_tb;
    reg reset_tb;
    reg Cond_Chk_tb;
    reg [31:0] instruction_tb;
    // wires
    wire [6:0] opcode_tb;
    wire [4:0] rs1_tb;
    wire [4:0] rs2_tb;
    wire [4:0] rd_tb;
    wire [2:0] funct3_tb;
    wire [6:0] funct7_tb;
    wire IorD_tb;
    wire MemWrite_tb;
    wire [1:0] MtoR_tb;
    wire IRWrite_tb;
    wire [31:0] Imm_tb;
    wire AluSrcA_tb;
    wire [1:0] AluSrcB_tb;
    wire [3:0] AluControl_tb;
    wire PCSrc_tb;
    wire RegWrite_tb;
    wire Branch_tb;
    wire PCWrite_tb;
    wire PCEn_tb;
    wire [4:0] current_stage_tb;
    wire [4:0] next_stage_tb;

//  module instantiation    
decode_unit d0(
    // inputs
    .clk(clk_tb),
    .reset(reset_tb),
    .instruction_reg(instruction_tb),
    .Cond_Chk_reg(Cond_Chk_tb),
    // outputs
    .opcode_reg(opcode_tb),
    .rs1_reg(rs1_tb),
    .rs2_reg(rs2_tb),
    .rd_reg(rd_tb),
    .funct3_reg(funct3_tb),
    .funct7_reg(funct7_tb),
    .IorD_reg(IorD_tb),
    .MemWrite_reg(MemWrite_tb),
    .MtoR_reg(MtoR_tb),
    .IRWrite_reg(IRWrite_tb),
    .Imm_reg(Imm_tb),
    .AluSrcA_reg(AluSrcA_tb),
    .AluSrcB_reg(AluSrcB_tb),
    .AluControl_reg(AluControl_tb),
    .PCSrc_reg(PCSrc_tb),
    .RegWrite_reg(RegWrite_tb),
    .Branch_reg(Branch_tb),
    .PCWrite_reg(PCWrite_tb),
    .PCEn_reg(PCEn_tb),
    .current_stage(current_stage_tb),
    .next_stage(next_stage_tb)
);

always #5 clk_tb = ~clk_tb;

//  Initial block to set initial values
initial begin
    clk_tb <= 0;
    reset_tb <= 1;
    Cond_Chk_tb = 1'b0;
    instruction_tb = 32'h00000000;
    
    #8
    reset_tb <= 0;

    // R-type instruction
    Cond_Chk_tb = 1'b1;
    instruction_tb = 32'h015a04b3; // add x9, x20, x21
    #45
    $finish;
end
endmodule