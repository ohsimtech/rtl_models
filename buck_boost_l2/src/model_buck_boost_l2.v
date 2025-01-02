
module model_buck_boost_l2 #(
  parameter MODEL_DATA_WIDTH = 32,
  parameter MODEL_DATA_WIDTH_DECIMAL = 24
)(
  input aclk, 
  input resetn, 
  input ce,

  input s1,

  input signed [MODEL_DATA_WIDTH-1:0] kL,
  input signed [MODEL_DATA_WIDTH-1:0] kC,
  input signed [MODEL_DATA_WIDTH-1:0] kR,
  input signed [MODEL_DATA_WIDTH-1:0] kRL,
  input signed [MODEL_DATA_WIDTH-1:0] kRC,
  input signed [MODEL_DATA_WIDTH-1:0] vdc,

  output reg signed [MODEL_DATA_WIDTH-1:0] iL,
  output signed [MODEL_DATA_WIDTH-1:0] vL,
  output signed [MODEL_DATA_WIDTH-1:0] vRL,
  output signed [MODEL_DATA_WIDTH-1:0] iC,
  output signed [MODEL_DATA_WIDTH-1:0] vRC,
  output signed [MODEL_DATA_WIDTH-1:0] iO,
  output reg signed [MODEL_DATA_WIDTH-1:0] vO
);

  wire signed [(MODEL_DATA_WIDTH*2)-1:0] vL_k;
  wire signed [MODEL_DATA_WIDTH-1:0] vL_k_resized;
  wire signed [(MODEL_DATA_WIDTH*2)-1:0] iC_k;
  wire signed [MODEL_DATA_WIDTH-1:0] iC_k_resized;
  wire signed [(MODEL_DATA_WIDTH*2)-1:0] vO_k;
  wire signed [MODEL_DATA_WIDTH-1:0] vO_k_resized;
  wire signed [(MODEL_DATA_WIDTH*2)-1:0] vRL_k;
  wire signed [(MODEL_DATA_WIDTH*2)-1:0] vRC_k;
  reg s1_cap;

  always @(posedge aclk)
    if (!resetn)
      s1_cap <= 1'b0;
    else
      if (ce)
        s1_cap <= s1;

  assign vL = s1_cap? vdc-vRL: vO-vRL;

  /* inductor gain */
  assign vL_k = -(vL * kL);
  assign vL_k_resized = $signed(vL_k >>> MODEL_DATA_WIDTH_DECIMAL);

  /* inductor integrator */
  always @(posedge aclk)
    if (!resetn)
      iL <= {MODEL_DATA_WIDTH{1'b0}};
    else 
      if (ce)
        iL <= vL_k_resized + iL;

  assign iC = s1_cap? -iO: iL-iO;

	/* Voltage in the inductor resistance */
	assign vRL_k = iL * kRL;
	assign vRL = $signed(vRL_k >>> MODEL_DATA_WIDTH_DECIMAL);

	/* Voltage in the capacitor resistanc (ESR) */
	assign vRC_k = iC * kRC;
	assign vRC = $signed(vRC_k >>> MODEL_DATA_WIDTH_DECIMAL);

  /* capacitor gain */
  assign iC_k = iC * kC;
  assign iC_k_resized = $signed(iC_k >>> MODEL_DATA_WIDTH_DECIMAL);

  /* capacitor integrator */
  always @(posedge aclk)
    if (!resetn)
      vO <= {MODEL_DATA_WIDTH{1'b0}};
    else 
      if (ce)
        vO <= iC_k_resized + vO + vRC;

  /* resistor gain */
  assign vO_k = vO * kR;
  assign iO = $signed(vO_k >>> MODEL_DATA_WIDTH_DECIMAL);

endmodule