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
    output reg [5:0] out_sell_num;

);

/////////////////////////////parameter/////////////////////////
/*
parameter s_price=3'b001;
parameter s_wait=3'b010;
parameter s_in_coin=3'b011;
parameter s_cmp=3'b100;
parameter s_sub=3'b101;
parameter s_rtn=3'b110;
*/
parameter s_idle=3'b001;
parameter s_price=3'b010;
parameter s_in_coin=3'b011;
parameter s_rtn=3'b100 ;     //deal with output 
parameter s_buy_success=3'b101;
parameter s_buy_fail=3'b110;

////////////////////////////reg declare//////////////////////////
reg [ 2:0 ] next_state;
reg [ 2:0 ] current_state;
reg [ 4:0 ] price [5:0];
reg [ 8:0 ] acc;
reg [ 2:0 ] count_out;
reg [ 2:0 ] item_buy;
//reg in_coin_valid_delay;


wire [5:0] object_price;      //50=110010


wire compare; // 1:buy 0: not enough


////////////////////////////FSM state/////////////////////////
//current state
always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        current_state <= s_idle;
    end
    else begin
        current_state <= next_state;
    end

//next_state
always @(*) begin
    case( current_state )
    //1 initial
        s_idle:
        begin
            next_state = ( in_item_valid ) ? s_price : 
                         ( in_coin_valid ) ? s_in_coin : s_idle;
            /*
            if( in_item_valid )
                 next_state = s_price;
            else if ( in_coin_valid )begin    //to s_in_coin(when return and then buy)
                next_state=s_in_coin;
            end
            else begin
                next_state = s_idle;
            end 
            */
        end
    
    //2 item price
        s_price: 
        begin
            if ( in_coin_valid ) begin
                next_state = s_in_coin; 
            end
            else begin
                next_state = s_price; 
            end 

        end
            
     //3 give money and deal with ( s_fail and s_rtn output)
        s_in_coin :begin
            next_state = ( !in_coin_valid && in_rtn_coin) ? s_rtn :
                         ( !in_coin_valid && compare )    ? s_buy_success : 
                         ( !in_coin_valid && !compare )   ? s_buy_fail :
                         (  s_in_coin ) ;
        end
        

     //4
        s_buy_success:begin   // deal with sub then return
            next_state <= s_rtn;
        end   
    //5
        s_fail:begin
            next_state = ( in_rtn_coin ) ? s_rtn : ( in_coin_valid ) ? s_idle : s_fail ;
        end
    //6
        s_rtn:begin
            next_state = s_idle;
        end

    default: next_state = current_state ;
    endcase
end
////////////////////////////////////////////////
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

///////////////////////ACC design for total money /////////////////////
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        acc <= 0;
    end
    else if ( in_coin_valid )
        acc <= acc + in_coin;
    else if ( current_state == s_rtn )   //clear when next item price in
        acc <= acc % div_b;
end

/////////////////////////Return output  /////////////////////////////////////


////////////////////////COMPARE for combitional ////////////////////////////////////////
assign object_price = ( in_buy_item != 0 ) ? price[ in_buy_item-1 ] : 0;
assign compare =  acc >= object_price  ;








//////////////////////out_monitor/////////////////
/*
always @(posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin
        in_coin_valid_delay <= 0;
    end
    else in_coin_valid_delay <= in_coin_valid ;
end
always @(*) begin
    if ( in_coin_valid_delay && enough )
    out_monitor <= acc;
    else 

end
*/

endmodule