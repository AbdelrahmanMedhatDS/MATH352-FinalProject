function V = initializeGrid(rows, cols, topV, bottomV, leftV, rightV, initialValue)
    
    % Initialize grid with zeros or a given initial value
    V = initialValue * ones(rows, cols);
    
    % Apply boundary conditions:
    
    % Top edge
    V(1, :) = topV;
    
    % Bottom edge
    V(end, :) = bottomV;
    
    % Left edge
    V(:, 1) = leftV;
    
    % Right edge
    V(:, end) = rightV;
end
