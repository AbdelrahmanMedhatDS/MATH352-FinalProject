function [V_new, iterations, converged] = jacobiSolver(V, max_iterations, tolerance)
    % Improved Jacobi solver with convergence check
    % V: Initial voltage grid with boundary conditions
    % max_iterations: Maximum number of iterations
    % tolerance: Convergence tolerance
    % Returns:
    % V_new: Final voltage grid
    % iterations: Number of iterations performed
    % converged: Boolean indicating whether solution converged


    % nargin i.e. : number of arguments in 
    if nargin < 3 
        tolerance = 1e-6; % Default tolerance if not provided
    end
    
    [rows, cols] = size(V);
    V_new = V; 
    converged = false;
    iterations = 0;

    for iter = 1:max_iterations
        V_old = V_new; 
        
        for i = 2:rows-1
            for j = 2:cols-1
                V_new(i, j) = 0.25 * ( ...
                    V_old(i+1, j) + ...
                    V_old(i-1, j) + ...
                    V_old(i, j+1) + ...
                    V_old(i, j-1) ...
                );
            end
        end
        
        % Check for convergence: maximum absolute difference
        max_diff = max(max(abs(V_new - V_old)));
        iterations = iter;
        
        if max_diff < tolerance
            converged = true;
            break;
        end
    end
    
    % Report if not converged
    if ~converged
        disp(['Warning: Jacobi method did not converge after ' num2str(max_iterations) ' iterations.']);
        disp(['Maximum difference: ' num2str(max_diff)]);
    else
        disp(['Jacobi method converged after ' num2str(iterations) ' iterations.']);
    end
end