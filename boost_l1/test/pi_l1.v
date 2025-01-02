/**
	Module name: pi_l1
	Author: P.Trujillo
	Date: Nov24
	Description: Level 1 PI regulator
	History:
		- 1.0: Module created
**/

module pi_l1 #(
  parameter DATA_WIDTH = 32,
  parameter DATA_WIDTH_DECIMAL = 24
)(
  input wire aclk, 
  input wire resetn,
  input wire ce,

  input wire signed [DATA_WIDTH-1:0] in,
  input wire signed [DATA_WIDTH-1:0] reference,
  input wire signed [DATA_WIDTH-1:0] kp,
  input wire signed [DATA_WIDTH-1:0] ki,
  input wire signed [DATA_WIDTH-1:0] max,
  input wire signed [DATA_WIDTH-1:0] min,

  output wire signed [DATA_WIDTH-1:0] out
);

  reg signed [DATA_WIDTH-1:0] error;
  wire signed [(DATA_WIDTH*2)-1:0] kp_error;
  wire signed [DATA_WIDTH-1:0] kp_error_resized;

  wire signed [(DATA_WIDTH*2)-1:0] ki_error;
  wire signed [DATA_WIDTH-1:0] ki_error_resized;
  reg signed [DATA_WIDTH-1:0] ki_error_acc;

  wire signed [DATA_WIDTH-1:0] out_nsat;

  always @(posedge aclk)
    if (!resetn)
      error <= {DATA_WIDTH{1'b0}};
    else 
      if (ce)
        error = reference-in;
  
  /* proportional action */
  assign kp_error = kp * error;
  assign kp_error_resized = $signed(kp_error >>> DATA_WIDTH_DECIMAL);

  /* integral action */
  assign ki_error = ki * error;
  assign ki_error_resized = $signed(ki_error >>> DATA_WIDTH_DECIMAL);

  always @(posedge aclk)
    if (!resetn)
      ki_error_acc <= {DATA_WIDTH{1'b0}};
    else
      if (ce)
        ki_error_acc <= ki_error_resized + ki_error_acc;

  assign out_nsat = kp_error_resized + ki_error_acc;
  assign out = (out_nsat > max)? max:((out_nsat < min)? min:out_nsat);

endmodule