function common_time = common_clock(start_time)
%Calculates elapsed time since a starting time
%INPUTS:
%     start_time     A reference time to calculate elasped time from
%
%OUTPUTS:
%     common_time    Elapsed time since start_time (seconds)
%

c = clock();
common_time = (c(4) - start_time(1))*3600 + ...
    (c(5)-start_time(2))*60 + ...
    c(6) - start_time(3);