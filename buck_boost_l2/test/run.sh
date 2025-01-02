
iverilog -o testbench.vvp -s buck_boost_l2_tb buck_boost_l2_tb.sv pwm_l1.v pi_l1.v ../src/model_buck_boost_l2.v
vvp testbench.vvp

rm testbench.vvp
