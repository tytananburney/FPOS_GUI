function [handles] = setup_Frame_Plots(handles)
% Formate plots for the frame IMU, including plot titles, labels, and axes

%Create socket to listen on
handles.frame.u = udp('127.0.0.1','LocalPort',9556);
handles.frame.u.InputBufferSize = 512;

%% Create Acceleration Plot
%facc_time: the handle of the frame acceleration plot

handles.frame.Ax_axis = plot(handles.facc_time,0,nan(1),'-r');
hold(handles.facc_time,'on');
handles.frame.Ay_axis = plot(handles.facc_time,0,nan(1),'-b');
handles.frame.Az_axis = plot(handles.facc_time,0,nan(1),'-k');
hold(handles.facc_time,'off');

title(handles.facc_time,'Frame Acceleration-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.facc_time,'Time, t (s)');
ylabel(handles.facc_time,'Acceleration, a (m/s^2)');
%legend(handles.facc_time,'Ax', 'Ay', 'Az');

axis(handles.facc_time,'manual');
box(handles.facc_time,'on');

xlim(handles.facc_time,[0 10]);
ylim(handles.facc_time,[-1500 1500]);


%% Create Angular Velocity Plot
%fangv_time: the handle of the frame angular velocity plot

handles.frame.Gx_axis = plot(handles.fangv_time,0,nan(1),'-r');
hold(handles.fangv_time,'on');
handles.frame.Gy_axis = plot(handles.fangv_time,0,nan(1),'-b');
handles.frame.Gz_axis = plot(handles.fangv_time,0,nan(1),'-k');
hold(handles.fangv_time,'off');

title(handles.fangv_time,'Frame Angular Velocity-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.fangv_time,'Time, t (s)');
ylabel(handles.fangv_time,'Angular Velocity, \omega (deg/s)');
% legend(handles.fangv_time,'Gx', 'Gy', 'Gz');

axis(handles.fangv_time,'manual');
box(handles.fangv_time,'on');

xlim(handles.fangv_time,[0 10]);
ylim(handles.fangv_time,[-150 150]);


%% Pre-allocate Data for Plots
%Creates new fields in the handles structure
%so that this data can be used in other functions in this GUI

handles.frame.sample_num = zeros(1,5000);
handles.frame.time = 1:5000;
handles.frame.Gx = zeros(1,5000);
handles.frame.Gy = zeros(1,5000);
handles.frame.Gz = zeros(1,5000);
handles.frame.Ax = zeros(1,5000);
handles.frame.Ay = zeros(1,5000);
handles.frame.Az = zeros(1,5000);

%% Other variables for updating plots
handles.frame.k = 1;
handles.frame.idx = 1;
handles.frame.starttime = -1;
handles.frame.lefttime = 1;

%Frame Plots will update every 1/n sample points
handles.frame.plotDownSample = 10;

