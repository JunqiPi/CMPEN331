`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2022 08:24:38 PM
// Design Name: 
// Module Name: pc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module datapath(
input clk,
output wire[31:0] pc,
output wire[31:0] destinOut,
output wire ewreg,
output wire em2reg,
output wire ewmem,
output wire [3:0] ealuc,
output wire ealuimm,
output wire [4:0] edestReg,
output wire [31:0] eqa,
output wire [31:0] eqb,
output wire [31:0] eimm32,
output wire mwreg,
output wire mm2reg,
output wire [4:0] mdestReg,
output wire [31:0] mr,
output wire [31:0] mqb,
output wire[31:0] mdo,
output wire wwreg, 
output wire wm2reg,
output wire[31:0] wr,
output wire[31:0] wdo 
);
wire[31:0] pc_next;

pc pc_dp(clk, pc_next, pc);

pcAdder pcA_dp(pc, pc_next);

wire[31:0] instOut;

IM IM_dp(pc,instOut);

Ifid If_dp(clk ,instOut, destinOut);

wire regrt, wreg, wmem, aluimm, m2reg;
wire[3:0] aluc;

wire[5:0] op = destinOut[31:26];
wire[5:0] func = destinOut[5:0];

Control Control_dp(op,func,wreg,m2reg,wmem,aluc,aluimm,regrt);

wire[4:0] destReg;
wire[4:0] rt = destinOut[20:16];
wire[4:0] rd = destinOut[15:11];

RegMux Mux_dp(rt,rd,regrt,destReg);

wire[4:0] rs = destinOut[25:21];
wire[31:0] qa;
wire[31:0] qb;
wire[31:0] b;
wire[31:0] r;

wire[4:0] wdestReg;
wire[31:0] wbData;

RegFile Reg_dp(rs,rt,wdestReg,wbData,wwreg,clk,qa,qb);

wire[15:0] imm=destinOut[15:0];
wire[31:0] imm32;
IE IE_dp(imm,imm32);

ID ID_dp(clk,wreg,m2reg,wmem,aluc,aluimm,destReg,qa,qb,imm32,ewreg,em2reg,ewmem,ealuc,ealuimm,edestReg,eqa,eqb,eimm32);


Alu_Mux AM_dp(qb,imm32,aluimm,b);

Alu Alu_dp(qb,b,aluc,r);

EXEMEM EXE_dp(wreg,m2reg,wmem,destReg,r,qb,clk,mwreg, mm2reg, mwmem, mdestReg, mr, mqb);

Data_mem DM_dp(mr,mqb,mwmem,clk, mdo);

MEMWB MEM_dp(mwreg, mm2reg, mdestReg, mr, mdo, clk,wwreg, wm2reg, wdestReg, wr, wdo );

WbMux WbMux(wr,wdo,wm2reg,wbData);

endmodule

module pc(
input clk,
input[31:0] nextpc,
output reg[31:0] pc
);
initial begin
    pc <=100;
end

always @(posedge clk)
    begin
        pc<=nextpc;
    end

endmodule

module IM(
input[31:0] pc,
output reg[31:0] instOut
);
    reg [31:0] memory [0:63];
    
    initial begin
    	memory[0] = 32'hA00000AA;
    	memory[1] = 32'h10000011;
    	memory[2] = 32'h20000022 ;
    	memory[2] = 32'h30000033 ;   	
    	memory[4] = 32'h40000044;
    	memory[5] = 32'h50000055 ;
    	memory[6] = 32'h60000066 ;
    	memory[7] = 32'h70000077 ;
    	memory[8] = 32'h80000088 ;
    	memory[9] = 32'h90000099 ;
    	
    	memory[25]= 32'b10001100001000100000000000000000;//100:   lw $v0, 00($at)
    	memory[26]= 32'b10001100001000110000000000000100;//104:   lw $v1, 04($at)
    	memory[27]= 32'b10001100001001000000000000001000;//108:    lw $4, 08($1)
    	memory[28]= 32'b10001100001001010000000000001100;//112:    lw $5, 12($1) 
    	memory[29]= 32'b00000000010010100011000000100000;//116:    add $6, $2, $10 
    end

always @(*)
    begin
        instOut=memory[pc[31:2]];
    end
endmodule

module pcAdder(
input[31:0] pc,
output reg[31:0] nextpc
);
always @(*)
    begin
        nextpc<=pc+4;
    end
endmodule

module Ifid(
input clk,
input[31:0] instOut,
output reg[31:0] dinstOut
);

always @(posedge clk)
    begin
        dinstOut<=instOut;
    end
endmodule

module Control(
input[5:0] op,
input[5:0] func,
output reg wreg,
output reg m2reg,
output reg wmem,
output reg[3:0] aluc,
output reg aluimm,
output reg regrt
);
always @(*)
    begin
        case(op)
            6'b000000:
                begin
                    case(func)
                        6'b100000: begin //add
                            wreg=1;
                            m2reg=0;
                            wmem=0;
                            aluc=4'b0010;
                            aluimm=0;
                            regrt=0;
                        end
                            
                        6'b100010:  begin //sub
                            wreg =1;
                            m2reg = 0;
                            wmem = 0;
                            aluc = 4'b0110;
                            aluimm = 0;
                            regrt = 0;
                        end
                        
                    endcase
                end
            6'b100011: //lw
                begin
                    wreg =1;
                    m2reg = 1;
                    wmem = 0;
                    aluc = 4'b0010;
                    aluimm = 1;
                    regrt = 1;
                end
            6'b101011: 
                begin
                    wreg =0;
                    m2reg = 0;
                    wmem = 1;
                    aluc = 4'b0010;
                    aluimm = 1;
                    regrt = 1;
                end
        endcase
    end
endmodule

module RegMux(
input[4:0] rt,
input[4:0] rd,
input regrt,
output reg[4:0] dest
);
always @(*)
    begin
        if(regrt==0) dest<=rd;
        else if(regrt==1) dest <= rt;
    end
endmodule

module RegFile(
input[4:0] rs,
input[4:0] rt,
input[3:0] wdestReg,
input[31:0] wbData,
input wwreg,
input clk,
output reg[31:0] qa,
output reg[31:0] qb
);
reg[31:0] intern[0:31];
integer i;
initial begin
    for(i=0;i<32;i=i+1) 
        begin
            intern[i] <= 0;
        end
end
always @(*)
    begin
        qa=intern[rs];
        qb=intern[rt];
    end
always @(negedge clk)
    begin
        if(wwreg==1) intern[wdestReg] <= wbData;
    end

endmodule

module IE(
input[15:0] imm,
output reg[31:0] imm32
);
always @(*)
    begin
        imm32 <= {{16{imm[15]}},imm};
    end
endmodule

module ID(
input clk,
input wreg,
input m2reg,
input wmem,
input [3:0] aluc,
input aluimm,
input[4:0] destReg,
input[31:0] qa,
input[31:0] qb,
input[31:0] imm32,
output reg ewreg,
output reg em2reg,
output reg ewmem,
output reg [3:0] ealuc,
output reg ealuimm,
output reg[4:0] edestReg,
output reg [31:0] eqa,
output reg [31:0] eqb,
output reg [31:0] eimm32
);
always @(posedge clk)
    begin
        ewreg=wreg;
        em2reg=m2reg;
        ewmem=wmem;
        ealuc=aluc;
        ealuimm=aluimm;
        edestReg=destReg;
        eqa=qa;
        eqb=qb;
        eimm32=imm32;
    end
endmodule


module Alu_Mux(
input[31:0] eqb,
input[31:0] eimm32,
input ealuimm,
output reg[31:0] b 
);
always @(*)
    begin
        if(ealuimm==0) b<=eqb;
        else if(ealuimm==1) b <= eimm32;
    end

endmodule

module Alu(
input[31:0] eqa,
input[31:0] b,
input[3:0] ealuc,
output reg[31:0] r 
);
always @ (*) 
begin
	case(ealuc)
	4'b0000: begin
		r = eqa & b;
	end
	4'b0001: begin
		r = eqa | b;
	end
	4'b0010: begin
		r = eqa + b;
	end
	4'b0110: begin
		r = eqa - b;
	end
	4'b0111: begin
		if(eqa < b) begin
			r = 32'd1;
		end

		else begin
			r = 32'd0;
		end
	end
	4'b1100: begin
		r = ~(eqa | b);
	end
	
	endcase

end

endmodule

module EXEMEM(
input ewreg,
input em2reg,
input ewmem,
input[4:0] edestReg,
input [31:0] r,
input [31:0] eqb,
input clock,
output reg mwreg,
output reg mm2reg,
output reg mwmem,
output reg[4:0] mdestReg,
output reg[31:0] mr,
output reg[31:0] mqb 
);
always @(posedge clock)
    begin
        mwreg<=ewreg;
        mm2reg<=em2reg;
        mwmem<=ewmem;
        mdestReg<=edestReg;
        mr<=r;
        mqb<=eqb;
    end

endmodule

module Data_mem(
input[31:0] mr,
input[31:0] mqb,
input mwmem,
input clk,
output reg[31:0] mdo 
);
reg[31:0] mem[63:0];
initial begin 
    	mem[0] = 32'hA00000AA;
    	mem[1] = 32'h10000011;
    	mem[2] = 32'h20000022 ;
    	mem[3] = 32'h30000033 ;   	
    	mem[4] = 32'h40000044;
    	mem[5] = 32'h50000055 ;
    	mem[6] = 32'h60000066 ;
    	mem[7] = 32'h70000077 ;
    	mem[8] = 32'h80000088 ;
    	mem[9] = 32'h90000099 ;
    	
    	mem[25]= 32'b10001100001000100000000000000000;//100:    lw $2, 00($1) 
    	mem[26]= 32'b10001100001000110000000000000100;//104:    lw $3, 04($1)
    	mem[27]= 32'b10001100001001000000000000001000;//108:    lw $4, 08($1)
    	mem[28]= 32'b10001100001001010000000000001100;//112:    lw $5, 12($1)
    	mem[29]= 32'b00000000010010100011000000100000;//116:    add $6, $2, $10 
end
always @(*)
    begin
        mdo=mem[mr[31:2]];
    end
always @(negedge clk)
    begin
        if(mwmem==1) mem[mr[31:2]]=mqb;
    end

endmodule

module MEMWB(
input mwreg,
input mm2reg,
input[4:0] mdestReg,
input [31:0] mr,
input [31:0] mdo,
input clock,
output reg wwreg,
output reg wm2reg,
output reg[4:0] wdestReg,
output reg[31:0] wr,
output reg[31:0] wdo 
);
always @(posedge clock)
    begin
        wwreg<=mwreg;
        wm2reg<=mm2reg;
        wdestReg<=mdestReg;
        wr<=mr;
        wdo<=mdo;
    end

endmodule

module WbMux(
input [31:0] wr,
input [31:0] wdo,
input wm2reg,
output reg[31:0] wbData
);
always @(*)
    begin
        if(wm2reg==0) wbData<=wr;
        else if(wm2reg==1) wbData <= wdo;
    end

endmodule








