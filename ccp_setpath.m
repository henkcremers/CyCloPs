function ccp_setpath(varargin)
%==========================================================================
%USE: cnpru_setpath(varargin)
%set the MATLAB path to include the important toolboxes
%by default only adds the SPM and CNPRU paths. 
%--------------------------------------------------------------------------
%optional arguments: 
%## 'all' -- set all other toolboxes
%## 'SchultzMclean' -- various code from Schultz & Maclean; peak_nii/FIVE/
%## 'art' -- ART toolbox 
%## 'misc' -- various other small funtions
%## 'pronto' -- machine learning toolbox
%## 'CANLAB' -- canlab core tools
%
% EXAMPLE 
% cnpru_setpath('all')
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%default paths 
%--------------------------------------------------------------------------
CNPRUpath = '/Volumes/WD2T/Tools/CCP';
addpath(genpath(CNPRUpath));


%--------------------------------------------------------------------------
%additional toolboxes:
%--------------------------------------------------------------------------

toolboxpaths = {...,
    '/Volumes/WD2T/Tools/art_toolbox',...                   % toolbox for quality control
    '/Volumes/WD2T/Tools/misc',...                          % misc smaller functions  
    '/Volumes/WD2T/Tools/CanlabCore-master',...             % Tor Wager' CANLAB tools:                  http:/wagerlab.colorado.edu/tools
    '/Volumes/WD2T/Tools/PRoNTo_v.1.1_r740',...             % Pronto; machine learing toolbox:          http:/www.mlnl.cs.ucl.ac.uk/pronto/
    '/Volumes/WD2T/Tools/ParRec2Nii2015',...                % ParRec2Nii from Dr. Guo. Added 12/29/15
    '/Volumes/WD2T/Tools/NIFTI_tools', ...                  % tools to convert image files? Dr. Guo sent over w ParRec2NIFTItools
    '/Volumes/WD2T/Tools/dataQuality-1.4.5',...             % data quality toolbox from NYU:            http:/cbi.nyu.edu/software/dataQuality.php
    '/Volumes/WD2T/Tools/tapas',...                         % various tools from TNU lab zurich         http:/www.translationalneuromodeling.org/tnu-checkphysretroicor-toolbox/
    '/Volumes/WD2T/Tools/conn15g',...                       % Conn; Connectivity toolbox:               http:/www.nitrc.org/projects/conn/
    '/Volumes/WD2T/Tools/BCT/2017_01_15_BCT',...            % Brain Connectivity Toolbox, Sporns et al    
    '/Volumes/WD2T/Tools/BrainNetViewer_20150807',...       % Brain network viz. 
    '/Volumes/WD2T/Tools/GraphVar_beta_v_05.0',...          % Graph theory toolbox, uses BCT
    '/Volumes/WD2T/Tools/DPABI_V1.2_141101',...             % RS-connectivity tools. 
    '/Volumes/WD2T/Tools/mw_mfp',...                        % motion parameter figer print http:/www.medizin.uni-tuebingen.de/kinder/en/research/neuroimaging/software/     
    '/Volumes/WD2T/Tools/rsatoolbox',...                    % RSA    
    '/Volumes/WD2T/Tools/FSLNets',...	                    % https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLNets#Installing_FSLNets
    '/Volumes/WD2T/Tools/NeuroElf_v10_5153',...
    '/Volumes/WD2T/Tools/cPPI_29_Aug_2014',...	            % correlational PPI toolbox Fornito; https://www.nitrc.org/frs/download.php/6977/cPPI_29_Aug_2014.zip/?i_agree=1&release_id=2738
    }; 

 %    Neuroelf interferes with SVM in matlab  
 %   '/Volumes/WD2T/Tools/NeuroElf_v09c/NeuroElf_v09c',...   % neuroelf; visualisation and stats toolbox http:/neuroelf.net/
 %   '/Volumes/WD2T/Tools/SchultzMclean',...                 % Tools from Aaron Schults & Donald Mclean
 %   '/Volumes/WD2T/Tools/spm12/toolbox/PhysIO',...          % physio correction for fMRI

 for j = 1:length(toolboxpaths); addpath(genpath(toolboxpaths{j})); end
   
%     for i = 1:length(varargin)
%         arg = varargin{i};
%         if ischar(arg)
%             switch lower(arg)
%                 case 'all'
%                     for j = 1:length(toolboxpaths); addpath(genpath(toolboxpaths{j})); end
%                 case 'SchultzMclean'
%                     addpath(genpath('/Volumes/WD2T/Tools/SchultzMclean'))
%                 case 'art'
%                     addpath(genpath('/Volumes/WD2T/Tools/art_toolbox'));
%                 case 'misc'
%                     addpath(genpath('/Volumes/WD2T/Tools/misc'));
%                     %addpath(genpath('/Volumes/WD2T/Tools/misc
%                 case 'pronto'
%                     addpath(genpath('/Volumes/WD2T/Tools/PRoNTo_v.1.1_r740')); 
%                 case 'CANLAB'    
%                     addpath(genpath('/Volumes/WD2T/Tools/CANLAB_code/SCN_Core_Support'));           
%             end
%         end
%     end


%-------------------------------------------------------------------------
% SPM version - added last so on top
%--------------------------------------------------------------------------
spmver = 12;
SPMpath1 = '/Volumes/WD2T/Tools/spm12';
SPMpath2 = '/Volumes/WD2T/Tools/spm12_updates_r7487';



% spmver = 8;
% SPMpath = '/Volumes/WD2T/Tools/spm8';

for i = 1:length(varargin)
arg = varargin{i};
    if ischar(arg)
    switch lower(arg)
    case 'spmver'
        spmver = varargin{i+1};
        
        if spmver == 12;
        SPMpath1 = '/Volumes/WD2T/Tools/spm12';
        SPMpath2 = '/Volumes/WD2T/Tools/spm12_updates_r7487';
        elseif spmver == 8; 
        SPMpath1 = '/Volumes/WD2T/Tools/spm8';
        else
        disp(['invalid SPM version: ' num2str(spmver) ' , will use the default spm8'])    
        spmver = 8;
        end
    end
    end
end

disp(['using SPM version: ' num2str(spmver)])
addpath(genpath(SPMpath1));
addpath(genpath(SPMpath2));
%%  remove toolboxes that interfere with matlab functions or % fieldtrip 

rmpathsub('/Volumes/WD2T/Tools/GraphVar_beta_v_05.0/src/ext/BCT')
% if spmver == 12 ;
%     try
%     rmpathsub('/Volumes/WD2T/Tools/spm12_updates_r7487/external/fieldtrip');
%     %rmpathsub('/Volumes/WD2T/Tools/spm8/spm8_update/external/fieldtrip');
%     catch 
%     end
% end    
%     

end

