function [data,tv] = read_db(Years,SiteId,pth_subdir,var_name,warn_flag)

% read_db reads half hourly data for a single variable from multiple 
%         years into a single column vector ('data')and creates a time 
%         vector of identical length ('tv')whose elements correspond to the times 
%         at which the half hourly averages for each value in 'data_db' were computed.

%       1. lists of possible filenames that could contain the time vector are first built from
%          the years, subdirectory path, site ID and variable name that the user inputs to the function.  Time vector
%          filenames are known to terminate with '_tv' or to be called simply 
%          'TimeVector'.
%          Whichever of these lists is non-empty is placed in the variable 'name_tv'.  If both lists
%          are empty, an error is returned to the user.

%       2. The year storage mode, stored in the flag 'override99' is then set for input to 'read_bor', via
%          the function 'read_db_file'.
%          The flag is set to 1 if 'name_tv' has the value 'clean_tv' or 'TimeVector'--indicating that the data 
%          for the desired variable for the period 1996-1999 is stored in separate folders, and 0 if the data 
%          from 1996-1999 is found in the same folder.  

%       3. The time vector filenames contained in the elements of 'name_tv' are concatenated with subdirectory paths. 
         
%       4. Half hourly averaged data is read in to the variable 'data_db' by passing the years, 
%          subdirectory path, site ID and variable name to 'read_bor' via the function 'read_db_file'.

%       5. For each time vector file stored in 'name_tv', the time values are read into 'tv_db'
%          via 'read_bor' and the number of elements in 'tv_db' compared to the number of elements in 'data_db.' When
%          a time vector is found of equal length to the data vector, we move on.

%       6. The time interval (in days) from midnight of January 1  of the first year to January 1 of the last year 
%          input by the user is divided into half hourly segments (1/48th of a day).  The elements in this vector, 
%          'tv', are compared to those elements contained in the vector 'tv_db', and data from those common times is 
%          read into 'data' from 'data_db'. Missing data corresponding to the remaining times in 'tv' are stored in 
%          'data' as NaNs.  The elements of 'tv' are then properly rounded to the nearest half hour.



arg_default('warn_flag',1);

tv = [datenum(Years(1),1,1,0,30,0):1/48:datenum(Years(end)+1,1,1)]';
tv = round(tv.*48)./48;

% -------------------------------------------------------------------------
% 1. Find year storage mode (override_99 flag)
% -------------------------------------------------------------------------
pth_yyyy  = biomet_path('yyyy',SiteId,pth_subdir);
if Years <= 1999 ...
        & ((( ~isempty(findstr(lower(pth_yyyy),'\flux\')) & isempty(findstr(lower(pth_yyyy),'flux\clean'))) ...
        | (~isempty(findstr(lower(pth_yyyy),'\climate\')) & isempty(findstr(lower(pth_yyyy),'climate\clean')))))...
        & ~strcmp(upper(SiteId),'UBC_TOTEM')
    override_99 = 0;
else
    override_99 = 1;
end

% -------------------------------------------------------------------------
% 2. Find possible time vector names
% -------------------------------------------------------------------------
ind_yyyy = findstr(pth_yyyy,'yyyy');
if override_99 == 0
    pth_yyyy(ind_yyyy:ind_yyyy+3) = num2str(1999);
else
    pth_yyyy(ind_yyyy:ind_yyyy+3) = num2str(Years(1));
end
file_yyyy = fullfile(pth_yyyy,var_name);
ind_slash = find(file_yyyy == '\');
lst_tv = dir(fullfile(file_yyyy(1:ind_slash(end)),'*_tv'));
lst_TV = dir(fullfile(file_yyyy(1:ind_slash(end)),'TimeVector'));
% When running in version 5 the path needs to be removed
if ~isempty(lst_TV)
   ind = find(lst_TV.name == '\');
   if ~isempty(ind)
      lst_TV.name = lst_TV.name(ind(end)+1:end);
   end
end

name_tv = {lst_tv(:).name lst_TV(:).name};
name_tv = name_tv(find(~cellfun('isempty',name_tv)));
if isempty(name_tv)
    if warn_flag
        disp(['Could not find time vector']);
    end
    %tv = NaN;
    data = NaN;
    return
end
   

% -------------------------------------------------------------------------
% 3. Prepend subdir name to time vector names
% -------------------------------------------------------------------------
ind_slash = find(var_name == '\');
if ~isempty(ind_slash)
    for i = 1:length(name_tv)
        name_tv(i) = {[var_name(1:ind_slash(end)) char(name_tv(i))]};    
    end
end


% -------------------------------------------------------------------------
% 4. Read data for all years
% -------------------------------------------------------------------------
[data_db] = read_db_file(Years,SiteId,pth_subdir,var_name,warn_flag,override_99);

% -------------------------------------------------------------------------
% 5. Read time vector of length equal to that of data
% -------------------------------------------------------------------------
no = 0;
k = 1;
while no == 0
    [tv_db] = read_db_file(Years,SiteId,pth_subdir,char(name_tv(k)),warn_flag,override_99,8);
    if length(tv_db) == length(data_db) | (length(data_db) == 1 & isnan(data_db))
        no = 1;
    end
    k = k+1;
end
tv_db = round(tv_db.*48)./48;

% -------------------------------------------------------------------------
% 6. Find common times
% -------------------------------------------------------------------------
% tv = [datenum(Years(1),1,1,0,30,0):1/48:datenum(Years(end)+1,1,1)]';
% tv = round(tv.*48)./48;
% [tv_dum,ind_tv_db,ind_tv] = intersect(tv_db,tv,'tv');
% 
% data = NaN.*ones(size(tv));
% if length(data_db) > 1
%     data(ind_tv) = data_db(ind_tv_db);
% end
% 
% tv = fr_round_hhour(tv);


% -------------------------------------------------------------------------
% 6. Find common times
% -------------------------------------------------------------------------

% code inserted 7/13/2010 so that high frequency time vector can be read in (3 min
% in addition to 30 min data -- originally added for the Powell River light
% transect by kai* and NickG, February 2005.

if mean(diff(tv_db)) > 1/48-1/86400 & mean(diff(tv_db)) < 1/48+1/86400 %takes care of hhour data
    tv_db= round(tv_db.*48)./48;

%     tv = [datenum(Years(1),1,1,0,30,0):1/48:datenum(Years(end)+1,1,1)]';
%     tv = round(tv.*48)./48;
    [tv_dum,ind_tv_db,ind_tv] = intersect(tv_db,tv,'tv');
    
    data = NaN.*ones(size(tv));
    
    if length(data_db) > 1
       data(ind_tv) = data_db(ind_tv_db);
    end
    
    tv = fr_round_hhour(tv);
else % takes care of other averaging intervals
    data = data_db;
    tv = tv_db;
end

return

%--------------------------------------------------------------------------

function data_db = read_db_file(Years,SiteId,pth_subdir,var_name,warn_flag,override_99,bytes)
% Read data file including year after last if it exists 

arg_default('bytes',[]);

pth_full  = biomet_path('yyyy',SiteId,pth_subdir);
file_full = fullfile(pth_full,var_name);

pth_next_year  = biomet_path(Years(end)+1,SiteId,pth_subdir);
file_next_year = fullfile(pth_next_year,var_name);

try
    if (Years(end)==2000 | Years(end)==1999) & exist(file_next_year) & ~strcmp(upper(SiteId),'UBC_TOTEM')
        data_db = read_bor(file_full,bytes,[],[Years Years(end)+1],[],override_99);
    else
        data_db = read_bor(file_full,bytes,[],Years,[],override_99);
    end
catch
    if warn_flag
        disp(['Could not find ' var_name]);
        disp(lasterr);
    end
    data_db = NaN;
end
