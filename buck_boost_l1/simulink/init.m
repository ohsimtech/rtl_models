
close all
clear all
clc

ts = 1e-6;

L = 100e-6;
C = 330e-6;
R = 5;

vin = 100;

kp = 0;
ki = 20;
fsw =10e3;

% sim("buck_boost_l1.slx")