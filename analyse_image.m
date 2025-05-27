%as usual
clc; clear; close all;

% Load data from CSV files
undeformed = readmatrix('undeformed.csv');
deformed = readmatrix('deformed_lh.csv');
nbPixelPerCm = readmatrix('scale.csv');

% Extract X and Y coordinates and scale them
% in our csv file, the coordinates are stored in the
% 6th and 7th column beginning on the second line

x0 = undeformed(2:end,6)/nbPixelPerCm - deformed(2,6)/nbPixelPerCm;
y0 = undeformed(2:end,7)/nbPixelPerCm - deformed(2,7)/nbPixelPerCm;
x1 = deformed(2:end,6)/nbPixelPerCm - deformed(2,6)/nbPixelPerCm;
y1 = deformed(2:end,7)/nbPixelPerCm - deformed(2,7)/nbPixelPerCm;

% Compute displacement vectors
dx = x1 - x0;
dy = y1 - y0;

% Compute total displacement magnitude
displacement = sqrt(dx.^2 + dy.^2);
displacement = displacement*10; % cm->mm

% Find the point of maximum displacement
[maxDisp, maxIdx] = max(displacement);
maxX = x0(maxIdx);
maxY = y0(maxIdx);

%--------------quiver plot (arrows)-----------------
figure; 
quiver(x0, y0, dx, dy, 0, 'r');
hold on;
scatter(x0, y0, 'bo');
scatter(x1, y1, 'gx');
xlabel('X [cm]'); ylabel('Y [cm]');
legend('Displacement Vectors', 'Initial Positions', 'Final Positions');
axis equal; grid on;
exportgraphics(gcf, 'quiver_plot_lh.png', 'Resolution', 300);

%--------------adjustable heat map------------------
% Define grid resolution
numPoints = 1000;
xq = linspace(min(x0), max(x0), numPoints);
yq = linspace(min(y0), max(y0), numPoints);
[Xq, Yq] = meshgrid(xq, yq);

% Interpolate displacement magnitude over the grid
Vq = griddata(x0, y0, displacement, Xq, Yq, 'cubic');

% Plot the interpolated displacement field
figure;
contourf(Xq, Yq, Vq, 20, 'LineColor', 'none');
hold on;
scatter(x0, y0, 30, displacement, 'filled', 'MarkerEdgeColor', 'k'); % Original points
colorbarHandle = colorbar;
ylabel(colorbarHandle, 'Displacement [mm]');
plot(maxX, maxY, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(maxX, maxY, sprintf('  %.2f mm', maxDisp), 'Color', 'red', 'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
xlabel('X [cm]'); ylabel('Y [cm]');
axis equal; grid on;
exportgraphics(gcf, 'heatmap_1_lh.png', 'Resolution', 300);

%---------------smooth heat map-------------------
F = scatteredInterpolant(x0, y0, displacement, 'natural');
Vqs = F(Xq, Yq);

% Plot smooth deformation map
figure;
imagesc(xq, yq, Vqs); % Display as an image
set(gca, 'YDir', 'normal');
colorbarHandle = colorbar;
ylabel(colorbarHandle, 'Displacement [mm]');
hold on;
plot(maxX, maxY, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(maxX, maxY, sprintf('  %.2f mm', maxDisp), 'Color', 'red', 'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
xlabel('X [cm]'); ylabel('Y [cm]');
axis equal; grid on;
exportgraphics(gcf, 'heatmap_2_lh.png', 'Resolution', 300);
