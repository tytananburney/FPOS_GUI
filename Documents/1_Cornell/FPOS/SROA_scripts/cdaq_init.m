function daqSession = cdaq_init()
%Create a DAQ session. Specify for how many data points to collect per second.
    daqSession = daq.createSession('ni');
%     sample_rate = 1;
    daqSession.Rate = 4;
%     daqSession.DurationInSeconds = 10;
    disp('DAQ ready');
    %Tell the Session which analog inputs to read from
    ch0 = addAnalogInputChannel(daqSession,'cDAQ2Mod3','ai0','voltage');
    ch1 = addAnalogInputChannel(daqSession,'cDAQ2Mod3','ai1','voltage');
    ch2 = addAnalogInputChannel(daqSession,'cDAQ2Mod3','ai2','voltage');
    ch3 = addAnalogInputChannel(daqSession,'cDAQ2Mod3','ai3','voltage');
    ch4 = addAnalogInputChannel(daqSession,'cDAQ2Mod3','ai4','voltage');
    ch7 = addAnalogInputChannel(daqSession,'cDAQ2Mod3','ai7','voltage');
    ch8 = addAnalogInputChannel(daqSession,'cDAQ2Mod3','ai16','voltage');
    
    
    % create and open a SROA log file
    %SROA_fid = fopen('SROA_thermal_data.txt','w');
    %fprintf(SROA_fid,'Time [sec] \t Cold tip [K] \t SC diode 1 [K] \t SC diode 2 [K] \t SC diode 3 [K] \t Pressure [Torr] \t Thermocouple 1 [C] \t Thermocouple 2 [C]\n');
    

%SingleEnded => One terminal of the thermocouple is connected to ai0...2,
%and the other is connected to ground.
% ch7.InputType = 'SingleEndedNonReferenced';
% ch8.InputType = 'SingleEndedNonReferenced';
ch7.InputType = 'Differential';
ch8.InputType = 'Differential';