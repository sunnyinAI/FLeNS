% Load the .mat file (replace with the correct variable names as necessary)
dataset = 'susy';
load(['/MATLAB Drive/FedNS-main/results_new/' , dataset, '_data_sketch_size.mat'], 'sketch_size', 'loss_FedNS', 'loss_FedNDES', 'loss_FleNS', 'time_FedNS', 'time_FedNDES', 'time_FleNS')

h = figure(1);
% Plot time taken by each method
figure;
plot(sketch_size, time_FedNS, '-o', 'LineWidth', 2);    % Plot for FedNS
hold on;
plot(sketch_size, time_FedNDES, '-x', 'LineWidth', 2);  % Plot for FedNDES
hold on;
plot(sketch_size, time_FleNS, '-s', 'LineWidth', 2);    % Plot for FleNS

% Define the font style
fontStyle = 'Times New Roman';

% Customize axes and labels
% X and Y labels with consistent font style and size
xlabel('Sketch size', 'fontsize', 14, 'FontName', fontStyle)
ylabel('Time (Seconds)', 'fontsize', 14, 'FontName', fontStyle)

% Add legend to distinguish between the plots
legend({'FedNS', 'FedNDES', 'FleNS'}, 'fontsize', 14, 'Location', 'best');

% Add title and grid for clarity
title('SUSY', 'fontsize', 16);
grid on;

% Adjust font size for better readability
set(gca, 'fontsize', 14);

% Save plot as PNG
saveas(gcf, ['/MATLAB Drive/FedNS-main/results_new/time_vs_sketch_size_', dataset, '.png']);
