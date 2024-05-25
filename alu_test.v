module alu_test;
    // regs
    reg clk_tb;
    reg reset_tb;
    reg [6:0] opcode_tb;
    reg [3:0] AluControl_tb;
    reg [31:0] SrcA_tb;
    reg [31:0] SrcB_tb;
    reg PCSrc_tb;
    reg [4:0] current_stage_tb;
    // wires
    wire [31:0] AluResult_tb;
    wire [31:0] AluOut_tb;
    wire Cond_Chk_tb;
    wire [31:0] pc_up_tb;

//  module instantiation
alu a0(
    // inputs
    .clk(clk_tb),
    .reset(reset_tb),
    .opcode_reg(opcode_tb),
    .AluControl_reg(AluControl_tb),
    .SrcA_reg(SrcA_tb),
    .SrcB_reg(SrcB_tb),
    .PCSrc_reg(PCSrc_tb),
    .current_stage(current_stage_tb),
    // outputs
    .AluResult_reg(AluResult_tb),
    .AluOut_reg(AluOut_tb),
    .Cond_Chk_reg(Cond_Chk_tb),
    .pc_up_reg(pc_up_tb)
);

always #5 clk_tb = ~clk_tb;

//  Initial block to set initial values
initial begin
    clk_tb <= 0;
    reset_tb <= 1;
    opcode_tb = 7'b0000000;
    AluControl_tb = 4'b0000;
    SrcA_tb = 32'h00000000;
    SrcB_tb = 32'h00000000;
    PCSrc_tb = 1'b0;
    current_stage_tb = 0;
    #8
    reset_tb <= 0;

    // R-type (add)
    opcode_tb = 7'b0110011;
    AluControl_tb = 4'b0000;
    SrcA_tb = 32'h00001111;
    SrcB_tb = 32'h00001010;
    PCSrc_tb = 1'b0;
    current_stage_tb = 2;
    #10
    
    // B-type (beq)
    opcode_tb = 7'b1100011;
    AluControl_tb = 4'b1000;
    SrcA_tb = 32'h00001111;
    SrcB_tb = 32'h00001111;
    PCSrc_tb = 1'b1;
    current_stage_tb = 16;
    #10
    $finish;
end
endmodule