function [] = physio_cpulse_intplot(physio,varargin)
%--------------------------------------------------------------------------
% interactive plot to adjust the peak detection of the PPU signal.
%--------------------------------------------------------------------------
% USE: physio_cpulse_intplot(physio,varargin)
% IN:
%  - physio: data strucuture from the PhysioIO toolbox
%
%  optionals
%   'legend', 0/1; 1 to plot the legend. default is 0
%   'interval: interval for the slider, default is 5 seconds.
%   'marksize', size of the markers, default is 50
%   'sacsize', size of the saccade scoring, defualt is 100;
%
% OUT:
% physio; updated data structure for with adjusted peak detection 
% (phyio.ons_secs.cpulse). saved as '_physio_manadjust_cpulse.mat'
% =========================================================================

% Defaults
% -------------------------------------------------------------------------
fq    = 500;
xmax  = max(physio.ons_secs.c);
ndat  = length(physio.ons_secs.c);
interval = 20;
leg = 0;
marksize = 50;
sacsize = 100;
nblocks = 1;
ftitle = 'PPU data';

% get the user input
%------------------------------------------------------------
for i = 1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'legend', leg = varargin{i+1};
            case 'interval', interval = varargin{i+1};
            case 'marksize', marksize = varargin{i+1};
            case 'sacsize', sacsize = varargin{i+1};
            case 'title', ftitle = varargin{i+1};
        end
    end
end


% create an xaxis in sec scale - UPDATE TAKE FROM PHYSLOG
% xd = 0:(1/fq):(ndat/fq);
% xd = xd(1:ndat); xd = xd';
xd = physio.ons_secs.t;

%==========================================================================
% Create the Figure
%==========================================================================

f = figure;
%get(f)
set(f,'name',ftitle) ;
aH = get(gcf,'CurrentAxes');

set(f,'Units','normalized');

pval = [0.3 0.3 0.6 0.6];
set(f,'Position',pval);

%         %fix the subplots locations;
%         ax=get(sb(b),'Position');
%         ax(1)=ax(1)-0.05;
%         ax(4)=ax(4) + 0.02*ax(3);
%         set(sb(b),'Position',ax);

%the main signal - UPDATE MARKERS !!!
ppudata = physio.ons_secs.c;
xvals = xd;
% markers  = floor(physio.ons_secs.cpulse*fq);
markers  = physio.ons_secs.cpulse;
markers  = markers(markers>xd(1));
nmark = length(markers);

% marker index - BUG FIX 20190507
for nm = 1:nmark   
    %mi1 = find(xvals==markers(nm));
    [mval mi2] = min((abs(xvals-markers(nm)))); % search for closest point
    % disp(['val: ' num2str(mval)]);
    markind(nm) = mi2;
end
startscan = xd(floor(physio.ons_secs.svolpulse(1)*fq));
hold on;

% plot the PPU data
%---------------------------------------------
sp1 = subplot(2,1,1);
p1 = plot(xvals,ppudata,'k');
title('PPU','FontSize',16);
xlabel('Time (sec)');
%         l1 = line([startscan startscan],[min(ppudata) max(ppudata)]);
%         set(l1,'LineWidth',2);
%         set(l1,'Color','g');


% plot the peak detection as 'x' on the signal
%-----------------------------------------------

hold on;
% sachandles.points = scatter(xd(markers),ppudata(markers),'x','b','CreateFcn', @controlWithUi);
sachandles.points = scatter(markers,ppudata(markind),'x','b','CreateFcn', @controlWithUi);
set(sachandles.points,'SizeData',sacsize);

% Plot the HR - UPDATE

% HRt = xd(markers);
HRt = markers;
% HR  = 60./diff(physio.ons_secs.cpulse);
% HR  = 60./diff((markers./fq));
HR  = 60./diff((markers));
sp2 = subplot(2,1,2); % this is with "advanced" peak detection
p2 = plot(HRt(1:end-1),HR,'r','CreateFcn', @controlWithUi);
title('HR','FontSize',16);
%         l2 = line([startscan startscan],[0 max(HR)]);
%         set(l2,'LineWidth',2);
%         set(l2,'Color','g');

% link the axes
linkaxes([sp1,sp2], 'x' );

if leg == 1;
    lg = legend('Data','Saccade','MarkerOnsetPos','MarkerOnsetNeg');
end

%=====================================================%
% Inline Function to interact with the data points    %
%=====================================================%

    function controlWithUi(varargin)
        
        %start location
        left = 0.003;
        bottom = 0.8;
        width = 0.08;
        hight = 0.1;
        
        %1) change data
        hb1 = uicontrol('Style','pushbutton','String','Change');
        set(hb1,'Units','normalized');
        set(hb1,'Position',[left bottom width hight]);
        %set(hb1,'Callback',{@startDragFcn})
        set(hb1,'Callback',{@ChangeDataFcn});
        
        %2) add data
        hb2 = uicontrol('Style','pushbutton','String','Add');
        set(hb2,'Units','normalized');
        set(hb2,'Position',[left bottom-hight width hight]);
        set(hb2,'Callback',{@addDataFcn});
        
        %3) add data
        hb3 = uicontrol('Style','pushbutton','String','Remove');
        set(hb3,'Units','normalized');
        set(hb3,'Position',[left bottom-hight*2 width hight]);
        set(hb3,'Callback',{@RemoveDataFcn});
        
        %4) Save data
        hb4 = uicontrol('Style','pushbutton','String','Save');
        set(hb4,'Units','normalized');
        set(hb4,'Position',[left bottom-hight*3 width hight]);
        set(hb4,'Callback',{@SaveFigFcn});
        
        %5) slider to control the block that is displayed
        
        %the Text
        tu = uicontrol('Style','text','String','Block');
        get(tu);
        set(tu,'Units','normalized');
        set(tu,'Position',[left bottom-hight*4.5 width hight/2]);
        set(tu,'FontSize',18);
        %set(tu,'Callback',{@setxaxis})
        
        %the slider to control the block
        %nblocks = 5;
        nblocks = round(ndat/(fq*interval));
        sl = uicontrol('Style', 'slider',...
            'Min',1,'Max',nblocks+1,'Value',1,...
            'SliderStep',[1/(nblocks+1) 1],...
            'String','Block #',...
            'Callback', {@setxaxis});
        set(sl,'Units','normalized');
        set(sl,'Position',[left bottom-hight*5 width hight/2]);
        
    end

    function ChangeDataFcn(varargin)
        
        zoom off
        pan off
        
        [pind,xs,ys] = selectdata('sel','closest','Label','on','Ignore',p1);
        
        if length(pind)==1;  index = pind;
        elseif length(pind)>1 & isempty(pind{1});  index = pind{2};
        elseif length(pind)>1 & ~isempty(pind{1}); index = pind{1};
        end
        
        % get the location of the mouse.
        [x,y] = ginput(1);
        
        xpdata = get(sachandles.points,'XData');
        ypdata = get(sachandles.points,'YData');
        
        %change the selected data point.
        xpdata(index) = x;
        ypdata(index) = y;
        
        % update the plot
        set(sachandles.points, 'XData', xpdata);
        set(sachandles.points, 'YData', ypdata);
        
        HRtn = sort(xpdata);
        HRnew  = 60./abs(diff(HRtn));
        HRtn = HRtn(1:end-1);
        set(p2, 'XData',HRtn);
        set(p2, 'YData',HRnew);
        
    end


    function addDataFcn(varargin)
        
        zoom off
        pan off
        
        [x,y] = ginput(1);
        
        %get the current data
        xData = get(sachandles.points,'XData');
        yData = get(sachandles.points,'YData');
        
        l = length(xData);
        
        % add the data points
        xData(l+1) = x;
        yData(l+1) = y;
        
        % update a data point
        set(sachandles.points, 'XData', xData);
        set(sachandles.points, 'YData', yData);
        
        % update HR
        HRtn = sort(xData);
        HRnew  = 60./abs(diff(HRtn));
        HRtn = HRtn(1:end-1);
        set(p2, 'XData',HRtn);
        set(p2, 'YData',HRnew);
        
    end

    function RemoveDataFcn(varargin)
        
        zoom off
        pan off
        
        [pind,xs,ys] = selectdata('sel','closest','ignore',p1);
        %if isempty(pind{1}); in=2; else in=1 ; end
        %index = pind{in};
        index = pind;
        
        if length(pind)==1;  index = pind;
        elseif length(pind)>1 & isempty(pind{1});  index = pind{2};
        elseif length(pind)>1 & ~isempty(pind{1}); index = pind{1};
        end
        
        %get the current data
        xData = get(sachandles.points,'XData');
        yData = get(sachandles.points,'YData');
        
        %remove data point
        xData(index)=[];
        yData(index)=[];
        
        % update a data point
        set(sachandles.points, 'XData', xData);
        set(sachandles.points, 'YData', yData);
        
        % update HR
        HRtn = sort(xData);
        HRnew  = 60./abs(diff(HRtn));
        HRtn = HRtn(1:end-1);
        set(p2, 'XData',HRtn);
        set(p2, 'YData',HRnew);
    end

    function SaveFigFcn(varargin)
        disp('save the data')
        
        xVal = get(sachandles.points,'XData');
        %yVal = get(sachandles.points,'YData');
        
        %     newval = ((xVal*120)+1)';
        %     newval = int32(newval);
        %     physio.ons_secs.cpulse = [newval newval];
        
        physio.ons_secs.cpulse = sort(xVal);
        
        %save([ftitle '_tapas_regressors_manadjust.mat'],'physio.ons_secs','sqpar')
        save([ftitle '_physio_manadjust_cpulse.mat'],'physio')
    end

    function setxaxis(hObj,Value)
        
        zoom out; zoom out; zoom out;
        
        val = get(hObj,'Value');
        
        %fix the val
        vec = 1:(nblocks+1);
        df = vec-val;
        [junk loc] = min(abs(df));
        
        %get the axes
        aH = get(gcf,'CurrentAxes');
        
        if loc == 1
            xlimblock = [xd(1) xd(end)]  ;
            set(aH,'XLim',xlimblock);
        else
            st = round((loc-1)/nblocks*ndat);
            en = round(st+interval*fq);
            
            % fix some bugs:
            % if en > ndat; en = ndat; end
            if st > ndat-interval*fq | en > ndat ; st = ndat-interval*fq; en = ndat; end
            xlimblock = [xd(st) xd(en)];
            set(aH,'XLim',xlimblock);
        end
    end
end




