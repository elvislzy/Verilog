`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/28 23:55:36
// Design Name: 
// Module Name: FIFO_top
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

module FIFO_top #(parameter WIDTH = 32, parameter ADDRWIDTH = 4)
(
    wdata,
    wpush,
    wclk,
    wrstn,
    wfull,
    rdata,
    rempty,
    rpop,
    rclk,
    rrstn
);

input   [WIDTH-1:0] wdata;
input               wpush;
input               wclk;
input               wrstn;
output              wfull;
output  [WIDTH-1:0] rdata;
output              rempty;
input               rpop;
input               rclk;
input               rrstn;

//////////////////////////////////////////////////////////////////////////////////
wire    [WIDTH-1:0]     wdata;
wire    [WIDTH-1:0]     rdata;
wire    [ADDRWIDTH-1:0] waddr;
wire    [ADDRWIDTH-1:0] raddr;
wire                    w_en;

wire    [ADDRWIDTH:0]   rptr;
wire    [ADDRWIDTH:0]   wptr; 
wire    [ADDRWIDTH:0]   rptr_wclk;
wire    [ADDRWIDTH:0]   wptr_rclk;

//////////////////////////////////////////////////////////////////////////////////
assign  w_en = ~wfull & wpush;


//////////////////////////////////////////////////////////////////////////////////
sram_lib #(.WIDTH(WIDTH), .ADDRWIDTH(ADDRWIDTH)) FIFO_mem
(   
    .clk            (wclk       ),
    .wdata          (wdata      ),
    .waddr          (waddr      ),
    .w_en           (w_en       ),
    .raddr          (raddr      ),
    .rdata          (rdata      )
);

wr_control #(.ADDRWIDTH(ADDRWIDTH)) wr_control
(
    .wclk           (wclk       ),
    .wrstn          (wrstn      ),
    .waddr          (waddr      ),
    .wpush          (wpush      ),
    .rptr_wclk      (rptr_wclk  ),
    .wfull          (wfull      ),
    .wptr           (wptr       )
);

sync_2flop #(.DATAWIDTH(32'd5)) sync_w2r
(
    .d              (wptr       ),
    .q              (wptr_rclk  ),
    .clk            (rclk       ),
    .rst            (rrstn      )
);

re_control #(.ADDRWIDTH(ADDRWIDTH)) re_control
(
    .rclk           (rclk       ),
    .rrstn          (rrstn      ),
    .rpop           (rpop       ),
    .wptr_rclk      (wptr_rclk  ),
    .raddr          (raddr      ),
    .rptr           (rptr       ),
    .rempty         (rempty     )
);

sync_2flop #(.DATAWIDTH(32'd5)) sync_r2w
(
    .d              (rptr       ),
    .q              (rptr_wclk  ),
    .clk            (wclk       ),
    .rst            (wrstn      )
);


endmodule
