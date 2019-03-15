function [files,missfiles] = CCP_get_filelist(project_info,varargin)
%--------------------------------------------------------------------------
% USE: files = CCP_get_filelist(project_info,varargin)
% get a list of (image) files per subject directory 
%
% IN:
% ## project_info; standard CCP project info file (*.m, *.mat or a
% project structure, the latter should be loaded into workspace before)
%
% optionals: 
% ## 'dirs'; the directory where to look ('stats','func','struct','jobs','other') 
%        --if other is chooses, specificy the actual directory wihtin 
%          each subject directory
% ## 'fileID'; the file identifier (eg. 'con_000*') or cell { 's*' 'w*'}
%
%
% OUT:
% files; a list of image file which can be used for an SPM analsyis
%
% EXAMPLE files = CNPRU_get_filelist(project_info,'dirs','stats','fileID','con_001.img')
% --will give all files in the stats directory with the name 'con_001.img'
%--------------------------------------------------------------------------

pathstr = pwd; 
ext = 'xxx';
if ~isstruct(project_info)
[pathstr,name,ext] = fileparts(project_info);
end

if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m') 
    run(project_info);
elseif isstruct(project_info)
    project = project_info; 
else
    error('this is not the right format')
end

currdir = pwd; 

% defaults
%-----------------------------------------------------------
dirs   = 'stats';   % default option for the 
fileID = 'con_0001*';   % default fileID for the preprocessed images
files = {}; 
missfiles = {};
nofiles = 0;


% get the user imput 
%------------------------------------------------------------
 for i = 1:length(varargin)
  arg = varargin{i};
  if ischar(arg)
      switch arg
         case 'fileID', fileID = varargin{i+1};
         case 'dirs',   dirs = varargin{i+1};
         if strcmp(dirs,'other'); mandir = varargin{i+2}; end

       end
   end
 end

root = project.rootdir;
nsub = size(project.subjects,1);
nsess = project.func.sess;
nrun = project.func.run;
nfunc = size(project.func.dir,1);
%--------------------------------------------------------------------------    

count = 0;


%start the loop
for s = 1:nsub;  
    
    sub = project.subjects{s,1};
    
    %swith to the specific directory
    switch dirs
        case 'func'
         for f = 1:nfunc; 
         imagedir{f} = fullfile(root,sub,project.func.dir{f,1}); 
         end

        case 'struct'
         nstruct = length(project.struct.dir); 
         for sd = 1:nstruct
         imagedir{sd} = fullfile(root,sub,project.struct.dir{sd,1}); 
         end

        case 'stats'
         nstats = length(project.stats.dir);
         for st = 1:nstats
         imagedir{st} = fullfile(root,sub,project.stats.dir{st,1}); 
         end 
         
        case 'jobs'
         njobs = length(project.jobs);
         for st = 1:njobs   
         imagedir{st} = fullfile(root,sub,project.jobs{st,1}); 
         end
         
%        case 'struct/T1W3D/VBM'
%         nvbm = length(project.jobs);
%         for st = 1:nvbm   
%         imagedir{st} = fullfile(root,sub,project.jobs{st,1}); 
%        end

        case 'other'  
         %imagedir{1} = mandir; 
         imagedir{1} = fullfile(root,sub,mandir); 
    end
    
         %go to the directory to get the files 
         for c = 1:length(imagedir)
         cd(imagedir{c})
         
         if iscell(fileID); 
            nfd = length(fileID); 
            
            for nf = 1:nfd; % counter for all files
                
             Files = dir(fileID{nf});
             nimages = length(Files);
             if nimages == 0;
                 warning(['dir : ' imagedir{c} ' has no files that match the fileID']);
                 nofiles = nofiles + 1;
                 missfiles{nofiles,1} = imagedir{c};
             elseif nimages ~= 0;  
             for f = 1:nimages 
             fname = fullfile(imagedir{c},Files(f).name);   
             if exist(fname, 'file') == 2    
             count = count + 1;
             files{count,1} =  fname;  
             end
             
             end
             end
            end
             
        else
                 
             Files = dir(fileID);
             nimages = length(Files);
             if nimages == 0;
                 warning(['dir : ' imagedir{c} ' has no files that match the fileID']);
                 
                 nofiles = nofiles + 1;
                 missfiles{nofiles,1} = imagedir{c};
             elseif nimages ~= 0;  
             for f = 1:nimages 
             fname = fullfile(imagedir{c},Files(f).name);   
             if exist(fname, 'file') == 2    
             count = count + 1;
             files{count,1} =  fname;  
             end
             
             end
             end
             
         end
                 
         end    

%          Files = dir(fileID);
%          nimages = length(Files);
%          if nimages == 0;
%              warning(['dir : ' imagedir{c} ' has no files that match the fileID']);
%          elseif nimages ~= 0;  
%          for f = 1:nimages 
%          fname = fullfile(imagedir{c},Files(f).name);   
%          if exist(fname, 'file') == 2    
%          count = count + 1;
%          files{count,1} =  fname;  
%          end
% 
%               end     
%          end
%    end

end   
cd(currdir)

return


    
    

    
    
    
    
    
    