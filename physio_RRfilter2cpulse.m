function physio = RRfilter2cpulse(physio);
% time-stamps to RR
cpulse = physio.ons_secs.cpulse;
RR = (diff(cpulse));

% filter the RR interval
[RRf loc] = filloutliers(RR,'spline');

% detect clusters of outliers
[a nclus] = bwlabel(double(loc));

% adjust the timestamps
cpulsef = cpulse;
for l = 1:nclus
    cloc = find(a==l);
    cpulsef(cloc+1) = cpulse(cloc(1))+cumsum(RRf(cloc));
end

% update the physio structure 
physio.ons_secs.cpulse = cpulsef;
return