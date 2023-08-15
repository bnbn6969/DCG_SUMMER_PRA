module VM(
///////////////////////////input////////////////////////////// 
    input wire clk;
    input wire rst_n;
    input wire in_item_valid;
    input wire in_coin_valid;
    input wire [5:0] in_coin;
    input wire in_rtn_coin;
    input wire [2:0] in_buy_item;
    input wire [4:0] in_item_price;

////////////////////////////output/////////////////////////
    output reg [8:0] out_monitor;
    output reg out_valid;
    output reg [3:0] out_consumer;
    output reg [5:0] out_sell_num
);
/////////////////////////////parameter/////////////////////////
parameter s_idle=3'b001;
parameter s_price=3'b010;
parameter s_in_coin=3'b011;
parameter s_rtn=3'b100 ;                   //deal with output 
parameter s_buy_success=3'b101;
parameter s_buy_fail=3'b110;               //deal with output 

////////////////////////////reg declare//////////////////////////
reg [ 2:0 ] next_state;
reg [ 2:0 ] current_state;
reg [ 4:0 ] price [5:0] ;
reg [ 3:0 ] count_out ;
reg [ 2:0 ] object_item;
reg [ 5:0 ] total_sale_num [ 5:0 ] 

wire [ 4:0 ]object_price;

integer i;

////////////////////////////FSM state/////////////////////////
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        current_state <= s_idle;
    end
    else 
        current_state <= next_state;   
end

always @( * ) begin
    case ( current_state )
    //1
        s_idle :begin
            if ( in_item_valid ) begin
                next_state = s_price;
            end
            else if ( in_coin_valid ) begin
                next_state = s_in_coin;
            else
                next_state = current_state;
            end
        end
    //2
       s_price :begin
            if ( in_coin_valid ) begin
                next_state = s_in_coin;
            end
            else begin
                next_state = current_state;
            end
        end
    //3
     s_in_coin :begin
            if ( !in_coin_valid &&  in_rtn_coin ) begin
                next_state = s_rtn;
            end
            else if ( !in_coin_valid && in_buy_item !=0 && compare ) begin
                next_state = s_buy_success;
            end
            else if ( !in_coin_valid && in_buy_item !=0 && !compare )
                next_state = s_buy_fail;
            else
                next_state = current_state;
        end
    //4
        s_buy_success:begin   // deal with sub then return
            next_state = s_rtn;
        end   
    //5
        s_buy_fail:begin
            if ( in_coin_valid ) begin
                next_state = s_in_coin;
            end
            else
                next_state = current_state;
            //next_state = ( in_rtn_coin ) ? s_rtn : ( in_coin_valid ) ? s_idle : s_buy_fail ;
        end
    //6
        s_rtn:begin
            if ( count_out == 5 ) // need fix OK
                next_state = s_idle ;
            else
                next_state = current_state ;
        end

        default : next_state = current_state ; 
    endcase
end

///////////////////give money/////////////////////////////
always @(posedge clk ) begin  //price[0] means item1       price[1] means item 2
    if( in_item_valid )begin
        price[5] <= in_item_price;
        price[4] <= price[5];
        price[3] <= price[4];
        price[2] <= price[3];
        price[1] <= price[2];
        price[0] <= price[1];
    end
end
//////////////////count//////////////////////////////////////////
always @(posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        count_out <= 0;
    else if ( current_state == s_buy_fail || current_state == s_rtn )begin
        count_out <= count_out + 1;
    end
    else
        count_out <= 0;
    
    end
    
end
///////////////////////ACC design for total money /////////////////////
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        acc <= 0;
    end
    else if ( in_coin_valid )
        acc <= acc + in_coin;
   
end
/////////////////////////S_BUY_SUCESS///////////////////////////////
always @(posedge clk ) begin
    if ( current_state == s_buy_success )begin
        acc <= acc - object_price;    
    end
end

///////////////////////////store object_item/////////////////////////
always @(posedge clk or negedge rst_n) begin
    if ( !rst_n )begin
        object_item <= 0;
    end
    else if ( in_buy_item != 0 ) begin
        object_item <= in_buy_item;
    end
    
end

/////////////////////////output///////////////////////////////////////////////
////////////////////////out_monitor/////////////////////////////////////////
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        out_monitor <= 0;
    end
    else if ( in_coin_valid )                   //display
        out_monitor <= out_monitor + in_coin ;
    else if ( current_state == s_buy_fail )     
        out_monitor <= out_monitor ;
    else
        out_monitor <= 0 ;
end

////////////////////////out_valid////////////////////////////////////////
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        out_valid <= 0;
    end
    else if ( count_out ) //need fix  
        out_valid <= 1 ;
    else if ( count_out == 5 ) //need fix OK
        out_valid <= 0 ;
    else
        out_valid <= 0 ; 
end

///////////////////////out_consumor///////////////////////////////
always @(posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        out_consumer <= 0;
    end
    else if ( out_valid && current_state == s_rtn && count_out == 0 ) begin   // output : item acc =acc
        out_consumer <= object_item ;
    end
    else if ( out_valid && current_state == s_rtn && count_out == 1 ) begin  //num of 50
        out_consumer <= acc / 50 ;
        acc <= acc % 50 ;
    end
    else if ( out_valid && current_state == s_rtn && count_out == 2 ) begin
        out_consumer <= acc / 20 ;
        acc <= acc % 20 ;
    end
    else if ( out_valid && current_state == s_rtn && count_out == 3 ) begin
        out_consumer <= acc / 10 ;
        acc <= acc % 10 ;
    end
    else if ( out_valid && current_state == s_rtn && count_out == 4 ) begin
        out_consumer <= acc / 5 ;
        acc <= acc % 5 ;
    end
    else if ( out_valid && current_state == s_rtn && count_out == 5 ) begin
        out_consumer <= acc ;
    end
    else if (out_valid && current_state == s_buy_fail && count_out < 6 )
        out_consumer <= 0 ;
    
end

//////////////////////////////////total_sale_num///////////////////////////////
always @(posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        for ( int i=0 ; i < 6 ; i = i + 1  )
            total_sale_num[i] <= 0;
    end
    else if ( next_state == s_buy_success )begin
        total_sale_num [ in_buy_item -1 ] = total_sale_num [ in_buy_item -1 ] + 1 ;
    end
    else if ( in_item_valid ) begin
        for ( int i=0 ; i < 6 ; i = i + 1  )
            total_sale_num[i] <= 0;
    end
end

///////////////////////////////out_sale_num////////////////////////////////////////
always @(posedge clk ) begin
    if ( !rst_n )begin
        out_sale_num <=0 ;
    end
    else if ( out_valid )begin //need fix
        out_sale_num <= total_sale_num [count_out];
    end
end

////////////////////////COMPARE for combitional ////////////////////////////////////////
assign object_price = ( in_buy_item != 0 ) ? price[ in_buy_item-1 ] : 0;
assign compare =  ( acc >= object_price )  ;
// count :    0        1        2           3            4           5       6
// acc   :   acc      acc      acc%50      acc%20       acc%10     acc%5
// 152       152      152       2            2            2          2       0
/*
div_b = ( count_out == 1 ) ? 50 :     
        ( count_out == 2 ) ? 20 :
        ( count_out == 3 ) ? 10 : 
        ( count_out == 4 ) ? 5  : 1; 
*/

    






endmodule