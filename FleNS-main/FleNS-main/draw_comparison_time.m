% Load the .mat file (replace with the correct variable names as necessary)
dataset = 'phishing';
load(['/MATLAB Drive/FedNS-main/results_new/', dataset, '_data_comparison_with_time.mat'], 'sketch_size', 'loss_FedNS', 'loss_FedNDES', 'loss_FleNS', 'time_FedNS', 'time_FedNDES', 'time_FleNS', 'time_FedNewton', 'time_GD', 'time_znewton', 'time_newton_aadmm_Hk')

% Plotting the times for all methods in a single graph
figure;
plot(1:repeat, time_FedNS, '-o', 'LineWidth', 2);    % Plot for FedNS
hold on;
plot(1:repeat, time_FedNDES, '-x', 'LineWidth', 2);  % Plot for FedNDES
plot(1:repeat, time_FleNS, '-s', 'LineWidth', 2);    % Plot for FleNS
plot(1:repeat, time_FedNewton, '-d', 'LineWidth', 2);% Plot for FedNewton
plot(1:repeat, time_GD, '-^', 'LineWidth', 2);       % Plot for GD
plot(1:repeat, time_znewton, '-v', 'LineWidth', 2);  % Plot for Newton Zero
plot(1:repeat, time_newton_aadmm_Hk, '-p', 'LineWidth', 2); % Plot for Newton AADMM Hk


% Define the font style
fontStyle = 'Times New Roman';

% Customize axes and labels
% X and Y labels with consistent font style and size
xlabel('Iteration', 'fontsize', 14, 'FontName', fontStyle)
ylabel('Time (Seconds)', 'fontsize', 14, 'FontName', fontStyle)

% Add legend to distinguish between the plots
legend({'FedNS', 'FedNDES', 'FleNS', 'FedNewton', 'GD', 'Newton Zero', 'Newton AADMM Hk'}, 'fontsize', 14, 'Location', 'best');

% Add title and grid for clarity
title('Time taken by each method over iterations', 'fontsize', 16);
grid on;

% Adjust font size for better readability
set(gca, 'fontsize', 14);

% Save plot as PNG
saveas(gcf, ['/MATLAB Drive/FedNS-main/results_new/time_comparison_', dataset, '.png']);
