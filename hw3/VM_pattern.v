`timescale 1ns / 1ps
module testbench();

//==============================================================================//
//                                      I/O                                     //
//==============================================================================//
reg  [4:0] opcode;
reg  [3:0] in_n0;
reg  [3:0] in_n1;
reg  [3:0] in_n2;
reg  [3:0] in_n3;
reg  [3:0] in_n4;
reg  [3:0] in_n5;

wire [8:0] out_n;

CN TOP(
    .opcode (opcode),
    .in_n0  (in_n0 ),
    .in_n1  (in_n1 ),
    .in_n2  (in_n2 ),
    .in_n3  (in_n3 ),
    .in_n4  (in_n4 ),
    .in_n5  (in_n5 ),
    .out_n  (out_n )
);

//==============================================================================//
//                                    Integer                                   //
//==============================================================================//
integer PATNUM = 200;
integer SEED   = 99;
integer patcount;
integer i;
integer j;

//==============================================================================//
//                                  Declaration                                 //
//==============================================================================//
reg       clk;
reg [4:0] golden_n[0:5];
reg [4:0] temp;
reg [8:0] golden_out;


//==============================================================================//
//                                     clock                                    //
//==============================================================================//
always #(20 / 2.0) clk = ~clk;

//==============================================================================//
//                                    Initial                                   //
//==============================================================================//
initial begin
    clk = 1;
    @(negedge clk);
    for (patcount = 0; patcount < PATNUM; patcount = patcount + 1) begin
        input_task;
        check_ans_task;
    end
    repeat(2) @(posedge clk);
    $display("YOU PASS ALL PATTERN!!!");
    $finish;
end

task input_task; begin
    in_n0 = $random(SEED);
    in_n1 = $random(SEED);
    in_n2 = $random(SEED);
    in_n3 = $random(SEED);
    in_n4 = $random(SEED);
    in_n5 = $random(SEED);
    
    get_register_value_task(.address (in_n0), .value (golden_n[0]));
    get_register_value_task(.address (in_n1), .value (golden_n[1]));
    get_register_value_task(.address (in_n2), .value (golden_n[2]));
    get_register_value_task(.address (in_n3), .value (golden_n[3]));
    get_register_value_task(.address (in_n4), .value (golden_n[4]));
    get_register_value_task(.address (in_n5), .value (golden_n[5]));

    opcode[4:3] = $random(SEED);
    
    if (opcode[4:3] === 2'b11) begin
        for (i = 6 - 1; i > 0; i = i - 1) begin
            for (j = 0; j <= i -1; j = j + 1) begin
                if (golden_n[j] > golden_n[j + 1]) begin
                    temp            = golden_n[j];
                    golden_n[j]     = golden_n[j + 1];
                    golden_n[j + 1] = temp;
                end
            end
        end
    end
    else if (opcode[4:3] === 2'b10) begin
        for (i = 6 - 1; i > 0; i = i - 1) begin
            for (j = 0; j <= i -1; j = j + 1) begin
                if (golden_n[j] < golden_n[j + 1]) begin
                    temp            = golden_n[j];
                    golden_n[j]     = golden_n[j + 1];
                    golden_n[j + 1] = temp;
                end
            end
        end
    end
    else if (opcode[4:3] === 2'b01) begin
        temp        = golden_n[5];
        golden_n[5] = golden_n[0];
        golden_n[0] = temp;
        
        temp        = golden_n[4];
        golden_n[4] = golden_n[1];
        golden_n[1] = temp;
        
        temp        = golden_n[3];
        golden_n[3] = golden_n[2];
        golden_n[2] = temp;
    end
    
    if (golden_n[1] > golden_n[2]) begin
        opcode[2:0] = $random(SEED) % 'd7 + 1; // 1 ~ 7;
    end
    else begin
        opcode[2:0] = $random(SEED);
    end
    
    case(opcode[2:0])
        3'b000: golden_out = golden_n[2] - golden_n[1];
        3'b001: golden_out = golden_n[0] + golden_n[3];
        3'b010: golden_out = (golden_n[3] * golden_n[4]) / 2;
        3'b011: golden_out = golden_n[1] + (golden_n[5] * 2);
        3'b100: golden_out = golden_n[1] & golden_n[2];
        3'b101: golden_out = ~golden_n[0];
        3'b110: golden_out = golden_n[3] ^ golden_n[4];
        3'b111: golden_out = golden_n[1] << 1;
    endcase
    @(negedge clk);
end
endtask

task check_ans_task; begin
    if (out_n !== golden_out) begin
        $display("YOU FAIL");
        repeat(2) @(negedge clk);
        $finish;
    end
end
endtask

task get_register_value_task(
    input  [3:0] address,
    output [4:0] value
);
begin
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
endtask

endmodule
