function [imagefiles,roidata] = CCP_extract_data(file,roi_image,varargin);
%--------------------------------------------------------------------------
% USE: [imagefiles,roidata] = CCP_extract_data(file,roi_image);
% Extract contrast values from subjects stats images. 
% 
% IN:
% ## file: either a SPM.mat file from group analysis, or a CCP project_info.mat type of file. 
% ## roi_image: an image file to extract data from. 
% optionals (only for a project_info file) 
% ## 'dirs'; the directory where to look ('stats','func','struct') 
% ## 'fileID'; the file identifier (eg. 'con_000*) 
% --defaults are con_0001.img for the stats directory 
% ## 'savefile'; this will savefile the data; default is no 
%
% OUT: 
% imagefiles,
% roidata; 
% this script will also savefile all data in a new directory
%
% NOTE: the real data extraction is done by the rex.m script, type help rex
% to see all the options for that code, which could be entered into line 141
% in this code... this should be updated soon to allow function arguments.
%
% EXAMPLE
% [imagefiles,roidata] = CCP_extract_data('/MyData/project_info.mat','/MyRois/Amygdala.nii');
%--------------------------------------------------------------------------
curr = pwd;

savefile = 0; 
name = 'XXX';
ext  = 'XXX';

if ~isstruct(file)
[pathstr,name,ext] = fileparts(file);
end

imagefiles = {};

[roi_path,roi_name,roi_ext] = fileparts(roi_image); 
[tnum,tstr,dstr] = ntimeformat(clock);
newroi = [roi_name '_data_' dstr];

%--------------------------------------------------------------------------
% check the input file, and create an imagefiles list.
% -------------------------------------------------------------------------

disp(['set-up filelist for ' roi_name]);

    % for SPM.mat file
    % --------------------
    if strcmp(name,'SPM');

        load(file);
        %     nsess = length(SPM.Sess);
        %     ncond = length(SPM.Sess(1,1).U);
        nscan = length(SPM.xY.VY); %get the number of scans


        for i = 1:nscan;
            imagefiles{i,1} = SPM.xY.VY(i,1).fname;  % ',' num2str(i)];
        end

        roidatadir = fullfile(pathstr,newroi);
        
    % end

    % not SPM file; 
    % ------------------------------------
    elseif ~strcmp(name,'SPM')
    
%     if strcmp(ext, '.mat'); load(file); 
%     elseif ~strcmp(name,'SPM') && strcmp(ext, '.m'); run(name); 
%     elseif isstruct(file); project=file; 
%     end
    
    if strcmp(ext, '.mat')
        load(file);
    elseif strcmp(ext, '.m') 
        run(name);
    elseif isstruct(file)
        project = file; 
    else
        error('this is not the right format')
    end
    
    
%     % if ~strcmp(name,'SPM') && strcmp(ext, '.mat') || ~strcmp(name,'SPM') && strcmp(ext, '.m'); 
%     
%     if ~isstruct(project)
%         error('dont recognize the input')
%     end

    
    % for project info file
    root = project.rootdir;
    nsub = size(project.subjects,1);
    nsess = project.func.sess;
    nrun = project.func.run;
    nfunc = size(project.func.dir,1);
    nstat = size(project.stats.dir,1);
    
    % defaults
    %-----------------------------------------------------------
    dirs   = 'stats';   % default option for the 
    fileID = 'con_0001*';   % default fileID for the preprocessed images
    files = {}; 


    % get the user imput 
    %------------------------------------------------------------
     for i = 1:length(varargin)
      arg = varargin{i};
      if ischar(arg)
          switch arg
             case 'fileID', fileID = varargin{i+1};
             case 'dirs',   dirs = varargin{i+1};
           end
       end
     end

    %get the images
    imagefiles = CCP_get_filelist(file,'dirs',dirs,'fileID',fileID);
    roidatadir = fullfile(root,project.infodir,newroi);
    end



%--------------------------------------------------------------------------
%extract data. 
%--------------------------------------------------------------------------

% uses the rex.m code form whiftield-gabrieli. here are some options: 
% =========================================================================
% REX(SOURCES, ROIS, 'paramname1',paramvalue1,'paramname2',paramvalue2,...);
%   permits the specification of additional parameters:
%       'summary_measure' :     choice of summary measure (across voxels) [{'mean'},'eigenvariate','median','weighted mean','count']
%       'level' :               summarize across [{'rois'},'clusters','peaks','voxels']
%       'scaling' :             type of scaling (for timeseries extraction) [{'none'},'global','roi']
%       'conjunction_mask':     filename of conjunction mask volume(s)
%       'output_type' :         choice of saving output ['none',{'savefile'},'savefilerex']
%       'gui' :                 starts the gui [{0},1] 
%       'select_clusters'       asks user to select one or more clusters if multiple clusters exists within each ROI [0,{1}]
%       'dims' :                (for 'eigenvariate' summary measure only): number of eigenvariates to extract from the data
%       'mindist' :             (for 'peak' level only): minimum distance (mm) between peaks 
%       'maxpeak' :             (for 'peak' level only): maximum number of peaks per cluster

disp('...extracting data');
images = imagefiles(1:end,:); 
l = size(images,1); 
for i = 1:l
    im = images{i,1};
    mean=rex(im,roi_image,'select_clusters',0);
    roidata(i,1) = mean;
    txtdata{i+1,1} = im; 
    txtdata{i+1,2} = num2str(mean); 
    
end

disp('...Done')

% check if the data needs to be savefiled. 
for i = 1:length(varargin)
  arg = varargin{i};
  if ischar(arg)
    switch arg
       case 'savefile', savefile = 1; 
    end
  end
end

if savefile == 1;
disp('...saving data')
if ~exist(roidatadir); mkdir(roidatadir);  fileattrib(roidatadir,'+w','a'); end 

file = fullfile(roidatadir,[roi_name '_' fileID '.mat'])
save(file,'roidata','txtdata') 
disp([ '...data savefiled in ' roidatadir])
end

end



    


    
    
    
    
    
    
    
    