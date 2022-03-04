`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/29 00:02:53
// Design Name: 
// Module Name: sram_lib
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


module sram_lib #(parameter WIDTH = 32, parameter ADDRWIDTH = 4)
(   
    clk,
    wdata,
    waddr,
    w_en,
    raddr,
    rdata
);

input                   clk;
input   [WIDTH-1:0]     wdata;
input   [ADDRWIDTH-1:0] waddr;
input                   w_en;
input   [ADDRWIDTH-1:0] raddr;
output  [WIDTH-1:0]     rdata;

parameter DEPTH = 1<<ADDRWIDTH;
reg     [WIDTH-1:0] mem [0:DEPTH-1];


always @(posedge clk) begin
    if(w_en)
        mem[waddr]  <= wdata;    
end

assign  rdata = mem[raddr];

endmodule
