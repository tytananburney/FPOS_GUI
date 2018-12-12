function [handles] = setup_OSA_Plots(handles)
%Setup osa plots, including titles, labels, and axes

%Create socket to listen on
%handles.osa.u = tcpip('10.0.0.200',2222);
handles.osa.u = udp('10.0.0.200',2222);

%% Create Acceleration Plot
%oacc_time: the handle of the frame acceleration plot

handles.osa.Ax_axis = plot(handles.oacc_time,0,nan(1),'-r');
hold(handles.oacc_time,'on');
handles.osa.Ay_axis = plot(handles.oacc_time,0,nan(1),'-b');
handles.osa.Az_axis = plot(handles.oacc_time,0,nan(1),'-k');
hold(handles.oacc_time,'off');

title(handles.oacc_time,'OSA Acceleration-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.oacc_time,'Time, t (s)');
ylabel(handles.oacc_time,'Acceleration, a (m/s^2)');
%legend(handles.oacc_time,'Ax', 'Ay', 'Az');

axis(handles.oacc_time,'manual');
box(handles.oacc_time,'on');

xlim(handles.oacc_time,[0 10]);
ylim(handles.oacc_time,[-1500 1500]);


%% Create Angular Velocity Plot
%angv_Time: the handle of the frame angular velocity plot

handles.osa.Gx_axis = plot(handles.angv_time,0,nan(1),'-r');
hold(handles.angv_time,'on');
handles.osa.Gy_axis = plot(handles.angv_time,0,nan(1),'-b');
handles.osa.Gz_axis = plot(handles.angv_time,0,nan(1),'-k');
hold(handles.angv_time,'off');

title(handles.angv_time,'OSA Angular Velocity-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.angv_time,'Time, t (s)');
ylabel(handles.angv_time,'Angular Velocity, \omega (deg/s)');
%legend(handles.angv_time,'Gx', 'Gy', 'Gz');

axis(handles.angv_time,'manual');
box(handles.angv_time,'on');

xlim(handles.angv_time,[0 10]);
ylim(handles.angv_time,[-150 150]);


%% Pre-allocate Data for Plots
%Creates new fields in the handles structure
%so that this data can be used in other functions in this GUI
handles.osa.sample_num = zeros(1,5000);
handles.osa.time = zeros(1,5000);
handles.osa.Gx = zeros(1,1000);
handles.osa.Gy = zeros(1,1000);
handles.osa.Gz = zeros(1,1000);
handles.osa.Ax = zeros(1,1000);
handles.osa.Ay = zeros(1,1000);
handles.osa.Az = zeros(1,1000);

%% Other variables for updating plots
handles.osa.k = 1;
handles.osa.idx = 1;
handles.osa.starttime = -1;
handles.osa.lefttime = 1;
handles.osa.filename = 'test_osa_data.csv';

%Plots will update every 1/n sample points
handles.osa.plotDownSample = 10;

