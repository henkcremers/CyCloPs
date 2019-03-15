function [regions] = vox2name(coord,atlastype)
% USE: [regions] = vox2name(coord,atlastype)
% gives a regions name based on voxel coordinates, for a certain atlas. 
% -adpated from Donald McLean, peak_nii code. 
% the atlas labels in the list files need to be checked and updates !!. 

nc = size(coord,1); 
regions = {}; 
probvec = [];

switch atlastype
    
    case 'haroxf' 
        
    hoatlas = '/Volumes/WD2T/Tools/CCP/AtlasRois/HarvardOxford/HOAprob/HarvardOxFord_AtlasInfo.mat';
    load(hoatlas)
    
       % link the voxel coordinates to brain structures. 
       % ----------------------------------------------

       for i = 1:nc
           count = 0;
           for j = 1:length(atlasinfo)
               [xyz,ii,d] = spm_XYZreg('NearestXYZ',coord(i,:),atlasinfo(j).XYZmm); % this needs to be fixed, also check the type of coordinates
               
               if d<8 & atlasinfo(j).prob(ii)>5; %%ii ~= 0;
                   
                   count = count +1;
                   probvec(count) = atlasinfo(j).prob(ii);
                   regions{i,count} = [atlasinfo(j).name '_' num2str(atlasinfo(j).prob(ii)) 'p'];
               end
               
           end
           % fix the order
           [dump loc] = sort(probvec);
           regions = regions(fliplr(loc));
           
           
           if count == 0
               
               
               % try the cerebellum atlas
               try
                   cereb = load('/Volumes/WD2T/Tools/CCP/AtlasRois/Cerebellum/CerebellumInfo.mat');
                   
                   % probt = [50 40 30 20 10 5 1]; 
                   % for p = 1:length(probt);   
                   for c = 1:length(cereb.atlasinfo)
                       [xyz,ii,d] = spm_XYZreg('NearestXYZ',coord(i,:),cereb.atlasinfo(c).XYZmm);
                       if d<10 & cereb.atlasinfo(c).prob(ii)>0; %%ii ~= 0;
                           count = count +1;
                           probvec(count) = atlasinfo(j).prob(ii);
                           regions{i,count} = [cereb.atlasinfo(c).name '_' num2str(cereb.atlasinfo(c).prob(ii)) 'p'];
                       end
                       
                       if count > 0;
                       [dump loc] = sort(probvec);
                       regions = regions(fliplr(loc));
                       else
                           regions{i,1} = 'NoClue';
                       end
                       
                   end
                   
               catch
               end
               %--------------------------------------------------------------------------------
           end
           probvec = [];
       end
            
    
    case 'AAL'
        
        
            atlas_list = '/Volumes/WD2T/Tools/CCP/AtlasRois/AAL/aal_MNI_V4_List.mat';
            atlas_im   = '/Volumes/WD2T/Tools/CCP/AtlasRois/AAL/aal_MNI_V4.img';	

            % set up the atlas info the are mm coordinates!!
            % -----------------------------------------------

            D    = spm_vol(atlas_im);
            [img XYZ] = spm_read_vols(D);
            atlas.XYZmm = XYZ;
            atlas.img = img;

            load(atlas_list);
            for n = 1:length(ROI)
                ROInames{n} = ROI(n).Nom_C;
            end


            % link the voxel coordinates to brain structures. 
            % ----------------------------------------------

            for i = 1:nc
            [xyz,ii] = spm_XYZreg('NearestXYZ',coord(i,:),atlas.XYZmm);
            val = atlas.img(ii);

            if val ~= 0; 
                ROIind=find([ROI.ID]==val);
                if ~isempty(ROIind);
                %if ROIind ~=isempty(ROIind);
                    regions{i,1} = ROInames{ROIind};
                else 
                    regions{i,1} = 'NoClue';
                end
            else 
                regions{i,1} = 'NoClue';
            end

            end 
end
end

