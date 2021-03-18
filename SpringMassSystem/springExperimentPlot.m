function springExperimentPlot(z, y, zBounds, yBounds, yTrace, yIndex)
%% springExperimentPlot: (z, y, zBounds, yBounds)
%
% Description: Plots the spring experiment / feder mass system
%              into the current figure.
%
% Note: Maybe the use of classes for the elements is more appropriate.
%
% Inputs:
%     z         ... Trace of z (Length of rope from motor to spring)
%     y         ... Trace of y (Length of rope from mass to role)
%     zBounds   ... Bounds of z : [min(z), max(z)]
%     yBounds   ... Bounds of y : [min(y), max(y)]
%     yTrace    ... [Optional] Trace of y for plotting next to Bird.
%     yIndex    ... [Optional] Current index of y for plotting next to Bird.
%
% Returns:
%     -
%
% $ Revision: R2018b
% $ Author: Knoll Sebastian
% $ Contact: matlab@sebastianknoll.net
% $ Date: 14.03.2021
%---------------------------------------------------------

%% Defines
% max delta of data to simulate
deltaZ = abs(diff(zBounds));
deltaY = abs(diff(yBounds));

% max positions for plot
motorToSpringMinMax = [5, 12];
roleToBirdMinMax = [10, 40];

% determine draw ratio (trace to draw length)
zDrawRatio = abs(diff(motorToSpringMinMax)) / deltaZ;
yDrawRatio = abs(diff(roleToBirdMinMax)) / deltaY;
drawRatio = min([zDrawRatio, yDrawRatio]);

% ---------------------------------------------------------------------
% Bird / Mass
bird.width = 2;
bird.height = 2;
bird.faceColor = [0 .5 .5];
bird.colorString = 'k';
bird.lineWidth = 2;

% ---------------------------------------------------------------------
% Role / Upper role
role.diameter = 4;
role.anchorVertRope = [0; 40];
role.anchorMotorRopeAngle = 60;
role.colorString = 'k';
role.lineWidth = 2;

role = addRoleStuff(role);

% ---------------------------------------------------------------------
% Motor
motor.height = 0;
motor.diameter = 4;
motor.colorString = 'k';
motor.lineWidth = 2;

motor = addMotorStuff(motor);

dif = role.anchorMotorRope - motor.ropeAnchor(role);
drawAngle = atan(dif(2)/dif(1))*180/pi;
drawMotorRoleLength = norm(dif);

% ---------------------------------------------------------------------
% Spring
spring.anchorLeft = [1; 0];
spring.length = 10;
spring.twists = 5;
spring.diameter = 4;
spring.anchorLength = 2;
spring.colorString = 'k';
spring.lineWidth = 2;
spring.rotationAngle = drawAngle;

spring = addSpringStuff(spring);

anchorRoleRope = role.anchorMotorRope;
anchorMotorRope = motor.ropeAnchor(role);

% -------------------------------------------------------------------------
% Motor to spring line
drawZ = drawRatio*z;
motorSpringLineLength = motorToSpringMinMax(1) + drawZ;

spring.length = drawMotorRoleLength - drawRatio*z - drawRatio*(roleToBirdMinMax(2) - y);
spring.anchorLeft = anchorMotorRope + motorSpringLineLength * [cos(drawAngle*pi/180); sin(drawAngle*pi/180)];

% ---------------------------------------------------------------------
% Asign everthing again :S
spring = addSpringStuff(spring);
motor = addMotorStuff(motor);
role = addRoleStuff(role);

% ---------------------------------------------------------------------
%% Draw - add it to current figure
%figure;
hold on; axis equal;
xlim([-40, 20]); ylim([-5, 50]);
spring.plot();
role.plot();
motor.plot(role);
% Draw theoretical line
plot([anchorMotorRope(1), anchorRoleRope(1)], [anchorMotorRope(2), anchorRoleRope(2)], 'k--', 'LineWidth', 1)
% Draw motor -> spring line
plot([anchorMotorRope(1), spring.anchorLeft(1)], [anchorMotorRope(2), spring.anchorLeft(2)], spring.colorString, 'LineWidth', spring.lineWidth);

% Draw spring -> role line
springAnchorRight = spring.getRightAnchor();
plot([springAnchorRight(1), anchorRoleRope(1)], [springAnchorRight(2), anchorRoleRope(2)], spring.colorString, 'LineWidth', spring.lineWidth);
% Draw role -Y bird line
plot([role.anchorVertRope(1), role.anchorVertRope(1)], [role.anchorVertRope(2), role.anchorVertRope(2) - roleToBirdMinMax(1) - drawRatio*y], spring.colorString, 'LineWidth', spring.lineWidth);
rectangle(  'Position',[role.anchorVertRope(1) - bird.width/2, role.anchorVertRope(2) - roleToBirdMinMax(1) - drawRatio*y - bird.height, bird.width, bird.height], ...
            'FaceColor', bird.faceColor, ...
            'EdgeColor', bird.colorString, ...
            'LineWidth', bird.lineWidth);

% Trace [Optional]
if exist('yTrace', 'var') && exist('yIndex', 'var')
    border = 5;
    fA = flip(yTrace(1:yIndex));
    t = 1:length(fA);
    
    plot(t, role.anchorVertRope(2) - roleToBirdMinMax(1) - drawRatio*fA - bird.height / 2, '--', 'Color', bird.faceColor, 'LineWidth', 2);
    plot(t(border:end),  role.anchorVertRope(2) - roleToBirdMinMax(1) - drawRatio*fA(border:end) - bird.height / 2, 'Color', bird.faceColor, 'LineWidth', 2);
end
% ---------------------------------------------------------------------
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

function role = addRoleStuff(role) 

    role.getPos = @() [ role.anchorVertRope(1)-role.diameter, ...
                        role.anchorVertRope(2)-role.diameter / 2, ...
                        role.diameter, role.diameter];


    role.rotation = @() role.anchorMotorRopeAngle * pi / 180;
    role.anchorMotorRope = role.anchorVertRope - role.diameter / 2*[1; 0] + role.diameter / 2*[-sin(role.rotation()); cos(role.rotation())];

    role.plotAnchorMotorRope = @() scatter(role.anchorMotorRope(1), role.anchorMotorRope(2), 'rx', 'LineWidth', role.lineWidth);
    role.plotRole = @() rectangle('Position', role.getPos(), 'Curvature', [1, 1], ...
                               'LineWidth', role.lineWidth, ...
                               'EdgeColor', role.colorString);

    %role.plot = @() [role.plotRole(), role.plotAnchorMotorRope()];
    role.plot = @() [role.plotRole()];
end

function motor = addMotorStuff(motor) 

    inlineIndex = @(x, dim) x(dim);
    motor.getPos = @(relToRole)  [relToRole.anchorMotorRope(1)-(relToRole.anchorMotorRope(2) - motor.height -  motor.diameter/2*sin(relToRole.rotation())) / tan(relToRole.rotation()) - motor.diameter/2 - motor.diameter/2*cos(relToRole.rotation()), ...
                                  motor.height, ...
                                  motor.diameter, motor.diameter];

    motor.ropeAnchor = @(relToRole) [inlineIndex(motor.getPos(relToRole), 1) + motor.diameter/2 + motor.diameter/2*sin(relToRole.rotation()); ...
                                     inlineIndex(motor.getPos(relToRole), 2) + motor.diameter/2*cos(relToRole.rotation())];

    motor.plotGeneric = @(relToRole, cur) rectangle('Position', motor.getPos(relToRole), ...
                                                    'Curvature', cur, ...
                                                    'LineWidth', motor.lineWidth, ...
                                                    'EdgeColor', motor.colorString);

    motor.plotDrawAnchor = @(relToRole) scatter(inlineIndex(motor.getPos(relToRole), 1), ...
                                                inlineIndex(motor.getPos(relToRole), 2), ...
                                                'rx', 'LineWidth', motor.lineWidth);

    motor.plotRopeAnchor = @(relToRole) scatter(inlineIndex(motor.ropeAnchor(relToRole), 1), ...
                                                inlineIndex(motor.ropeAnchor(relToRole), 2), ...
                                                'rx', 'LineWidth', motor.lineWidth);

    motor.plotRect = @(relToRole) motor.plotGeneric(relToRole, [0, 0]);
    motor.plotRole = @(relToRole) motor.plotGeneric(relToRole, [1, 1]);

    %motor.plot = @(relToRole) [motor.plotRect(relToRole), motor.plotRole(relToRole), motor.plotRopeAnchor(relToRole), motor.plotDrawAnchor(relToRole)];
    motor.plot = @(relToRole) [motor.plotRect(relToRole), motor.plotRole(relToRole)];

end

end

