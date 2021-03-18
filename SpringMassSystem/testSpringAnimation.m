%% Init
clear all;
close all;
clc;

%% Defines
% Define two arbitrary traces for z & y
t = 0:.01:10;

fz = 6;
z = 1 + sin(2*pi*fz*t);

fy = 5;
y = 1 + cos(2*pi*fy*t);

%% Animation
% Iterate over time and plot each time the expirement

bounds = @(array) [floor(min(array)), ceil(max(array))];

fig = figure();
try
    for index = 1:length(t)

        clf(fig); 
        springExperimentPlot(10*z(index), 10*y(index), 10*bounds(z), 10*bounds(y), 10*y, index);
        drawnow();

    end
catch ME
end