module Checkdigit(
    input wire clk,
    input wire  rst_n,
    input wire  in_valid,
    input wire  [3:0] in_num,
    output reg  out_valid,
    output wire [3:0] out
);
///////////////////////////////decalre////////////////////////
reg[7 : 0] acc;
reg cnt;
wire [3:0] add_a;
wire [3:0] modulo;
wire [3:0] sub;

//////////////////////////combinational//////////////////////////////////
assign add_a= ( cnt ) ? in_num :             //*1
              ( in_num < 5 ) ? in_num << 1 : //*2 
              ( in_num ==5 ) ? 1 : 
              ( in_num ==6 ) ? 3 :
              ( in_num ==7 ) ? 5 :  
              ( in_num ==8 ) ? 7 : 9;
    
////////////////////////////seqution//////////////////////////////////
always @(posedge clk or negedge rst_n) begin  //deal cnt =>also be the input_flag
    if(!rst_n)begin
        cnt <= 0;
    end
    else if(in_valid) begin
        cnt <= cnt + 1 ;
    end
    else cnt <= 0 ;
    
end

always @(posedge clk or negedge rst_n ) begin //acc => accumulate
    if(!rst_n)begin
        acc <= 8'b0 ;
    end
    else if(in_valid)begin
        acc <= acc + add_a ;
    end
    else if ( out_valid ) begin
        acc <= 8'b0 ;
    end 
end

always @(posedge clk or negedge rst_n ) begin // out_valid
    if(!rst_n)begin
        out_valid <= 0 ;
    end
    else if ( !in_valid && cnt )
        out_valid <= 1;
    else if ( out_valid )  //when deal down next cycle reset 
        out_valid <= 0 ;
    
end 

//////////////////////output /////////////////////////////////
assign modulo = acc % 10 ;
assign sub = 10 - modulo ;
assign out = ( !out_valid ) ? 4'b0 :  
             ( sub == 10 ) ? 15 : sub;

endmodule

