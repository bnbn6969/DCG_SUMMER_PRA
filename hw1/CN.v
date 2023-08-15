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
////////////////////////////declartion wire reg///////////////////////
wire [3:0] value_0;
wire [3:0] value_1;
wire [3:0] value_2;
wire [3:0] value_3;
wire [3:0] value_4;
wire [3:0] value_5;
wire [3:0] sort[11:0][5:0]; //large-->small

reg [3:0] num[5:0];

//////////////////////////////////////////////////////////////////
 register reg_copy_0 ( .address(in_n0), .value ( value_0 ) ); 
 register reg_copy_1 ( .address(in_n1), .value ( value_1 ));
 register reg_copy_2 ( .address(in_n2), .value ( value_2 ));
 register reg_copy_3 ( .address(in_n3), .value ( value_3 ));
 register reg_copy_4 ( .address(in_n4), .value ( value_4 ));
 register reg_copy_5 ( .address(in_n5), .value ( value_5 ));

/////////////////////////////sort0////////////////////////////////////
assign sort[0][0] = ( value_0 > value_1 ) ? value_0 : value_1;
assign sort[0][1] = ( value_0 > value_1 ) ? value_1 : value_0;
assign sort[0][2] = value_2;
assign sort[0][3] = value_3;
assign sort[0][4] = value_4;
assign sort[0][5] = value_5;

/////////////////////////////sort1////////////////////////////////////
assign sort[1][0] = sort[0][0];
assign sort[1][1] = sort[0][1];
assign sort[1][2] = ( sort[0][2] > sort[0][3] ) ? sort[0][2] : sort[0][3];
assign sort[1][3] = ( sort[0][2] > sort[0][3] ) ? sort[0][3] : sort[0][2];
assign sort[1][4] = sort[0][4];
assign sort[1][5] = sort[0][5];

/////////////////////////////sort2////////////////////////////////////
assign sort[2][0] = sort[1][0];
assign sort[2][1] = sort[1][1];
assign sort[2][2] = sort[1][2];
assign sort[2][3] = sort[1][3];
assign sort[2][4] = ( sort[1][4] > sort[1][5] ) ? sort[1][4] : sort[1][5];
assign sort[2][5] = ( sort[1][4] > sort[1][5] ) ? sort[1][5] : sort[1][4];

/////////////////////////////sort3////////////////////////////////////
assign sort[3][0] = ( sort[2][0] > sort[2][2] ) ? sort[2][0] : sort[2][2];
assign sort[3][1] = sort[2][1];
assign sort[3][2] = ( sort[2][0] > sort[2][2] ) ? sort[2][2] : sort[2][0];
assign sort[3][3] = sort[2][3];
assign sort[3][4] = sort[2][4];
assign sort[3][5] = sort[2][5];

/////////////////////////////sort4////////////////////////////////////
assign sort[4][0] = sort[3][0];
assign sort[4][1] = sort[3][1];
assign sort[4][2] = sort[3][2];
assign sort[4][3] = ( sort[3][3] > sort[3][5] ) ? sort[3][3] : sort[3][5];
assign sort[4][4] = sort[3][4];
assign sort[4][5] = ( sort[3][3] > sort[3][5] ) ? sort[3][5] : sort[3][3];

/////////////////////////////sort5////////////////////////////////////
assign sort[5][0] = ( sort[4][0] > sort[4][4] ) ? sort[4][0] : sort[4][4];
assign sort[5][1] = sort[4][1];
assign sort[5][2] = sort[4][2];
assign sort[5][3] = sort[4][3];
assign sort[5][4] = ( sort[4][0] > sort[4][4] ) ? sort[4][4] : sort[4][0];
assign sort[5][5] = sort[4][5];

/////////////////////////////sort6////////////////////////////////////
assign sort[6][0] = sort[5][0];
assign sort[6][1] = ( sort[5][1] > sort[5][5] ) ? sort[5][1] : sort[5][5];
assign sort[6][2] = sort[5][2];
assign sort[6][3] = sort[5][3];
assign sort[6][4] = sort[5][4];
assign sort[6][5] = ( sort[5][1] > sort[5][5] ) ? sort[5][5] : sort[5][1];

/////////////////////////////sort7////////////////////////////////////
assign sort[7][0] = sort[6][0];
assign sort[7][1] = ( sort[6][1] > sort[6][2] ) ? sort[6][1] : sort[6][2];
assign sort[7][2] = ( sort[6][1] > sort[6][2] ) ? sort[6][2] : sort[6][1];
assign sort[7][3] = sort[6][3];
assign sort[7][4] = sort[6][4];
assign sort[7][5] = sort[6][5];

/////////////////////////////sort8////////////////////////////////////
assign sort[8][0] = sort[7][0];
assign sort[8][1] = sort[7][1];
assign sort[8][2] = sort[7][2];
assign sort[8][3] = ( sort[7][3] > sort[7][4] ) ? sort[7][3] : sort[7][4];
assign sort[8][4] = ( sort[7][3] > sort[7][4] ) ? sort[7][4] : sort[7][3];
assign sort[8][5] = sort[7][5];

/////////////////////////////sort9////////////////////////////////////
assign sort[9][0] = sort[8][0];
assign sort[9][1] = ( sort[8][1] > sort[8][3] ) ? sort[8][1] : sort[8][3];
assign sort[9][2] = sort[8][2];
assign sort[9][3] = ( sort[8][1] > sort[8][3] ) ? sort[8][3] : sort[8][1];
assign sort[9][4] = sort[8][4];
assign sort[9][5] = sort[8][5];

/////////////////////////////sort10////////////////////////////////////
assign sort[10][0] = sort[9][0];
assign sort[10][1] = sort[9][1];
assign sort[10][2] = ( sort[9][2] > sort[9][4] ) ? sort[9][2] : sort[9][4];
assign sort[10][3] = sort[9][3];
assign sort[10][4] = ( sort[9][2] > sort[9][4] ) ? sort[9][4] : sort[9][2];
assign sort[10][5] = sort[9][5];

/////////////////////////////sort11////////////////////////////////////
assign sort[11][0] = sort[10][0];
assign sort[11][1] = sort[10][1];
assign sort[11][2] = ( sort[10][2] > sort[10][3] ) ? sort[10][2] : sort[10][3];
assign sort[11][3] = ( sort[10][2] > sort[10][3] ) ? sort[10][3] : sort[10][2];
assign sort[11][4] = sort[10][4];
assign sort[11][5] = sort[10][5];

always @(*) begin
    case(opcode[4:3])
        2'b00:begin         //maintain
            num[0]=value_0;
            num[1]=value_1;
            num[2]=value_2;
            num[3]=value_3;
            num[4]=value_4;
            num[5]=value_5;
        end

        2'b01:begin         //invert
            num[0]=value_5;
            num[1]=value_4;
            num[2]=value_3;
            num[3]=value_2;
            num[4]=value_1;
            num[5]=value_0;
        end        

        2'b10:begin        //big-->small
            num[0]=sort[11][0];
            num[1]=sort[11][1];
            num[2]=sort[11][2];
            num[3]=sort[11][3];
            num[4]=sort[11][4];
            num[5]=sort[11][5];
        end

        2'b11:begin       //small-->big
            num[0]=sort[11][5];
            num[1]=sort[11][4];
            num[2]=sort[11][3];
            num[3]=sort[11][2];
            num[4]=sort[11][1];
            num[5]=sort[11][0];
            
        end
    endcase   
end

always @(*) begin
    case(opcode[2:0])
            3'b000: out_n = num[2] - num[1];
            3'b001: out_n = num[0] + num[3];
            3'b010: out_n = (num[3] * num[4]) >> 1;
            3'b011: out_n = num[1] + ( num[5] << 1 );
            3'b100: out_n = num[1] & num[2];
            3'b101: out_n = ~num[0];
            3'b110: out_n = num[3] ^ num[4];
            3'b111: out_n = num[1] << 1;
       endcase
    
end
endmodule

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
