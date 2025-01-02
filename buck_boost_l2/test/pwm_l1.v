/**
	Module name: pwm_l1
	Author: P.Trujillo
	Date: Nov24
	Description: Pulse Width Modulator
	History:
		- 1.0: Module created
**/

module pwm_l1 (
  input aclk, 
  input resetn,
  input ce,

  input [31:0] period,
  input [31:0] comparator,
  output pwm
);

  reg [31:0] period_counter;

	/* Sawtooth generator */
  always @(posedge aclk)
    if ((!resetn) || (period_counter == period))
      period_counter <= 32'd0;
    else 
      if (ce)
        period_counter <= period_counter + 32'd1;
  
	/* Comparator */
  assign pwm = (comparator > period_counter)? 1'b1: 1'b0;

endmodule