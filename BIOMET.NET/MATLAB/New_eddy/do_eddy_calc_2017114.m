function [Stats_single,miscVariables] = do_eddy_calc(EngUnits,miscVariables,configIN,SystemNum,currentDate)

%Revisions: 
% June 26, 2008 (Nick/Zoran)
%   - Added MiscVariables to fr_calc_eddy as an input and an output parameter, and
%     as an output parameter to this function, to enable the program
%   to keep track of which Tair and Pbarometric were actually used
%   Stats.MiscVariables
% kai* Oct 18, 2004 - changed handling of spectra, spikes and stationarity
% so they take default values. Always rotate HF data before stationarity
% test
% kai* Feb 16, 2005 - made configIN.System(SystemNum).Delays.ArrayLengths
% == length(Eddy_HF_data) possible
% - Moved delay removal to fr_create_system_data

Stats_single = [];

% STEP - Get misc. variables for calculations
BarometricP = fr_get_BarometricP(miscVariables);
Tair        = fr_get_mean_Tair(miscVariables);
Krypton     = fr_get_Krypton_chan(configIN);

% STEP - Get HF data
%            Eddy_HF_data = EngUnits(:,configIN.System(SystemNum).CovVector);           Replaced this line with
Eddy_HF_data = EngUnits;                                                   % this one on Oct 24, 2002

% STEP - Calculate spikes, despike if selected
if configIN.System(SystemNum).Spikes.ON == 1 
    configIN.Spikes.Fs = configIN.System(SystemNum).Fs; %set spectra calc frequency to that of system
    [Spikes, Eddy_HF_data]  = fr_calc_spikes(Eddy_HF_data,configIN);    
end

% !!! DELAYS ARE ALL REMOVED AT THIS POINT !!!
% These two steps have been moved to fr_create_system_data 
% STEP - Calculate Delay times
% STEP - Overide delays to those just calculated
% Therefore delays are set empty, i.e. no shift is done in fr_calc_eddy.
Eddy_HF_delay = [];

% STEP - Do basic statistics and covariances
[EddyStats,junk,miscVariables]   = fr_calc_eddy(Eddy_HF_data, Eddy_HF_delay,...
    configIN.System(SystemNum).Rotation, BarometricP, Krypton,Tair,miscVariables);  

% Add all fields to Stats_single
fNames = fieldnames(EddyStats);
for ifields = 1:length(fNames);
    Stats_single = setfield(Stats_single,{1},char(fNames(ifields)),getfield(EddyStats,char(fNames(ifields))));
end
%Stats_single = setfield(Stats_single,{1},'EddyStats',EddyStats);

% STEP - Add spikes, delays field to Eddy_results
if configIN.System(SystemNum).Spikes.ON == 1 
    Stats_single = setfield(Stats_single,{1},'Spikes',Spikes);
end

% STEP - Delay and Rotate the high frequency data before calculation of spectra and stationarity
if configIN.System(SystemNum).Spectra.ON == 1 | configIN.System(SystemNum).Stationarity.ON == 1
    [Eddy_HF_data] = fr_rotatn_hf(Eddy_HF_data,[Stats_single.Three_Rotations.Angles.Eta ...
            Stats_single.Three_Rotations.Angles.Theta Stats_single.Three_Rotations.Angles.Beta]);      
end


% STEP - Calculate stationarity
if configIN.System(SystemNum).Stationarity.ON == 1
    configIN.Stationarity.Fs = configIN.System(SystemNum).Fs; %set spectra calc frequency to that of system
    Stationarity_single   = fr_calc_stationarity(Eddy_HF_data, Eddy_HF_delay, configIN); 
    Stats_single = setfield(Stats_single,{1},'Stationarity',Stationarity_single);
end

% STEP - Calculate spectra
if configIN.System(SystemNum).Spectra.ON == 1 
    configIN.Spectra.Fs     = configIN.System(SystemNum).Fs; %set spectra calc frequency to that of system
    Spectra_single  = fr_calc_spectra(Eddy_HF_data, Eddy_HF_delay,configIN,[]); 
    Stats_single = setfield(Stats_single,{1},'Spectra',Spectra_single);
end



%STEP - Add selected setup info to Eddy_results
Stats_single = setfield(Stats_single,{1},'SourceInstrumentNumber',...
    getfield(configIN.System(SystemNum),'Instrument'));

Stats_single = setfield(Stats_single,{1},'SourceInstrumentChannel',...
    getfield(configIN.System(SystemNum),'CovVector'));                                
return




% STEP - Calculate correction factors
%Cfdeg_single   = fr_calc_cfdeg(Eddy_HF_data, Stats_all, c, currentDate);    

% STEP - Store results
%Stats_all = fr_cfdeg_add(currentDate,Cfdeg_single,c,Stats_all,c);   


%-----------------------------------------------------------------
function Stats_Out = eddy_calc_reorder_stats(Stats_In);     
Stats_Out.MiscVariables.NumOfSamples = Stats_In.DataLen;
Stats_Out.Zero_Rotations.Angles = Stats_In.Angles;
Stats_Out.Zero_Rotations.Avg = Stats_In.BeforeRot.AvgMinMax(1,:);
Stats_Out.Zero_Rotations.Min = Stats_In.BeforeRot.AvgMinMax(2,:);
Stats_Out.Zero_Rotations.Max = Stats_In.BeforeRot.AvgMinMax(3,:);
Stats_Out.Zero_Rotations.Std = Stats_In.BeforeRot.AvgMinMax(4,:);


%-----------------------------------------------------------------
function BarometricP = fr_get_BarometricP(miscVariables);
if isfield(miscVariables,'BarometricP')
    BarometricP = miscVariables.BarometricP;
    if isnan(BarometricP) | abs(BarometricP) > 110 | abs(BarometricP) < 80;
        BarometricP = [];
    end
else
    BarometricP = [];
end

%-----------------------------------------------------------------
function Tair        = fr_get_mean_Tair(miscVariables)
if isfield(miscVariables,'Tair')
    Tair = miscVariables.Tair;
    if isnan(Tair) | abs(Tair) == 0 ;
        Tair = [];
    end
else
    Tair = [];
end

%-----------------------------------------------------------------
function Krypton     = fr_get_Krypton_chan(configIN)
Krypton = [];



