function [handles] = setup_SROA_Plots(handles)

%Automatically turn on plot
% set(handles.sroa_check,'Value',1);
handles.sroa.on = 1;


%% Create Pressure Plot
% press_time: the handle of the sroa pressure plot

handles.sroa.pressure_axis = plot(handles.press_time,0,nan(1),'-k');
hold(handles.press_time,'on');

title(handles.press_time,'Pressure-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.press_time,'Time, t (s)');
ylabel(handles.press_time,'Pressure (Torr)');

axis(handles.press_time,'auto');
box(handles.press_time,'on');

xlim(handles.press_time,[0 60]);



%% Create Cold Temperature Plot

handles.sroa.cold_tip_axis = plot(handles.cold_temp_time,0,nan(1),'-k');
hold(handles.cold_temp_time,'on');
handles.sroa.SC1_axis = plot(handles.cold_temp_time,0,nan(1),'-r');
handles.sroa.SC2_axis = plot(handles.cold_temp_time,0,nan(1),'-g');
hold(handles.cold_temp_time,'off');

title(handles.cold_temp_time,'Cold Temp-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.cold_temp_time,'Time, t (s)');
ylabel(handles.cold_temp_time,'Temperature (K)');

axis(handles.cold_temp_time,'auto');
box(handles.cold_temp_time,'on');
xlim(handles.cold_temp_time,[0 60]);

%% Create Warm Temperature Plot

handles.sroa.compressor_axis = plot(handles.warm_temp_time,0,nan(1),'-m');
hold(handles.warm_temp_time,'on');
handles.sroa.expander_axis = plot(handles.warm_temp_time,0,nan(1),'-c');
hold(handles.warm_temp_time,'off');

title(handles.warm_temp_time,'Warm Temp-Time','FontSize',10,'FontWeight','bold');
xlabel(handles.warm_temp_time,'Time, t (s)');
ylabel(handles.warm_temp_time,'Temperature (C)');

axis(handles.warm_temp_time,'auto');
box(handles.warm_temp_time,'on');
xlim(handles.warm_temp_time,[0 60]);
%% Pre-allocate Data for Plots
%Creates new fields in the handles structure
%so that this data can be used in other functions in this GUI

handles.sroa.time = 1:5000;
handles.sroa.cold_tip = zeros(1,5000);
handles.sroa.SC1 = zeros(1,5000);
handles.sroa.SC2 = zeros(1,5000);
handles.sroa.pressure = zeros(1,5000);
handles.sroa.compressor = zeros(1,5000);
handles.sroa.expander = zeros(1,5000);

%% Other variables for updating plots
handles.sroa.k = 1;
handles.sroa.idx = 1;
handles.sroa.commontime = 0;
handles.sroa.lefttime = 1;

%sroa Plots will update every 1/n sample points
handles.sroa.plotDownSample = 5;

