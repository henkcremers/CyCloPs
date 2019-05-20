%%  BCS:  Loop network analysis statistics
% -------------------------------------------------------------------------

% clean up
clear all; close all; clc;

% ADJUST: working directory

% "base" directoty
nwdir_base = ['/Volumes/WD2T/BPD/NWAppi'];
if ~exist(nwdir_base); mkdir(nwdir_base); end
cd(nwdir_base);

% specific directory
wd = [nwdir_base '/mydir'];

% ADJUST: load/define important files
% --------------------
load('/Volumes/WD2T/BPD/BPD_info/BPD_ER_info.mat')
atlas = '/Volumes/WD2T/BPD/BPD_info/networkQC/20180824/NCUT121_BPD.mat';

proc.getdata  = 0;
proc.getnwm   = 0;
proc.atlas    = 1;
proc.stats    = 0;


subjects = project.subjects;
nsub = size(subjects,1);

%% gather all connectivity matrices
%--------------------------------------------------------------------------

if proc.getdata == 1;
    
    NWA.atlas.name = 'NCUT121';
    NWA.connmethod = 'bicglasso';
    NWA.date = '20190319';
    
    count = 0;
    for j = 1:nsub
        
        % ADJUST
        sdir = [project.rootdir subjects{j} '/func/T0/ER/nwppi'];
        cd(sdir)
        disp(sdir)
        
        % ADJUST
        nwfile = 'ppinw_comb.mat';
        
        if exist(nwfile)
            count = count + 1;
            load(nwfile);
            %ncon = size(ppinw.mean.gppi,3);
            ncon = size(nw.mean.conn,3);
            
            conname = {'Baseline','Anticipation','Recovery'};
            
            for c = 1:ncon;
                
                subnw_raw = ppinw.run(c).bicglasso;
                
                % IMPORTANT: processing steps of the connectivity matrix
                subnw = nwa_proc_conn(subnw_raw,'abs','diag0');
                
                NWA.data{c}(:,:,count) = subnw;
                NWA.datalabel{c} = conname{c};
                NWA.subjects{count} = subjects{j};
                
                % add group info
                g = str2num(project.subjects{j,2});
                NWA.group.num(count)  = g;
                if g ==1; gn = 'Control'; else gn = 'NoControl'; end
                NWA.group.name{count} = str2num(project.subjects{j,2});
            end
        end
        clear nw
    end
    
    mkdir(wd); cd(wd)
    save('NWA.mat','NWA')
end

%% calculate network metrics
% -------------------------------------------------------------------------
if proc.getnwm  == 1;
    cd(wd)
    load NWA.mat;
    disp (['working on NWA dataset: ' NWA.atlas.name ' ' NWA.connmethod ' ' NWA.date])
    [NWA] = nwa_wrap2bnv(NWA); % wrapper around BCT toolbox
    save('NWA.mat','NWA')
    
end

%% add atlas info
% -------------------------------------------------------------------------
if proc.atlas  == 1;
    
    cd(wd)
    
    % load the NWA file
    load NWA.mat
    
    % load the atlas info
    load (atlas)
    
    % add the atlas info for the current analyses
    NWA.atlas.RegionList = RegionList;
    NWA.atlas.Datalist = DataList;
    NWA.atlas.Overlap = Overlap;
    NWA.atlas.OverlapLabel = OverlapLabels;
    save('NWA.mat','NWA');
    
end

%% -------------------------------------------------------------------------
if proc.stats == 1;
    
end