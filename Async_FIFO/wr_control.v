`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/29 00:37:13
// Design Name: 
// Module Name: wr_control
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


module wr_control #(parameter ADDRWIDTH = 4)
(
    wclk,
    wrstn,
    waddr,
    wpush,
    rptr_wclk,
    wfull,
    wptr
);

input                   wclk;
input                   wrstn;
input   [ADDRWIDTH-1:0] waddr;
input                   wpush;
input   [ADDRWIDTH:0]   rptr_wclk;
output                  wfull;
output  [ADDRWIDTH:0]   wptr;

reg                     wfull;
reg     [ADDRWIDTH:0]   wptr;
reg     [ADDRWIDTH:0]   wbin;
wire                    wfull_tmp;
wire    [ADDRWIDTH:0]   wptr_tmp;
wire    [ADDRWIDTH:0]   wbin_tmp;

//////////////////////////////////////////////////////////////////////////////////
assign waddr = wbin[ADDRWIDTH-1:0];
assign wbin_tmp = (wpush & ~wfull) ? wbin + 1'b1 : wbin; 
//bin2gray
assign wptr_tmp = (wbin_tmp>>1) ^ wbin_tmp;
//full
assign wfull_tmp = (wptr_tmp == {~rptr_wclk[ADDRWIDTH:ADDRWIDTH-1],rptr_wclk[ADDRWIDTH-2:0]});     //use gray code to judge full
                                                                                                //depth = 16
                                                                                                //0  5'b00000 -> 5'b00_000
                                                                                                //16 5'b10000 -> 5'b11_000
//////////////////////////////////////////////////////////////////////////////////
always @(posedge wclk or negedge wrstn) begin
    if(!wrstn) begin
        wbin    <= 'd0;
        wptr    <= 'd0;
        wfull   <= 1'b0;
    end
    else begin
        wbin    <= wbin_tmp;
        wptr    <= wptr_tmp;
        wfull   <= wfull_tmp;
    end 
end


endmodule
