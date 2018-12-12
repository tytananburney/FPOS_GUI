function handles = reset_OSA_imu(handles)
%Clear osa data from last run, reset indecies, reset plots, create a new
%log file

%Reset temporary data storage
handles.osa.time = zeros(1,5000);
handles.osa.Ax = zeros(1,5000);
handles.osa.Ay = zeros(1,5000);
handles.osa.Az = zeros(1,5000);
handles.osa.Gx = zeros(1,5000);
handles.osa.Gy = zeros(1,5000);
handles.osa.Gz = zeros(1,5000);
handles.osa.temp = zeros(1,5000);
handles.osa.count = zeros(1,5000);
handles.osa.sample_num = zeros(1,5000);

%Reset data index
handles.osa.k = 1;
handles.osa.lefttime = 1;
handles.osa.starttime = -1;

%Reset plots
xlim(handles.oacc_time,[0 10]);
xlim(handles.angv_time,[0 10]);

%Create Log File
handles.osa.fid = fopen(handles.osa.filename,'w');

%Write Log File Header Information
fprintf(handles.osa.fid,'M-G362 CSV Log File,OSA IMU\n');
fprintf(handles.osa.fid,'Creation Date:,%s\n',datestr(now));
fprintf(handles.osa.fid,'Scaled 32-bit Data,SF_GYRO=+0.0050/2^16 dps/lsb,SF_ACCL=+0.125/2^16 mg/lsb,SF_TEMP=+0.0042724/2^16 degC/lsb\n');
fprintf(handles.osa.fid,'Scaled 32-bit Data,Gx[dps],Gy[dps],Gz[dps],Ax[mG],Ay[mG],Az[mG],Ts[deg.C],Counter[dec],Error\n');

%Get Starting time
handles.osa.startdate = datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF');
