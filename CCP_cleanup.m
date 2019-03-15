function [files] = CCP_cleanup(project_info,varargin);
%--------------------------------------------------------------------------
% USE: [files] = CCP_cleanup(project_info,varargin);
% move (default) or delete all files that match the prefix in func and struct directories
% and directories that are in the project.deldirs; 
%
%IN 
% ## project_info
% ## 'dirs'; the directory where to look ('stats','func','struct','jobs','other') 
%        --if other is chooses, specificy the actual directory wihtin 
%          each subject directory
% ## 'fileID'; the file identifier (eg. 'con_000*') 
% optional 
% ## mode; when 'mode','del' all files will be deleted, copy is the default
%--------------------------------------------------------------------------

pathstr = pwd; 
ext = 'xxx';
if ~isstruct(project_info)
[pathstr,name,ext] = fileparts(project_info);
end

if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m') 
    run(name);
elseif isstruct(project_info)
    project = project_info; 
else
    error('this is not the right format')
end


mode = 'copy'; %'del'
fileID = {'XXX'};
dirs = 'jobs';

% get the user imput 
%------------------------------------------------------------
 for i = 1:length(varargin)
  arg = varargin{i};
  if ischar(arg)
      switch arg
         case 'fileID', fileID = varargin{i+1};
         case 'dirs',   dirs = varargin{i+1};
         if strcmp(dirs,'other'); mandir = varargin{i+2}; end
         case 'mode'; mode = varargin{i+1}; 
       end
   end
 end


% if length(varargin) > 0
%     if varargin{1} == 'mode';
%         mode =  varargin{2};
%     end
% end

% [pathstr,name,ext] = fileparts(project_info);
% 
% 
% if strcmp(ext, '.mat')
%     load(project_info);
% elseif strcmp(ext, '.m')
%     run(name);
% else
%     error('this is not the right format')
% end

root = project.rootdir;
nsub = size(project.subjects,1);
nsess = project.func.sess;
nrun = project.func.run;
nfunc = size(project.func.dir,1);
nstruct = size(project.struct.dir,1);
currentdir = pwd;

%--------------------------------------------------------------------------

files = CCP_get_filelist(project_info,'fileID',fileID,'dirs',dirs);
% % dirs = {};
% count = 0;
% dircount = 0;


% also delete potential other directories
% ---------------------------------------
 for s = 1:nsub;

    sub = project.subjects{s,1};
    struct = project.struct.dir;
    func = project.func.dir;
    stats = project.stats.dir;
    %Misc directories. %allow wildcards 20130513
    %--------------------------------------------------------
    last = end_file(files);
    for nd = 1:length(project.deldirs);
        
        ddir = fullfile(root,sub,project.deldirs{nd,1});
        if ~isempty(regexp(ddir,'*'));    
            d = dir(ddir); 
            for n = 1:length(d)
                last = end_file(files);
                files{last+1,1} = fullfile(root,sub,d(n).name);
            end       
        else   
            last = end_file(files);
            files{last+1,1} = ddir;          
        end       
    end
 end

cd(pathstr)

%display the files that will be moves or deleted
for d = 1:size(files,1);
    disp(files{d})
end

if isempty(files);
    disp('There are no files that match the prefix..')
    return
end

%--------------------------------------------------------------------------
%ask if the files really need to be deleted or quit the script
%--------------------------------------------------------------------------
resp='x';
while resp~='c' && resp~='q'

    resp=input(['These files/directories will ' mode ' please check!! and press c to continue, or q to quit ....'], 's');

    if resp =='c'

        for d = 1:size(files,1);

            obj = files{d};
            e = exist(obj);

            switch mode
                case 'copy'
                    clc
                    disp(['..moving files/directories ' files{d} ' to /old dir press ctrl + c to force quit'])
                    [path,name,etx] = fileparts(obj);
                    olddir = [path '/OLD'];
                    if ~exist(olddir); mkdir(olddir); end
                    if exist(obj)
                    movefile(obj,olddir)
                    end

                case 'del'
                    clc
                    disp(['..deleting files/directories ' files{d} ' press ctrl + c to force quit'])
                    if e == 2 %it is a file
                        delete(files{d});
                    elseif e == 7;
                        rmdir(files{d},'s');
                    end
            end
        end

        if resp =='q'
            break
            disp('.. stop the script')
        end
    end
end

%end

function last = end_file(file);
last = size(file); last = last(1);
return
    
    
    
    
    
    
    