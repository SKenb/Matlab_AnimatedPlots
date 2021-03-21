%% Init
clear;
close all;
clc;

%% Defines
% Define two arbitrary traces for z & y
t = 0:.01:10;

fy = 1;
y = 2 + cos(2*pi*fy*t);

fi = 6;
i = 1 + sin(2*pi*fi*t);

%% Animation
% Iterate over time and plot each time the expirement

fig = figure();
try
    for index = 1:length(t)

        clf(fig); 
        magnetExperimentPlot(y, index, i);
        drawnow();

    end
catch ME
end