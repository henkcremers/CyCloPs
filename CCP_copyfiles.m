function [] = CCP_copyfiles(project_info,dir1,fileID,dir2,varargin);
% =========================================================================
% USE: CCP_copyfiles(project_info,dir1,fileID,dir2);
% copy files that match a certain fileid in dir1 to dir2.
%
% IN:
% ## project_info: standard CCP project info structure
% ## dir1: directory within each subject that you want file to copy from
% ## fileID: identifier that looks for the files, eg. {'*brain.nii'}
% ## dir2: directory within each subject that you want file to copy to
%
% EXAMPLE:
% CCP_copyfiles(project_info,'mydir1/stat','con*','mydir2/stats');
%==========================================================================

[pathstr,name,ext] = fileparts(project_info);
if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m')
    run(name);
else
    error('this is not the right format')
end

curRoot = project.rootdir;
tarRoot = curRoot;
nsub = size(project.subjects,1);

% user input
%-----------
for i = 1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'cr', curRoot = varargin{i+1};
            case 'tr', tarRoot = varargin{i+1};
        end
    end
end

%--------------------------------------------------------------------------

current = pwd;

count = 0;
copyfiles = {};

%start the loop
for s = 1:nsub;
    
    sub = project.subjects{s,1};
    cd (fullfile(curRoot,sub,dir1));
    
    for p = 1:length(fileID)
        cfiles = dir(fileID{p});
        % cfiles = dir(fileID); %changed this on 1/21/14 -EN
        
        for n = 1:size(cfiles,1)
            
            file = fullfile(pwd,cfiles(n).name);
            
            % tdir = fullfile(curRoot,sub,dir2);
            % tdir = fullfile(dir2,sub,dir1);
            tdir = fullfile(tarRoot,sub,dir2);
            
            if exist(file) & isfile(file)
                
                count = count + 1;
                copyfiles{count,1} = file;
                copyfiles{count,2} = tdir;
                
            end
        end
    end
end


%display the files that will be copied
%-----------------------------------------------
for c = 1:size(copyfiles,1);
    disp([copyfiles{c,1} ' 2 ' copyfiles{c,2}])
end

% wait for user input:
%-----------------------------------------------
resp='x';
while resp~='c'
    resp=input('These files will be copied, press c to continue....', 's');
end

%start to copy all the files:
%-----------------------------------------

for c = 1:size(copyfiles,1);
    disp(['copyfiles ' copyfiles{c,1} ' 2 ' copyfiles{c,2}]);
    if ~exist(copyfiles{c,2}); mkdir(copyfiles{c,2}); end 
    copyfile(copyfiles{c,1},copyfiles{c,2})
end

cd (current);







