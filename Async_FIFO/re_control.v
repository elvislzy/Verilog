`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/12 15:27:35
// Design Name: 
// Module Name: re_control
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


module re_control #(parameter ADDRWIDTH = 4)
(
    rclk,
    rrstn,
    rpop,
    wptr_rclk,
    raddr,
    rptr,
    rempty
);

input   wire                    rclk;
input   wire                    rrstn;
input   wire                    rpop;
input   wire    [ADDRWIDTH:0]   wptr_rclk;

output  wire    [ADDRWIDTH-1:0]  raddr;
output  reg     [ADDRWIDTH:0]    rptr;
output  reg                     rempty;

reg             [ADDRWIDTH:0]    rbin;
wire            [ADDRWIDTH:0]    rbin_tmp;
wire            [ADDRWIDTH:0]    rgray_tmp;
wire                            rempty_tmp;

//////////////////////////////////////////////////////////////////////////////////
//ctrl
//////////////////////////////////////////////////////////////////////////////////
assign  raddr = rbin[ADDRWIDTH-1:0];
assign  rbin_tmp = (rpop & ~rempty) ? rbin + 1'b1 : rbin;
//bin2gray
assign  rgray_tmp = (rbin_tmp >> 1) ^ rbin_tmp;
//empty
assign  rempty_tmp = rgray_tmp == wptr_rclk;

//////////////////////////////////////////////////////////////////////////////////
//reg
//////////////////////////////////////////////////////////////////////////////////
always @(posedge rclk or negedge rrstn) begin
    if(!rrstn) begin
        rptr    <= 'd0;
        rempty  <= 1'b1;
        rbin    <= 'd0;
    end
    else begin
        rptr    <= rgray_tmp;
        rempty  <= rempty_tmp;
        rbin    <= rbin_tmp;
    end
end

endmodule
