function [VIF, devec] = ccp_check_design(varargin)
%--------------------------------------------------------------------------
% USE:  ccp_check_design(varargin)
% check the first level design for efficiency and colinarity of regressors
% -------------------------------------------------------------------------
% 
% check design efficiency 
% based on: http://imaging.mrc-cbu.cam.ac.uk/imaging/DesignEfficiency
%
% check a design matrix for coliniarity (Variance Inflation Factor). 
% based on http://www.mathworks.com/help/econ/examples/time-series-regression-ii-collinearity-and-estimator-variance.html
%
% IN: (optional)
% ## SPM.mat; if none is selected, a ui will promt to select the file 
% 
% OUT: 
% ## VIF: variance inflation factor
% ## devec: efficiency per contrast (if contrasts are specified)
%--------------------------------------------------------------------------

if isempty(varargin)
     clear SPM
     [spmfile, pathname, filterindex] = uigetfile('SPM.mat', 'Select a SPM.mat file');
else 
     spmfile = varargin{1};
end
cd(pathname)
load(spmfile)

disp(['SPM file in: ' pathname])
%% print the design efficciency
if isfield(SPM,'xCon')  
disp('-----------------------------------------------------------')   
disp('Efficiency for each contrast: ')
disp('-----------------------------------------------------------')

dm = SPM.xX.X;
devec = [];
nc = length(SPM.xCon);
for c = 1:nc;
    con = SPM.xCon(1,c).c;
    
    % scale the contrast! 
    con  = scale_contrast(con);
    deseff = trace((con'*inv(dm'*dm)*con)^-1);
    name = SPM.xCon(1,c).name;
    devec(1,c) = deseff;
    disp(['contrast ' num2str(c) ' : ' name ' has efficiency ' num2str(deseff)])
end
end

%% check the variance inflation factor. 
%for first level model, get rid of the session parameters
nvar = size(SPM.xX.X,2); 
if isfield(SPM,'Sess')
    ns = length(SPM.Sess);
    dm = SPM.xX.X(:,1:end-ns);
    names = SPM.xX.name(1:end-2);
else
    %for second level remove the intercept?
    dm = SPM.xX.X;
    names = SPM.xX.name;
end
nvar = size(dm,2);
R0 = corr(dm); %R0 = corrplot(dm)
VIF = diag(inv(R0))';
highVIF = find(VIF>5);  
disp('-----------------------------------------------------------')
disp('VIF>5 for any regressor: ')
disp('-----------------------------------------------------------')
for j = 1:length(highVIF)  
   disp ([names{highVIF(j)} ' has a VIF of ' num2str(VIF(highVIF(j)))])   
end

%% plot the correlations, and histogram of the variables if there arent too many
if nvar<8
    corrplot(dm,'varNames',names,'testR','on') 
else
    disp('there are too many variables to plot')
end

%% colinarity test, see matlab site for more info
try
collintest(dm,'varNames',names,'tolIdx',10,'tolProp',0.5,'display','off','plot','on');
catch
end
return

