module MIPS(
    //input
    input wire clk;
    input wire rst_n;
    input wire in_valid;
    input wire [31:0] instruction;
    input wire [19:0] output_reg;
    //OUTPUT
    output reg  out_valid, instruction_fail;
    output reg [31:0] out_1, out_2, out_3, out_4;
);

/////////////////////////decalretion wire and reg///////////////////
    reg [31:0] instruction_1_reg ;
    reg [20:0] instruction_2_reg ;
  

    reg [31:0] instruction_1_nxt ;
    reg [15:0] instruction_2_nxt ;
   


    reg in_valid_1 , in_valid_2 , in_valid_3 ;
    wire [5:0] OPCODE , FUNCT ;
    wire [4:0] RS , RT , RD , SHAMT ;
    wire [15:0] IMM;
    reg  [31:0] reg_1, reg_2, reg_3, reg_4, reg_5, reg_6 ;
    reg  OPCODE_FAIL_FLAG_stage_2, OPCODE_FAIL_FLAG_stage_3 , RTYPE;
    reg  [31:0] value ;
    
    //STORE RS AND TRANFER TO NEXT
    reg  [31:0] RS_value, RT_value ;
    //4TH FOR output_reg
    reg [19:0] output_1_reg ;
    reg [19:0] output_2_reg ;
    reg [19:0] output_3_reg ;

    reg [19:0] output_1_nxt ;
    reg [19:0] output_2_nxt ;
    reg [19:0] output_3_nxt ;
  
/////////////////////////valid order//////////////////////////
    always @(posedge clk or negedge rst_n ) begin
        if ( !rst_n )begin
            in_valid_1 <= 0 ;
            in_valid_2 <= 0 ;
            in_valid_3 <= 0 ;
            out_valid  <= 0 ;
        end
        else begin
            in_valid_1 <= in_valid   ;
            in_valid_2 <= in_valid_1 ;
            in_valid_3 <= in_valid_2 ;
            out_valid  <= in_valid_3 ;
        end
    end

// ===========================================================
//                           reg_1 fetch
// ===========================================================
//instruction_1_reg
    always @( posedge clk or negedge rst_n ) begin
        if ( !rst_n )begin
            instruction_1_reg <= 0 ;
        end
        else begin
            instruction_1_reg <= instruction_1_nxt;
        end
    end
    always @(*) begin
        if ( in_valid ) begin
            instruction_1_nxt = instruction ;
        end
        else begin
            instruction_1_nxt = 0 ;
        end
    end
//output_reg_1
    always @( posedge clk or negedge rst_n ) begin
        if ( !rst_n )begin
            output_1_reg <= 0 ;
        end
        else begin
            output_1_reg <= output_1_nxt ;
        end
    end

    always @(*) begin
        if ( in_valid ) begin
            output_1_nxt = output_reg ;
        end
        else begin
            output_1_nxt = 0 ;
        end
    end

// ===========================================================
//                           reg_2 Decode                     
// ===========================================================
   assign RS = instruction_1_reg [25:21];
   assign RT = instruction_1_reg [20:16];
   assign OPCODE  = instruction_1_reg [31:26] ;


   always @(posedge clk) begin //RTYPE
    if ( OPCODE == 6'b000000 )begin
        RTYPE <= 1;
    end
    else RTYPE <= 0;
   end

   always @(posedge clk ) begin
    if ( (OPCODE==6'b000000) || (OPCODE==6'b001000) 
        && ((RS == 5'b10001) || (RS == 5'b10010) || (RS == 5'b01000) || (RS == 5'b10111) || (RS == 5'b11111) || (RS == 5'b10000))  
        && ((RT == 5'b10001) || (RT == 5'b10010) || (RT == 5'b01000) || (RT == 5'b10111) || (RT == 5'b11111) || (RT == 5'b10000)) )
    begin
        OPCODE_FAIL_FLAG_stage_2  <= 0; // valid
    end
    else OPCODE_FAIL_FLAG_stage_2 <= 1;
   end


   always @( posedge clk ) begin
    case (RS)
        5'b10001 : RS_value <= reg_1;
        5'b10010 : RS_value <= reg_2;
        5'b01000 : RS_value <= reg_3;
        5'b10111 : RS_value <= reg_4;
        5'b11111 : RS_value <= reg_5;
        5'b10000 : RS_value <= reg_6;
        default:  RS_value <= 0;

    endcase
   end

   always @( posedge clk ) begin
    case (RT)
        5'b10001 : RT_value <= reg_1;
        5'b10010 : RT_value <= reg_2;
        5'b01000 : RT_value <= reg_3;
        5'b10111 : RT_value <= reg_4;
        5'b11111 : RT_value <= reg_5;
        5'b10000 : RT_value <= reg_6;
         
        default:  RT_value <= 0;
    endcase
   end

   always @(posedge clk  or negedge rst_n ) begin
     if ( !rst_n ) begin
        instruction_2_reg <= 0 ;
     end
     else begin
        instruction_2_reg <= instruction_1_reg[20:0] ;
     end
   end
   //output_reg_2
    always @( posedge clk or negedge rst_n ) begin
        if ( !rst_n )begin
            output_2_reg <= 0 ;
        end
        else begin
            output_2_reg <= output_2_nxt ;
        end
    end

    always @(*) begin
        if ( in_valid ) begin
            output_2_nxt = output_1_reg ;
        end
        else begin
            output_2_nxt = 0 ;
        end
    end
// ===========================================================
//                           reg_3 ALU                     
// ===========================================================  
   
   assign RD      = instruction_2_reg [15:11];
   assign SHAMT   = instruction_2_reg [10:6];
   assign FUNCT   = instruction_2_reg [5:0];
   assign IMM     = instruction_2_reg [15:0];
//deal with fail_stage_3
   always @( * ) begin
        if ( 
                RTYPE
            && (!OPCODE_FAIL_FLAG_stage_2) 
            && ((RD == 5'b10001) || (RD == 5'b10010) || (RD == 5'b01000) || (RD == 5'b10111) || (RD == 5'b11111) || (RD == 5'b10000))  
            && ((FUNCT == 6'b100000) || (FUNCT == 6'b100100) || (FUNCT == 6'b100101) || (FUNCT == 6'b100111) || (FUNCT == 6'b000000) || (FUNCT == 6'b000010)) 
           )begin
            OPCODE_FAIL_FLAG_stage_3 =0 ; //valid for r type
            end

        else if ( 
                    ( !RTYPE )
                 && ( !OPCODE_FAIL_FLAG_stage_2 ) 
                ) begin
                    OPCODE_FAIL_FLAG_stage_3 =0 ; //valid for i type
                  end
        else begin
            OPCODE_FAIL_FLAG_stage_3 = 1 ;
        end
   end
   always @( * ) begin
        case(FUNCT)
            6'b100000  : value = RS_value + RT_value ;
            6'b100100  : value = RS_value & RT_value ;
            6'b100101  : value = RS_value | RT_value ;
            6'b100111  : value = ~(RS_value | RT_value) ;
            6'b000000  : value = RS_value << SHAMT ;
            6'b000010  : value = RS_value >> SHAMT ;
            default    : value = 0 ;
        endcase
   end
    //output_reg_3
    always @( posedge clk or negedge rst_n ) begin
        if ( !rst_n )begin
            output_3_reg <= 0 ;
        end
        else begin
            output_3_reg <= output_3_nxt ;
        end
    end

    always @(*) begin
        if ( in_valid ) begin
            output_3_nxt = output_2_reg ;
        end
        else begin
            output_3_nxt = 0 ;
        end
    end

// ===========================================================
//                           reg_4  READ                   
// =========================================================== 
    
    always @(posedge clk or negedge rst_n ) begin //out_1
        if ( !rst_n )begin
            out_1 <= 0;
        end
        else if (  in_valid_3 && !OPCODE_FAIL_FLAG_stage_3 )begin
            case(output_3_reg[4:0])
                5'b10001: out_1 <= reg_1;
                5'b10010: out_1 <= reg_2;
                5'b01000: out_1 <= reg_3;
                5'b10111: out_1 <= reg_4;
                5'b11111: out_1 <= reg_5;
                5'b10000: out_1 <= reg_6;
            endcase
        end
        else out_1 <= 0;
    end

    always @(posedge clk or negedge rst_n ) begin //out_2
        if ( !rst_n )begin
            out_2 <= 0;
        end
        else if (  in_valid_3 && !OPCODE_FAIL_FLAG_stage_3 )begin
            case(output_3_reg[9:5])
                5'b10001: out_2 <= reg_1;
                5'b10010: out_2 <= reg_2;
                5'b01000: out_2 <= reg_3;
                5'b10111: out_2 <= reg_4;
                5'b11111: out_2 <= reg_5;
                5'b10000: out_2 <= reg_6;
            endcase
        end
        else out_2 <= 0;
    end

    always @(posedge clk or negedge rst_n ) begin //out_3
        if ( !rst_n )begin
            out_3 <= 0;
        end
        else if (  in_valid_3 && !OPCODE_FAIL_FLAG_stage_3 )begin
            case(output_3_reg[14:10])
                5'b10001: out_3 <= reg_1;
                5'b10010: out_3 <= reg_2;
                5'b01000: out_3 <= reg_3;
                5'b10111: out_3 <= reg_4;
                5'b11111: out_3 <= reg_5;
                5'b10000: out_3 <= reg_6;
            endcase
        end
        else out_3 <= 0;
    end
    
    always @(posedge clk or negedge rst_n ) begin //out_4
        if ( !rst_n )begin
            out_4 <= 0;
        end
        else if (  in_valid_3 && !OPCODE_FAIL_FLAG_stage_3 )begin
            case(output_3_reg[19:15])
                5'b10001: out_4 <= reg_1;
                5'b10010: out_4 <= reg_2;
                5'b01000: out_4 <= reg_3;
                5'b10111: out_4 <= reg_4;
                5'b11111: out_4 <= reg_5;
                5'b10000: out_4 <= reg_6;
            endcase
        end
        else out_4 <= 0;
    end

    always @(posedge clk or negedge rst_n ) begin //instruction_fail
        if ( !rst_n )begin
            instruction_fail <= 0;
        end
        else if (  in_valid_3 && OPCODE_FAIL_FLAG_stage_3 )begin
            instruction_fail <= 1;
        end
        else instruction_fail <= 0;
    end


 //////////////////////////////////////////////////////////////////////////  
 //reg_1 10001
   always @(posedge clk or negedge rst_n) begin
        if ( !rst_n )begin
            reg_1 <= 0 ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && RTYPE && RD == 5'b10001 )begin
            reg_1 <= value ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && !RTYPE && instruction_2_reg [20:16] == 5'b10001 )begin// RT_STAGE3 = instruction_2_reg [20:16]
            reg_1 <= RS_value + IMM ;
        end
   end
//reg_2 10010
   always @(posedge clk or negedge rst_n) begin
        if ( !rst_n )begin
            reg_2 <= 0 ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && RTYPE && RD == 5'b10010 )begin
            reg_2 <= value ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && !RTYPE && instruction_2_reg [20:16] == 5'b10010 )begin// RT_STAGE3 = instruction_2_reg [20:16]
            reg_2 <= RS_value + IMM ;
        end
   end
//reg_3 01000
   always @(posedge clk or negedge rst_n) begin
        if ( !rst_n )begin
            reg_3 <= 0 ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && RTYPE && RD == 5'b01000 )begin
            reg_3 <= value ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && !RTYPE && instruction_2_reg [20:16] == 5'b01000 )begin// RT_STAGE3 = instruction_2_reg [20:16]
            reg_3 <= RS_value + IMM ;
        end
   end
   //reg_4 10111
   always @(posedge clk or negedge rst_n) begin
        if ( !rst_n )begin
            reg_4 <= 0 ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && RTYPE && RD == 5'b10111 )begin
            reg_4 <= value ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && !RTYPE && instruction_2_reg [20:16] == 5'b10111 )begin// RT_STAGE3 = instruction_2_reg [20:16]
            reg_4 <= RS_value + IMM ;
        end
   end
   //reg_5 11111
   always @(posedge clk or negedge rst_n) begin
        if ( !rst_n )begin
            reg_5 <= 0 ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && RTYPE && RD == 5'b11111 )begin
            reg_5 <= value ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && !RTYPE && instruction_2_reg [20:16] == 5'b11111 )begin// RT_STAGE3 = instruction_2_reg [20:16]
            reg_5 <= RS_value + IMM ;
        end
   end
   //reg_6 10000
   always @(posedge clk or negedge rst_n) begin
        if ( !rst_n )begin
            reg_6 <= 0 ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && RTYPE && RD == 5'b10000 )begin
            reg_6 <= value ;
        end
        else if ( ! OPCODE_FAIL_FLAG_stage_3 && !RTYPE && instruction_2_reg [20:16] == 5'b10000 )begin// RT_STAGE3 = instruction_2_reg [20:16]
            reg_6 <= RS_value + IMM ;
        end
   end

endmodule