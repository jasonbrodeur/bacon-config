%===============================================================
function c = MCM3_init_all(dateIn)
%===============================================================
% 
% (c) Zoran             File created:       Apr 3, 2008
%                       Last modification:  Jan 18, 2009
%
%
%   Revisions:
%
%  - May 5, 2009 (Zoran)
%       added: c.System(nMainEddy).Alignment.Enable = 1;
%       for compatibility with new functions
%
%  - Jan 18, 2010 (JJB)
%  - modified c.ext to look for uppercase "D" in extension
%  - This was causing a problem with running hf data calculations on linux
%  systems, as data files had a capital "D" and not lowercase "d"
%

try
    
Dates    = zeros(1,100);
% All times are GMT
Dates(1) = datenum(2008,5,1,0,30,0);  % ini file initiated for this date

% The following line needs to be changed when dateIn becomes datenum (not a string yyyymmddQQ)
dateIn = datenum(str2num(dateIn(1:4)),str2num(dateIn(5:6)),str2num(dateIn(7:8)),str2num(dateIn(9:10))/96*24,0,0);

%-------------------------------
% Common 
%-------------------------------
c.PC_name       = fr_get_pc_name;
[c.path,c.hhour_path,c.database_path] = fr_get_local_path;
c.ext           =  '.DMCM3';  %'.dMCM3';
c.hhour_ext     = '.hMCM3.mat';
c.site          = 'MCM3';
localPCname	  = fr_get_pc_name;
c.gmt_to_local = -5/24;                 %(5-hour GMT offset for EST)

% Instrument numbers in the order of their dependency
% (independent first)
nPDQ        = 1;     % PDQ3000
nTc         = 2;     % Thermocouples (depend on PDQ)
nIRGA       = 3;     % LI-6262 IRGA (depends on PDQ & IRGA pressure)
nSONIC      = 4;     % Serially logged sonic
nMET        = 5;     % climate file
nTair_site  = 6;
nPb_site    = 7;

nMainEddy   = 1;

% Variables listed within this section will become part of the
% fr_p_bar is used here to correct pressure (measured in a hut)
if strcmp(c.PC_name, 'TP02_PC')
    c.MiscVariables(1).Name             = 'BarometricP';
	c.MiscVariables(1).Execute          = {'miscVar = 101.3;'};                 % use constant barometric pressure of 101.3 kPa, correct fluxes 
else
c.MiscVariables(1).Name             = 'BarometricP';
c.MiscVariables(1).Execute          = {['nTair = ' num2str(nTair_site) ';'],...           
      ['nPb = ' num2str(nPb_site) ';'],...
       'miscVar = fr_p_bar(Instrument_data(nPb).EngUnits,3,Instrument_data(nTair).EngUnits);'};

c.MiscVariables(2).Name             = 'Tair';
c.MiscVariables(2).Execute          = {['nTair = ' num2str(nTair_site) ';'],...       
    	'miscVar = Instrument_data(nTair).EngUnits;'}; 
end
%------------------------------------------------
% All instruments
% (sort them by their dependencies -> independent
%  calculations first)
%------------------------------------------------

%-----------------------
% PDQ3000 #1 definitions:
%-----------------------
c.Instrument(nPDQ).Name      = 'PDQ3000';
c.Instrument(nPDQ).Type      = 'PDQ3000';
c.Instrument(nPDQ).SerNum    = 0;
c.Instrument(nPDQ).FileID    = '1';
c.Instrument(nPDQ).FileType  = 'Digital2'; % Digital1 - the original binary format (no header info)
c.Instrument(nPDQ).Fs        = 20;         % sampling frequency for the DAQbook
c.Instrument(nPDQ).Oversample = 6;         % used when resampling. Use 6 if a 20.8833Hz system is mixed with 20Hz system.
								           % That gives a resample ratio of 125/120. Not needed if all Fs are matched.                                
c.Instrument(nPDQ).ChanNumbers = [1:2];
c.Instrument(nPDQ).NumOfChans  = length(c.Instrument(nPDQ).ChanNumbers);
c.Instrument(nPDQ).Poly        = [ 1000*ones(c.Instrument(nPDQ).NumOfChans,1) zeros(c.Instrument(nPDQ).NumOfChans,1)];    % convert to mV];        %
c.Instrument(nPDQ).Poly(6,:)   = [1 0];    % make sure that w signal has gain 1
c.Instrument(nPDQ).ChanNames = {'w', 'Tc1'};
c.Instrument(nPDQ).ChanUnits = {'m/s','mV'};
c.Instrument(nPDQ).Alignment.Type = '';              % this instrument (Slave) will be aligned with the Master
c.Instrument(nPDQ).Alignment.ChanNum = 0;            % chanel used for the alignment

%-----------------------
% Barometer
%-----------------------
%c.Instrument(nPb).Name       = 'Barometer';
% c.Instrument(nPb).Type       = 'Vaisala';
% c.Instrument(nPb).SerNum     = 0;
% c.Instrument(nPb).FileType   = 'Instrument';    % "Instrument" type file mean that an actual instrument should be used
% c.Instrument(nPb).FileID     = num2str(nPDQ);   % instead of a real file (in this case Instrument - DAQbook
% c.Instrument(nPb).Fs         = c.Instrument(str2num(c.Instrument(nPb).FileID)).Fs;           % Frequency of sampling for the sonic
% c.Instrument(nPb).Oversample = c.Instrument(str2num(c.Instrument(nPb).FileID)).Oversample;   % 
% c.Instrument(nPb).ChanNumbers = [20];  
% c.Instrument(nPb).NumOfChans = length(c.Instrument(nPb).ChanNumbers);  
% c.Instrument(nPb).ChanNames  = {'Pbarometric'};
% c.Instrument(nPb).ChanUnits  = {'kPa'};
% c.Instrument(nPb).Poly       = [0.0092 60];
% c.Instrument(nPb).Delays.Samples = [0];
% c.Instrument(nPb).ProcessData = {['nPb = ' num2str(nPb) ';'],...    
%       'Instrument_data(nPb).EngUnits = filtfilt(fir1(10,0.1),1,Instrument_data(nPb).EngUnits);'};
% c.Instrument(nPb).CovChans   = [];
% c.Instrument(nPb).Alignment.Type = '';
% c.Instrument(nPb).Alignment.ChanNum = []; 

%-----------------------
% Thermocouples
%-----------------------
c.Instrument(nTc).Name       = 'EC Thermocouple';
c.Instrument(nTc).Type       = 'TheromcoupleE'; % Don't use TcE type.  That is predefined type for DAQbook TCs not for PDQ.
c.Instrument(nTc).SerNum     = 0;
c.Instrument(nTc).FileType   = 'Instrument';    % "Instrument" type file mean that an actual instrument should be used
c.Instrument(nTc).FileID     = num2str(nPDQ);   % instead of a real file (in this case Instrument - DAQbook
c.Instrument(nTc).Fs         = c.Instrument(str2num(c.Instrument(nTc).FileID)).Fs;           % Frequency of sampling for the sonic
c.Instrument(nTc).Oversample = c.Instrument(str2num(c.Instrument(nTc).FileID)).Oversample;   % 
c.Instrument(nTc).ChanNumbers = [1 2];  
c.Instrument(nTc).NumOfChans = length(c.Instrument(nTc).ChanNumbers);  
c.Instrument(nTc).ChanNames  = {'Tc1','w'};
c.Instrument(nTc).ChanUnits  = {'degC','m/s'};
c.Instrument(nTc).Poly       = [];
c.Instrument(nTc).Delays.Samples = [0];
c.Instrument(nTc).CovChans   = [1];
c.Instrument(nTc).Alignment.Type = 'Slave';
c.Instrument(nTc).Alignment.ChanNum = [2];         % chanel used for the alignment (use PDQ w to match with digital input w from CSAT)
c.Instrument(nTc).Alignment.Span = [-60 60];     % 
c.Instrument(nTc).Alignment.Shift = 0;            % 


%-----------------------
% IRGA LI-7000 definitions:
%-----------------------
c.Instrument(nIRGA).Name      = 'EC IRGA';
c.Instrument(nIRGA).Type      = '7000';
c.Instrument(nIRGA).SerNum    = 738;             % add 001 to the end of the actual SN to signify which calibration is used (see licor.m)
c.Instrument(nIRGA).FileID    = '3';
c.Instrument(nIRGA).FileType  = 'Digital2';         % 
c.Instrument(nIRGA).Fs         = 20;           % Frequency of sampling for the sonic
c.Instrument(nIRGA).Oversample = 6;   % 
c.Instrument(nIRGA).ChanNumbers = [1:6];              
c.Instrument(nIRGA).NumOfChans = length(c.Instrument(nIRGA).ChanNumbers);
c.Instrument(nIRGA).ChanNames = {'co2','h2o','Tbench','Plicor','Pgauge','w_CSAT3','diag'};
c.Instrument(nIRGA).ChanUnits = {'umol/mol','mmol/mol','degC','kPa','kPa','m/s','1'};
c.Instrument(nIRGA).Poly      =  [];
c.Instrument(nIRGA).CovChans  = [1 2];
c.Instrument(nIRGA).Delays.Samples = [14 15];		   % JJB changed this on May 13, 2010 - he had changed it before from [] to [11 14], and now has changed it back.
c.Instrument(nIRGA).Alignment.Type = 'Slave';              % this instrument (Slave) will be aligned with the Master
c.Instrument(nIRGA).Alignment.ChanNum = [6];               % chanel used for the alignment (use DAQ w2 to match with digital input w1 from Gill)
c.Instrument(nIRGA).Alignment.Shift = 0; 			% added by JJB, July 15, 2010
c.Instrument(nIRGA).Alignment.Span = [-100 100]; 		% added by JJB, July 15, 2010
c.Instrument(nIRGA).Alignment.MaxAutoSampleReduction = 3; 	% added by JJB, July 15, 2010 % Changed to current value 3 on Sep 8, 2010 by JJB on advice of Zoran

s = warning;
warning off;
if 1==2  % disable calibrations for the time being so I can test the rest of the program (Z, Sep 10, 2007)
     [c.Instrument(nIRGA).Cal.CO2,...
            c.Instrument(nIRGA).Cal.H2O] = fr_get_Licor_cal(char(c.site),dateIn,2);
else
    c.Instrument(nIRGA).Cal.CO2 = [1 0];
    c.Instrument(nIRGA).Cal.H2O = [1 0];
end
warning(s);

%-----------------------
% Sonic - serially logged
%-----------------------
c.Instrument(nSONIC).Type       = 'CSAT3';
c.Instrument(nSONIC).SerNum     = 1545;
c.Instrument(nSONIC).FileType   = 'Digital2'; 
c.Instrument(nSONIC).FileID     = '2';               % String!
c.Instrument(nSONIC).Fs         = 20;                % Frequency of sampling
c.Instrument(nSONIC).Poly       =  [];
c.Instrument(nSONIC).Oversample = 6;                 % 
c.Instrument(nSONIC).ChanNumbers = [1:5];            % chans to read from
c.Instrument(nSONIC).NumOfChans = length(c.Instrument(nSONIC).ChanNumbers);
c.Instrument(nSONIC).ChanNames  = {'u','v','w','T_sonic','diag'};
c.Instrument(nSONIC).ChanUnits  = {'m/s','m/s','m/s','degC','1'};
c.Instrument(nSONIC).Delays.Samples = [0 0 0 0];
c.Instrument(nSONIC).CovChans     = [1 2 3 4];
c.Instrument(nSONIC).Orientation  = 0;                % degrees from North 
c.Instrument(nSONIC).Alignment.Type = 'Master';       % all instruments get aligned to this instrument (Master)
c.Instrument(nSONIC).Alignment.ChanNum = 3;
c.Instrument(nSONIC).Alignment.Span = [-200 200];     % chanel used for the alignment (use DAQ w2 to match with digital input w1 from Gill)
c.Instrument(nSONIC).Alignment.Shift = [0]; 			% added by JJB, July 15, 2010
c.Instrument(nSONIC).Alignment.MaxAutoSampleReduction = [3]; 	% added by JJB, July 15, 2010 % Changed to current value 3 on Sep 8, 2010 by JJB on advice of Zoran


%-----------------------
% Met data definitions:
%-----------------------
c.Instrument(nMET).Name       = 'Site Met Data';
c.Instrument(nMET).Type       = 'CSI';
c.Instrument(nMET).FileType   = 'MET';        %
c.Instrument(nMET).FileID     = num2str(nMET);               % String!
c.Instrument(nMET).Fs         = 1/1800;                % Frequency of sampling
c.Instrument(nMET).Oversample = 1;                 % 
c.Instrument(nMET).ChanNumbers = [23,28,53,77,78];            % chans to read from
c.Instrument(nMET).NumOfChans = length(c.Instrument(nMET).ChanNumbers);
c.Instrument(nMET).TableID    = [105];
c.Instrument(nMET).ChanNames  = {'WindSpeed','WindDir','Pbar','Tair','Rh'};
c.Instrument(nMET).ChanUnits  = {'m/s','deg','kPa','^oC','%'};

%-----------------------
% Site barometer
%-----------------------
c.Instrument(nPb_site).Name       = 'Barometer';
c.Instrument(nPb_site).Type       = 'From MET file';
%%%%%%%%%%%%%%% Following changed by JJB, 20180324 -non-commented lines pulled from MCM1_init_all.m
% c.Instrument(nPb_site).FileType   = 'Instrument';    % "Instrument" type file mean that an actual instrument should be used
% c.Instrument(nPb_site).FileID     = num2str(nMET);   %
% c.Instrument(nPb_site).Fs         = c.Instrument(str2num(c.Instrument(nMET).FileID)).Fs;           % Frequency of sampling 
% c.Instrument(nPb_site).Oversample = c.Instrument(str2num(c.Instrument(nMET).FileID)).Fs;   % 
% c.Instrument(nPb_site).ChanNumbers = [3];  
% c.Instrument(nPb_site).NumOfChans = length(c.Instrument(nPb_site).ChanNumbers);  
% c.Instrument(nPb_site).ChanNames  = {'Pbarometric'};
% c.Instrument(nPb_site).ChanUnits  = {'kPa'};
c.Instrument(nPb_site).FileType   = 'TurkeyPointClim';    % Changed by JJB, 20180324
	c.Instrument(nPb_site).FileID     = '';   % (this is the datalogger database files)
	c.Instrument(nPb_site).Fs         = 1;           % Frequency of sampling 
	c.Instrument(nPb_site).Oversample = 0;   % 
	c.Instrument(nPb_site).ChanNumbers = [1];  
	c.Instrument(nPb_site).NumOfChans = 1;  
	c.Instrument(nPb_site).ChanNames  = {'Pressure'};
	c.Instrument(nPb_site).ChanUnits  = {'kPa'};
	c.Instrument(nPb_site).Delays.Samples = [0];
	c.Instrument(nPb_site).ProcessData = {['nPb_site = ' num2str(nPb_site) ';'],...
      'Instrument_data(nPb_site).EngUnits = Instrument_data(nPb_site).EngUnits(2);'...
      };
	c.Instrument(nPb_site).CovChans   = [];
	c.Instrument(nPb_site).Alignment.Type = '';
	c.Instrument(nPb_site).Alignment.ChanNum = [];  
	
%-----------------------
% Site air temperature (best measurement of thermodynamic air temperature)
%-----------------------
c.Instrument(nTair_site).Name       = 'Tair';
c.Instrument(nTair_site).Type       = 'From MET file';
c.Instrument(nTair_site).SerNum     = 0;
%%%%%%%%%%%%%%% Following changed by JJB, 20180324 -non-commented lines pulled from MCM1_init_all.m
% c.Instrument(nTair_site).FileType   = 'Instrument';    % "Instrument" type file mean that an actual instrument should be used
% c.Instrument(nTair_site).FileID     = num2str(nMET);   %
% c.Instrument(nTair_site).Fs         = c.Instrument(str2num(c.Instrument(nTair_site).FileID)).Fs;           % Frequency of sampling 
% c.Instrument(nTair_site).Oversample = c.Instrument(str2num(c.Instrument(nTair_site).FileID)).Fs;   % 
% c.Instrument(nTair_site).ChanNumbers = [4];  
% c.Instrument(nTair_site).NumOfChans = length(c.Instrument(nTair_site).ChanNumbers);  
% c.Instrument(nTair_site).ChanNames  = {'T_air'};
% c.Instrument(nTair_site).ChanUnits  = {'degC'};
c.Instrument(nTair_site).FileType   = 'TurkeyPointClim';    % "Instrument" type file mean that an actual instrument should be used
	c.Instrument(nTair_site).FileID     = '';   % (this is the datalogger database files)
	c.Instrument(nTair_site).Fs         = 1;           % Frequency of sampling 
	c.Instrument(nTair_site).Oversample = 0;   % 
	c.Instrument(nTair_site).ChanNumbers = [1];  
	c.Instrument(nTair_site).NumOfChans = 1;  
	c.Instrument(nTair_site).ChanNames  = {'Ta'};
	c.Instrument(nTair_site).ChanUnits  = {'degC'};
	c.Instrument(nTair_site).Delays.Samples = [0];
	c.Instrument(nTair_site).ProcessData = {['nTair_site = ' num2str(nTair_site) ';'],...
      'Instrument_data(nTair_site).EngUnits = Instrument_data(nTair_site).EngUnits(1);'...
      };
	c.Instrument(nTair_site).CovChans   = [];
	c.Instrument(nTair_site).Alignment.Type = '';
	c.Instrument(nTair_site).Alignment.ChanNum = []; 


%------------------------------------------------
% Main Eddy system
%
%------------------------------------------------
c.System(nMainEddy).ON 		       = 1;                        % system #1 calculations are ON
c.System(nMainEddy).Type            = 'Eddy';                   % eddy correlation system
c.System(nMainEddy).Name            = 'Main EC systen, MCM3 site';            % long system name
c.System(nMainEddy).FieldName       = 'MainEddy';               % this is the output structure field name for all the system stats
c.System(nMainEddy).Rotation        = 'Three';                    % do three rotations
c.System(nMainEddy).Fs              = 20;                       % sampling freq. for the system 
% c.System(nMainEddy).Instrument      = [nSONIC nIRGA nTc];       % select instruments (Anemometer + IRGA) for system 1
c.System(nMainEddy).Instrument      = [nSONIC nIRGA];       % select instruments (Anemometer + IRGA) for system 1

c.System(nMainEddy).MaxFluxes       = 15;
c.System(nMainEddy).MaxMisc         = 15;
c.System(nMainEddy).Delays.RefChan  = 3;                    % Delays calculated against this channel (T sonic)
c.System(nMainEddy).Delays.ArrayLengths = [inf inf];        % the num of points used [ RefChan  DelayedChan]
c.System(nMainEddy).Delays.Span = 40;                       % max LAG (see fr_delay.m)
c.System(nMainEddy).Delays.Channels = [5 6];                % Delays calculated on channels 5 and 6 (CO2 and H2O) 
c.System(nMainEddy).Delays.Overide = 1;						% Overide delays to those calculated
%c.System(nMainEddy).Alignment.Enable = 1;                   % 
c.System(nMainEddy).Alignment.Enable = 'FALSE';                   	% updated by JJB on Nov 01, 2017. Commented line above
c.System(nMainEddy).Alignment.SampleLength = [5000]; 	% added by JJB, July 15, 2010
c.System(nMainEddy).Alignment.MaxAutoSampleReduction = [3]; 	% added by JJB, July 15, 2010

%------------------------------------------------
% Extra system analysis
% See fr_calc_spectra, fr_calc_spikes and fr_calc_stationarity
% for default parameters 
%------------------------------------------------
c.ExtraCalculations = [];

c.Spectra.ON 	   = 1;
c.Spikes.ON        = 1;
c.Stationarity.ON  = 0;

%------------------------------------------------
% Short file information
%
%------------------------------------------------

% Do not create short files for this system.  Uncomment the lines
% below to create short files.

% c.Shortfiles.Remove(1).System       = 'MainEddy'; %from this 'system' field remove the following fields below
% c.Shortfiles.Remove(1).Fields       = {'Zero_Rotations', ...
%       'Stationarity', ...
%       'Turbulence_Statistics'};
% c.Shortfiles.Remove(1).ProcessData  = {'for k = 1:length(st); st(k).MainEddy.Spectra = []; end;',...
%       'for k = 1:length(st); st(k).MainEddy.Three_Rotations.LinDtr = []; end',...
%       'for k = 1:length(st); st(k).MainEddy.Three_Rotations.AvgDtr.Cov = []; end',...
%    };
% c.Shortfiles.Remove(2).System       = 'Instrument'; %from this 'system' field remove the following fields below
% c.Shortfiles.Remove(2).Fields       = {'Name',...
%     'Type',...
%     'SerNum',...
%     'ChanNames',...
%     'ChanUnits',...
%     'Std'};
% 

catch
    disp(sprintf('Error in MCM3_init_all.m.  Input dateIn: %s',dateIn))
    disp('------------ error message -----------------------')
    disp(lasterr)
    disp('------------ error message -----------------------')
end
