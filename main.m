function main()
    clc; clear;

    % ==== Step 1: Input Parameters ====
    rows = 10;
    cols = 10;
    max_iterations = 500;
    tolerance = 1e-6;

    % Boundary voltages
    topV = 100;
    bottomV = 0;
    leftV = 75;
    rightV = 50;

    % Initial value for inner points
    initialValue = 0;

    % Choose solving mode :
        % Set to true to use conductivity model
        % Set to false to do not consider the conductivity

    useConductivity = false;

    % ==== Step 2: Initialize Grid ====
    V = initializeGrid(rows, cols, topV, bottomV, leftV, rightV, initialValue);

    % Store original grid with boundary conditions
    V_boundary = V;

    % ==== Step 3: Solve the system ====
    if ~useConductivity
        % Linear case: Use Jacobi iteration
        disp('Solving using Jacobi iteration (linear case)...');
        [V_final, iterations, converged] = jacobiSolver(V, max_iterations, tolerance);
    else
        % Nonlinear case: Use fsolve with conductivity
        disp('Solving using nonlinear system with conductivity...');

        % Generate random conductivity matrix
        sigma = generateConductivityMatrix(rows, cols);

        % Extract interior points as initial guess
        x0 = zeros((rows-2)*(cols-2), 1);
        idx = 1;
        for i = 2:rows-1
            for j = 2:cols-1
                x0(idx) = V(i, j);
                idx = idx + 1;
            end
        end

        % Setup options for fsolve
        options = optimset('Display', 'iter', 'MaxFunEvals', 1000);

        % Solve nonlinear system
        [x, fval, exitflag] = fsolve(@(v) nonlinearSystem(v, V_boundary, sigma, rows, cols), x0, options);

        % Reconstruct full solution
        V_final = V_boundary;
        idx = 1;
        for i = 2:rows-1
            for j = 2:cols-1
                V_final(i, j) = x(idx);
                idx = idx + 1;
            end
        end

        % Check solution quality
        if exitflag > 0
            disp('Nonlinear solution converged successfully.');
        else
            disp('Warning: Nonlinear solution may not have converged.');
            disp(['Exit flag: ' num2str(exitflag)]);
        end
    end

    % ==== Step 4: Display Results ====

    % Display initial voltage grid as a table in a figure
    figure;
    uitable('Data', V_boundary, ...
            'Position', [20 20 500 400], ...
            'ColumnWidth', {50}, ...
            'RowName', 1:rows, ...
            'ColumnName', 1:cols);
    title('Initial Voltage Grid');

    disp("Initial Voltage Grid:");
    disp(V_boundary);

    % Display initial voltage grid as a table in a figure
    figure;
    uitable('Data', V_final, ...
            'Position', [20 20 500 400], ...
            'ColumnWidth', {50}, ...
            'RowName', 1:rows, ...
            'ColumnName', 1:cols);
    title('Initial Voltage Grid');

    disp("Final Voltage Grid:");
    disp(V_final);

    % Create heatmap visualization
    figure;
    imagesc(V_final);
    colormap(jet);
    colorbar;
    title('Voltage Distribution');
    xlabel('Column');
    ylabel('Row');
    axis equal tight;

end
