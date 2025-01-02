
`timescale 1ns/1ns

`define _1us 1000
`define _10us 10000
`define _100us 100000
`define _1ms 1000000
`define _40ns 4
`define ntest 3
`define clkcycle 10
`define cecycle 1000
`define picycle 1000

`define data_width 32
`define data_width_decimal 20

module boost_l1_tb ();

  reg aclk;
  reg resetn;
  reg ce;
  reg ce_pi;

  real L;
  real kL;
  reg signed [`data_width-1:0] r_kL;
  real C;
  real kC;
  reg signed [`data_width-1:0] r_kC;
  real R;
  real kR;
  reg signed [`data_width-1:0] r_kR;
  real vdc;
  reg signed [`data_width-1:0] r_vdc;
  real ts;
  reg [31:0] period;

  /* Regulator */
  real reference;
  reg signed [`data_width-1:0] r_reference;

  real kp;
  reg signed [`data_width-1:0] r_kp;
  real ki;
  reg signed [`data_width-1:0] r_ki;
  real max;
  reg signed [`data_width-1:0] r_max;
  
  wire pwm;
  wire signed [`data_width-1:0] meas_iL;
  wire signed [`data_width-1:0] meas_vL;
  wire signed [`data_width-1:0] meas_iC;
  wire signed [`data_width-1:0] meas_iO;
  wire signed [`data_width-1:0] meas_vO;
  wire signed [`data_width-1:0] comparator_iq;
  wire [31:0] comparator;

  /*	clk generation	*/
  initial begin
    aclk = 1'b0;
    #(`clkcycle/2);
    forever
      #(`clkcycle/2) aclk = ~aclk;
  end

  initial begin
    ce <= 1'b0;
    forever begin
      #(`cecycle-`clkcycle);
      ce <= 1'b1;
      #(`clkcycle);
      ce <= 1'b0;
    end
  end

  initial begin
    ce_pi <= 1'b0;
    forever begin
      #(`picycle-`clkcycle);
      ce_pi <= 1'b1;
      #(`clkcycle);
      ce_pi <= 1'b0;
    end
  end

  pi_l1 #(
  .DATA_WIDTH(`data_width),
  .DATA_WIDTH_DECIMAL(`data_width_decimal)
  ) pi_inst (
  .aclk(aclk), 
  .resetn(resetn),
  .ce(ce_pi),
  .in(meas_vO),
  .reference(r_reference),
  .kp(r_kp),
  .ki(r_ki),
  .max(r_max),
  .min(0),
  .out(comparator_iq)
  );

	/* PI range 0:1 -> 0:2048 */
	/* Modulator range 0:1 -> 0:100 */
	/* Global range 0: */

  pwm_l1 pwm_inst0 (
  .aclk(aclk), 
  .resetn(resetn),
  .ce(ce_pi),
  .period(period),
  .comparator({20'd0, comparator_iq[31-:12]}),
  .pwm(pwm)
  );

  model_boost_l1 #(
  .MODEL_DATA_WIDTH(`data_width),
  .MODEL_DATA_WIDTH_DECIMAL(`data_width_decimal)
  ) dut (
  .aclk(aclk), 
  .resetn(resetn), 
  .ce(ce),
  .s1(pwm),
  .kL(r_kL),
  .kC(r_kC),
  .kR(r_kR),
  .vdc(r_vdc),
  .iL(meas_iL),
  .vL(meas_vL),
  .iC(meas_iC),
  .iO(meas_iO),
  .vO(meas_vO)
  );

  initial begin
    $dumpfile ("boost_test.vcd"); // Change filename as appropriate. 
    $dumpvars();

    ts = 0.000000001*`cecycle;
    L = 0.0001;
    C = 0.00033;
    R = 5;
    vdc = 100;
    reference = 150;
    kp = 0.05;
    ki = 20*ts;
    period = 100;
    max = period-10;

    kL = ts/L;
    r_kL = kL * 2**`data_width_decimal;
    kC = ts/C;
    r_kC = kC * 2**`data_width_decimal;
    kR = 1/R;
    r_kR = kR * 2**`data_width_decimal;   
    r_vdc = vdc * 2**`data_width_decimal;   
    r_reference = reference * 2**`data_width_decimal; 
    r_kp = kp * 2**`data_width_decimal; 
    r_ki = ki * 2**`data_width_decimal; 
    r_max = max * 2**`data_width_decimal; 

    resetn <= 1'b0;

    #(4*`clkcycle);

    resetn <= 1'b1;

    #(150*`_1ms);
    
    reference = 300;
    r_reference = reference * 2**`data_width_decimal; 
    
    #(150*`_1ms);
    $finish();
  end

endmodule