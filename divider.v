`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/07 00:07:54
// Design Name: 
// Module Name: divider
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


module divider
    #(
        parameter WIDTH = 32,
        parameter CBIT = 5
    )
    (
    clk,
    rst,
    enable,
    dividend,
    divisor,
    quotient, 
    remainder,
    dout_vld
    );

    input               clk;
    input               rst;
    input               enable;
    input   [WIDTH-1:0] dividend;
    input   [WIDTH-1:0] divisor;

    output  [WIDTH-1:0] quotient;
    output  [WIDTH-1:0] remainder;
    output              dout_vld;


    reg     [WIDTH-1:0] divisor_reg;
    reg     [WIDTH-1:0] quotient;
    reg     [WIDTH-1:0] remainder;
    wire    [WIDTH:0]   sub_result;

    reg     [CBIT-1:0]  cnt;
    reg                 dout_vld;
    reg                 active;
    //
    assign sub_result = {remainder[WIDTH-2:0],quotient[WIDTH-1]} - divisor_reg;

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            quotient        <= 'd0;
            remainder       <= 'd0;
            divisor_reg     <= 'd0;          
        end  
        else if(enable && active) begin
            if(sub_result[WIDTH]==0) begin
                remainder   <= sub_result[WIDTH-1:0];
                quotient    <= {quotient[WIDTH-2:0],1'b1};
            end
            else begin
                remainder   <= {remainder[WIDTH-2:0],quotient[WIDTH-1]};
                quotient    <= {quotient[WIDTH-2:0],1'b0};
            end 
        end
        else begin
            quotient        <= dividend;
            remainder       <= 'd0;
            divisor_reg     <= divisor;
        end
    end


    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            cnt         <= 'd0;
            active      <= 1'b0;    
            dout_vld    <= 1'b0;
        end
        else if(enable && active) begin
            if(cnt == WIDTH-1) begin
                cnt         <= 'd0;
                active      <= 1'b0;
                dout_vld    <= 1'b1;
            end 
            else begin
                cnt         <= cnt + 1'b1;
            end
        end
        else begin
            active          <= 1'b1;
            dout_vld        <= 1'b0;
        end 
    end

endmodule