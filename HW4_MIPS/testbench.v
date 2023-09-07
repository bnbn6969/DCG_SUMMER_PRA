`timescale 1ns / 1ps
`define CYCLE_TIME 5.0

module testbench();

//================================================================//
//                                I/O                             //
//================================================================//
reg         clk;
reg         rst_n;
reg         in_valid;
reg  [31:0] instruction;
reg  [19:0] output_reg;

wire        out_valid;
wire        instruction_fail;
wire [31:0] out_1;
wire [31:0] out_2;
wire [31:0] out_3;
wire [31:0] out_4;

MIPS MIPS(
    .clk              (clk             ),
    .rst_n            (rst_n           ),
    .in_valid         (in_valid        ),
    .instruction      (instruction     ),
    .output_reg       (output_reg      ),
    .out_valid        (out_valid       ),
    .out_1            (out_1           ),
    .out_2            (out_2           ),
    .out_3            (out_3           ),
    .out_4            (out_4           ),
    .instruction_fail (instruction_fail)
);

//================================================================//
//                             integer                            //
//================================================================//
integer PATNUM;
integer k;
integer cnt;
integer count;
integer patcount;
integer CYCLE = `CYCLE_TIME;
integer input_file;
integer output_file;

//================================================================//
//                            registers                           //
//================================================================//
reg        golden_instruction_fail;
reg [31:0] golden_out1;
reg [31:0] golden_out2;
reg [31:0] golden_out3;
reg [31:0] golden_out4;

//================================================================//
//                              clock                             //
//================================================================//
always #(CYCLE / 2.0) clk = ~clk;

//================================================================//
//                             initial                            //
//================================================================//
initial begin
    input_file  = $fopen("input.txt",  "r");
    output_file = $fopen("output.txt", "r");
    k = $fscanf(input_file, "%d\n", PATNUM);
    
    reset_task;
    for (patcount = 0 ; patcount < PATNUM + 10 ; patcount = patcount + 1) begin
        @(negedge clk);
        if (patcount < PATNUM)begin
            in_valid = 1;
            k = $fscanf(input_file, "%b", instruction);
            k = $fscanf(input_file, "%b", output_reg);
        end
        else begin
            in_valid    = 0;
            instruction = 0;
            output_reg  = 0;
        end
        
        check_ans_task;
        
        if (cnt == 10) begin
            $display("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display("                                                     The execution latency are over 10 cycles                                               ");
            $display("--------------------------------------------------------------------------------------------------------------------------------------------");
            $finish;
        end
        
        if (in_valid === 1 && out_valid !== 1) begin
            cnt = cnt + 1;
        end
    end
    
    @(negedge clk);
    if (out_valid !== 0 || out_1 !== 0 || out_2 !== 0 || out_3 !== 0 || out_4 !== 0 || instruction_fail !== 0) begin
        $display("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display("                                              Fail!  Valid and output should be zero                                               ");
        $display("--------------------------------------------------------------------------------------------------------------------------------------------");
        $finish;
    end 
    
    repeat(2) @(negedge clk);
    YOU_PASS_task;
    $finish;
end

//================================================================//
//                             task                               //
//================================================================//
task reset_task; begin
    rst_n         = 1;
    in_valid      = 0;
    cnt           = 0;
    count         = 0;
    force clk     = 0;
    #(CYCLE); rst_n = 0;
    #(CYCLE);

    if(out_valid !==0 || out_1 !== 0 || out_2 !== 0 || out_3 !== 0 || out_4 !== 0 || instruction_fail !== 0) begin
        $display("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display("                                              Fail!  Valid and output should be zero after rst                                              ");
        $display("--------------------------------------------------------------------------------------------------------------------------------------------");
        $finish;
    end

    #(CYCLE) rst_n = 1;
    #(CYCLE) release clk;
end
endtask

task check_ans_task; begin
    if (out_valid === 1) begin
        k = $fscanf(output_file, "%b", golden_instruction_fail);
        k = $fscanf(output_file, "%d", golden_out1);
        k = $fscanf(output_file, "%d", golden_out2);
        k = $fscanf(output_file, "%d", golden_out3);
        k = $fscanf(output_file, "%d", golden_out4);
        if (instruction_fail !== golden_instruction_fail || out_1 !== golden_out1 || out_2 !== golden_out2 || out_3 !== golden_out3 || out_4 !== golden_out4) begin
            $display("---------------------------------------------------------------------------------------------------------------------------------------");
            $display("                                                         WRONG ANSWER FAIL!                                                            ");
            $display("                                                          Pattern No. %3d                                                              ", count);
            $display("                                          instruction_fail:%b       golden answer:%b                                                   ", instruction_fail, golden_instruction_fail);
            $display("                                          out_1:           %d       golden answer:%d                                                   ", out_1,            golden_out1);
            $display("                                          out_2:           %d       golden answer:%d                                                   ", out_2,            golden_out2);
            $display("                                          out_3:           %d       golden answer:%d                                                   ", out_3,            golden_out3);
            $display("                                          out_4:           %d       golden answer:%d                                                   ", out_4,            golden_out4);
            $display("---------------------------------------------------------------------------------------------------------------------------------------");
            $finish;
        end
        count = count + 1;
    end
end
endtask

task YOU_PASS_task; begin
    $display("----------------------------------------------------------------------------------------------------------------------");
    $display("                                                  Congratulations!                                                    ");
    $display("                                            You have passed all patterns!                                             ");
    $display("----------------------------------------------------------------------------------------------------------------------");
    $finish;
end
endtask

endmodule
