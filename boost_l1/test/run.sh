
iverilog -o testbench.vvp -s boost_l1_tb boost_l1_tb.sv pwm_l1.v pi_l1.v ../src/model_boost_l1.v
vvp testbench.vvp

rm testbench.vvp
