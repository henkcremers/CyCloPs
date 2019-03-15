function [] = CCP_QualityControl(project_info,varargin)
%--------------------------------------------------------------------------
% USE: CCP_QualityControl(project_info,varargin)
%--------------------------------------------------------------------------
% runs the program ART through a list of subject directories.
% (/project/skeedy/MATLAB_code/art_toolbox) -- needs to be added to the path
% check for spikes in the data, and excessive movement of subjects
% saves a *.mat and a *.txt with a summary of the data quality
% in the file in the project info foler. 
%
% IN: 
% ## project_info
% optional
% ## mode; several options: 
%          -'all'; default
%          -'group'; image check based on VBM toolbox
% ## fileID; default is 'swr*
%--------------------------------------------------------------------------


% defaults:
%-------------------
mode   = 'all';   % default option for the 
fileID = 'swr*';  % default fileID for the preprocessed functional images

% get the user imput 
%--------------------
 for i = 1:length(varargin)
  arg = varargin{i};
  if ischar(arg)
      switch (arg)
         case 'mode', mode = varargin{i+1};
         case 'fileID', fileID = varargin{i+1};;
       end
   end
 end

disp(mode)   
disp(fileID) 

[pathstr,name,ext] = fileparts(project_info);

if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m') 
    run(name);
else
    error('this is not the right format')
end

root = project.rootdir;
nsub = size(project.subjects,1);
nsess = project.func.sess;
nrun = project.func.run;
nfunc = size(project.func.dir,1);

count = 0; 
spm_list = {};

errors = {}; 
errorcount = 0; 


%swith to the QC options
switch mode
        case {'all','ART'}

%==========================================================================
% RUN the ART toolbox on all models 
%==========================================================================



% create a list of excisting SPM.mat files: 
%--------------------------------------------------------------------------

for s = 1:nsub;
    sub = project.subjects{s,1};
    for st = 1:length(project.stats.dir)
        spmfile = fullfile(root,sub,project.stats.dir{st},'SPM.mat');
        if exist(spmfile)
            count = count + 1;
            spm_list{count,1} = spmfile;
        else
            errorcount = errorcount + 1;
            errors{errorcount,1} = 'no spm file';
        end 
    end 
end


% Run ART on all first level SPM.mat files
%--------------------------------------------------------------------------

qc_summary = {}; 

for k = 1:length(spm_list);
    close all %close the figures that are open. 
    art_batch(spm_list{k});
    
    %get the summary data. 
    [pathstr,name,ext] = fileparts(spm_list{k});
    spmtxt = fullfile(pathstr,[name '_outliers.txt']);
    art_info = importdata(spmtxt);
    nums = art_info.data(1,:); %get the summary data. 
    numscell = num2cell(nums(1,:)); 

    %get the header info only for the first subject
    if k == 1; 
    qc_summary(1,2:(1+length(art_info.textdata))) = art_info.textdata(:); 
    end

    qc_summary{k+1,1} = pathstr; 
    qc_summary(k+1,2:(1+length(numscell))) = numscell(:); 

end


% save the quality control data in the project info dir.  
%--------------------------------------------------------------------------

 [tnum,tstr,dstr] = ntimeformat(clock);
 filename = fullfile(project.rootdir,project.infodir,[dstr '_' project.name '_' project.task '_QualityControl']); 
 save([filename '.mat'],'qc_summary','errors') %wite as mat file
 % dlmcell([filename '.txt'],qc_summary,' ')  

 
 
        case {'all','Group'}

    
%==========================================================================
%Run the QC options of the VBM toolbox on functional images
%==========================================================================

        
        
% create a list of files 
%--------------------------------------------------------------------------

current = pwd; 
count = 0;
files = {}; 

for s = 1:nsub; %loop over subjects

    sub = project.subjects{s,1};
    struct = project.struct.dir{1}; 
    
    for fn = 1:nfunc %and functional directories (=fn) 
        
    func = project.func.dir{fn}; 
    subdir = fullfile(root,sub,func); 
    fl = dir([subdir '/' fileID]); % files per dir (fl)
    nf = length(fl);               % number of files (nf)
    
        for j = 1:nf 
            count = count +1; 
            files{count,1} = fullfile(subdir,fl(j).name); 
        end
    end
end
        
    
% check the images
%--------------------------------------------------------------------------

matlabbatch{1}.spm.tools.vbm8.tools.showslice.data = files;
matlabbatch{1}.spm.tools.vbm8.tools.showslice.scale = 0;
matlabbatch{1}.spm.tools.vbm8.tools.showslice.slice = 0; 

[tnum,tstr,dstr] = ntimeformat(clock); 

file1 = [project.rootdir '/' project.infodir '/' dstr '_' project.name '_' project.task '_QCfuncimages.mat']; 
save(file1,'matlabbatch'); 
clear matlabbatch

% check the sample homogeneity 
%--------------------------------------------------------------------------

matlabbatch{1}.spm.tools.vbm8.tools.check_cov.data = files; 
matlabbatch{1}.spm.tools.vbm8.tools.check_cov.scale = 0;
matlabbatch{1}.spm.tools.vbm8.tools.check_cov.slice = 0;
matlabbatch{1}.spm.tools.vbm8.tools.check_cov.gap = 5;
%matlabbatch{1}.spm.tools.vbm8.tools.check_cov.nuisance = struct('c', {});

file2 = [project.rootdir '/' project.infodir '/' dstr '_' project.name '_' project.task '_QCfuncoutliers.mat']; 
save(file2,'matlabbatch');
 
end
 
return

function last = end_file(file);
last = size(file); last = last(1);
return
    

    

    
    
    
    
    
    