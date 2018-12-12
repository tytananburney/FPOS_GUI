function handles = reset_sroa_data(handles)
%Clear data from last run, reset indecies, reset plots, and create a new
%log file

%Reset temporary data storage
handles.sroa.time = zeros(1,5000);
handles.sroa.cold_tip = zeros(1,5000);
handles.sroa.SC1 = zeros(1,5000);
handles.sroa.SC2 = zeros(1,5000);
handles.sroa.pressure = zeros(1,5000);
handles.sroa.compressor = zeros(1,5000);
handles.sroa.expander = zeros(1,5000);

%Reset data index
handles.sroa.k = 1;
handles.sroa.lefttime = 1;
handles.sroa.starttime = -1;

%Reset plots
xlim(handles.press_time,[0 60]);
xlim(handles.cold_temp_time,[0 60]);
xlim(handles.warm_temp_time,[0 60]);

%Get Starting time
handles.sroa.startdate = datestr(now);



