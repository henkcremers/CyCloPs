function [] = ccp_bet_struct(image)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

bet_input = '-F -f 0.3 -g 0"';
[impath fim ext] = fileparts(image);
if isempty(impath)
   impath = pwd;
end
cd(impath);


fsl_path = '/usr/local/fsl';
setenv('FSLDIR',fsl_path)
setenv('FSLOUTPUTTYPE','NIFTI')
curpath = getenv('PATH');
setenv('PATH',sprintf('%s:%s',fullfile(fsl_path,'bin'),curpath));

% for st = 1:length(project.func.dir)     
% fdir = fullfile(root,sub,project.func.dir{st});


% change path 
%cd (fdir)

% set orientation - this changes the whole immages !! maybe VBM toolbox??
% ---------------
% func
%fim = [pwd '/NPCL16_RS1ER.nii'];

%fim = image; %[sub '_RS' num2str(st) 'ER.nii'];
%fim_brain = [sub '_RS' num2str(st) 'ER_brain.nii'];
fim_brain = [fim '_brain.nii'];
%system(['sh -c ". ${FSLDIR}/etc/fslconf/fsl.sh;${FSLDIR}/bin/bet ' fim ' ' fim_brain ' '  '-F -f 0.3 -g 0"']) 
system(['sh -c ". ${FSLDIR}/etc/fslconf/fsl.sh;${FSLDIR}/bin/bet ' image ' ' fim_brain ' '  bet_input])
try
gunzip([fim_brain '.gz'])
delete([fim_brain '.gz'])
catch 
end

return

