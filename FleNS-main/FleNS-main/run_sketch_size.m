clear
close all
% clear;
% close all;

% Set dataset name
dataset = 'susy';  % Change this to the desired dataset name without the extension
mat_file = ['/MATLAB Drive/FedNS-main/datasets_clean/', dataset, '.mat'];

% Load the dataset
load(mat_file);

% Normalizing the dataset
for j = 2:size(X, 2)
    temp1 = abs(X(:, j));
    temp = max(temp1);
    for i = 1:size(X, 1)
        if (temp ~= 0)
            X(i, j) = X(i, j) / temp;
        end
    end
end

y = y';
% Parameters based on dataset name
num_feature = size(X, 2);
total_sample = size(y, 1);

if dataset == "covtype"
    mu = 1;
    no_workers = 200;
    rho = 50;
    alpha = 1;
    k = 20;
    num_iter = 3;
    sketch_size = 5:2:23;
elseif dataset == "susy"
    mu = 1;
    no_workers = 60;
    rho = 50;
    alpha = 1;
    k = 15;
    num_iter = 15;
    sketch_size = 3:3:30;
elseif dataset == "cod-rna"
    mu = 1;
    no_workers = 60;
    rho = 50;
    alpha = 1;
    k = 15;
    num_iter = 15;
    sketch_size = 3:3:30;
elseif dataset == "phishing" % iter = 11
    mu = 1;
    no_workers = 40;
    rho = 0.1;
    alpha = 0.25;
    k = 17;
    num_iter = 10;
    sketch_size = 10:5:50;
end

lambda_logistic = 1E-3;
repeat = 1;

dataSamples_per_worker = floor(total_sample / no_workers);
total_sample = no_workers * dataSamples_per_worker;

X_fede = X;
y_fede = y;
y_fede = double(y_fede);
X_fede = double(X_fede);

% Execute standard newton method
[loss_snewton] = standard_newton(X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, lambda_logistic);
obj0 = loss_snewton(end);

% Initialize arrays to store time taken for each method
time_FedNS = zeros(length(sketch_size), 1);
time_FedNDES = zeros(length(sketch_size), 1);
time_FleNS = zeros(length(sketch_size), 1);

% Execute FedNS and FedNDES methods
for j = 1:length(sketch_size)
    for i = 1:repeat
        k = sketch_size(j);

        % Time for FedNS
        tic;
        [~, loss, ~] = FedNS(X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k, "Gaussian", mu);
        time_FedNS(j) = toc;
        loss_FedNS(j, i) = loss(end);
        
        % Time for FedNDES
        tic;
        [~, loss, ~] = FedNDES(X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k + 5, "Gaussian", mu);
        time_FedNDES(j) = toc;
        loss_FedNDES(j, i) = loss(end);
        
        % Time for FleNS
        tic;
        [~, loss, ~] = FleNS(X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k + 5, "Gaussian", mu);
        time_FleNS(j) = toc;

        %[~, loss, ~] = FedNS(X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k, "Gaussian", mu);
        %loss_FedNS(j, i) = loss(end);
        %[~, loss, ~] = FedNDES(X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k + 5, "Gaussian", mu);
        %loss_FedNDES(j, i) = loss(end);
        %[~, loss, ~] = FleNS(X_fede, y_fede, no_workers, num_feature, dataSamples_per_worker, num_iter, obj0, lambda_logistic, k + 5, "Gaussian", mu);
        loss_FleNS(j, i) = loss(end);
    end
end

% Save results
save(['/MATLAB Drive/FedNS-main/results_new/', dataset, '_data_sketch_size_15.mat'], 'sketch_size', 'loss_FedNS', 'loss_FedNDES', 'loss_FleNS', 'time_FedNS', 'time_FedNDES', 'time_FleNS');
