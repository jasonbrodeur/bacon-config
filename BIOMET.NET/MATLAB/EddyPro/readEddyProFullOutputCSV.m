function [trace_str,ind_year] = readEddyProFullOutputCSV(Year,fileName);

% function reads full rich output file generated by EddyPro EC flux
% calculation software and stores all columns in a matlab structured
% variable trace_str. Based on the UBC Biomet.net function readDISCSV
% created for reading FCRN files

% (c) Nick Grant

% File created: April 9, 2014

% Revisions:

% e.g. eddypro_MPB1_full_output_2014-04-04T122717.csv

header = textread(fileName,'%s',4);
namesChar = [char(header(2))]; % No of , equals no of columns
unitsChar = [char(header(3))];
dataChar = [char(header(4))];
unitsChar = strrep(unitsChar,'#','N');
tmp=namesChar;

%replace characters in the var name string that will crash textread
tmp=strrep(tmp,'(z-d)/L','MO_L');
tmp=strrep(tmp,'-','_');
tmp=strrep(tmp,'/','_');
tmp=strrep(tmp,'*','_star');
namesChar=tmp;

%ind_names = [0 find([char(header(2)) ','] == ',')];
ind_names = [0 find([namesChar ','] == ',')];
ind_units = [0 find([unitsChar ','] == ',')];
ind_data  = [0 find([dataChar ','] == ',')];
n_col = length(ind_names)-1;


tv_year = fr_round_hhour([datenum(Year,1,1,0,30,0):1/48:datenum(Year+1,1,1)]);

for i = 1:n_col
    trace_str(i).TimeVector = tv_year;
    trace_str(i).DOY        = tv_year-datenum(Year,1,0);
    trace_str(i).variableName = namesChar(ind_names(i)+1:ind_names(i+1)-1);
    trace_str(i).ini.units = unitsChar(ind_units(i)+2:ind_units(i+1)-2);
    trace_str(i).data = NaN .* zeros(size(tv_year));
end


% Generate format string using apriori EddyPro full output format info
t = char(ones(n_col-4,1)*'%f,')'; % Create n_col-4 times %f, 
width_col = diff(ind_data(1:end-1))-1;
xx=t(:)';
%formatStr = ['%' num2str(width_col(1)) 's,%' num2str(width_col(2)) 's,%' num2str(width_col(3)) 's,%' num2str(width_col(4)) 'f,' xx(1:end-1)];
formatStr = ['%' num2str(width_col(1)) 's,%' num2str(width_col(2)) 's,%' num2str(width_col(3)) 's,%f,' xx(1:end-1)];

%Load up the data
disp(['Loading ' fileName]);

eval(['[' namesChar '] = textread(fileName,formatStr,''headerlines'',3);']);

% dv=datevec(datenum(date(2),'dd/mm/yyyy'));
% Year=dv(1);
HHMM=char(time);
tv = datenum(Year,1,floor(DOY),str2num((HHMM(:,1:2))),str2num(HHMM(:,4:5)),0);
tv_year = fr_round_hhour([datenum(Year,1,1,0,30,0):1/48:datenum(Year+1,1,1)]);
[tv_dum,ind_year,ind_tv] = intersect(tv_year,tv);

for j = 1:n_col
    if eval(['isnumeric(' trace_str(j).variableName ')'])
        eval(['trace_str(j).data(ind_year) = ' trace_str(j).variableName '(ind_tv);']);
    else
        eval(['trace_str(j).data = ' trace_str(j).variableName '(1);']);
    end
end
