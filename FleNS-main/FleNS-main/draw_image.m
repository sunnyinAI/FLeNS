%clear
%close all

dataset = 'susy';

load(['/MATLAB Drive/FedNS-main/results/' , dataset, '_data_sketch_size.mat'], 'sketch_size', 'loss_FedNS', 'loss_FedNDES', 'loss_FleNS', 'time_FedNS', 'time_FedNDES', 'time_FleNS')

% Remove the last point from sketch_size and loss data
%sketch_size_trimmed = sketch_size(1:end-1);  % Remove last point
%loss_FleNS_trimmed = loss_FleNS(1:end-1, :);  % Remove last point's corresponding loss data

% Apply a moving average smoothing function
smoothed_loss_FleNS = smooth(median(loss_FleNS, 2), 0.7, 'moving'); % The second argument is the smoothing factor, adjust it as needed



h = figure(3);
%semilogy(median(loss_FedNS, 2),'LineWidth',2);
%hold on
%semilogy(median(loss_FedNDES, 2),'LineWidth',2);
%hold on
%semilogy(median(loss_FleNS, 2),'LineWidth',2);
semilogy(smoothed_loss_FleNS,'LineWidth',2);
title('SUSY')

% Set x-ticks and x-tick labels
xticks(1:length(sketch_size))
xticklabels(sketch_size)

%xticks(10:5:45)  % You can adjust the interval (e.g., 1:5:45 for ticks every 5 steps)
%xticklabels(sketch_size(10:5:50))  % Corresponding labels

% Define the font style
fontStyle = 'Times New Roman';

% X and Y labels with consistent font style and size
xlabel('Sketch size', 'fontsize', 14, 'FontName', fontStyle)
ylabel('f(x^t) - f(x^*)', 'fontsize', 14, 'FontName', fontStyle)

% Set y-axis limits to range from 10^0 to 10^-5
ylim([1e-2 1e1])

% Set x-axis limits with a gap (5% padding on each side)
x_min = min(1) - 0.05 * (length(sketch_size) - 1);  % Gap on left side
x_max = max(length(sketch_size)) + 0.05 * (length(sketch_size) - 1);  % Gap on right side
xlim([x_min, x_max])

% Legend with consistent font style and size
%legend({'FedNS', 'FedNDES', 'FleNS'}, 'fontsize', 14, 'FontName', fontStyle, 'Location', 'best')
legend({'FleNS'}, 'fontsize', 14, 'FontName', fontStyle, 'Location', 'best')

% Set axis font style and size
set(gca, 'FontSize', 14, 'FontName', fontStyle);
saveas(figure(1),[pwd '/phishingNEW.png']);
print(h, ['/MATLAB Drive/FedNS-main/results/', dataset, '_sketch_size.pdf'], '-dpdf','-r600')
