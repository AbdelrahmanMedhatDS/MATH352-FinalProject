function F = nonlinearSystem(v, V_boundary, sigma, rows, cols)
    % Defines the nonlinear system for voltage distribution with varying conductivity
    % v: Flattened vector of unknown voltages (interior points only)
    % V_boundary: Original grid with boundary values set
    % sigma: Conductivity matrix
    % rows, cols: Dimensions of the grid
    
    % Reconstruct full grid from boundary and interior points
    V = V_boundary;
    
    % Fill in interior points from the solution vector
    idx = 1;
    for i = 2:rows-1
        for j = 2:cols-1
            V(i, j) = v(idx);
            idx = idx + 1;
        end
    end
    
    % Initialize residual vector
    F = zeros(size(v));
    
    % Calculate residuals for interior points
    idx = 1;
    for i = 2:rows-1
        for j = 2:cols-1
            % Average conductivity at half-grid points
            sigma_east = 0.5 * (sigma(i, j) + sigma(i, j+1));
            sigma_west = 0.5 * (sigma(i, j) + sigma(i, j-1));
            sigma_north = 0.5 * (sigma(i, j) + sigma(i-1, j));
            sigma_south = 0.5 * (sigma(i, j) + sigma(i+1, j));
            
            % Discretized version of ∇·(σ∇V) = 0 using finite differences
            F(idx) = sigma_east * (V(i, j+1) - V(i, j)) + ...
                     sigma_west * (V(i, j-1) - V(i, j)) + ...
                     sigma_north * (V(i-1, j) - V(i, j)) + ...
                     sigma_south * (V(i+1, j) - V(i, j));
            
            idx = idx + 1;
        end
    end
end