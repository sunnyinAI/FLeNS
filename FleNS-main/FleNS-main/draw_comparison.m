% Load the .mat file (replace with the correct variable names as necessary)
dataset = 'phishing';
data = load('/MATLAB Drive/FedNS-main/Comparison_Results/phishing_data.mat');

% Assuming the .mat file contains the relevant loss variables
% (You may need to adjust these based on the actual content of your .mat file)
loss_GD = data.loss_GD;
loss_FedNewton = data.loss_FedNewton;
loss_znewton = data.loss_znewton;
loss_newton_aadmm_Hk = data.loss_newton_aadmm_Hk;
loss_FedNS = data.loss_FedNS;
loss_FedNDES = data.loss_FedNDES;
loss_FleNS = data.loss_FleNS;

% Create the figure
h = figure(3);

% Plotting each algorithm's loss on a semilogarithmic plot
semilogy(mean(loss_GD, 2), 'LineWidth', 2); % Plot FedAvg (GD)
hold on
semilogy(mean(loss_FedNewton, 2), 'LineWidth', 2); % Plot FedNewton
semilogy(mean(loss_znewton, 2), 'k', 'LineWidth', 2); % Plot FedNL (zNewton)
semilogy(mean(loss_newton_aadmm_Hk, 2), 'LineWidth', 2); % Plot FedNew
semilogy(mean(loss_FedNS, 2), 'LineWidth', 2); % Plot FedNS
semilogy(mean(loss_FedNDES, 2), 'LineWidth', 2); % Plot FedNDES
semilogy(mean(loss_FleNS, 2), 'LineWidth', 2); % Plot FleNS

title(dataset)

% Labels and legend
xlabel({'No. of communication rounds'}, 'fontsize', 14);
ylabel('f(x^t) - f(x^*)', 'fontsize', 14);
legend({'FedAvg', 'FedNewton', 'FedNL', 'FedNew', 'FedNS', 'FedNDES', 'FleNS'}, 'fontsize', 14, 'Location', 'best');

% Y-axis limits for semilogy
ylim([1E-13 1E4]);

% Axis font and appearance settings
set(gca, 'fontsize', 14);
saveas(figure(1),[pwd '/Phishing2.png']);
% Saving the plot as a high-resolution PDF
print(h, ['/MATLAB Drive/FedNS-main/Comparison_Results/', dataset, '.pdf'], '-dpdf', '-r600');
