function magnetExperimentPlot(yTrace, index, iTrace)
%% springExperimentPlot: (yTrace, index, iTrace)
%
% Description: Plots the magnet experiment into the current figure.
%
% Note: Maybe the use of classes for the elements is more appropriate.
%
% Inputs:
%     yTrace    ... Trace of y (Position of ball)
%     index     ... Current index of y for plotting.
%     iTrace    ... [Optional] Trace of i
%
% Returns:
%     -
%
% $ Revision: R2021a
% $ Author: Knoll Sebastian
% $ Contact: matlab@sebastianknoll.net
% $ Date: 21.03.2021
%---------------------------------------------------------

%% Defines
yDrawMax = 10;
yDrawMin = 5;

drawRatio = (yDrawMax - yDrawMin) / (max(yTrace) - min(yTrace));

% ---------------------------------------------------------------------
% Magnet

magnet.position = [0; 0];
magnet.height = 10;
magnet.width = 6;
magnet.lineWidth = 2;
magnet.colorString = 'k';
magnet.wire.border = 2;
magnet.wire.lineWidth = 3;
magnet.wire.colorString = 'k';

% i Trace [Optional]
if exist('iTrace', 'var')
   lineWidthMin = 1; lineWidthMax = 5;
   ratio = (lineWidthMax - lineWidthMin) / (max(iTrace) - min(iTrace));
   magnet.wire.lineWidth = iTrace(index)*ratio;
end

magnet = addMagnetStuff(magnet);

% ---------------------------------------------------------------------
% Ball
ball.y = yTrace(index);
ball.size = 4;
ball.lineWidth = 2;
ball.colorString = 'k';

ball.plot = @() rectangle(  'Position', [magnet.position(1)-ball.size/2, ...
                                         magnet.position(2) - ball.y * drawRatio - ball.size, ...
                                         ball.size, ball.size], ...
                            'Curvature', [1, 1], ...
                            'LineWidth', ball.lineWidth, ...
                            'EdgeColor', ball.colorString);

% ---------------------------------------------------------------------
% Plot
hold on;

magnet.plot();
ball.plot();

% ---------------------------------------------------------------------
% Traces 
border = 30;
fA = flip(yTrace(1:index));
t = .1*(0:length(fA)-1);

plot(t, magnet.position(2) - fA*drawRatio, '--', 'Color', 'r', 'LineWidth', 2);
plot(t(border:end),  magnet.position(2) - fA(border:end)*drawRatio, 'Color', 'r', 'LineWidth', 2);



axis equal;
ylim([-15, yDrawMax + 5 + ball.size]); 
xlim([-15, yDrawMax + 5 + ball.size]);

% ---------------------------------------------------------------------
%% Functions

function magnet = addMagnetStuff(magnet)
    
    widthHalf = magnet.width / 2;
    magnet.plotRect = @() rectangle('Position', [magnet.position(1)-widthHalf, magnet.position(2), magnet.width, magnet.height], ...
                                    'Curvature', [.2, .2], ...
                                    'LineWidth', magnet.lineWidth, ...
                                    'EdgeColor', magnet.colorString);
    
    magnet.wire.anchorLeft = [magnet.position(1); magnet.position(2) + magnet.wire.border];
    magnet.wire.length = magnet.height - 2*magnet.wire.border;
    magnet.wire.twists = floor(magnet.wire.length);
    magnet.wire.diameter = magnet.width;
    magnet.wire.anchorLength = 0;
    magnet.wire.colorString = magnet.wire.colorString;
    magnet.wire.lineWidth = magnet.wire.lineWidth;
    magnet.wire.rotationAngle = 90;
    
    portYOffset = [0, magnet.wire.length];
    magnet.wire.plotPort = @(number) plot(magnet.position(1) + widthHalf*[1, 3], ...
                                          magnet.position(2) + magnet.wire.border + portYOffset(number) * [1, 1], ...
                                          magnet.wire.colorString, ...
                                          'LineWidth', magnet.wire.lineWidth);

    magnet.wire = addSpringStuff(magnet.wire);
    
    magnet.plot = @() [ magnet.plotRect(), magnet.wire.plot(), ...
                        magnet.wire.plotPort(1), magnet.wire.plotPort(2)];
end

% From BirdExperiment
function spring = addSpringStuff(spring)

    inlineIndex = @(x, dim) x(dim, :);
    inlineIndex2 = @(x, dim) x(:, dim);

    spring.getTwistLength = @() spring.length - 2*spring.anchorLength;
    spring.getTwistPoints = @() [spring.anchorLength + kron((0:spring.getTwistLength()/spring.twists:spring.getTwistLength()), [1, 1]); ...
                                 kron(spring.diameter/2*ones(1, spring.twists+1), [1, -1])];

    spring.roation = @() spring.rotationAngle*pi/180;
    spring.getRotationMatrix = @() [cos(spring.roation()), -sin(spring.roation()); ...
                                    sin(spring.roation()), cos(spring.roation())];

    spring.getPoints = @() spring.anchorLeft +  spring.getRotationMatrix() * ([0, spring.anchorLength, inlineIndex(spring.getTwistPoints(), 1), spring.length-spring.anchorLength, spring.length; ...
                                                                              0, 0, inlineIndex(spring.getTwistPoints(), 2), 0, 0]);
    spring.plot = @() plot(inlineIndex(spring.getPoints(), 1), inlineIndex(spring.getPoints(), 2), ...
                            spring.colorString, 'LineWidth', spring.lineWidth);

    spring.getLeftAnchor = @() [inlineIndex2(spring.getPoints(), 1)];
    spring.getRightAnchor = @() [inlineIndex2(spring.getPoints(), length(spring.getPoints()))];

end

end

