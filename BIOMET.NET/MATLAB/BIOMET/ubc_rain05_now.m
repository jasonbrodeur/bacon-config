% ubc_rain05_now
% this function creates one file for the period given

dateToday = datevec(now);
yearToday = dateToday(1);

%in_pth = '\\annex001\DataBase\2011\UBC_Totem\Climate\Totem1';
in_pth = sprintf('\\\\ANNEX001\\DATABASE\\%d\\UBC_Totem\\Climate\\Totem1',yearToday);

out_pth = '\\paoa001\web_page_wea\';


in_pth = ([in_pth '\ubc05']);
num_days = 2;								% number of days to be plotted
start_date = datenum(yearToday,1,1);
t=read_bor([ in_pth '_tv'],8);                % matlab time vector

ind = find( t >= (now-7) & t <=  now);        % extract the requested period
t = t(ind)-datenum(yearToday,1,0);

GMTshift = 8/24;                                    % ubc data is in GMT
lotus_offset = datenum(yearToday,1,1)-datenum(1900,1,1)+1 - GMTshift; % to convert matlab decimal time to Lotus/Excel time
%offset_doy = 0;

nn = length(ind);
d = zeros(nn,16);

form='%12.6f  ';

for i=5
    form=[form '%8.3f '];
    c = sprintf('tmp = read_bor(%s%s.%s%s,[],[],[],ind);',39,in_pth,num2str(i),39);
    eval(c);
    d = tmp;
    fprintf([num2str(i) ' ']);
end

form=[form ' \r\n'];

             filestring = sprintf('%srain.dat', out_pth);
             fid=fopen([ filestring ],'w');

   for nday=0:(num_days-1)
      n=nday*288;
     for i=1:288
		lotus_time = (lotus_offset + t(n+i));    
		fprintf(fid, form, lotus_time, d(n+i,:));
    end     
   end
     fclose(fid);