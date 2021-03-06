function view_one_site(ind,year,siteID,selectedPlots,select)

% select: 1 = plot diagnostic figures only
%         0 = plot all figures

if ~exist('select') | isempty(select);
    select = 0;
end

close_all_figures
currentDate = datenum(year,1,0) + ind;

switch upper(siteID)
	case 'CR', 
        sSiteName = 'Campbell River';
        sClimDiag = 'frbc_pl(ind,year,select);';
        sEC_cal = 'cal_pl(ind+1,year,siteID);';
        sPR_cal = 'cal_pl(ind+1,year,siteID,[],''PR'');';
        sEC_flux = 'eddy_pl(ind,year,siteID,select);';
        % sCH_cal = 'cal_pl(ind+1,year,siteID,[],''CH'');';
        sCH_cal = [];
        % sCH_flux = 'chamber_pl(ind-1,year,siteID,select);';
        sCH_flux = 'cr_ch_pl(ind-1,year,siteID,select);';
	case 'OA', 
        siteID = 'PA';
        sSiteName = 'Old Aspen';
        sClimDiag = 'paoa_pl(ind,year,select);';
        sEC_cal = 'cal_pl(ind+1,year,siteID);';
        sPR_cal = 'cal_pl(ind+1,year,siteID,[],''PR'');';
        sEC_flux = 'eddy_pl(ind,year,siteID,select);';
        sCH_cal = 'cal_pl(ind+1,year,siteID,[],''CH'');';
        sCH_flux = 'chamber_pl(ind-1,year,siteID,select);';
	case 'OBS', 
        siteID = 'BS';
        sSiteName = 'Old Black Spruce';
        sClimDiag = 'paob_pl(ind,year,select);';
        sEC_cal = 'cal_pl(ind+1,year,siteID);';
        sPR_cal = 'cal_pl(ind+1,year,siteID,[],''PR'');';
        sEC_flux = 'eddy_pl(ind,year,siteID,select);';
        sCH_cal = 'cal_pl(ind+1,year,siteID,[],''CH'');';
        sCH_flux = 'chamber_pl(ind-1,year,siteID,select);';
	case 'OJP', 
        siteID = 'JP';
        sSiteName = 'Old Jack Pine';
        sClimDiag = 'paoj_pl(ind,year,select);';
        sEC_cal = 'cal_pl(ind+1,year,siteID);';
        sPR_cal = 'cal_pl(ind+1,year,siteID,[],''PR'');';
        sEC_flux = 'eddy_pl(ind,year,siteID,select);';
        sCH_cal = 'cal_pl(ind+1,year,siteID,[],''CH'');';
        sCH_flux = 'chamber_pl(ind-1,year,siteID,select);';
	case 'OY', 
        sSiteName = 'VI Clearcut - OY Site';
        sClimDiag = 'plt_oy(ind,year,select);';
        % sEC_cal = 'cal_pl(ind+1,year,siteID);';
        sEC_cal = [];
        sPR_cal = [];
        sEC_flux = 'eddy_pl_new(ind,year,''OY'',select);';
        sCH_cal = [];
        sCH_flux = [];
	case 'YF', 
        sSiteName = 'VI Young Fir - YF Site';
        sClimDiag = 'yf_pl(ind,year,select);';
        sEC_cal = 'cal_pl_LI7000(ind,year,''YF'');';
        sPR_cal = [];
        sEC_flux = 'eddy_pl_new(ind,year,''YF'',select);';
        sCH_cal = 'cal_pl(ind+1,year,siteID,[],''CH'');';
        sCH_flux = 'chamber_pl(ind-1,year,siteID,select);';
	case 'HJP02', 
        sSiteName = 'Harvested Jack Pine 2002';
        sClimDiag = 'HJP02_pl(ind,year,select);';
        sEC_cal = [];
        sPR_cal = [];
        sEC_flux = 'HJP02_plt_fluxes(ind,year,''HJP02'',select);';
        sCH_cal = [];
        sCH_flux = [];
	case 'HJP75', 
        sSiteName = 'Harvested Jack Pine 1975';
        sClimDiag = 'HJP75_pl(ind,year,select);';
        sEC_cal = 'cal_pl_LI7000_old(ind,year,''HJP75'');';
        sPR_cal = [];
        sEC_flux = 'HJP02_plt_fluxes(ind,year,''HJP75'',1);';
        sCH_cal = [];
        sCH_flux = [];
	case 'MH', 
        sSiteName = 'MH Retension Site';
        sClimDiag = 'MH_pl(ind,year,select);';
        sEC_cal = [];
        sPR_cal = [];
        sEC_flux = [];
        sCH_cal = [];
        sCH_flux = [];
	case 'UBC CLIMATE STATION', 
        sSiteName = 'UBC Climate Stations';
        sClimDiag = 'ubc_pl301(ind,year,select);';
        sEC_cal = [];
        sPR_cal = [];
        sEC_flux = [];
        sCH_cal = [];
        sCH_flux = [];
    otherwise
        errordlg('Wrong site ID!','Error Message','modal')
        return
end

fr_set_site(siteID,'n');

%----------------------------------------------------------
%   Plot Diagnostics
%----------------------------------------------------------
if strmatch('Climate/Diagnostics',selectedPlots)
	try
        if ~isempty(sClimDiag)
            title_figure([ sSiteName ' (Climate/Diagnostics)'])
            runAndWait(sClimDiag)
        end
	end
end
close_all_figures

%----------------------------------------------------------
%   Plot EC Calibrations
%----------------------------------------------------------
if strmatch('EC Calibrations',selectedPlots)
	try
        if ~isempty(sEC_cal)
            title_figure([ sSiteName ' (Eddy Calibrations)'])
            runAndWait(sEC_cal)
        end
    end
end
close_all_figures

%----------------------------------------------------------
%   Plot Profile Calibrations
%----------------------------------------------------------
if strmatch('Profile Calibrations',selectedPlots)
	try
        if ~isempty(sEC_cal)
            title_figure([ sSiteName ' (Profile Calibrations)'])
            runAndWait(sPR_cal)
        end
	end
end
close_all_figures

%----------------------------------------------------------
%   Plot Eddy Fluxes
%----------------------------------------------------------
if strmatch('Eddy Fluxes',selectedPlots)
	try
        if ~isempty(sEC_flux)
            title_figure([ sSiteName ' (Eddy Fluxes)'])
            runAndWait(sEC_flux)
        end
	end
end
close_all_figures

%----------------------------------------------------------
%   Plot Chamber Calibrations
%----------------------------------------------------------
if strmatch('Chamber Calibrations',selectedPlots)
	try
        if ~isempty(sCH_cal)
            title_figure([ sSiteName ' (Chamber Calibrations)'])
            runAndWait(sCH_cal)
        end
	end
end
close_all_figures

%----------------------------------------------------------
%   Plot Chamber Fluxes
%----------------------------------------------------------
if strmatch('Chamber Fluxes',selectedPlots)
	try
        if ~isempty(sCH_flux)
            title_figure([ sSiteName ' (Chamber Fluxes)'])
            runAndWait(sCH_flux)
        end
	end
end
close_all_figures

return

function runAndWait(sFunction)

evalin('caller',sFunction);   
title_figure('Close all?')
pause

%------------------------------

function title_figure(title_1)
    figure
    axes
    set(gca,'box','off','position',[0 0 1 1])
    text(0.1,0.5,title_1,'fontsize',28)
    drawnow
    
function  close_all_figures

	childn = get(0,'children');
	ind = find((childn-fix(childn))==0);
	close(childn(ind));
     