function [errors] = CCP_create_jobfiles(project_info,template,changes,fileid)
%--------------------------------------------------------------------------
%function that creates subject specif job files in each subjects 'jobs'
%folder. these can then be run in batch mode with CNPRU_runjobs
%
%USE 
%CNPRU_create_jobfiles(project_info,template,changes,fileid)
%
%IN
%-project_info: project specific standard CNPRU data file ('*.m'/'*.mat')
%
%-template: template '*.m' file that contains the fiels 'SUBJECT',SESSION
% and/or 'RUN' 
%
%-changes = structre that contains changes to be made. needs to be one of
% the following: {'SUBJECT'}, {'SUBJECT' 'SESSION'} or {'SUBJECT' 'SESSION' 'RUN'}
% depending on the field that need te changed in the template file.
%
%-fileid: string that will be added to the subject specfic file name, can
% be used for example to say what kind of job it is (eg. 'preproc' or
% 'PPI'). Each file will always start with the current date, and contain
% subject/session id etc. 
%--------------------------------------------------------------------------


[pathstr,name,ext] = fileparts(project_info);


if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m') 
    run(name);
else
    error('this is not the right format')
end


if ~exist(template)
    error('can not find the template job')
end


root = project.rootdir;
nsub = size(project.subjects,1);
nsess = project.func.sess;
nrun = project.func.run;
nfunc = size(project.func.dir,1);


%templatedir = '/mnt/RAIDnew/fMRI/CIT-2010/HC_temp_mcode/batch_mfiles';
%templatefile = 'rerun_preproc.m';

%-----------------------------------    

currentdir = pwd;

l = length(changes); 

errors = {}; 
count = 0; 

%case only subjects 
%--------------------------------------------------------------------------
if l == 1 && strcmp(changes{1},'SUBJECT')
    
for s = 1:nsub
    sub = project.subjects{s,1};
    [tnum,tstr,dstr] = ntimeformat(clock);

    subfile = [dstr '_' sub '_' fileid '.m'];
    subfile = fullfile(project.rootdir,sub,char(project.jobs),subfile); 
    %6/6/14: i added char to project.jobs to fix an error -EN
    
    
    fieldchanges = {'SUBJECT' sub} ;
    
    try
    change_field(template,subfile,fieldchanges);
    catch
        count = count + 1;
        errors{count,1} = subfile;
    end
        
    
end

   

%case subjects and session 
%--------------------------------------------------------------------------

elseif l == 2 && strcmp(changes{2},'SESSION')
    
for s = 1:nsub
    for ns = 1:nsess;
        
    sub = project.subjects{s,1};
    sess = project.func.sessname{ns};    %% = {'A' 'B'}
    
    [tnum,tstr,dstr] = ntimeformat(clock);
    

    subfile = [dstr '_' sub '_' sess '_' fileid '.m'];
    subfile = fullfile(project.rootdir,sub,project.jobs,subfile);
    fieldchanges = {'SUBJECT' sub 'SESSION' sess}; 
    
    try
    change_field(template,subfile,fieldchanges);
    catch
        count = count + 1;
        errors{count,1} = subfile;
    end
end
end


%case subject subject, session and run
%--------------------------------------------------------------------------
    
elseif l == 3 && strcmp(changes{3},'RUN')
    
for s = 1:nsub
    for ns = 1:nsess;
        for r = 1:nrn;
    sub = project.subjects{s,1};
    sess = project.func.sessname{ns};    %% = {'A' 'B'}
    rn = project.func.rnname(r); rn = num2str(rn);
    [tnum,tstr,dstr] = ntimeformat(clock);
    
    subfile = [dstr '_' sub '_' sess '_' rn '_' fileid '.m'];
    subfile = fullfile(project.rootdir,sub,project.jobs,subfile);
    fieldchanges = {'SUBJECT' sub 'SESSION' sess 'RUN' rn}; 
    
    
    try
    change_field(template,subfile,fieldchanges);
    catch
        count = count + 1;
        errors{count,1} = subfile;
    end
    
        end
    end
end

else 
    error('something is wrong with inpunt for this function')
end


if ~isempty(errors); warning('could not create jobfiles for all subjects, check this'); end 

end



       
    
    
    
    
    
    
    
    
    
    
    
    