% Fix bad CO2 eddy calibration at OBS for 2003 

%  Feb 8, 2007:  NickG
%------------------------------------------------------
% 
% 
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'F:\HFREQ_BS\MET-DATA\recalc_20070208\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% find bad cal zeros 
ind_bad = find((decDOY > datenum(2004,1,0) & decDOY <= datenum(2004,1,366)) &...
    (cal_voltage(10,:) > 0));
% set ignore flag
cal_voltage(6,ind_bad)= 1;


% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
