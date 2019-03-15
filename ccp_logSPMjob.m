function [] = ccp_logSPMjob(file,varargin)
%==========================================================================
% USE:  ccp_logSPMjob(file,varargin)
% function that runs an spmjob (*.m / *.mat / matlabbatch) file, and output
% an html report
% NOTE: this function is basically a wrapper function around 
% ccp_runSPMjob.m 
%
% IN: 
% ##file: the spmjob file
%
% optional
% ## logpath: the path were a log (txt file) will be created of which files
% have been run
% ## name: name of the log file; a seperate file will be created for files
% that ran well, and ones that gave an error. 
% 
% EXAMPLE: ccp_logSPMjob('my_spmjob.m','logpath','/dir/lopathdir','name','logfile')
%==========================================================================

% Check if matlab path is there, run the setpath otherwise. 
% checkpath = path; checkpath = checkpath(1:27); 
% if ~strcmp(checkpath,'/project/skeedy/MATLAB_code')
% run('/project/skeedy/MATLAB_code/CNPRU/CNPRU_supp_func/ccp_setpath')
% end
%run('/project/skeedy/MATLAB_code/CNPRU/CNPRU_supp_func/ccp_setpath')


%default options
logpath =  pwd;
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

% % change to subject directory
cd(subdir)

% create a directory where the matlab output will be saved. 
[tnum,tstr,dstr] = ntimeformat(clock);
sublogdir = fullfile(subdir,[subfile '_' dstr]);
mkdir(sublogdir)

% Link 2 the ccp_runSPMjob.m function 
%-------------------------------------------------------------------------
% setup some options for the publish function 
% create the function command to parse into the 'publish.m' function

part1 = ['ccp_runSPMjob('];
part2 = [''''  file  ''''];
part3 = ['''logpath'''];
part4 = [''''  logpath  ''''];
part5 = ['''name'''];
part6 = ['''' name ''''];
func  = [part1 part2 ',' part3 ',' part4 ',' part5 ',' part6 ')']; 
function_options.codeToEvaluate=func ;
function_options.showCode = false; 
function_options.outputDir = sublogdir; 

disp(['running file ' file])

publish('ccp_runSPMjob.m',function_options);
return

