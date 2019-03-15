function [] = ccp_runSPMjob(file,varargin)
%==========================================================================
% USE:  ccp_runSPMjob(file,varargin)
% function that runs an spmjob (*.m) file 
% =========================================================================
% IN: 
% ## file: the spmjob file can be *.m, *.mat or matlabbatch structure  
%          (see spm_jobman.m)
%
% optional
% ## logpath: the path were a log (txt file) will be created of which files
% have been run
% ## name: name of the log file; a seperate file will be created for files
% that ran well, and ones that gave an error. 
% 
% example: ccp_runSPMjob('my_spmjob.m','logpath','/dir/logpathdir','name','logfile')
%==========================================================================


% Check if matlab path is there, run the setpath otherwise. 
% checkpath = path; checkpath = checkpath(1:27); 
% if ~strcmp(checkpath,'/project/skeedy/MATLAB_code')
% run('/project/skeedy/MATLAB_code/CNPRU/CNPRU_supp_func/ccp_setpath')
% end


%default log path and name
logpath = pwd;
name    = 'batchlog';

% get the user input 
%------------------------------------------------------------
 for i = 1:length(varargin)
  arg = varargin{i};
  if ischar(arg)
      switch arg
         case 'logpath', logpath = varargin{i+1};   
         case 'name', name = varargin{i+1};    
       end
   end
 end

 
% get the directory were the jobfile is. 
[subdir,subfile,EXT] = fileparts(file); 
if isempty(subdir)
    subdir = pwd;
end


% change to subject directory
cd(subdir) 
 
 
disp(['running file ' file])

 try 

%     jobfile = {file};
%     jobs = repmat(jobfile, 1,1);
%     inputs = cell(0, 1);
    spm('defaults', 'FMRI');
    spm_jobman('initcfg'); %this is recomendent, gives warning otherwise
%    spm_jobman('serial', jobs, '', inputs{:});
    spm_jobman('run',file)
    
    
    % keep a log of file that have succesfully been run: 
    
    [tnum,tstr,dstr] = ntimeformat(clock); 
    
    donefile = [logpath '/' name '_done.txt']; 
    fout = fopen(donefile,'a');
    
    %textline{1} = ['===========================']; 
    textline{1} = [tstr ': ' file ' has been run']; 

    for t = 1:length(textline)
    fprintf(fout,'%s\n',textline{t});
    end
    fclose(fout);
    
catch exception;

    etxt = ['File ' file ' did not run'];
    matlaberr = exception.message;
    warning(etxt);
    [tnum,tstr,dstr] = ntimeformat(clock);
    
    % Create a log file "errorlog.txt" that contains all the file
    % that did not run. 
    errorfile = [logpath '/' name '_error.txt']; 
    fout = fopen(errorfile,'a');
    
    %textline{1} = ['============================']; 
    textline{1} = [tstr ': ' etxt]; 

    for t = 1:length(textline)
    fprintf(fout,'%s\n',textline{t});
    end
    fclose(fout);

end