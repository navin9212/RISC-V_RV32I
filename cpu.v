//  module declaration
module cpu;
    // regs
    reg clk;
    reg reset;
    reg [31:0] pc_initial;
    // wires
    wire Cond_Chk;
    wire PCEn;
    wire IorD;
    wire MemWrite;
    wire PCSrc;
    wire RegWrite;
    wire Branch;
    wire PCWrite;
    wire IRWrite;
    wire AluSrcA;
    wire [1:0] AluSrcB;
    wire [3:0] AluControl;
    wire [1:0] MtoR;
    wire [4:0] current_stage;
    wire [4:0] next_stage;
    wire [31:0] pc;
    wire [31:0] pc_up;
    wire [31:0] instruction;
    wire [31:0] Imm;
    wire [31:0] data;
    wire [31:0] AluOut;
    wire [31:0] rsA;
    wire [31:0] rsB;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] AluResult;
    wire [31:0] addr;
    wire [31:0] wr_data;

//  module instantiations
fetch_unit f1(
    // inputs
    .clk(clk),
    .reset(reset),
    .PCEn_reg(PCEn),
    .pc_up_reg(pc_initial),
    .current_stage(current_stage),
    // outputs
    .pc_reg(pc)
);

decode_unit d1(
    // inputs
    .clk(clk),
    .reset(reset),
    .Cond_Chk_reg(Cond_Chk),
    .instruction_reg(instruction),
    // outputs
    .opcode_reg(opcode),
    .rs1_reg(rs1),
    .rs2_reg(rs2),
    .rd_reg(rd),
    .funct3_reg(funct3),
    .funct7_reg(funct7),
    .IorD_reg(IorD),
    .MemWrite_reg(MemWrite),
    .MtoR_reg(MtoR),
    .IRWrite_reg(IRWrite),
    .Imm_reg(Imm),
    .AluSrcA_reg(AluSrcA),
    .AluSrcB_reg(AluSrcB),
    .AluControl_reg(AluControl),
    .PCSrc_reg(PCSrc),
    .RegWrite_reg(RegWrite),
    .Branch_reg(Branch),
    .PCWrite_reg(PCWrite),
    .PCEn_reg(PCEn),
    .current_stage(current_stage),
    .next_stage(next_stage)
);

alu a1(
    // inputs
    .clk(clk),
    .reset(reset),
    .opcode_reg(opcode),
    .AluControl_reg(AluControl),
    .SrcA_reg(SrcA),
    .SrcB_reg(SrcB),
    .PCSrc_reg(PCSrc),
    .current_stage(current_stage),
    // outputs
    .AluResult_reg(AluResult),
    .AluOut_reg(AluOut),
    .Cond_Chk_reg(Cond_Chk),
    .pc_up_reg(pc_up)
);

imem i1(
    // inputs
    .clk(clk),
    .reset(reset),
    .IorD_reg(IorD),
    .MemWrite_reg(MemWrite),
    .IRWrite_reg(IRWrite),
    .AluControl_reg(AluControl),
    .pc_reg(pc),
    .AluOut_reg(AluOut),
    .rsB_reg(rsB),
    .current_stage(current_stage),
    // outputs
    .addr_reg(addr),
    .instruction_reg(instruction),
    .data_reg(data)
);

register_file r1(
    // inputs
    .clk(clk),
    .reset(reset),
    .MtoR_reg(MtoR),
    .RegWrite_reg(RegWrite),
    .AluSrcA_reg(AluSrcA),
    .AluSrcB_reg(AluSrcB),
    .rs1_reg(rs1),
    .rs2_reg(rs2),
    .rd_reg(rd),
    .data_reg(data),
    .AluOut_reg(AluOut),
    .pc_reg(pc),
    .Imm_reg(Imm),
    .current_stage(current_stage),
    // outputs
    .wr_data_reg(wr_data),
    .rsA_reg(rsA),
    .SrcA_reg(SrcA),
    .SrcB_reg(SrcB)
);

always #5 clk = ~clk;

//  Initial block to set initial values
initial begin
    clk <= 0;
    reset <= 1;
    // initialize pc
    pc_initial = 32'h10000000;
    // initialize memory locations
    i1.memory[pc_up] = 32'h015a04b3; // add x9, x20, x21
    // initialize registers
    r1.register[20] = 32'h00000011; // x20 = 17
    r1.register[21] = 32'h00000022; // x21 = 34

    #8
    reset <= 0;
    
    #10
    pc_initial = pc_up; // updated pc
    
    #40
    $display(r1.register[9]); // show result in x9
    $finish;
end
endmodule