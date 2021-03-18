function simulatedTankPlot(time, h1, h2, zp1, zp2, goalH2Array, maxH)
%% simulatedTankPlot: (time, h1, h2, zp1, zp2, goalH2Array, maxH)
%
% Description: Plots / Simulates the tank experiment.
%
% Note: -
%
% Inputs:
%     time        ... Time (Vector)
%     h1          ... Heihgt tank 1 (Vector)
%     h2          ... Heihgt tank 2 (Vector)
%     zp1         ... Pump voltage / inflow intensity #1 (Vector)
%     zp2         ... Pump voltage / inflow intensity #2 (Vector)
%     goalH2Array ... [Optional] Goal / reference for h2 (Const)
%     maxH        ... [Optional] Max height before overflow (Const)
%
% Returns:
%     -
%
% $ Revision: R2018b
% $ Author: Knoll Sebastian
% $ Contact: matlab@sebastianknoll.net
% $ Date: 14.11.2020
%---------------------------------------------------------

border = 20;
tankDistance = 80;
pumpDistance = 20;

tzp1 = sqrt(h1);
tzp2 = sqrt(h2);

tank2.x1 = border;
tank2.y1 = 0;
tank2.level = 20;
tank2.outflow = 0;
tank2 = completeTank(tank2);

tank1.x1 = border;
tank1.y1 = tank2.y2 + tankDistance;
tank1.level = 50;
tank1.outflow = 0;
tank1 = completeTank(tank1);

pump1.x1 = tank1.x2 - 10;
pump1.y1 = tank1.y2 + pumpDistance;
pump1.outflow = 0;
pump1 = completePump(pump1, tank1);

pump2.x1 = tank2.x2 - 10;
pump2.y1 = tank2.y2 + pumpDistance;
pump2.outflow = 0;
pump2 = completePump(pump2, tank2);

inter = [tank1.x1, tank2.x1, tank1.x2, tank2.x2, pump1.x1];
xMin = min(inter); xMax = max(inter);
inter = [tank1.y1, tank2.y1, tank1.y2, tank2.y2, pump1.y1];
yMin = min(inter); yMax = max(inter);

scale1 = 0.9*tank1.height/max(h1);
scale2 = 0.9*tank2.height/max(h2);

fig = figure(100);

try
    for index = 1:length(time)

        tank2.level = h2(index)*scale2;
        tank2.outflow =  tzp2(index)*tank2.maxOutflow/max(tzp2);
        tank2 = completeTank(tank2);

        tank1.level = h1(index)*scale1;
        tank1.outflow = tzp1(index)*tank1.maxOutflow/max(tzp1);
        tank1 = completeTank(tank1);

        pump2.outflow = zp2(index)*pump2.maxOutflow/max(zp2);
        pump1.outflow = zp1(index)*pump1.maxOutflow/max(zp1);

        pump1 = completePump(pump1, tank1);
        pump2 = completePump(pump2, tank2);

        clf(fig);
        hold on;
        pump1.draw();
        pump2.draw();
        tank1.draw(tankDistance+tank2.height-tank2.level); 
        tank2.draw(border);
        xlim([xMin-border xMax+border]); ylim([yMin-border yMax+border]);

        if exist('goalH2Array', 'var')

            goalH2 = goalH2Array(min(end, index));
            goal = goalH2*scale2;
            plot([tank2.x1, tank2.x2], tank2.y1+goal*[1, 1], 'b--');
        end

        if exist('maxH', 'var')
            goal = maxH*scale2;
            plot([tank2.x1, tank2.x2], tank2.y1+goal*[1, 1], 'r-.');

            if tank2.level >= maxH*scale2
                text(5, tank2.y1, 'Overflow :0');
            end

            goal = maxH*scale1;
            plot([tank1.x1, tank1.x2], tank1.y1+goal*[1, 1], 'r-.');

            if tank1.level >= maxH*scale1
                text(5, tank1.y1, 'Overflow :0');
            end
        end

        drawnow()

    end
catch ME
end

end

function pump = completePump(pump, relTank)
    
    pump.thickness = 5;
    pump.maxOutflow = pump.thickness;
    pump.height = 10;
    pump.length = 30;
    
    pump.draw1 = @() rectangle('Position', [pump.x1, pump.y1, pump.thickness, pump.height], 'EdgeColor', 'k', 'LineWidth', 2, 'FaceColor', 'k');
    pump.draw2 = @() rectangle('Position', [pump.x1, pump.y1+pump.height, pump.length, pump.thickness], 'EdgeColor', 'k', 'LineWidth', 2, 'FaceColor', 'k');

        
    if pump.outflow > 0
        height = pump.y1 - relTank.y1 - relTank.level;
        pump.drawOutflow = @() rectangle('Position', [pump.x1+(pump.thickness-pump.outflow)/2, pump.y1-height, min(pump.outflow, pump.thickness), max(height, pump.thickness)], 'FaceColor',[0 .5 .5]);
    else
        pump.drawOutflow = @() 0;
    end
    
    pump.draw = @() [pump.drawOutflow(), pump.draw1(), pump.draw2()];
end

function tank = completeTank(tank)

    tank.height = 100;
    tank.width = 30;
    
    tank.x2 = tank.x1 + tank.width;
    tank.y2 = tank.y1 + tank.height;
    tank.thickness = 2;
    tank.rect = [tank.x1 tank.y1 tank.width tank.height];
    
    tank.outlet = 5;
    tank.maxOutflow = tank.outlet;
    
    tank.drawTank = @() rectangle('Position', tank.rect, 'EdgeColor', 'k', 'LineWidth', tank.thickness);
    tank.drawOutlet = @() rectangle('Position', [tank.x1+tank.outlet tank.y1-tank.outlet tank.outlet tank.outlet], 'EdgeColor', 'k', 'LineWidth', tank.thickness);
    
    tank.fill = @() rectangle('Position', [tank.x1, tank.y1, tank.width, max(tank.level, 0)], 'FaceColor',[0 .5 .5]);
    
    if tank.outflow > 0
        tank.drawOutflow = @(height) rectangle('Position', [tank.x1+tank.outlet+(tank.outlet-tank.outflow)/2, tank.y1-height, min(tank.outflow, tank.outlet), max(height, tank.outlet)], 'FaceColor',[0 .5 .5]);
    else
        tank.drawOutflow = @(height) 0;
    end
    
    tank.draw = @(outflowHeight) [tank.fill(), tank.drawOutflow(outflowHeight), tank.drawTank(), tank.drawOutlet()];
end
