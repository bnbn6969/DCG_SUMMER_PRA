`timescale 1ns / 1ps
`define CYCLE_TIME 10.0

module testbench();

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
reg        clk;
reg        rst_n;
reg        in_valid;
reg  [3:0] in_num;

wire       out_valid;
wire [3:0] out;

Checkdigit Checkdigit(
    // Input signals
    .clk       (clk      ),
    .rst_n     (rst_n    ),
    .in_valid  (in_valid ),
    .in_num    (in_num   ),
    // Output signals
    .out_valid (out_valid),
    .out       (out      )
);

//================================================================
// clock
//================================================================
real	CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk;

//================================================================
// parameters & integer
//================================================================
integer PATNUM = 1000;
integer seed = 333;
integer i, j, k;
integer patcount;
integer gap;
integer delay;
integer total_delay;
integer golden_out;

//================================================================
// initial
//================================================================
initial begin
    rst_n = 1'b1;
    in_valid = 1'b0;
    in_num = 4'b0;
    total_delay = 0;
    
    force clk = 0;
    reset_task;
    
    for(patcount=0; patcount<PATNUM; patcount=patcount+1)
    begin	
        delay_task;	
        input_cal_task;
        wait_out_valid;
        check_ans;
        //$display("\033[0;32mPASS PATTERN NO.%3d \033[m", patcount);
    end
    
    YOU_PASS_task;
    $finish;
end

//================================================================
// task
//================================================================
task delay_task; begin
	gap = $urandom_range(1,4);
	repeat(gap) @(negedge clk);
end endtask

task wait_out_valid ; begin
	delay = 0;

	while(out_valid !== 1) begin
		@(negedge clk);
		delay = delay + 1;
		
		if(delay==100)	begin
			$display ("------------------------------------------------------------------------");
			$display ("                             FAIL! 		                               ");
			$display ("          out_valid is not pulled high after 100 CYCLE                 ");
			$display ( "-----------------------------------------------------------------------");
			#(100);
		    $finish ;
		end
	end



	total_delay = total_delay + delay;
end endtask


task reset_task ; begin
	#(0.5); rst_n = 0;

	#(2.0);
	if(out_valid !== 0 || out!==0) begin
		$display ("-------------------------------------------------------------------------------");
		$display ("                                 RESET  FAIL!                                  ");
		$display ( "                 out_valid and out should be 0 after initial RESET            ");
		$display ( "------------------------------------------------------------------------------");
		#(100);
	    $finish ;
	end
	
	#(1.0); rst_n = 1 ;
	#(3.0); release clk;
end endtask



task input_cal_task; begin
	golden_out = 0;
	in_valid = 1;

	for(i=0; i<15; i=i+1)begin
		in_num = $urandom_range(0,9);
		if(i%2 === 0) golden_out = golden_out + ((in_num*2)%10) + ((in_num*2)-((in_num*2)%10))/10;
		else golden_out = golden_out + in_num;

		check_out_while_input;

		@(negedge clk);
	end
	golden_out = 10 - (golden_out % 10);

	if(golden_out==10)	golden_out = 15;

	in_valid = 0;
	in_num =  0;

end endtask

task check_out_while_input; begin

	if(in_valid===1&&out_valid!==0) begin
	$display ("-----------------------------------------------------------------------------------------------------");
	$display ("                          					FAIL!                                              		");
	$display ("                        			out_valid should be 0 while in_valid is high                  		");
	$display ("-----------------------------------------------------------------------------------------------------");
	#(100)
	$finish;
	end
	
end endtask

task check_ans; begin

	if(golden_out!==out) begin
		$display ("-----------------------------------------------------------------------------------------------------");
		$display ("                          		WRONG Checkdigit FAIL!                                              ");
		$display ("                        				Pattern No. %3d                                                 ",patcount);
		$display ("                        				Your answer: %3d                                                ",out);
		$display ("                        				Gold answer: %3d                                                ",golden_out);
		$display ("-----------------------------------------------------------------------------------------------------");
		#(100)
		$finish;
	end

	@(negedge clk);

	if(out_valid!==0) begin
		$display ("-----------------------------------------------------------------------------------------------------");
		$display ("                          				FAIL!                                              			");
		$display ("                        		out_valid should be high only for one cycle                             ");
		$display ("-----------------------------------------------------------------------------------------------------");
		#(100)
		$finish;
	end
	
end endtask

task YOU_PASS_task;begin
$display ("----------------------------------------------------------------------------------------------------------------------");
$display ("                                                  Congratulations!                						             ");
$display ("                                           You have passed all patterns!          						             ");
$display ("                                           Total latency: %d cycles                						             ", total_delay);
$display ("----------------------------------------------------------------------------------------------------------------------");
$finish;
end endtask


endmodule


