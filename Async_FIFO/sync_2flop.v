`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/28 17:44:41
// Design Name: 
// Module Name: sync_2flop
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


module sync_2flop #(parameter DATAWIDTH = 4)
(
    d,
    q,
    clk,
    rst
);
input       [DATAWIDTH-1:0]     d;
input                       clk;
input                       rst;
output      [DATAWIDTH-1:0]     q;

reg         [DATAWIDTH-1:0]     dreg0;
reg         [DATAWIDTH-1:0]     dreg1;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        dreg0   <= 0;
        dreg1   <= 0;
    end
    else begin
        dreg0   <= d;
        dreg1   <= dreg0;
    end 
end

assign q = dreg1;
endmodule
