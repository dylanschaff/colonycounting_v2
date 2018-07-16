function stitch_all_scans(varargin)

    %%% First, we need to get all the path(s) to the raw images. 
    
    % if no paths are input:
    if nargin == 0
        
        % set the current working directory as the path to the data:
        paths = pwd;
        
    % otherwise:
    else
        
        % use the supplied cell as the path(s) to the data:
        paths = varargin{1};
        
    end
    
    %%% Next, we want to create a structure to store all stitching
    %%% information and image metadata. This will parse the raw image info into a structure
    %%% used by the rest of the code. 
    
    stitch_info = colonycounting_v2.stitch_all_scans.create_structure_to_store_stitch_info(paths);

    %%% Next, we need the user to input what channel each wavelength corresponds to.
    
    stitch_info = colonycounting_v2.stitch_all_scans.get_wavelength_channels(stitch_info);
    
    %%% Next, we need the user to input the scan tile dimensions. Also, we
    %%% will delete the stitched image made by Metamorph from the list of
    %%% images.
    
    stitch_info = colonycounting_v2.stitch_all_scans.get_scan_dimensions(stitch_info);
    
    %%% Next, we need get the amount to shift the images by 
    
    stitch_info = colonycounting_v2.stitch_all_scans.get_shifts(stitch_info);
    
    %%% Next, we need to create the stitched images. 
    
    colonycounting_v2.stitch_all_scans.perform_stitching(stitch_info);
    
end