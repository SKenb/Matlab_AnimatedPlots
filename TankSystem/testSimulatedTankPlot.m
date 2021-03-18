%% Init
clear;
close all;
clc;

%% Defines
% Define two arbitrary traces for h1 % h2 (6 zp1, zp2)

t = 0:.01:10;

f1 = 6;
h1 = 1 + sin(2*pi*f1*t);
zp1 = 1 + cos(2*pi*f1*t);

f2 = 5;
h2 = 1 + cos(2*pi*f2*t);
zp2 = 1 + sin(2*pi*f2*t);

%% Animation

%simulatedTankPlot(t, h1, h2, zp1, zp2)
simulatedTankPlot(t, h1, h2, zp1, zp2, mean(h1), mean(h1)+std(h1))
