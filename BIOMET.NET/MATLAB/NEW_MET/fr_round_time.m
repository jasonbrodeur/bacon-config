function dateOut = fr_round_time(dateIn,unitsIn,optionIn)
% fr_round_hhour - properly rounds a datenum 
%
% Inputs
%   dateIn      -   time vector 
%   unitsIn     -   units of time:
%                   'month',
%                   'day',
%                   'hour',
%                   '30min',   (default)
%                   'min',
%                   'sec'
%   optionIn    -   1 - round to the nearest unitsIn            (default)
%                   2 - round to the nearest end of unitsIn    
%                   3 - round to the nearest start of unitsIn
%
% (c) Zoran Nesic               File created:       Sep  4, 2005
%                               Last modification:  Feb 15, 2007

% Revisions:
%  Feb 15, 2007 (Z)
%       - fixed wrong defaults for optionIn in the comment lines

arg_default('optionIn',1);
arg_default('unitsIn','30MIN');

if isempty(dateIn)
    dateOut = [];
    return
end

[yearX,monthX,dayX,hourX,minuteX,secondX] = datevec(dateIn);

switch optionIn
    case 1,
        roundType = 'round';
    case 2,
        roundType = 'ceil';
    case 3,
        roundType = 'floor';
    otherwise,
        error 'Wrong optionIN'
end

if strcmp(upper(unitsIn),'SEC')
    secondX = feval(roundType,secondX);
elseif strcmp(upper(unitsIn),'MIN')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    minuteX = feval(roundType,minuteX);    
elseif strcmp(upper(unitsIn),'30MIN')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    minuteX = 30 * feval(roundType,minuteX ./ 30);    
elseif strcmp(upper(unitsIn),'HOUR')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    hourX = hourX + minuteX / 60 ;
    minuteX = 0;    
    hourX = feval(roundType,hourX);    
elseif strcmp(upper(unitsIn),'DAY')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    hourX = hourX + minuteX / 60 ;
    minuteX = 0;    
    dayX = dayX + hourX / 24;    
    hourX = 0;
    dayX = feval(roundType,dayX);    
elseif strcmp(upper(unitsIn),'MONTH')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    hourX = hourX + minuteX / 60 ;
    minuteX = 0;    
    dayX = dayX + hourX / 24;        
    hourX = 0;
    monthX = monthX + dayX / 12;
    dayX = 0;
    monthX = feval(roundType,monthX);  
else
    error 'Wrong units!'
end        
        
dateOut = datenum(yearX,monthX,dayX,hourX,minuteX,secondX);

