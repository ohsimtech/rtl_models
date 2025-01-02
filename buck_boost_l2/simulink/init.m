
close all
clear all
clc

L = 100e-6;
RL = 10e-3;
C = 60e-6;
RC = 2e-3;
R = 5;

vin = 100;

kp = 0;
ki = 20;
fsw = 25e3;

ts = 1e-6;

sim("buck_boost_l2")