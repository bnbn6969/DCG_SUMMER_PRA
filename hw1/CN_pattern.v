//register maybe
module register(
    input  [3:0] address,
    output [4:0] value,
    
);
always @(*) begin
    case(address)
    4'b0000:value = 5'd9;
    4'b0001:value = 5'd27;
    4'b0010:value = 5'd30;
    4'b0011:value = 5'd3;
    4'b0100:value = 5'd11;
    4'b0101:value = 5'd8;
    4'b0110:value = 5'd26;
    4'b0111:value = 5'd17;
    4'b1000:value = 5'd3;
    4'b1001:value = 5'd12;
    4'b1010:value = 5'd1;
    4'b1011:value = 5'd10;
    4'b1100:value = 5'd15;
    4'b1101:value = 5'd5;
    4'b1110:value = 5'd23;
    4'b1111:value = 5'd20;
    endcase
end
endmodule



module CN (
    input wire [4:0] opcode,
    input wire [3:0] in_n0,
    input wire [3:0] in_n1,
    input wire [3:0] in_n2,
    input wire [3:0] in_n3,
    input wire [3:0] in_n4,
    input wire [3:0] in_n5,
    output reg [8:0] out_n,  //9bit output
);

endmodule
