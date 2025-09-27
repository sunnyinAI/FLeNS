clear
close all

% Set dataset name
dataset = 'phishing';  % Change this to the desired dataset name without the extension
arff_file = ['/MATLAB Drive/FedNS-main/datasets_clean/', dataset, '.arff'];  % Path to the uploaded ARFF file
mat_file = ['/MATLAB Drive/FedNS-main/datasets_clean/', dataset, '.mat'];

% Load the dataset
load(mat_file);

for j=2:size(X,2)
    temp1=abs(X(:,j));
    temp=max(temp1);
        for i=1:size(X,1)
            if (temp ~= 0)
                X(i, j) = X(i, j) / temp;
            end
        end
end


y = y';
num_feature=size(X,2);
total_sample=size(y,1);

if dataset == "covtype"
    mu = 1;
    no_workers = 200;
    rho=50;
    alpha=1;
    k = 20;
elseif dataset == "susy" 
    mu = 1;
    no_workers = 60;
    rho=50;
    alpha=1;
    k = 20;
elseif dataset == "cod-rna" 
    mu = 1;
    no_workers = 60;
    rho=50;
    alpha=1;
    k = 10;

elseif dataset == "phishing" % iter = 11
    mu = 1;
    no_workers = 40; 
    rho=0.1; 
    alpha=0.25;
    k = 17;
end

lambda_logistic = 1E-3;
num_iter = 100;
repeat = 3;

dataSamples_per_worker=floor(total_sample/no_workers);

total_sample =no_workers*dataSamples_per_worker;

X_fede=X;
y_fede=y;
X_fede = double(X_fede);
y_fede = double(y_fede);

[obj_snewton]=standard_newton...
    (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter,lambda_logistic);
obj0 = obj_snewton(end);

% Initialize variables to store time for each method
time_FedNS = zeros(1, repeat);
time_FedNDES = zeros(1, repeat);
time_FleNS = zeros(1, repeat);
time_FedNewton = zeros(1, repeat);
time_GD = zeros(1, repeat);
time_znewton = zeros(1, repeat);
time_newton_aadmm_Hk = zeros(1, repeat);

for i = 1:repeat
    % Time for FedNS
    tic;
    [obj_FedNS(:, i), loss_FedNS(:, i), ~] = FedNS...
        (X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k, "Gaussian", mu);
    time_FedNS(:, i) = toc;  % Record time

    % Time for FedNDES
    tic;
    [obj_FedNDES(:, i), loss_FedNDES(:, i), ~] = FedNDES...
        (X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, 2 * k, "Gaussian", mu);
    time_FedNDES(:, i) = toc;  % Record time

    % Time for FleNS
    tic;
    [obj_FedNDES(:, i), loss_FleNS(:, i), ~] = FleNS...
        (X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, 2 * k, "Gaussian", mu);
    time_FleNS(:, i) = toc;  % Record time

    % Time for FedNewton
    tic;
    [obj_FedNewton(:, i), loss_FedNewton(:, i), ~] = FedNewton...
        (X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic);
    time_FedNewton(i) = toc;  % Record time

    % Time for GD
    tic;
    [obj_GD(:, i), loss_GD(:, i), ~] = GD...
        (X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic);
    time_GD(i) = toc;  % Record time

    % Time for znewton
    tic;
    [obj_znewton(:, i), loss_znewton(:, i), ~] = newton_zero...
        (X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic);
    time_znewton(i) = toc;  % Record time

    % Time for newton_ADMM_Hk
    tic;
    [obj_newton_aadmm_Hk(:, i), loss_newton_aadmm_Hk(:, i), ~] = newton_ADMM_Hk...
        (X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, rho, alpha);
    time_newton_aadmm_Hk(i) = toc;  % Record time
end

% Save the results including the time information
save(['/MATLAB Drive/FedNS-main/results_new/', dataset, '_data_comparison_with_time.mat'], 'repeat', 'loss_FedNS', 'loss_FedNDES', 'loss_FleNS', 'time_FedNS', 'time_FedNDES', 'time_FleNS', 'time_FedNewton', 'time_GD', 'time_znewton', 'time_newton_aadmm_Hk');
%{
for i = 1:repeat
    [obj_FedNS(:, i), loss_FedNS(:, i), ~]=FedNS...
        (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k, "Gaussian", mu);

    [obj_FedNDES(:, i), loss_FedNDES(:, i), ~]=FedNDES...
        (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, 2*k, "Gaussian", mu);

    [obj_FedNDES(:, i), loss_FleNS(:, i), ~]=FleNS...
        (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, 2*k, "Gaussian", mu);

    [obj_FedNewton(:, i), loss_FedNewton(:, i), ~]=FedNewton...
        (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic);

    [obj_GD(:, i), loss_GD(:, i), ~]=GD...
        (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic);

    [obj_znewton(:, i), loss_znewton(:, i), ~]=newton_zero...
        (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic);

    [obj_newton_aadmm_Hk(:, i), loss_newton_aadmm_Hk(:, i), ~]=newton_ADMM_Hk...
        (X_fede,y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, rho, alpha);
end

h = figure(1);
semilogy(mean(loss_GD, 2),'LineWidth',2);
hold on
semilogy(mean(loss_FedNewton, 2),'LineWidth', 2);
semilogy(mean(loss_znewton, 2),'k','LineWidth', 2);
semilogy(mean(loss_newton_aadmm_Hk, 2),'LineWidth',2);
semilogy(mean(loss_FedNS, 2),'LineWidth',2);
semilogy(mean(loss_FedNDES, 2),'LineWidth',2);
semilogy(mean(loss_FleNS, 2),'LineWidth',2);

xlabel({'Number of communication rounds'},'fontsize',16,'fontname','Times New Roman')
ylabel('$f(x^t) - f(x^*)$','Interpreter','latex','fontsize', 16, 'fontweight','bold')
legend({'FedAvg', 'FedNewton', 'FedNL', 'FedNew', 'FedNS', 'FedNDES', 'FleNS'},'fontsize', 16, 'Location', 'best');
ylim([1E-13 1E4]) 
set(gca,'fontsize',14,'fontweight','bold');
print(h, ['/MATLAB Drive/FedNS-main/Comparison_Results/', dataset, '.pdf'], '-dpdf','-r600')

save(['/MATLAB Drive/FedNS-main/Comparison_Results/', dataset, '_data.mat'],'loss_znewton', 'loss_newton_aadmm_Hk', 'loss_GD', 'loss_FedNewton', 'loss_FedNS', 'loss_FedNDES', 'loss_FleNS')
%}