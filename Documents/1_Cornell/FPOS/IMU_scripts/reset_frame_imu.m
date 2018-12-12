function handles = reset_frame_imu(handles)
%Clear data from last run, reset indecies, reset plots, and create a new
%log file

%Reset temporary data storage
handles.frame.sample_num = zeros(1,5000);
handles.frame.time = zeros(1,5000);
handles.frame.Ax = zeros(1,5000);
handles.frame.Ay = zeros(1,5000);
handles.frame.Az = zeros(1,5000);
handles.frame.Gx = zeros(1,5000);
handles.frame.Gy = zeros(1,5000);
handles.frame.Gz = zeros(1,5000);

%Reset data index
handles.frame.k = 1;
handles.frame.lefttime = 1;
handles.frame.starttime = -1;

%Reset plots
xlim(handles.facc_time,[0 10]);
xlim(handles.fangv_time,[0 10]);

%Create Log File
handles.frame.fid = fopen(handles.frame.filename,'w');

%Write Log File Header Information
fprintf(handles.frame.fid,'M-G362 CSV Log File,Frame IMU\n');
fprintf(handles.frame.fid,'Creation Date:,%s\n',datestr(now));
fprintf(handles.frame.fid,'Scaled 32-bit Data,SF_GYRO=+0.0050/2^16 dps/lsb,SF_ACCL=+0.125/2^16 mg/lsb,SF_TEMP=+0.0042724/2^16 degC/lsb\n');
fprintf(handles.frame.fid,'Scaled 32-bit Data,Gx[dps],Gy[dps],Gz[dps],Ax[mG],Ay[mG],Az[mG],Ts[deg.C],Counter[dec],Error\n');

%Open socket connection
fopen(handles.frame.u);
disp('Socket Opened');

%Get Starting time
handles.frame.startdate = datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF');



