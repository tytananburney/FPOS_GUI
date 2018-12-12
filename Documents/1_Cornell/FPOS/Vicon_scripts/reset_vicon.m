function handles = reset_vicon(handles)
%Clear data from last run, reset indecies, reset plots, and create a new
%log file

%Reset temporary data storage
handles.vicon.time = zeros(1,5000);
handles.vicon.posx = zeros(1,5000);
handles.vicon.posy = zeros(1,5000);
handles.vicon.posz = zeros(1,5000);
handles.vicon.roll = zeros(1,5000);
handles.vicon.pitch = zeros(1,5000);
handles.vicon.yaw = zeros(1,5000);

%Reset data index
handles.vicon.k = 1;
handles.vicon.lefttime = 1;
handles.vicon.starttime = -1;

%Reset plots
xlim(handles.euler,[0 10]);
xlim(handles.position,[0 10]);

%Get Starting time
handles.vicon.startdate = datestr(now);



