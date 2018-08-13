function colony_assignment = assign_cells_to_centroids(cells_x, cells_y, image_density, colony_centroids_x, colony_centroids_y)

    % get number of cells:
    num_cells = numel(cells_x);

    % create array to store assignement of each cell to a centroid:
    colony_assignment = zeros(num_cells, 1);

    % for each cell:
    for i = 1:num_cells
        
        % if the cell is not within the thresholded region:
        if image_density(cells_y(i), cells_x(i)) == 0
           
            % do nothing
            
        % otherwise:
        else
            
            % get distances between the cell and each centroid:
            distances = pdist2([cells_x(i), cells_y(i)], [colony_centroids_x, colony_centroids_y]);

            % get index of colony with the minimum distance:
            [~, index_min] = min(distances);

            % assign that cell to that colony:
            colony_assignment(i) = index_min;
            
        end

    end

end