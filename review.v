// -----------------------------------------------------------------
// Filename: review.v                                             
// 
// Company: 
// Description:                                                     
// 
// 
//                                                                  
// Author: Elvis.Lu<lzyelvis@gmail.com>                            
// Create Date: 02/01/2022                                           
// Comments:                                                        
// 
// -----------------------------------------------------------------


// -----------------------------------------------------------------
// cdc_slow to fast clock domain
// -----------------------------------------------------------------
module cdc_s2f(
    input   fclk,
    input   rstn,
    input   s_signal,
    output  f_signal
);

reg     [1:0] signal;

always @(posedge fclk or negedge rstn) begin
    if(!rstn) begin
        signal      <= 2'd0;
    end
    else
        signal      <= {signal[0], s_signal};
end

assign f_signal = signal[1];

endmodule

// -----------------------------------------------------------------
// pulse_fast to slow clk domain (feedback)
// -----------------------------------------------------------------
module pulse_f2s(
    input       f_clk,
    input       s_clk,
    input       rst_n,
    input       f_pulse,
    output      s_pulse
);

reg     signal;
reg     sync_signal;
reg     [1:0]   f2s_signal;
reg     [1:0]   s2f_signal;

wire            s2f_pulse;

always @(posedge f_clk or negedge rst_n) begin
    if(!rst_n)begin
        signal      <= 1'b0;
    end
    else if(f_pulse) begin
        signal      <= 1'b1;
    end
    else if(s2f_pulse) begin
        signal      <= 1'b0;
    end
end

always @(posedge s_clk or negedge rst_n) begin
    if(!rst_n) begin
        sync_signal <= 1'b0;
    end    
    else begin
        sync_signal <= signal;
    end
end

always @(posedge s_clk or negedge rst_n) begin
    if(!rst_n) begin
        f2s_signal  <= 2'd0;
    end
    else begin
        f2s_signal  <= {f2s_signal[0], sync_signal};
    end
end

assign s_pulse = f2s_signal[1];

always @(posedge f_clk or negedge rst_n) begin
    if(!rst_n) begin
        s2f_signal  <= 2'd0;
    end
    else begin
        s2f_signal  <= {s2f_signal[0], s_pulse};
    end
end

assign s2f_pulse = s2f_signal[1];

endmodule

// -----------------------------------------------------------------
// 1-bit_edge_detect
// -----------------------------------------------------------------

module edge_detect(
    input       clk,
    input       rst_n,
    input       data,
    output      pos_edge,
    output      neg_edge,
    output      data_edge
);

reg     [1:0]   data_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_reg        <= 2'd0;
    end
    else begin
        data_reg        <= {data_reg[0], data};  
    end
end

assign pos_edge = ~data_reg[0] & data_reg[1];
assign neg_edge = data_reg[0] & ~data_reg[1];
assign data_edge = pos_edge | neg_edge;

endmodule


// -----------------------------------------------------------------   
// deserialize
// -----------------------------------------------------------------
module deserialize #(parameter N = 8)
(
    input               clk,
    input               rst_n,
    input               data,
    output  reg [N-1:0] data_out
);

// same result
// lsb_first(input in lsb first)
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         data_out        <= 'd0;
//     end
//     else begin
//         data_out        <= {data_out[N-2:0], data};
//     end
// end

// msb_first
parameter NC = $clog2(N);

reg     [NC-1:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt             <= 'd0;
        data_out        <= 'd0;
    end
    else begin
        data_out[N-1-cnt]   <= data;
        cnt                 <= cnt + 1'b1;
    end
end


endmodule


// -----------------------------------------------------------------   
// flag-101
// -----------------------------------------------------------------   
module flag_101(
    input       clk,
    input       rst_n,
    input       data,
    output      flag
);

reg     [1:0]   state;
reg     [1:0]   state_next;

parameter INIT  = 2'b00;
parameter S0    = 2'b01;
parameter S1    = 2'b10;
parameter S2    = 2'b11;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state       <= 2'b00;
    end
    else begin
        state       <= state_next;
    end
end

always @(*) begin
    case(state)
        INIT:
            if(!rst_n)
                state_next = INIT;
            else if(data==1'b1)
                state_next = S0;
            else
                state_next = INIT;
        S0:
            if(!rst_n)
                state_next = INIT;
            else if(data==1'b0)
                state_next = S1;
            else
                state_next = S0;
        S1:
            if(!rst_n)
                state_next = INIT;
            else if(data==1'b1)
                state_next = S2;
            else
                state_next = INIT;
        S2:
            if(!rst_n)
                state_next = INIT;
            else if(data==1'b1)
                state_next = S0;
            else
                state_next = S1;
        default:
            state_next = INIT;
    endcase
end

assign flag = (state == S2);

endmodule

// -----------------------------------------------------------------   
// clk_divider
// // -----------------------------------------------------------------   
module divider_even #(parameter N = 2)
(
    input               clk,
    input               rst_n,
    output              clk_out
);

parameter WIDTH = $clog2(N-1);

reg     [WIDTH-1:0]   cnt;
reg                 clk_div;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt         <= 'd0;
    end
    else if(cnt == (N/2)-1) begin
        cnt         <= 'd0;
    end
    else begin
        cnt         <= cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clk_div     <= 1'b0;
    end
    else if(cnt == (N/2) -1) begin
        clk_div     <= ~clk_div;
    end
end

assign  clk_out = clk_div;

endmodule

module divider_odd #(parameter N = 7)
(
    input           clk,
    input           rst_n,
    output          clk_out
);

parameter WIDTH = $clog2(N);

reg     [WIDTH-1:0] cnt;

reg     clk_div0;
reg     clk_div1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt         <= 'd0;
    end
    else if(cnt == N-1) begin
        cnt         <= 'd0;
    end
    else begin
        cnt         <= cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clk_div0        <= 1'b0;
    end
    else if(cnt == 'd0) begin
        clk_div0        <= ~clk_div0;
    end
end

always @(negedge clk or negedge rst_n) begin
   if(!rst_n) begin
       clk_div1         <= 1'b0;
   end 
   else if(cnt == (N+1)/2) begin                        // overlap (N+1)/2 clock, totally 2 * (N+1)/2 -1 = N clk. since negative edge, -1
       clk_div1         <= ~clk_div1;
   end
end

assign clk_out = clk_div0 ^ clk_div1;

function [31:0] clogb2;
    input [31:0] depth;
    begin
        for(clogb2=0;depth>1;clogb2=clogb2 + 1)
            depth = depth >> 1;
    end
endmodule


// -----------------------------------------------------------------   
// glitch_free_clk_sw
// -----------------------------------------------------------------   
module clk_sw(
    input           clk0,
    input           clk1,
    input           rst_n,
    input           select,
    output          clk_out
);

reg     select_clk0;
reg     select_clk1;

reg     clk0_en;
reg     clk1_en;

always @(posedge clk0 or negedge rst_n) begin
    if(!rst_n) begin
        select_clk0     <= 1'b0;
    end
    else begin
        select_clk0     <= ~clk1_en & select;
    end
end

always @(negedge clk0 or negedge rst_n) begin
    if(!rst_n) begin
        clk0_en         <= 1'b0;
    end
    else begin
        clk0_en         <= select_clk0;
    end
end

always @(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        select_clk1     <= 1'b0;
    end
    else begin
        select_clk1     <= ~clk0_en & ~select;
    end
end

always @(negedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        clk1_en         <= 1'b0;
    end
    else begin
        clk1_en         <= select_clk1;
    end
end

assign clk_out = (clk0_en & clk0) | (clk1_en & clk1); 

endmodule

// -----------------------------------------------------------------   
// asynchonse reset sync release
// -----------------------------------------------------------------   
module sync_rstn(
    input           clk,
    input           rst_n,
    output          sync_rst_n
);

reg     [1:0]   rst_n_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rst_n_r     <= 2'b00;
    end
    else begin
        rst_n_r     <= {rst_n_r[0], 1'b1};
    end
end

assign sync_rst_n = rst_n_r[1];

endmodule

function [31:0] clogb2;
    input   [31:0]  depth;
    begin
        for(clogb2=0; depth>1; clogb2=clogb2+1)
            depth = depth >> 1;
    end
endfunction

// -----------------------------------------------------------------   
// y(n) = x(n) + x(n-1) + x(n-2) + x(n-3) + x(n-4)+ x(n-5)+ x(n-6)+ x(n-7)
// -----------------------------------------------------------------   

module ex1 #(parameter N = 8, parameter DEPTH = 8, parameter OW = N + clogb2(DEPTH))
(
    input               clk,
    input               rst_n,
    input   [N-1:0]     din,
    output  [OW-1:0]    dout
);

reg     [clogb2(DEPTH)-1:0] cnt;

reg     [OW-1:0]    data_r;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt     <= 'd0;
    end
    else if(cnt == DEPTH -1) begin
        cnt     <= 'd0;
    end
    else begin
        cnt     <= cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_r      <= 'd0;
    end
    else if(cnt == 0) begin
        data_r      <= din;
    end
    else begin
        data_r      <= data_r + din;
    end
end

function [31:0] clogb2;
    input   [31:0]  depth;
    begin
        for(clogb2=0; depth>1; clogb2=clogb2+1)
            depth = depth >> 1;
    end
endfunction

endmodule

// -----------------------------------------------------------------   
// y(n) = 0.75x(n) + 0.25y(n-1)
// -----------------------------------------------------------------   
module ex2 #(parameter N = 8)
(
    input           clk,
    input           rst_n,
    input   [N-1:0]   data,
    output  [N-1:0]   dout
);

reg     [N+2-1:0]   data_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_r      <= 'd0;
    end
    else begin
        data_r      <= 3*data + data_r;     // 0.75 * 4 = 3, 0.25 * 4 = 1; => 3x+y/4 = 0.75x + 0.25y
    end
end

assign dout = data_r >> 2;

endmodule

// -----------------------------------------------------------------   
// 2-4_decoder
// -----------------------------------------------------------------   
module decoder2_4(
    input   [1:0]   decode_in,
    output  [3:0]   decode_out
);

reg     [3:0]   data;

always @(*) begin
    case(decode_in)
        2'b00 : data = 4'b1110;
        2'b01 : data = 4'b1101;
        2'b10 : data = 4'b1011;
        2'b11 : data = 4'b0111;
        default : data = 4'b1111;
    endcase
end

assign decode_out = data;
endmodule

// -----------------------------------------------------------------   
// z = abs(x-y) 
// -----------------------------------------------------------------   

module abs #(parameter N = 8)
(
    input   signed  [N-1:0] x,
    input   signed  [N-1:0] y,
    output  [N:0]   z
);

wire    signed  [N:0] sub_result;

assign sub_result = x - y;

assign z = sub_result[N] ? (~sub_result + 1'b1) : sub_result; // |a| = ~a + 1'b1(2's complement)

endmodule


// -----------------------------------------------------------------   
// int(fi(data,5,1,1)) 
// -----------------------------------------------------------------   
module int_data(
    input   [4:0]   data,
    output  [3:0]   floor_data,
    output  [3:0]   ceil_data,
    output  [3:0]   round_data
);

assign floor_data = data[4] ? data[4:1] : data[4:1] - 1'b1;
assign ceil_data = data[4] ? data[4:1] : data[4:1] + 1'b1;
assign round_data = data[0] ? data[4:1] + 1'b1 : data[4:1];

endmodule


