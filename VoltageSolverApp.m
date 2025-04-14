function VoltageSolverApp
    % Create Octave-compatible GUI for the Voltage Solver
    % Uses only Octave-compatible GUI elements
    
    % Create main figure
    fig = figure('Name', 'Voltage Solver GUI', 'Position', [100 100 800 600], ...
                'MenuBar', 'none', 'NumberTitle', 'off');
    
    % === Input fields and labels ===
    % Rows
    uicontrol('Style', 'text', 'Position', [50 510 80 22], 'String', 'Rows:');
    h_rows = uicontrol('Style', 'edit', 'Position', [150 510 100 22], 'String', '10');
    
    % Columns
    uicontrol('Style', 'text', 'Position', [50 480 80 22], 'String', 'Columns:');
    h_cols = uicontrol('Style', 'edit', 'Position', [150 480 100 22], 'String', '10');
    
    % Top Voltage
    uicontrol('Style', 'text', 'Position', [50 450 80 22], 'String', 'Top Voltage:');
    h_topV = uicontrol('Style', 'edit', 'Position', [150 450 100 22], 'String', '100');
    
    % Bottom Voltage
    uicontrol('Style', 'text', 'Position', [50 420 80 22], 'String', 'Bottom Voltage:');
    h_bottomV = uicontrol('Style', 'edit', 'Position', [150 420 100 22], 'String', '0');
    
    % Left Voltage
    uicontrol('Style', 'text', 'Position', [50 390 80 22], 'String', 'Left Voltage:');
    h_leftV = uicontrol('Style', 'edit', 'Position', [150 390 100 22], 'String', '75');
    
    % Right Voltage
    uicontrol('Style', 'text', 'Position', [50 360 80 22], 'String', 'Right Voltage:');
    h_rightV = uicontrol('Style', 'edit', 'Position', [150 360 100 22], 'String', '50');
    
    % Use Conductivity checkbox
    h_useCond = uicontrol('Style', 'checkbox', 'Position', [150 330 150 22], ...
                         'String', 'Use Conductivity', 'Value', 0);
    
    % Status message
    h_status = uicontrol('Style', 'text', 'Position', [15 295 500 22], ...
                         'String', '', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    
    % Run button
    h_run = uicontrol('Style', 'pushbutton', 'Position', [150 250 100 30], ...
                     'String', 'Run Solver', 'Callback', @runSolver);
    
    % Create axes for the heatmap
    h_axes = axes('Position', [0.375 0.05 0.575 0.33]);
    title(h_axes, 'Voltage Heatmap');
    colormap(h_axes, 'jet');
    
    % Initial Matrix Header
    h_header = uicontrol('Style', 'text', 'Position', [300 510 460 22], ...
             'String', 'Initial Voltage Grid (with boundary conditions)', ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    
    % Initialize handles for initial grid cells - we'll create them in updateInitialGrid
    initial_grid_cells = {};
    
    % Call updateInitialGrid once to show the default grid
    updateInitialGrid();
    
    % Function to update and display the initial grid based on current parameters
    function updateInitialGrid()
        % Get current parameter values
        rows = str2double(get(h_rows, 'String'));
        cols = str2double(get(h_cols, 'String'));
        topV = str2double(get(h_topV, 'String'));
        bottomV = str2double(get(h_bottomV, 'String'));
        leftV = str2double(get(h_leftV, 'String'));
        rightV = str2double(get(h_rightV, 'String'));
        
        % Check for valid inputs
        if any(isnan([rows, cols, topV, bottomV, leftV, rightV]))
            return; % Invalid inputs, don't update
        end
        
        % Clear previous grid cells if they exist
        for i = 1:length(initial_grid_cells)
            if ishandle(initial_grid_cells{i})
                delete(initial_grid_cells{i});
            end
        end
        initial_grid_cells = {};
        
        % Create the initial grid
        initialValue = 0;
        V_initial = initializeGrid(rows, cols, topV, bottomV, leftV, rightV, initialValue);
        
        % Display the initial grid
        cell_width = min(40, 400/cols);
        cell_height = min(20, 300/rows);
        
        % Max number of rows to display before using ellipsis
        max_rows_to_display = 8;
        
        % Get header position to align the table properly
        header_pos = get(h_header, 'Position');
        table_top_y = header_pos(2) - 20; % Start table just below the header
        
        % Determine if we need ellipsis (if rows > max_rows_to_display)
        use_ellipsis = (rows > max_rows_to_display);
        
        % Calculate how many rows to show from top and bottom when using ellipsis
        rows_from_top = min(4, max_rows_to_display/2);
        rows_from_bottom = min(3, max_rows_to_display/2 - 1);
        
        % Calculate the x position to center the table under the header
        table_width = cols * cell_width + 20;  % Total width of the table
        table_center_x = header_pos(1) + header_pos(3)/2;  % Center of the header
        table_start_x = table_center_x - table_width/2;  % Start of the table
        
        % Create column headers
        for j = 1:cols
            h = uicontrol('Style', 'text', ...
                     'Position', [table_start_x + 20 + (j-1)*cell_width, table_top_y, cell_width, cell_height], ...
                     'String', num2str(j), ...
                     'HorizontalAlignment', 'center', ...
                     'FontWeight', 'bold', ...
                     'FontSize', 8);
            initial_grid_cells{end+1} = h;
        end
        
        % Create row headers and grid cells
        if use_ellipsis
            % Display top rows
            for i = 1:rows_from_top
                % Row header
                h = uicontrol('Style', 'text', ...
                         'Position', [table_start_x, table_top_y - i*cell_height, 20, cell_height], ...
                         'String', num2str(i), ...
                         'HorizontalAlignment', 'right', ...
                         'FontWeight', 'bold', ...
                         'FontSize', 8);
                initial_grid_cells{end+1} = h;
                
                % Grid cells
                for j = 1:cols
                    val = V_initial(i, j);
                    h = uicontrol('Style', 'text', ...
                             'Position', [table_start_x + 20 + (j-1)*cell_width, table_top_y - i*cell_height, cell_width, cell_height], ...
                             'String', sprintf('%d', val), ...
                             'HorizontalAlignment', 'center', ...
                             'FontSize', 8);
                    initial_grid_cells{end+1} = h;
                end
            end
            
            % Add ellipsis row
            h = uicontrol('Style', 'text', ...
                     'Position', [table_start_x, table_top_y - (rows_from_top+1)*cell_height, 20, cell_height], ...
                     'String', '...', ...
                     'HorizontalAlignment', 'right', ...
                     'FontWeight', 'bold', ...
                     'FontSize', 8);
            initial_grid_cells{end+1} = h;
            
            % Add ellipsis to cells
            for j = 1:cols
                h = uicontrol('Style', 'text', ...
                         'Position', [table_start_x + 20 + (j-1)*cell_width, table_top_y - (rows_from_top+1)*cell_height, cell_width, cell_height], ...
                         'String', '...', ...
                         'HorizontalAlignment', 'center', ...
                         'FontSize', 8);
                initial_grid_cells{end+1} = h;
            end
            
            % Display bottom rows
            for i = (rows - rows_from_bottom + 1):rows
                row_idx = i - (rows - rows_from_bottom) + 1 + rows_from_top + 1;
                
                % Row header
                h = uicontrol('Style', 'text', ...
                         'Position', [table_start_x, table_top_y - row_idx*cell_height, 20, cell_height], ...
                         'String', num2str(i), ...
                         'HorizontalAlignment', 'right', ...
                         'FontWeight', 'bold', ...
                         'FontSize', 8);
                initial_grid_cells{end+1} = h;
                
                % Grid cells
                for j = 1:cols
                    val = V_initial(i, j);
                    h = uicontrol('Style', 'text', ...
                             'Position', [table_start_x + 20 + (j-1)*cell_width, table_top_y - row_idx*cell_height, cell_width, cell_height], ...
                             'String', sprintf('%d', val), ...
                             'HorizontalAlignment', 'center', ...
                             'FontSize', 8);
                    initial_grid_cells{end+1} = h;
                end
            end
        else
            % Display all rows (no ellipsis needed)
            for i = 1:rows
                % Row header
                h = uicontrol('Style', 'text', ...
                         'Position', [table_start_x, table_top_y - i*cell_height, 20, cell_height], ...
                         'String', num2str(i), ...
                         'HorizontalAlignment', 'right', ...
                         'FontWeight', 'bold', ...
                         'FontSize', 8);
                initial_grid_cells{end+1} = h;
                
                % Grid cells
                for j = 1:cols
                    val = V_initial(i, j);
                    h = uicontrol('Style', 'text', ...
                             'Position', [table_start_x + 20 + (j-1)*cell_width, table_top_y - i*cell_height, cell_width, cell_height], ...
                             'String', sprintf('%d', val), ...
                             'HorizontalAlignment', 'center', ...
                             'FontSize', 8);
                    initial_grid_cells{end+1} = h;
                end
            end
        end
    end
    
    % Add callbacks to update the initial grid when parameters change
    set(h_rows, 'Callback', @(src,evt) updateInitialGrid());
    set(h_cols, 'Callback', @(src,evt) updateInitialGrid());
    set(h_topV, 'Callback', @(src,evt) updateInitialGrid());
    set(h_bottomV, 'Callback', @(src,evt) updateInitialGrid());
    set(h_leftV, 'Callback', @(src,evt) updateInitialGrid());
    set(h_rightV, 'Callback', @(src,evt) updateInitialGrid());
    
    % Callback function for the Run button
    function runSolver(hObject, eventdata)
        % Get input values
        rows = str2double(get(h_rows, 'String'));
        cols = str2double(get(h_cols, 'String'));
        topV = str2double(get(h_topV, 'String'));
        bottomV = str2double(get(h_bottomV, 'String'));
        leftV = str2double(get(h_leftV, 'String'));
        rightV = str2double(get(h_rightV, 'String'));
        useConductivity = get(h_useCond, 'Value');
        
        % Check for valid inputs
        if any(isnan([rows, cols, topV, bottomV, leftV, rightV]))
            set(h_status, 'String', '⚠️ Error: Invalid input values. Please use numbers only.');
            return;
        end
        
        % Update status
        set(h_status, 'String', '⏳ Solving...');
        drawnow;
        
        % Parameters
        max_iterations = 1000;
        tolerance = 1e-6;
        initialValue = 0;
        
        % Initialize grid
        V = initializeGrid(rows, cols, topV, bottomV, leftV, rightV, initialValue);
        V_boundary = V;
        
        % Solve based on selected method
        if ~useConductivity
            [V_final, iterations, converged] = jacobiSolver(V, max_iterations, tolerance);
            if converged
                set(h_status, 'String', ['✅ Solved using Jacobi method in ' num2str(iterations) ' iterations.']);
            else
                set(h_status, 'String', ['⚠️ Solution did not converge after ' num2str(iterations) ' iterations.']);
            end
        else
            sigma = generateConductivityMatrix(rows, cols);
            x0 = zeros((rows-2)*(cols-2), 1);
            idx = 1;
            for i = 2:rows-1
                for j = 2:cols-1
                    x0(idx) = V(i, j);
                    idx = idx + 1;
                end
            end
            options = optimset('Display', 'off', 'MaxFunEvals', 1000);
            [x, ~, exitflag] = fsolve(@(v) nonlinearSystem(v, V_boundary, sigma, rows, cols), x0, options);
            V_final = V_boundary;
            idx = 1;
            for i = 2:rows-1
                for j = 2:cols-1
                    V_final(i, j) = x(idx);
                    idx = idx + 1;
                end
            end
            if exitflag > 0
                set(h_status, 'String', '✅ Solved using conductivity successfully.');
            else
                set(h_status, 'String', '⚠️ Conductivity-based solution did not converge.');
            end
        end
        
        % Display result as heatmap
        axes(h_axes);
        imagesc(V_final);
        colorbar;
        title('Voltage Heatmap');
        xlabel('Column');
        ylabel('Row');
        
        % Display result in new figure
        result_str = sprintf('Voltage Solution Results (%dx%d grid):', rows, cols);
        result_fig = figure('Name', 'Voltage Solution Results', 'Position', [150 150 500 400]);
        uicontrol('Style', 'text', 'Position', [10 360 480 30], ...
                 'String', result_str, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        
        % Create a simple table-like display using text elements
        cell_width = min(40, 400/cols);
        cell_height = min(20, 300/rows);
        
        % Display all values in the results grid (no ellipsis)
        
        % Column headers
        for j = 1:cols
            uicontrol('Style', 'text', ...
                     'Position', [20 + (j-1)*cell_width, 340, cell_width, cell_height], ...
                     'String', num2str(j), ...
                     'HorizontalAlignment', 'center', ...
                     'FontWeight', 'bold', ...
                     'FontSize', 8);
        end
        
        % Row headers and voltage values
        for i = 1:rows
            % Row header
            uicontrol('Style', 'text', ...
                     'Position', [5, 340 - i*cell_height, 15, cell_height], ...
                     'String', num2str(i), ...
                     'HorizontalAlignment', 'right', ...
                     'FontWeight', 'bold', ...
                     'FontSize', 8);
            
            % Values
            for j = 1:cols
                val = V_final(i, j);
                uicontrol('Style', 'text', ...
                         'Position', [20 + (j-1)*cell_width, 340 - i*cell_height, cell_width, cell_height], ...
                         'String', sprintf('%d', val), ...
                         'HorizontalAlignment', 'center', ...
                         'FontSize', 8);
            end
        end
    end
end