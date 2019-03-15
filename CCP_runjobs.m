function [jobfiles] = CCP_runjobs(project_info,prefix);
%--------------------------------------------------------------------------
%USE: [jobfiles] = CCP_runjobs(project_info,prefix);
% runs a list of '*.m' spm jobfile 
%
%IN: 
% ## project_info; 
% ## prefix; ID for the jobfile
%OUT: 
% list of jobfiles 
%--------------------------------------------------------------------------

curr = pwd;
[pathstr,name,ext] = fileparts(project_info);

% count = 0;

if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m') 
    run(name);
else
    error('this is not the right format')
end

% get some info from the project.info file 
root = project.rootdir;
nsub = size(project.subjects,1);
nsess = project.subjects;
nrun = project.subjects;
nfunc = size(project.func.dir,1);

jobfiles = {};


%loop to create a list of files to run
%--------------------------------------------------------------------------
for s = 1:nsub
        cd (fullfile(root,project.subjects{s,1},char(project.jobs)))
        %6/6/14: i added char to project.jobs to fix an error -EN
        mfiles = dir(prefix);
        last = end_file(jobfiles);
        for m = 1:size(mfiles,1)
            jobfiles{last+m,1} = fullfile(root,project.subjects{s,1},char(project.jobs),mfiles(m).name);
            %6/6/14: i added char to project.jobs to fix an error -EN
        end 
end

cd (curr)

if isempty(jobfiles)
    error('there are no files that match the prefix...')
end

%% RUN THE BATCH 
% ========================
disp(jobfiles)

resp='x';
 while resp~='c' 
 resp=input('all the files in "jobfiles" will be run, check and press c to continue  ', 's');         
end  

disp('running batch....');

curr = pwd;
for j = 1:length(jobfiles)
         file = jobfiles{j};
         logpath = fullfile(project.rootdir,project.infodir);
         name = 'batchlog'; 
         ccp_logSPMjob(file,'logpath',logpath,'name',name)       
end
end

%inline function 
function last = end_file(file);
last = size(file); last = last(1);
end
    
    
    
    
    
    
    
    
    