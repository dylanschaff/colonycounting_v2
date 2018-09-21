function [shift_column, shift_row, image_size] = get_shift(images, num_rows, num_columns, path_images, name_folder, name_scan)

    % if there is only one wavelength:
    if numel(images) == 1

        % use that wavelength to align:
        list_images = images.list_images;

    % otherwise:
    else

        % use dapi:
        list_images = colonycounting_v2.utilities.get_structure_results_matching_string(images, 'channel', 'dapi');
        list_images = list_images.list_images;

    end

    % create array with list of position numbers:
    array_of_positions = 1:(num_rows * num_columns);
    
    % arrange position numbers into matrix (same order that scope acquires images):
    matrix_of_positions = reshape(array_of_positions, num_rows, num_columns);
    
    % get the row and column of the middle position to use for the alignment:
    tile_row_middle = round(num_rows/2);
    tile_column_middle = round(num_columns/2);
    
    % get the images:
    [image_middle, image_below, image_right] = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_images_from_tile_numbers(tile_row_middle, tile_column_middle, matrix_of_positions, list_images, path_images);

    % get image size:
    image_size = size(image_middle, 1);
    
    % scale images and convert to double:
    image_middle = double(scale(image_middle));
    image_below = double(scale(image_below));
    image_right = double(scale(image_right));
    
    % display images:
    image_display = [image_middle, image_right; image_below zeros(size(image_middle), 'like', image_middle)];
    handle_display = figure;
    imshow(image_display);
    
    % ask user how they would like to do the alignment:
    question_alignment = 'How do you want to align the images?';
    title_alignment = 'Scan Alignment';
    option_alignment_middle = 'Visually with the position shown';
    option_alignment_choice = 'Visually with a position of my choosing';
    option_alignment_overlap = 'Entering the pixel overlaps';
    answer = questdlg(question_alignment, title_alignment, option_alignment_middle, option_alignment_choice, option_alignment_overlap, option_alignment_middle);

    % close the image:
    close(handle_display);
    
    % depending on the answer:
    switch answer
        
        % if the user wants to enter a position:
        case option_alignment_choice
            
            % get the users desired image position:
            question_position = [{sprintf('Entor row (1-%d)', num_rows)}, {sprintf('Entor column (1-%d)', num_columns)}];
            title_position = 'Which image would you like to use for alignment?';
            position = inputdlg(question_position, title_position, [1 50]);
            position = str2double(position);
            
            % if the position is in range of the scan: 
            if all((position >= 1) & (position(1) <= num_rows) & (position(2) <= num_columns)) 
                
                % update the position to use for the alignment:
                tile_row_middle = position(1);
                tile_column_middle = position(2); 
                
                % get the new images:
                [image_middle, image_below, image_right] = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_images_from_tile_numbers(tile_row_middle, tile_column_middle, matrix_of_positions, list_images, path_images);
                
            % otherwise:
            else
                
                % do not update the position (and continue to use the middle):
                
            end

    end
    
    % depending on the answer:
    switch answer
            
        % if the user wants to align the images visually:
        case {option_alignment_middle, option_alignment_choice} 
            
            % get column shift distances:
            shift_column = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift_visually(image_middle, image_below);
            
            % get row shift distances:
            shift_row = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift_visually(image_middle, image_right);
            
        % if the user wants to align the images by entering an overlap:
        case option_alignment_overlap
            
            % get coordinates:
            [shift_column, shift_row] = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift_overlap(name_folder, name_scan);
            
            % adjust shift distances so that they have the same axes as
            % those set visually:
            shift_column.column = size(image_middle, 1) - shift_column.column;
            shift_row.row = size(image_middle, 1) - shift_row.row;
            
    end

end