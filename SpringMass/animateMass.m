function animateMass(t, z, titleStr, filename , figureId)
%% animateMass(t, z, titleStr, filename , figureId)
%
% Description: Plots / Simulates the 2-mass-system.
%
% Note: -
%
% Inputs:
%     time        ... Time (Vector)
%     z           ... Position of mass
%     titleStr    ... [Optional] Title of plot
%     filename    ... [Optional] Filename for gif which is generated
%     figureId    ... [Optional] Figure ID
%
% Returns:
%     -
%
% $ Revision: R2025a
% $ Author: Knoll Sebastian
% $ Contact: matlab@sebastianknoll.net
% $ Date: 16.10.2025
%---------------------------------------------------------

    if ~exist('titleStr', 'var'), titleStr = "$m = ?$, $k = ?$, $q = ?$"; end
    if ~exist('filename', 'var'), filename = "CS2_Mass.gif"; end
    if ~exist('figureId', 'var'), figureId = 1; end

    delayTime = .1;

    z = 20 * z / max(z);
    zMax = max(z);

    for idx = 1:length(t)
        
        figure(figureId);
        plotFrame(z(idx), zMax);
    
        title(titleStr);

        frame = getframe(gcf); % Get the current frame
        img = frame.cdata; % Get the image data
        [imind, cm] = rgb2ind(img, 256); % Convert to indexed image

        if idx == 1
            imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
        else
            imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
        end

    end

end

function plotFrame(z, zMax)
    % consts
    offset = 20;

    % Spring
    spring.anchorLeft = [0; 2];
    spring.length = offset + z;
    spring.twists = 5;
    spring.diameter = 1;
    spring.anchorLength = 2;
    spring.colorString = 'k';
    spring.lineWidth = 2;
    spring.rotationAngle = 0;
    
    spring = addSpringStuff(spring);
   
    spring.plot()

    % Mass 
    width= 10;
    height = 2*spring.anchorLeft(2);
    rectangle('Position', [offset + z, 0, width, height], 'EdgeColor', 'b', 'LineWidth', 2);

    xlim([0, zMax+2*width+offset]);
    ylim([0, 3*spring.anchorLeft(2);])
end

%% Functions
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
