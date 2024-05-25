//  module declaration
module decode_unit(
    //  input ports
    input clk,
    input reset,
    input wire Cond_Chk_reg, // branch condition check
    input wire [31:0] instruction_reg, // instruction currently under process
    //  output ports
    output reg [6:0] opcode_reg, // determines type of instruction
    output reg [4:0] rs1_reg, // defines source register 1
    output reg [4:0] rs2_reg, // defines source register 2
    output reg [4:0] rd_reg, // defines destination register
    output reg [2:0] funct3_reg, // depicts the exact instruction
    output reg [6:0] funct7_reg, // depicts the exact instruction
    output reg IorD_reg, // selects between pc value and calculated address for memory writeback
    output reg MemWrite_reg, // enables to write data in IMEM
    output reg [1:0] MtoR_reg, // selects data among load, R and U type instruction for register writeback
    output reg IRWrite_reg, // enables to write instruction in instruction register
    output reg [31:0] Imm_reg, // immediate data or offset
    output reg AluSrcA_reg, // selects data between pc value and source register 1 data
    output reg [1:0] AluSrcB_reg, // selects among constant value 4, source register 2 data and immediate data
    output reg [3:0] AluControl_reg, // signifies the operation to be performed by ALU
    output reg PCSrc_reg, // selects between AluResult and AluOut value
    output reg RegWrite_reg, // enables to write data in Register File
    output reg Branch_reg, // depicts whether an instruction is branch type or not
    output reg PCWrite_reg, // enables to write new pc value for jump type instruction and instruction fetch cycle
    output reg PCEn_reg, // enables to write new pc value for branch instructions
    output reg [4:0] current_stage, // tells the current FSM stage
    output reg [4:0] next_stage // tells the FSM stage to be followed next
);

//  PC_En controlling block
always @(PCWrite_reg, Branch_reg, Cond_Chk_reg) begin
PCEn_reg = PCWrite_reg | (Branch_reg & Cond_Chk_reg);
end

//  definition
always @(posedge clk or posedge reset) begin
    if (reset) begin
        opcode_reg <= 0;
        rs1_reg <= 0;
        rs2_reg <= 0;
        rd_reg <= 0;
        funct3_reg <= 0;
        funct7_reg <= 0;
        IorD_reg <= 1'bz;
        MemWrite_reg <= 0;
        MtoR_reg <= 2'bzz;
        IRWrite_reg <= 0;
        Imm_reg <= 0;
        AluSrcA_reg <= 1'bz;
        AluSrcB_reg <= 2'bzz;
        AluControl_reg <= 4'bzzzz;
        PCSrc_reg <= 1'bz;
        RegWrite_reg <= 0;
        Branch_reg <= 0;
        PCWrite_reg <= 0;
        PCEn_reg <= 0;
        current_stage <= 5'bzzzzz;
        next_stage <= 0;
    end 
    else begin
        current_stage = next_stage; // updates the current stage at each clock cycle
        case (next_stage)
            //  Fetching
            0: begin
                assign opcode_reg = instruction_reg[6:0];
                assign rs1_reg = instruction_reg[19:15];
                assign rs2_reg = instruction_reg[24:20];
                assign rd_reg = instruction_reg[11:7];
                assign funct3_reg = instruction_reg[14:12];
                assign funct7_reg = instruction_reg[31:25];
                IorD_reg <= 1'b0;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b1;
                AluSrcA_reg <= 1'b0;
                AluSrcB_reg <= 2'b01;
                AluControl_reg <= 4'b0000;
                PCSrc_reg <= 1'b0;
                RegWrite_reg <= 1'b0;
                PCWrite_reg <= 1'b1;
                if(opcode_reg == 7'b1100011) begin // branch instruction
                    Branch_reg <= 1'b1;
                end
                else begin // other instructions
                    Branch_reg <= 1'b0;
                end
                next_stage <= 1;
            end

            //  Decode
            1: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                if(opcode_reg == 7'b1100011) begin // branch instruction (calculation of jumping address)
                    AluSrcA_reg <= 1'b0;
                    AluSrcB_reg <= 2'b10;
                    AluControl_reg <= 4'b0000;
                    Branch_reg <= 1'b1;
                end
                else begin // other instructions
                    AluSrcA_reg <= 1'bz;
                    AluSrcB_reg <= 2'bzz;
                    AluControl_reg <= 4'bzzzz;
                    Branch_reg <= 1'b0;
                end
                case (opcode_reg)
                    7'b0110011: begin // R-type
                        Imm_reg <= 0;
                        next_stage <= 2;
                    end
                    7'b0000011: begin // I-type (load)
                        Imm_reg <= {{20{instruction_reg[31]}}, instruction_reg[31:20]};
                        next_stage <= 4;
                    end
                    7'b1100111: begin // I-type (jump)
                        Imm_reg <= {{20{instruction_reg[31]}}, instruction_reg[31:20]};
                        next_stage <= 12;
                    end
                    7'b0010011: begin // I-type (shift, logical, arithmetic)
                        case (funct3_reg)
                            3'b001, 3'b101: begin // slli, srli, srai
                                Imm_reg = {27'b0, instruction_reg[24:20]}; // shift amount immediate
                            end
                            3'b000, 3'b010, 3'b011, 3'b100, 3'b111: begin // addi, slti, sltiu, xori, ori, andi
                                Imm_reg <= {{20{instruction_reg[31]}}, instruction_reg[31:20]};
                            end
                        endcase
                        next_stage <= 7;
                    end
                    7'b0100011: begin // S-type
                        Imm_reg <= {{20{instruction_reg[31]}}, instruction_reg[31:25], instruction_reg[11:7]};
                        next_stage <= 8;
                    end
                    7'b1100011: begin // B-type
                        Imm_reg <= {{19{instruction_reg[31]}}, instruction_reg[31], instruction_reg[7], instruction_reg[30:25], instruction_reg[11:8], 1'b0};
                        next_stage <= 16;
                    end
                    7'b1100011: begin // J-type
                        Imm_reg <= {{11{instruction_reg[31]}}, instruction_reg[31], instruction_reg[19:12], instruction_reg[20], instruction_reg[30:21], 1'b0};
                        next_stage <= 14;
                    end
                    7'b0110111: begin // U-type (load)
                        Imm_reg <= {instruction_reg[31:20], 12'b0};
                        next_stage <= 10;
                    end
                    7'b0010111: begin // U-type (add)
                        Imm_reg <= {instruction_reg[31:20], 12'b0};
                        next_stage <= 11;
                    end
                endcase
                next_stage <= 2;
            end

            //  Execute (R-type)
            2: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 0;
                AluSrcA_reg <= 1'b1;
                AluSrcB_reg <= 2'b00;
                if (funct7_reg == 7'b0000000) begin
                    AluControl_reg <= {1'b0, funct3_reg}; // add, slt, sltu, sll, xor, srl, or, and
                end
                else if (funct7_reg == 7'b0100000) begin
                    AluControl_reg <= {1'b1, funct3_reg}; // sub, sra
                end
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 0;
                Branch_reg <= 0;
                PCWrite_reg <= 0;
                next_stage <= 3;
            end

            //  ALU Writeback (R-type & I-type (shift, logical, arithmetic) & U-type (auipc))
            3: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'b00;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b1;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 0;
            end

            //  Memory Address Calculation (I-type (load))
            4: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'b1;
                AluSrcB_reg <= 2'b10;
                AluControl_reg <= {1'b1, funct3_reg}; //lb, lh, lw, lbu, lhu
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 5;
            end

            //  Memory Read (I-type (load))
            5: begin
                IorD_reg <= 1'b1;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 6;
            end

            //  Memory Writeback (I-type (load))
            6: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'b01;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b1;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 0;
            end

            //  Execute (I-type (shift, logical, arithmetic))
            7: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 0;
                AluSrcA_reg <= 1'b1;
                AluSrcB_reg <= 2'b10;
                if (funct7_reg == 7'b0000000) begin
                    AluControl_reg <= {1'b0, funct3_reg}; // addi, slti, sltiu, slli, xori, srli, ori, andi
                end
                else if (funct7_reg == 7'b0100000) begin
                    AluControl_reg <= {1'b1, funct3_reg}; // srai
                end
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 0;
                Branch_reg <= 0;
                PCWrite_reg <= 0;
                next_stage <= 3;
            end

            //  Memory Address Calculation (S-type)
            8: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'b1;
                AluSrcB_reg <= 2'b10;
                AluControl_reg <= {1'b1, funct3_reg}; // sb, sh, sw
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 9;
            end

            //  Memory Write (S-type)
            9: begin
                IorD_reg <= 1'b1;
                MemWrite_reg <= 1'b1;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 0;
            end

            //  Load Immediate (U-type)
            10: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'b10;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b1;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 0;
            end

            //  Add Immediate (U-type)
            11: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'b0;
                AluSrcB_reg <= 2'b10;
                AluControl_reg <= 4'b0000;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 3;
            end

            //  ALU Writeback (I-type (jump))
            12: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'b00;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'b1;
                RegWrite_reg <= 1'b1;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 13;
            end

            //  Jump (I-type (jump))
            13: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'b1;
                AluSrcB_reg <= 2'b10;
                AluControl_reg <= 4'b0000;
                PCSrc_reg <= 1'b0;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b1;
                next_stage <= 0;
            end

            //  ALU Writeback (J-type)
            14: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'b00;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'b1;
                RegWrite_reg <= 1'b1;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b0;
                next_stage <= 15;
            end

            //  Jump (J-type)
            15: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'b0;
                AluSrcB_reg <= 2'b10;
                AluControl_reg <= 4'b0000;
                PCSrc_reg <= 1'b0;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b0;
                PCWrite_reg <= 1'b1;
                next_stage <= 0;
            end

            //  Condition Check (B-type)
            16: begin
                IorD_reg <= 1'bz;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'b1;
                AluSrcB_reg <= 2'b10;
                AluControl_reg <= {1'b1, funct3_reg}; //beq, bne, blt, bge, bltu, bgeu
                PCSrc_reg <= 1'b1;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b1;
                PCWrite_reg <= 1'b0;
                next_stage <= 17;
            end

            //  PC Update (B-type)
            17: begin
                IorD_reg <= 1'b0;
                MemWrite_reg <= 1'b0;
                MtoR_reg <= 2'bzz;
                IRWrite_reg <= 1'b0;
                AluSrcA_reg <= 1'bz;
                AluSrcB_reg <= 2'bzz;
                AluControl_reg <= 4'bzzzz;
                PCSrc_reg <= 1'bz;
                RegWrite_reg <= 1'b0;
                Branch_reg <= 1'b1;
                PCWrite_reg <= 1'b0;
                next_stage <= 0;
            end
        endcase
    end
end
endmodule