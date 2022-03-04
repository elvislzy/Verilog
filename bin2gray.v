module bin_to_gray(

bin_in,

gray_out

);

parameter data_width = 4;

 

input [data_width-1:0] bin_in;

output [data_width-1:0] gray_out;

 

assign gray_out = (bin_in >> 1) ^ bin_in;

 

endmodule