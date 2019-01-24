function count_cells_all_scans(varargin)

    %%% First, we need to get all the path(s) to the raw images. 

    paths = colonycounting_v2.utilities.get_paths_to_data(varargin);
    
    %%% Next, we need to count the number of cells.
    
    % for each path:
    for i = 1:numel(paths)
       
        % get path to scan:
        path_scan = paths{i};
        
        % get list of stitch infos (scans) in the folder:
        list_stitch_info = dir(fullfile(path_scan, 'Stitch_Info_*.mat'));
        
        % for each stitch info (scan) in the folder:
        for j = 1:numel(list_stitch_info)
           
            %%% First, load the stitch info and the small dapi stitch. 
            
            % load the stitch info:
            stitch_info = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, list_stitch_info(j).name));
            
            % get the name of the scan:
            name_scan = stitch_info.name_scan;
            
            % get the names of the dapi stitch:
            name_stitch = sprintf('Stitch_Original_%s_%s.mat', name_scan, 'dapi');
            name_stitch_small = sprintf('Stitch_Small_%s_%s.tif', name_scan, 'dapi');
            
            % load the stitches:
            stitch = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, name_stitch));
            stitch_small = readmm(fullfile(path_scan, name_stitch_small));
            stitch_small = stitch_small.imagedata;
            
            %%% Next, count the cells in each individual position.
            
            % display status:
            colonycounting_v2.utilities.display_status('Counting cells in', name_stitch, path_scan);
            
            % count the cells:
            cells.all.stitch = colonycounting_v2.count_cells_all_scans.count_cells_in_scan_gaussian_filter(stitch);
            
            % convert the cell coords to the reference frame of the small stitch:
            cells.all.stitch_small(:,2) = cells.all.stitch(:,2) / stitch_info.scale_rows;
            cells.all.stitch_small(:,1) = cells.all.stitch(:,1) / stitch_info.scale_columns;
            
            %%% Next, plot the cells on the small stitch and save. Note
            %%% that specifically the small stitch is annotated as the
            %%% MATLAB functions for adding the annotations do not like
            %%% especially large images. 
            
            % overlay on stitch:
            stitch_small_annotated = colonycounting_v2.count_cells_all_scans.overlay_on_image(stitch_small, cells.all.stitch_small);
                        
            % save annotated stitched image:
            imwrite(stitch_small_annotated, fullfile(path_scan, sprintf('Cell_Small_%s.tif', name_scan)));
                         
            % save cells:
            save(fullfile(path_scan, sprintf('Cell_Info_%s.mat', stitch_info.name_scan)), 'cells');
            
        end
        
    end

end