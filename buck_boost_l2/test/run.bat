
iverilog -o testbench.vvp -s buckboost_tb buck_boost_tb.sv pwm.v buck_boost.v pi.v
vvp testbench.vvp
