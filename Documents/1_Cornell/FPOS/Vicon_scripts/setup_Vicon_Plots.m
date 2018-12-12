function [handles] = setup_Vicon_Plots(handles)

%Automatically turn on plot
% set(handles.vicon_check,'Value',1);
handles.vicon.on = 1;


%% Create Pressure Plot
% quaternion: the handle of the vicon quaternion plot

handles.vicon.roll_axis = plot(handles.euler,0,nan(1),'-r');
hold(handles.euler,'on');
handles.vicon.pitch_axis = plot(handles.euler,0,nan(1),'-g');
handles.vicon.yaw_axis = plot(handles.euler,0,nan(1),'-b');
hold(handles.euler,'off');

title(handles.euler,'OSA Body Fixed Euler Angles','FontSize',10,'FontWeight','bold');
xlabel(handles.euler,'Time, t (s)');
ylabel(handles.euler,'Angles');

axis(handles.euler,'auto');
box(handles.euler,'on');

xlim(handles.euler,[0 10]);



%% Create Position Plot

handles.vicon.posx_axis = plot(handles.position,0,nan(1),'-r');
hold(handles.position,'on');
handles.vicon.posy_axis = plot(handles.position,0,nan(1),'-g');
handles.vicon.posz_axis = plot(handles.position,0,nan(1),'-b');
hold(handles.position,'off');

title(handles.position,'OSA Position-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.position,'Time, t (s)');
ylabel(handles.position,'Position [mm]');

axis(handles.position,'auto');
box(handles.position,'on');
xlim(handles.position,[0 10]);

%% Pre-allocate Data for Plots
%Creates new fields in the handles structure
%so that this data can be used in other functions in this GUI

handles.vicon.time = 1:5000;
handles.vicon.posx = zeros(1,5000);
handles.vicon.posy = zeros(1,5000);
handles.vicon.posz = zeros(1,5000);
handles.vicon.roll = zeros(1,5000);
handles.vicon.pitch = zeros(1,5000);
handles.vicon.yaw = zeros(1,5000);

%% Other variables for updating plots
handles.vicon.k = 1;
handles.vicon.idx = 1;
handles.vicon.commontime = 0;
handles.vicon.lefttime = 1;

%vicon Plots will update every 1/n sample points
handles.vicon.plotDownSample = 5;

