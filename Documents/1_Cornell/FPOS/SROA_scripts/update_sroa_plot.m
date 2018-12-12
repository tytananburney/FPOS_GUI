function handles = update_sroa_plot(handles,common_time)
%Update function for the SROA sensors. Pulls data off of daq session
%listener and updates the plots of the GUI.

%Inputs:
%   handles -       The structure containing all of the handles in the GUI.

%Outputs:
%   handles -       An updated structure containing all of the updated handles in the GUI

% disp('SROA mark');

%% Assign to Pre-allocated Variables

%Assignments
handles.sroa.time(handles.sroa.k) = common_time;
handles.sroa.cold_tip(handles.sroa.k) = handles.SROA_data(1);
handles.sroa.SC1(handles.sroa.k) = handles.SROA_data(2);
handles.sroa.SC2(handles.sroa.k) = handles.SROA_data(3);
handles.sroa.pressure(handles.sroa.k) = handles.SROA_data(5);
handles.sroa.compressor(handles.sroa.k) = handles.SROA_data(6);
handles.sroa.expander(handles.sroa.k) = handles.SROA_data(7);

%toc

%% Plot data

%  tic

%Update plot
%Update pressure x and y data
set(handles.sroa.pressure_axis,...
    'Xdata',handles.sroa.time(handles.sroa.lefttime:handles.sroa.k),...
    'Ydata',handles.sroa.pressure(handles.sroa.lefttime:handles.sroa.k));

%Update cold temp x and y data
set(handles.sroa.cold_tip_axis,...
    'Xdata',handles.sroa.time(handles.sroa.lefttime:handles.sroa.k),...
    'Ydata',handles.sroa.cold_tip(handles.sroa.lefttime:handles.sroa.k));
set(handles.sroa.SC1_axis,...
    'Xdata',handles.sroa.time(handles.sroa.lefttime:handles.sroa.k),...
    'Ydata',handles.sroa.SC1(handles.sroa.lefttime:handles.sroa.k));
set(handles.sroa.SC2_axis,...
    'Xdata',handles.sroa.time(handles.sroa.lefttime:handles.sroa.k),...
    'Ydata',handles.sroa.SC2(handles.sroa.lefttime:handles.sroa.k));

%Update warm temp x and y data
set(handles.sroa.compressor_axis,...
    'Xdata',handles.sroa.time(handles.sroa.lefttime:handles.sroa.k),...
    'Ydata',handles.sroa.compressor(handles.sroa.lefttime:handles.sroa.k));
set(handles.sroa.expander_axis,...
    'Xdata',handles.sroa.time(handles.sroa.lefttime:handles.sroa.k),...
    'Ydata',handles.sroa.expander(handles.sroa.lefttime:handles.sroa.k));

%Adjust x limits on plots
if handles.sroa.time(handles.sroa.k) - handles.sroa.time(handles.sroa.lefttime) > 60
    
    handles.sroa.lefttime = floor((handles.sroa.k + handles.sroa.lefttime)/2);
    
    set(handles.press_time,'xlim',...
        [handles.sroa.time(handles.sroa.k)-30 handles.sroa.time(handles.sroa.k)+30]);
    set(handles.cold_temp_time,'xlim',...
        [handles.sroa.time(handles.sroa.k)-30 handles.sroa.time(handles.sroa.k)+30]);
    set(handles.warm_temp_time,'xlim',...
        [handles.sroa.time(handles.sroa.k)-30 handles.sroa.time(handles.sroa.k)+30]);
    
end

% Number of data points archived
handles.sroa.k = handles.sroa.k+1;

%   toc


end
