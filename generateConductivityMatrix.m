function sigma = generateConductivityMatrix(rows, cols, min_val, max_val)
    % Generates a random conductivity matrix
    % rows, cols: Dimensions of the grid
    % min_val: Minimum conductivity value
    % max_val: Maximum conductivity value
    
    if nargin < 3
        min_val = 0.1;  % Default minimum value
    end
    
    if nargin < 4
        max_val = 2.0;  % Default maximum value
    end
    
    % Generate random conductivity values
    sigma = min_val + (max_val - min_val) * rand(rows, cols);
    
    % Ensure all values are positive (conductivity can't be negative)
    sigma = max(sigma, min_val);
    

end