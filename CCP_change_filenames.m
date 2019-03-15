function files = CCP_change_filenames(project_info,prefix,varargin);
%--------------------------------------------------------------------------
% USE: files = CCP_change_filenames(project_info,prefix,varargin);
% create a copy of all files that match the prefix in func and struct
% directories and rename them. 
% 
% IN: 
% ## project_info; 
% ## prefix; structure with the ID for the files, can contain a wildcart
% 
% optional 
% ## mode; specify the directories, default is all. 
%
% EXAMPLE: 
% CCP_change_filenames(project_info,{*.nii},'mode','func');
%--------------------------------------------------------------------------

[pathstr,name,ext] = fileparts(project_info);


if strcmp(ext, '.mat')
    load(project_info);
elseif strcmp(ext, '.m') 
    run(name);
else
    error('this is not the right format')
end

mode = 'all';
if length(varargin) > 0
    if varargin{1} == 'mode';
        mode =  varargin{2}
    end
end


root = project.rootdir;
nsub = size(project.subjects,1);
nsess = project.func.sess;
nrun = project.func.run;
nfunc = size(project.func.dir,1);
nstruct = size(project.struct.dir,1);
currentdir = pwd;

files = {};


%start the loop
for s = 1:nsub;

    %file = filelist{i,1};
    sub = project.subjects{s,1};
    struct = project.struct.dir;
    func = project.func.dir;

    %go to struct directories 
    %--------------------------------------------------------------------
    
    switch mode
        case {'str', 'all'}

            for str = 1:nstruct

                structdir = fullfile(root,sub,struct{str});
                cd(structdir);

                for p = 1:length(prefix)
                    renamefiles = dir(prefix{p});

                    last = end_file(files);

                    for n = 1:size(renamefiles,1)

                        files{last+n,1} = fullfile(pwd,renamefiles(n).name);
                        [pathstr,name,ext] = fileparts(files{last+n,1});
                        newfile = [sub '_UvA_T1' ext];
                        newdir = fullfile(pwd,newfile);
                        files{last+n,2} = newdir;
                        files{last+n,3} = '';
                        if n >1
                            files{last+n,3} = '!! There is more then one file that match the prefix !!';
                            newfile = [sub '_T1' num2str(n) ext];
                            newdir = fullfile(pwd,newfile);
                            files{last+n,2} = newdir;

                        end

                    end
                end
            end
    end

    
    %func directories
    %--------------------------------------------------------------------
    
    switch mode
        case {'all','fun'}

            for sess = 1:nsess
                for r = 1:nrun
                    loc = (sess-1)*nrun + r;

                    funcdir = fullfile(root,sub,func{loc,1});
                    %         cd(fullfile(root,sub,func{loc,1}));
                    cd(funcdir);

                    for p = 1:length(prefix)
                        renamefiles = dir(prefix{p});

                        last = end_file(files);

                        for n = 1:size(renamefiles,1)

                            files{last+n,1} = fullfile(pwd,renamefiles(n).name);
                            [pathstr,name,ext] = fileparts(files{last+n,1});

                            if iscell(project.func.sessname);
                                sessname = project.func.sessname{sess};
                            else
                                sessname = num2str(project.func.sessname(sess));
                            end

                            if iscell(project.func.runname);
                                runname = project.func.runname{r};
                            else
                                runname = num2str(project.func.runname(r));
                            end

                            %newfile = [sub '_' project.task  '_s' sessname '_r' runname ext];
                            %newfile = [sub '_' func{loc,1}(end-5:end) ext]; %different format, just copy the functional dir in the name?
                            %newfile = [sub '_ERr' num2str(r) '_4D' ext];
                            newfile = [sub '_UvA_SET' ext];
                            %newfile = [sub '_' project.task  '_s' sessname '_r' runname '_unZS' ext];
                            newdir = fullfile(pwd,newfile);
                            files{last+n,2} = newdir;
                            files{last+n,3} = '';
                            if n >1
                                files{last+n,3} = '!! There is more then one file that match the prefix !!';
                                newfile = [sub '_' project.task  '_s' sessname '_r' runname '_' num2str(n) ext];
                                newdir = fullfile(pwd,newfile);
                                files{last+n,2} = newdir;
                            end

                        end
                    end
                end

            end
    end
end
% end

for d = 1:size(files,1);
    [pathstr1,name1,ext] = fileparts(files{d,1});
    [pathstr2,name2,ext] = fileparts(files{d,2});
    if isempty(files{d,3}) 
    disp([name1 ' --> ' name2]) 
    else 
    disp([name1 ' --> ' name2 ' ' files{d,3}])     
    end   
end



cd(currentdir);
%--------------------------------------------------------------------------
%ask if the files really need to be renamed or quit the script 
%--------------------------------------------------------------------------
resp='x';
 while resp~='c' && resp~='q'
 resp=input('These files will be copied and renamed, please check, and press c to continue, or q to quit ....', 's');   
 
 if resp =='c'
   
    for d = 1:size(files,1);   
    disp(['..copying and renaming file ' files{d,1} ' press ctrl + c to force quit   ']) 
    [pathstr,name,ext] = fileparts(files{d,1});
    file1 = files{d,1};
    file2 = files{d,2};
    copyfile(file1,fullfile(pathstr, ['temp' ext]));
    movefile(fullfile(pathstr, ['temp' ext]),file2);
    end
  
 end 
    
   if resp =='q'
   break
  end
 end
 
disp('done')
%end
            
     
function last = end_file(file);
last = size(file); last = last(1);
return
   
