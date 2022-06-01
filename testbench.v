`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2022 10:22:18 PM
// Design Name: 
// Module Name: testbench
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


module testbench( );
reg clk_tb;
initial begin
    clk_tb=0;
end
wire [31:0] pc;
wire [31:0] dinstOut;
wire ewreg;
wire em2reg;
wire ewmem;
wire [3:0] aluc;
wire ealuimm;
wire [4:0] edestReg;
wire [31:0] eqa;
wire [31:0] eqb;
wire [31:0] eimm32;
wire mwreg,mm2reg;
wire [4:0] mdestReg;
wire [31:0] mr;
wire [31:0] mqb;
wire [31:0] mdo;
wire wwreg, wm2reg;
wire [31:0] wr;
wire [31:0] wdo; 

datapath datapath_tb(clk_tb, pc, dinstOut, ewreg, em2reg, ewmem, aluc,ealuimm,edestReg,eqa,eqb,eimm32, mwreg,mm2reg, mdestReg,mr,mqb,mdo,wwreg, wm2reg,wr,wdo);
always begin
    #5;
    clk_tb=~clk_tb;
end

endmodule
