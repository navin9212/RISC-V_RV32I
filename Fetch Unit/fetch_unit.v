//  module declaration
module fetch_unit(
    // input ports
    input clk,
    input reset,
    input wire PCEn_reg, // enables pc register
    input wire [31:0] pc_up_reg, // ALU output (updated pc value)
    input wire [4:0] current_stage, // tells the current FSM stage
    // output ports
    output reg [31:0] pc_reg // output pc register
);

//  definition
always @(posedge clk or posedge reset)
begin
    if (reset) begin
        pc_reg <= 0;
    end
    else begin
        // if PCEn_reg = 1 & current stage is "fetch" then proceed
        if (PCEn_reg == 1'b1 && current_stage == 0) begin
            pc_reg <= pc_up_reg; // pc updated to new pc value
        end
        else begin
            pc_reg <= pc_reg; // pc remains same instead
        end
    end
end
endmodule
