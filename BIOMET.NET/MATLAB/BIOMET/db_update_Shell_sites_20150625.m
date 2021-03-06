function db_update_Shell_sites(yearIn,sites);

% renames Shell logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array)

% file created: Nov 25, 2010       last modified:  July 15, 2014
% (c) Nick Grant

% revisions:
% June 8, 2015
%   -add processing for One Minute Avg files after Zoran added a new program table.
%
dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'SQT'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)
        
        siteId = char(sites{j});
        eval(['progressListShell_' siteId '_Clim_30min_Pth = fullfile(pth_db,''' siteId ...
            '_Clim_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_ClimatDatabase_Pth = [pth_db ''yyyy\' siteId...
            '\Climate\''];']);
        eval(['progressListShell_' siteId '_EC_Pth = fullfile(pth_db,''' siteId ...
            '_EC_flux_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_ECDatabase_Pth = [pth_db ''\yyyy\' siteId...
              '\Flux_Logger\''];']);
          
        % one minute avg update
        eval(['progressListShell_' siteId '_Clim_OneMinute_Pth = fullfile(pth_db,''' siteId ...
            '_Clim_1min_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_OneMinuteDatabase_Pth = [pth_db ''yyyy\' siteId...
            '\Climate\1min\''];']);
        

         % covariances pth and progress lists
        eval(['progressListShell_' siteId '_ECcomp_cov_Pth = fullfile(pth_db,''' siteId ...
            '_ECcomp_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_ECcompCov_Database_Pth = [pth_db ''yyyy\' siteId...
             '\Flux_Logger\''];']);
        
        eval(['progressListShell_' siteId '_Tc_cov_Pth = fullfile(pth_db,''' siteId ...
            '_Tc_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_TcCovDatabase_Pth = [pth_db ''yyyy\' siteId...
            '\Flux_Logger\''];']);
        
        eval(['progressListShell_' siteId '_Ts_cov_Pth = fullfile(pth_db,''' siteId ...
            '_Ts_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_TsCovDatabase_Pth = [pth_db ''yyyy\' siteId...
            '\Flux_Logger\''];']);
         
         
        filePath = sprintf('d:\\sites\\%s\\CSI_net\\old\\',siteId);

        datFiles = dir(fullfile(filePath,'*.dat'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),[datFiles(i).name(1:end-3) fileExt]);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_Clim_30m.*'',[],[],[],progressListShell_' siteId '_Clim_30min_Pth,Shell_' siteId '_ClimatDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s Clim:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_flux_30m.*'',[],[],[],progressListShell_' siteId '_EC_Pth,Shell_' siteId '_ECDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s EC:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
       
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_OneMinuteAvg.*'',[],[],[],progressListShell_' siteId '_Clim_OneMinute_Pth,Shell_' siteId '_OneMinuteDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s Clim 1min:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
	   % covariances
       
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_comp_cov.*'',[],[],[],progressListShell_' siteId '_ECcomp_cov_Pth,Shell_' siteId '_ECcompCov_Database_Pth,2);'])
        eval(['disp(sprintf('' %s EC_comp_cov:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
 
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_Tc_cov.*'',[],[],[],progressListShell_' siteId '_Tc_cov_Pth,Shell_' siteId '_TcCovDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s Tc_cov:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
     
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_Tscov.*'',[],[],[],progressListShell_' siteId '_Ts_cov_Pth,Shell_' siteId '_TsCovDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s Ts_cov:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
		convert_raw_logger_covariances_to_fluxes(yearIn,siteId);
        
        
        % extract and output daily 1 min averaged EC data for Brian
        % Sinfield (GMT)
        
        if strcmp(char(sites(j)),'SQM')
        doy_now = now-datenum(yearIn,1,0);
        st=doy_now-1;
        ed=doy_now;
        pth_1min = biomet_path(yearIn(k),'SQM','Climate\1min');
        pth_out = 'D:\Sites\SQM\export\';
        create_1min_avg(datenum(yearIn,1,st,0,30,0):datenum(yearIn,1,ed,0,30,0),pth_1min,pth_out);
        
        % export java variable files and footprint jpeg for SQ release
        % expt, June 2015
        pth_cfl = biomet_path(yearIn(k),'SQM','Flux_Logger\computed_fluxes');
        SQ_export_csv(pth_cfl,'D:\SITES\SQM\export\java_variables');
		run_SQ_footprint_hhourly('SQM',fr_round_time(now,'30min',3),'D:\SITES\SQM\export\footprint');
        end
    end %j 
    
end %k
