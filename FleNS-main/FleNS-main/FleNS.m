function [obj_FleNS, loss_FleNS, transmitted_bits]=FleNS...
    (XX,YY, no_workers, num_feature, noSamples, num_iter, obj0, lambda_logistic, m, method, mu)


s1=num_feature;
s2=noSamples;
grads=ones(num_feature,no_workers);
alpha = 0.0001;
w=zeros(s1,1);

max_iter = num_iter;
N = 10000;

    % Step 1: Local Gradient Computation and Sketching
    
    % Loop over iterations
    for t = 1:max_iter
        % For each worker j
        transmitted_bits(t) = t*num_feature*32;
    
        for j = 1:no_workers
            % Extract local data (XX_j and YY_j)
            first = (j-1)*s2+1;
            last = first + s2 - 1;
            
            % Compute local gradient: g_{D_j,t} = 1/n_j * sum(∇L(f(w; x_ij), y_ij)) + λw_t
            grads(:, j) = -(XX(first:last, 1:num_feature)' * (YY(first:last) ./ (1 + exp(YY(first:last) .* (XX(first:last, 1:num_feature) * w)))) ) + lambda_logistic * w;
            
            % Apply sketching to the Hessian's feature dimension: \hat{H}_{D_j,t}
            S(:, :, j) = gen_sketch_mat(m, num_feature, method);  % Using SJLT, Gaussian, etc.
            temp_hessian = lambda_logistic * eye(num_feature, num_feature);  % Initialize Hessian
            
            % Compute Hessian: H_j = sum( second derivatives based on data )
            for k = first:last
                temp_hessian = temp_hessian + YY(k)^2 * (XX(k, :)' * XX(k, :)) * (exp(YY(k) * XX(k, :) * w) / (1 + exp(YY(k) * XX(k, :) * w))^2);
            end
            
            % Apply sketching: \hat{H}_{D_j,t} = S_j^T * sqrtm(H_j) * S_j
            Hessian(:, :, j) = S(:, :, j) * sqrtm(temp_hessian);
            sketchHessian(:, :, j) = Hessian(:,:,j)' * Hessian(:,:,j);
            % disp(size(sketchHessian(:, :, j)));
        end
    
    
    
    % Step 2: Nesterov's Acceleration
    
        % Nesterov's Acceleration: v_{t+1} = w_t + β_t (w_t - w_{t-1})
        if t > 1
            beta_t = (t - 1) / (t + 2);  % Compute Nesterov's acceleration coefficient
            v = w + beta_t * (w - w_old);  % Update v_t
        else
            v = w;  % For the first iteration, v = w
        end
        w_old = w;  % Keep track of the previous weight
    
    
    
    % Step 3: Communication to the Global Server
    
        % Transmit sketched Hessian and gradients to the global server
        for j = 1:no_workers
            % Upload H_j and g_j to the global server
            transmitted_Hessian(:, :, j) = sketchHessian(:, :, j);
            transmitted_grads(:, j) = grads(:, j);
        end
    
    
    
    
    % Step 4: Aggregation at Global Server
        % Global Aggregation at the server
        global_Hessian = zeros(num_feature, num_feature);
        global_grad = zeros(num_feature, 1);
        
        for j = 1:no_workers
            % Aggregate Hessians: H_t = sum(n_j/N * \hat{H}_{D_j,t})
            global_Hessian = global_Hessian + (noSamples / N) * transmitted_Hessian(:, :, j);
            
            % Aggregate gradients: g_t = sum(n_j/N * g_{D_j,t})
            global_grad = global_grad + (noSamples / N) * transmitted_grads(:, j);
        end
    
    
    
       %Step 5: Global Model Update
    
        % Global Model Update: w_{t+1} = w_t - μ H_t^(-1) g_t
        w = w - mu * (global_Hessian \ global_grad);
    
        final_obj =lambda_logistic*0.5*norm(w)^2;
    
        for ii =1:no_workers
            first = (ii-1)*s2+1;
            last = first+s2-1;
            %final_obj = final_obj + 0.5*norm(XX(first:last,1:s1)*out_central - YY(first:last))^2;
            final_obj = final_obj+sum(log(1+exp(-YY(first:last).*(XX(first:last,1:s1)*w))));
        end
        
        % Send the updated global model w back to the workers
        % (Implicit communication step in code, as 'w' is used by all workers)
        obj_FleNS(t)=final_obj;
        loss_FleNS(t)=abs(final_obj-obj0);
    end
end