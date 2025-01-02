/**
  Module name: ohs_boost_l1
  Author: P.Trujillo
  Date: March 2024
  Revision: 1.0
  History: 
    1.0: Model created
**/

module model_boost_l1 #(
  parameter MODEL_DATA_WIDTH = 32,
  parameter MODEL_DATA_WIDTH_DECIMAL = 22
)(
  input aclk, 
  input resetn, 
  input ce,

  /* Control input */
  input s1,

  /* Model parameters */
  input signed [MODEL_DATA_WIDTH-1:0] kL,
  input signed [MODEL_DATA_WIDTH-1:0] kRL,
  input signed [MODEL_DATA_WIDTH-1:0] kC,
  input signed [MODEL_DATA_WIDTH-1:0] kR,
  input signed [MODEL_DATA_WIDTH-1:0] vdc,
   
  /* Model outputs*/
  output reg signed [MODEL_DATA_WIDTH-1:0] iL,
  output wire signed [MODEL_DATA_WIDTH-1:0] vL,
  output wire signed [MODEL_DATA_WIDTH-1:0] iC,
  output reg signed [MODEL_DATA_WIDTH-1:0] vO,
  output wire signed [MODEL_DATA_WIDTH-1:0] iO
);

  wire signed [(MODEL_DATA_WIDTH*2)-1:0] vL_k;
  wire signed [MODEL_DATA_WIDTH-1:0] vL_k_resized;
  wire signed [(MODEL_DATA_WIDTH*2)-1:0] iC_k;
  wire signed [MODEL_DATA_WIDTH-1:0] iC_k_resized;
  wire signed [(MODEL_DATA_WIDTH*2)-1:0] iO_k;
  wire signed [MODEL_DATA_WIDTH-1:0] vO_k_resized;

	assign vL = s1? vdc: vdc-vO;

  /* inductor gain */
  assign vL_k = vL * kL;
  assign vL_k_resized = $signed(vL_k >>> MODEL_DATA_WIDTH_DECIMAL);

  /* inductor integrator */
  always @(posedge aclk)
    if (!resetn)
      iL <= {MODEL_DATA_WIDTH{1'b0}};
    else 
      if (ce)
        iL <= vL_k_resized + iL;
	
	assign iC = s1? -iO: iL-iO;

  /* capacitor gain */
  assign iC_k = iC * kC;
  assign iC_k_resized = $signed(iC_k >>> MODEL_DATA_WIDTH_DECIMAL);

  /* capacitor integrator */
  always @(posedge aclk)
    if (!resetn)
      vO <= {MODEL_DATA_WIDTH{1'b0}};
    else 
      if (ce)
        vO <= iC_k_resized + vO;

	/* resistor gain */
  assign iO_k = vO * kR;
  assign iO = $signed(iO_k >>> MODEL_DATA_WIDTH_DECIMAL);

endmodule
