%% Init
close all;
clear;
clc;

set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultAxesXGrid','on');
set(groot,'defaultAxesYGrid','on');
set(groot,'defaultAxesFontSize',16)

get(0,'Factory');
set(0,'defaultfigurecolor',[1 1 1]);

%% Defines
m1 = 1; m2 = 1;
k1 = .5; k2 = .5;
c = .8;

A = [
    -k1/m1,      0,      -c/m1,      c/m1;
    0,      -k2/m2,       c/m2,     -c/m2;
    1,           0,          0,         0;
    0,           1,          0,         0
];

b = [1/m1; 0; 0; 0];

C = [0, 0, 1, 0;
     0, 0, 0, 1];
d = zeros(2, 1);

sys = ss(A, b, C, d);

t = linspace(0, 15, 1e3);
u = zeros(size(t));
u(t<2) = 5;

[z, tOut] = lsim(sys, u, t);

skipIdx = 10;
animateSystem(tOut(1:skipIdx:end), z(1:skipIdx:end, 1), z(1:skipIdx:end, 2))