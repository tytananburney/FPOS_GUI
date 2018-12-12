function handles = init_frame_imu(handles,collect_time)
%Tells the frame IMU to start recording data. Initiates a reset and self
%check on the IMU upon running. %Accepted times are 10 sec, 15 sec, 30 sec, 45 sec, 60 sec, 2 min, 5 min,
%and 10 minutes.

%Inputs:
%
%   collect_time    ----    the amount of time to collect for before
%                           automatically stopping (in seconds)

%Outputs:
%
%   error           ----    0: no errors, 1: IMU not started
%

%Make collect_time an optional argument.
if nargin < 2
    collect_time = 7200;
end

%Run the Frame IMU in the background. This ensures data will be collected
%at 125 Hz. (!<command> excutes in a command prompt in the background)

% Defaults to 60 minutes. I can add additional cases, but
%the way the syntax works for running in the background, the code can't
%accept a generic time. 

%Pressing Ctrl+C in the command window in the background will immediately 
%and safely halt data collection.

%Set mode = 1 for normal operation, mode = 0 for test mode
mode = 1;

if mode == 1
    display('**OPERATING IN FRAME NORMAL MODE**');
else
    display('**OPERATING IN FRAME TEST MODE**');
    collect_time = -1;
end

try
    switch collect_time
        case -1 %Test Mode           
            !python PythonFiles/test_G362_plotStreamMode32sec_frame.py &
        case 10
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 10 -d 125 &
        case 15
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 15 -d 125 &
        case 30
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 30 -d 125 &
        case 45
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 45 -d 125 &
        case 60
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 60 -d 125 &
        case 120
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 120 -d 125 &
        case 300
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 300 -d 125 &
        case 600
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 600 -d 125 &
        case 3600
            !python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -t 3600 -d 125 &
        otherwise
            logname = ['Test_Data\',datestr(now,'mmm_dd'),'\FlightLogs\',handles.flog_symbol,datestr(now,'HH_MM_SS'),'_frame_log.csv'];
            unixtime = posixtime(datetime('now','TimeZone','UTC'));
            downsample = 10;
            command_str = ['python PythonFiles/G362_plotStreamMode32sec_frame.py -s "COM3" -d 125 -t ',num2str(7200),' -o ',logname,' -z ', num2str(downsample),' &'];
            system(command_str);
    end
catch
    warning('IMU could not be started')
end

