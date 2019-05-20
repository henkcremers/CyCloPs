function physio = physio_cpulse_detect(physio,varargin)

% defaults 
doplot = false;
intplot=false

% get the user input
%------------------------------------------------------------
for i = 1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'plot', doplot=true
            case 'intplot',intplot=true    
        end
    end
end


% get data
ppudata = physio.ons_secs.c;
xd = physio.ons_secs.t;
d_ppu = diff(ppudata); 

% nt = 10000;
nt = length(ppudata);

%% detect peak 
[dump peak_loc] = sort(d_ppu);
peak_ppu = ppudata(peak_loc);
peak_thr = peak_ppu(end-5000:end);
peak_thr = median(peak_thr(peak_thr>0));

% peak_thr = median(abs(ppudata(peak_loc));
% peak_thr = peak_thr*0.8
% cpulse_inx = find(d_ppu>peak_thr); cpulse_inx = cpulse_inx(cpulse_inx<=nt); 
% %filter
% dc = diff(cpulse_inx)<20;
% dc0 = find(dc==0);
% dc0 = cpulse_inx(dc0);
% for j = 1:length(dc0);
%     if j == 1; s = 1; else s = dc0(j)+1; end
%     e = dc0(j)-1;
%     m = find(max(d_ppu(s:e)));
%     cpulse_inxf(j) = m;
% end

%% Build in Matlab code
mpp = (1/200);
[pks, locs] = findpeaks(ppudata(1:nt),xd(1:nt),'MinPeakHeight',peak_thr,'MinPeakProminence',mpp);
physio.ons_secs.cpulse = locs;


% plot(xd(1:nt),d_ppu(1:nt),'r');
% hold on 
if doplot
plot(xd(1:nt),ppudata(1:nt),'k');
hold on
scatter(locs,pks,'x','b');
end

if intplot
    physio_cpulse_intplot(physio)
end


end