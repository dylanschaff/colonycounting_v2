function segment_all_scans(varargin)

    %%% First, we need to get all the path(s) to the raw images. 

    % if no paths are input:
    if nargin == 0
        
        % set the current working directory as the path to the data:
        paths = {pwd};
        
    % otherwise:
    else
        
        % use the supplied cell as the path(s) to the data:
        paths = varargin{1};
        
    end
    
    %%% Next, we need to segment the wells.
    
    % for each path:
    for i = 1:numel(paths)
       
        % get path to scan:
        path_scan = paths{i};
        
        % get list of stitch infos (scans) in the folder:
        list_stitch_info = dir(fullfile(path_scan, 'Stitch_Info_*.mat'));
        
        % for each stitch info (scan) in the folder:
        for j = 1:numel(list_stitch_info)
           
            % load the stitch info:
            stitch_info = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, list_stitch_info(j).name));
            
            % get the name of the scan:
            name_scan = stitch_info.name_scan;
            
            % get the name of the small DAPI stitch:
            name_stitch_small = sprintf('Stitch_Small_%s_%s.tif', name_scan, 'dapi');
            
            % load the small stitch:
            stitch_small = readmm(fullfile(path_scan, name_stitch_small));
            stitch_small = stitch_small.imagedata;
            
            % get name and path for file to store boundaries:
            file_name_boundaries = sprintf('Segment_Info_%s.mat', stitch_info.name_scan);
            
            % check for existence of boundaries file:
            if exist(fullfile(path_scan, file_name_boundaries), 'file') == 2
                
                % load the boundaries:
                boundaries = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, file_name_boundaries));
                boundaries_small_well = boundaries.small.well;
                boundaries_small_colonies = boundaries.small.colonies;
                
            % if the boundaries file does not already exist:
            else
                
                % create structure to store boundaries:
                boundaries_small_well = struct;
                boundaries_small_well.coordinates_boundary_small = [];
                boundaries_small_well.coordinates_mask_small = [];
                boundaries_small_well.status = '';
                boundaries_small_colonies = struct;
                boundaries_small_colonies.coordinates_boundary_small = [];
                boundaries_small_colonies.coordinates_mask_small = [];
                boundaries_small_colonies.status = '';
                
            end
            
            % segment the well:
            instructions_well = 'Segment the well.';
            boundaries_small_well = colonycounting_v2.segment_all_scans.gui_to_segment_a_stitch(stitch_small, boundaries_small_well, instructions_well);
            
            % segment the colonies:
            instructions_colonies = 'Segment the colonies.';
            boundaries_small_colonies = colonycounting_v2.segment_all_scans.gui_to_segment_a_stitch(stitch_small, boundaries_small_colonies, instructions_colonies);

            % get boundary coords in reference frame of original stitch:
            boundaries.small.well = boundaries_small_well;
            boundaries.small.colonies = boundaries_small_colonies;
            boundaries = colonycounting_v2.segment_all_scans.scale_coords_boundary_up(boundaries, stitch_info.scale_rows, stitch_info.scale_columns);

            % load the cells:
            cells = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, sprintf('Cell_Info_%s.mat', name_scan)));
            
            % determine cells in the well/colonies:
            cells.well = colonycounting_v2.segment_all_scans.get_cells_within_boundaries(cells, boundaries.original.well);
            cells.colonies = colonycounting_v2.segment_all_scans.get_cells_within_boundaries(cells, boundaries.original.colonies);
            
            % get the name of the original DAPI stitch:
            name_stitch_original = sprintf('Stitch_Original_%s_%s.mat', name_scan, 'dapi');
            
            % load the original stitch:
            stitch_original = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, name_stitch_original));
            
            % overlay on stitch:
            stitch_original_annotated = colonycounting_v2.segment_all_scans.overlay_on_image(stitch_original, cells);
            
            % create downsized version of annotated stitch:
            stitch_small_annotated = imresize(stitch_original_annotated, [size(stitch_original_annotated, 1)/stitch_info.scale_rows, size(stitch_original_annotated, 2)/stitch_info.scale_columns]);
            
            % save boundaries:
            save(fullfile(path_scan, file_name_boundaries), 'boundaries');
            
            % save the annotated images:
            save(fullfile(path_scan, sprintf('Segment_Original_%s.mat', name_scan)), 'stitch_original_annotated');
            imwrite(stitch_small_annotated, fullfile(path_scan, sprintf('Segment_Small_%s.tif', name_scan)));
            
        end
        
    end

end