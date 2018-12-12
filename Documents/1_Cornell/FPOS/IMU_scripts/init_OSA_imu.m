function handles = init_OSA_imu(handles,collect_time)
%Sends a message to the Raspberry Pi, telling it to turn on the IMU

if nargin < 2
    collect_time = 7200;
end

%Set mode = 0 to generate fake data for testing purposes
mode = 1;

%Use a default sample rate of 125 samples/sec.
samplerate = 125;
dsample = 10;
filename = ['Test_Data/',datestr(now,'mmm_dd'),'/',handles.flog_symbol,datestr(now,'HH_MM_SS'),'_osa_log.csv'];

if mode == 1
    
    disp('**OPERATING IN OSA NORMAL MODE**');
    
    %Open a socket connection to the OSA
    fopen(handles.osa.u);
    
    %Send IMU commands
    unixtime = posixtime(datetime('now','TimeZone','UTC'));
    fwrite(handles.osa.u,['/dev/ttyUSB0,',num2str(collect_time),',',filename,',',num2str(samplerate),',',num2str(dsample),',',num2str(unixtime)]);
    
    %Read the first 8 bytes sent back
    reply = fread(handles.osa.u,8);
    if strcmp('Approved',char(reply'))
        disp('**OSA Successfully Started**');
    else
        warning('**OSA did not recieve start command**');
        fclose(handles.osa.u);
    end
    
else
    
    disp('**OPERATING IN OSA TEST MODE**');
    !python PythonFiles/test_TCPclient.py &
    
end

disp('OSA IMU started');

end