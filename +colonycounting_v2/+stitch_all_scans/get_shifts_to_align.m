function stitch_info = get_shifts_to_align(stitch_info)

    % ask user if any scans have the same alignments:
    question = 'Do any scans have the same alignments?';
    title = 'Scan Alignment';
    answer = questdlg(question, title, 'Yes, all do.', 'Yes, all in a folder do.', 'No, none do.', 'Yes, all do.');

    % if all scans have the same alignment:
    if strcmp(answer, 'Yes, all do.')
       
        % get shift:
        [shift_row, shift_column, image_size] = ...
            colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift(...
            stitch_info(1).scan_info(1).images, ...
            stitch_info(1).scan_info(1).num_tiles_row, ...
            stitch_info(1).scan_info(1).num_tiles_column, ...
            'ALL FOLDERS', ...
            'ALL SCANS');
        
    end
    
    % for each folder:
    for i = 1:numel(stitch_info)
        
        % if all scans in the folder have the same alignment:
        if strcmp(answer, 'Yes, all in a folder do.')

            % get alignment:
            [shift_row, shift_column, image_size] = ...
                colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift(...
                stitch_info(i).scan_info(1).images, ...
                stitch_info(i).scan_info(1).num_tiles_row, ...
                stitch_info(i).scan_info(1).num_tiles_column, ...
                stitch_info(i).path_folder, ...
                'ALL SCANS');

        end
       
        % for each scan:
        for j = 1:numel(stitch_info(i).scan_info)
            
            % if no scans have the same sizes:
            if strcmp(answer, 'No, none do.')
            
                % get alignment:
                [shift_column, shift_row, image_size] = ...
                    colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift(...
                    stitch_info(i).scan_info(j).images, ...
                    stitch_info(i).scan_info(j).num_tiles_row, ...
                    stitch_info(i).scan_info(j).num_tiles_column, ...
                    stitch_info(i).path_folder, ...
                    stitch_info(i).scan_info(j).name_scan);
            
            end
    
            % save:
           stitch_info(i).scan_info(j).shift_column = shift_column;
           stitch_info(i).scan_info(j).shift_row = shift_row;
           stitch_info(i).scan_info(j).image_size = image_size;
            
        end
        
    end

end