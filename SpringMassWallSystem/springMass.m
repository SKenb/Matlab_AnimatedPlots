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
m = 1;
k = 2;
q = 3;

A = [0, 1; -k/m, -q/m];
b = [0; 1/m];
c = [1, 0];
d = 0;

sys = ss(A, b, c, d);
G = tf(sys);


%% Transformation
T = [-1, 0; 0, 1/m];
Tinv = inv(T);

Ad = T*A*Tinv;
bd = T*b;
cd = c*Tinv;
dd = d;

sysT = ss(Ad, bd, cd, dd);
GT = tf(sysT);

%% Impulse

getSettingsStrcut = @(m, k, q) struct("m", m, "k", k, "q", q);

getSys = @(m, k, q) tf(ss([0, 1; -k/m, -q/m], [0; 1/m], [1, 0], 0));


for settings = [ ...
            getSettingsStrcut(1, 2, 3), ...
            getSettingsStrcut(1, 5, 2), ...
        ]

    [y, t] = impulse(getSys(settings.m, settings.k, settings.q));

    titleStr = strcat("$m = ", num2str(settings.m), "$, $k = ", num2str(settings.k), "$, $q = ", num2str(settings.q), "$");
    filename = strcat("m", num2str(settings.m), "_k", num2str(settings.k*1000), "_q", num2str(settings.q*1000), ".gif");

    animateMass(t, y, titleStr, filename);

end


