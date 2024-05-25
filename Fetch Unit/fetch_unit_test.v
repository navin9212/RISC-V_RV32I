module fetch_unit_test;
    // regs
    reg clk_tb;
    reg reset_tb;
    reg PCEn_tb;
    reg [31:0] pc_up_tb;
    reg [4:0] current_stage_tb;
    // wires
    wire [31:0] pc_tb;

//  module instantiation
fetch_unit f0(
    // inputs
    .clk(clk_tb),
    .reset(reset_tb),
    .PCEn_reg(PCEn_tb),
    .pc_up_reg(pc_up_tb),
    .current_stage(current_stage_tb),
    // outputs
    .pc_reg(pc_tb)
);

always #5 clk_tb = ~clk_tb;

//  Initial block to set initial values
initial begin
    clk_tb <= 0;
    reset_tb <= 1;
    PCEn_tb <= 1'b0;
    pc_up_tb <= 32'h00000000;
    current_stage_tb <= 0;
    
    #8
    reset_tb <= 0;
    
    //  pc update (PCEn_tb = 1)
    PCEn_tb = 1'b1;
    pc_up_tb = 32'h00002231;
    #15
    
    //  pc unchanged (PCEn_tb = 0)
    PCEn_tb = 1'b0;
    pc_up_tb = 32'h00005237;
    #15
    $finish;
end
endmodule
