function [tv,climateData] = fr_read_csi(wildCard,dateIn,chanInd,tableID,verbose_flag,timeUnit,roundType)
% fr_read_sci_net(wildCard,dateIn,chanInd)
%                      - extract all or selected data from a csi file
% 
% [tv,climateData] = fr_read_csi(wildCard,dateIn,chanInd)
%
% Inputs:
%       wildCard - full file name including path. Wild cards accepted
%       dateIn   - time vector to extract.  [] extracts all data
%       chanInd  - channels to extract. [] extracts all
%       tableID  - Table to be extracted
%       verbose_flag - 1 -ON, otherwise OFF
%       timeUnit - nearest time unit that time will be rouned to (see
%                  fr_round_time). When rounding on the seconds function
%                  will assume that the time is in columns 2-5 otherwise
%                  2-4 (YEAR, DOY, HHMM, SECONDS)
%       roundType - 1,2,3 -> see fr_round_type for details
%
% Zoran Nesic           File Created:      Apr 21, 2005
%                       Last modification: Sep  4, 2005

% Revisions
%
% Sep 4, 2005 (Z)
%   - added arg_default
%   - added new inputs: timeUnit and roundType to provide better handling
%     of a wider range csi files with different sampling times (down to 1
%     second samples)
%   - made it compatible with dir statement from Matlab 5.3.1 (it will
%     remove the extra path info from dir.name record
%   - If input file is empty it returns empty matrices

% Default arguments
arg_default('verbose_flag',0);          % verbose off
arg_default('timeUnit','30min');        % rounding to half hour
arg_default('roundType',2);             % rounding to the end of timeUnit

tv = [];
climateData = [];

x = findstr('\',wildCard);
pth = wildCard(1:x(end));
h = dir(wildCard);
% remove path from h.name if necessery
for i=1:length(h)
    s1 = strfind(h(i).name,pth)    ;
    if s1 > 0
        h(i).name = h(i).name(length(pth)+1:end);
    end
end
dateIn = fr_round_hhour(dateIn);

climateData = [];
for i=1:length(h)
    if verbose_flag,fprintf(1,'Loading: %s. ', [pth h(i).name]);end
    dataInNew = csvread([pth h(i).name]);
    ind = find(dataInNew(:,1) == tableID);
    dataInNew = dataInNew(ind,:);
    if verbose_flag,fprintf(1,'  Length = %f\n',size(dataInNew,1));end
    climateData = [climateData ; dataInNew];
end

% exit if there is no data to process
if isempty(climateData)
    return
end

if ~exist('chanInd') | isempty(chanInd)
    chanInd = 1:size(climateData,2);
end

switch upper(timeUnit)
    case 'SEC'
        tv = fr_csi_to_timevector(climateData(:,2:5));      % if rounding on the seconds 
    otherwise
        tv = fr_csi_to_timevector(climateData(:,2:4));
end

tv = fr_round_time(tv,timeUnit,roundType);
[tv,indSort] = sort(tv);
climateData = [climateData(indSort,chanInd)];

if exist('dateIn') & ~isempty(dateIn)
    dateIn = fr_round_time(dateIn,timeUnit,roundType);
    [junk,junk,indExtract] = intersect(dateIn,tv );
else
    indExtract = 1:size(tv,1);
end
   
tv = tv(indExtract);
climateData = climateData(indExtract,:);


function tv = fr_csi_to_timevector(csiTimeMatrix)

if size(csiTimeMatrix,2) == 4
    secondX = csiTimeMatrix(:,4);
else
    secondX = 0;
end

tv = datenum( csiTimeMatrix(:,1),1 , csiTimeMatrix(:,2),...
              fix(csiTimeMatrix(:,3)/100),...
              (csiTimeMatrix(:,3)/100 - fix(csiTimeMatrix(:,3)/100))*100,secondX);
