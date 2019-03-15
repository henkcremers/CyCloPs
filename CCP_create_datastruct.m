function newdir = CCP_create_datastruct(project_info);
%--------------------------------------------------------------------------
% USE: newdir = CCP_create_datastruct(project_info);
% function that creates all directories in project_info
%--------------------------------------------------------------------------

% clear all; 
[pathstr,name,ext] = fileparts(project_info);

if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m') 
    run(name);
else
    error('this is not the right format')
end

projectdir = {};

root = project.rootdir;
nsub = size(project.subjects,1);
nsess = project.subjects;
nrun = project.subjects;
nfunc = size(project.func.dir,1);
nstruc = size(project.struct.dir,1);
nadd = size(project.adddirs,1);


%loop over subjects; 
%--------------------------------------------------------------------------
for s = 1:nsub
    
    %structural directories
    for struc = 1:nstruc; 
    last = end_file(projectdir);
    projectdir{last+1,1} = fullfile(root,project.subjects{s,1},project.struct.dir{struc,1}); 
    end
    
    % jobs directory
    projectdir{last+2,1} = fullfile(root,project.subjects{s,1},project.jobs{1});
    
    %stats directories
    for f = 1:size(project.stats.dir,1)
    last = end_file(projectdir);
    projectdir{last+1,1} = fullfile(root,project.subjects{s,1},project.stats.dir{f,1});
    end
    
    %func directories
    for f = 1:nfunc  
    last = end_file(projectdir);
    projectdir{last+1,1} = fullfile(root,project.subjects{s,1},project.func.dir{f,1});
    end
    
    %additional directories, if any. 
    if nadd > 0
    for f = 1:nadd 
    last = end_file(projectdir);
    projectdir{last+1,1} = fullfile(root,project.subjects{s,1},project.adddirs{f,1});
    end
    end
    
end

%%create sub directories 
%--------------------------------------------------------------------------

%check if directories are there already
count = 0;
newdir = {};
for i = 1:length(projectdir)
    e = exist(projectdir{i},'dir');
    if e ~= 7 && e~=2
        count = count +1;
        newdir{count,1} = projectdir{i}; 
    end
end

%create the ones that are not
disp(newdir)
resp='x';
 while resp~='c' 
 resp=input('These files do not seem to be there, press c to continue and make them....', 's');         
end  

for f = 1:size(newdir,1);
    mkdir(newdir{f,1});
    fileattrib(newdir{f,1},'+w','a')
end

    
function last = end_file(file);
last = size(file); last = last(1);
return
    
    
    
    
    
    
    
    
    