module scan_reg #(parameter N = 8)  (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 scan,
    input  wire     [N-1:0]     d,
    input  wire                 scan_data,
    output wire                 scan_out
    output reg      [N-1:0]     q
);



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        q       <= 'd0;
    end
    else if(scan) begin
        q       <= {q[N-2:0], scan_data};
    end
    else begin
        q       <= d;
    end
end

assign scan_out = q[N-1];

endmodule //scan_reg