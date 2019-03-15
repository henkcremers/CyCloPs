function [] = ccp_reslice4fsl(varargin)
%--------------------------------------------------------------------------
% USE:  ccp_reslice4fsl(varargin)
% reslice image or all images in a directoy so they can be overlaid to the FSL
% template (dimension 91x109x109 voxel size 2x2x2)
%
% IN: (optional)
% ## image or image directoy; if none is selected, a ui will promt to select a dir
% ## 'standard' (spm_reslice; works best for images with large amount of
%                data
%     'map' - works better with binary images or atlasses. 
%--------------------------------------------------------------------------

if isempty(varargin)
    imdir = uigetdir(pwd,'select image directory');
    ftype = 'directory';
else 
    imdir = varargin{1};
    %check dir
    if isdir(imdir)
       ftype = 'directory';
        %error('this is not a directory')
    else 
        ftype = 'image';
    end 
end

method = 'standard';
if length(varargin)>1;
    method = varargin{2};
end

%% main part of the code

switch ftype
    case 'directory'


        % change diretory. 
        cd(imdir); 

        imtypes = {'*.img' '*.nii'};
        for im = 1:length(imtypes)

            imfiles(im).imfiles = dir(imtypes{im}); 
            n_im(im) = length(imfiles(im).imfiles); 

        end

        if sum(n_im) ==0; 
            error('there are no image files in this directory')
        end

        disp('...reslicing')
        for im = 1:length(imtypes)
        for j = 1:n_im(im);  
            file = imfiles(im).imfiles(j).name;
%             P = {fslbrain; file};
%             flags.mean = 'false';
%             flags.prefix = 'f';
%             %flags.which = '1'; % this needs to be fixed, creates copies now of the
%             %fsl file 
%             spm_reslice(P,flags)
            reslice (file,method) 
        end
        end
        disp('done')
        
    case 'image'   
        
            file = imdir;
            %try
%             P = {fslbrain; file};
%             flags.mean = 'false';
%             flags.prefix = 'f';
%             %flags.which = '1'; % this needs to be fixed, creates copies now of the
%             %fsl file 
%             spm_reslice(P,flags)

            reslice (file,method) 
%             catch
%                 warning('can not reslice the image')
%             end
            
end


end 


function reslice (file,method)

    % fsl brain template check
    fslbrain = '/Volumes/WD2T/Tools/CCP/AtlasRois/AAL/MNI152_T1_2mm_brain.nii';
    if ~exist(fslbrain) 
        error('Cannot find FSL template brain')
    end 
    
    switch method
        case 'standard'
            
            P = {fslbrain; file};
            flags.mean = 'false';
            flags.prefix = 'f';
            %flags.which = '1'; % this needs to be fixed, creates copies now of the
            %fsl file 
            spm_reslice(P,flags)
            
        case 'map'
        % this is a workaround for the scn_map_image code. somehow when the img (3d) data is
        % passed on to spm_write_vol, the image reconstruction behaves
        % weird (e.g. contains less values than the orignal. Here the data
        % is passed on to iimg_recontruct_vols insteads.
            
        img = scn_map_image(file, fslbrain);
        dims = prod(size(img));
        data = reshape(img,1,dims);
        [fMaskInfo] = iimg_read_img(fslbrain, 2);
        [p n e] = fileparts(file);
        name = ['f' n e]; 
        iimg_reconstruct_vols(data', fMaskInfo, 'outname',name);
    end

end

