function handles = update_vicon_plot(handles,common_time)
%Update function for the vicon sensors. Pulls data off of daq session
%listener and updates the plots of the GUI.

%Inputs:
%   handles -       The structure containing all of the handles in the GUI.

%Outputs:
%   handles -       An updated structure containing all of the updated handles in the GUI

% disp('vicon mark');

%% Assign to Pre-allocated Variables

%Assignments
handles.vicon.time(handles.vicon.k) = common_time;
handles.vicon.posx(handles.vicon.k) = handles.ViconOSA.Position(1);
handles.vicon.posy(handles.vicon.k) = handles.ViconOSA.Position(2);
handles.vicon.posz(handles.vicon.k) = handles.ViconOSA.Position(3);
handles.vicon.yaw(handles.vicon.k) = handles.ViconOSA.EulerAngBody(1);
handles.vicon.pitch(handles.vicon.k) = handles.ViconOSA.EulerAngBody(2);
handles.vicon.roll(handles.vicon.k) = handles.ViconOSA.EulerAngBody(3);


%toc

%% Plot data

%  tic

%Update plot
%Update position x and y data
set(handles.vicon.roll_axis,...
    'Xdata',handles.vicon.time(handles.vicon.lefttime:handles.vicon.k),...
    'Ydata',handles.vicon.roll(handles.vicon.lefttime:handles.vicon.k));
set(handles.vicon.pitch_axis,...
    'Xdata',handles.vicon.time(handles.vicon.lefttime:handles.vicon.k),...
    'Ydata',handles.vicon.pitch(handles.vicon.lefttime:handles.vicon.k));
set(handles.vicon.yaw_axis,...
    'Xdata',handles.vicon.time(handles.vicon.lefttime:handles.vicon.k),...
    'Ydata',handles.vicon.yaw(handles.vicon.lefttime:handles.vicon.k));

%Update position x and y data
set(handles.vicon.posx_axis,...
    'Xdata',handles.vicon.time(handles.vicon.lefttime:handles.vicon.k),...
    'Ydata',handles.vicon.posx(handles.vicon.lefttime:handles.vicon.k));
set(handles.vicon.posy_axis,...
    'Xdata',handles.vicon.time(handles.vicon.lefttime:handles.vicon.k),...
    'Ydata',handles.vicon.posy(handles.vicon.lefttime:handles.vicon.k));
set(handles.vicon.posz_axis,...
    'Xdata',handles.vicon.time(handles.vicon.lefttime:handles.vicon.k),...
    'Ydata',handles.vicon.posz(handles.vicon.lefttime:handles.vicon.k));


%Adjust x limits on plots
if handles.vicon.time(handles.vicon.k) - handles.vicon.time(handles.vicon.lefttime) > 10
    
    handles.vicon.lefttime = floor((handles.vicon.k + handles.vicon.lefttime)/2);
    
    set(handles.euler,'xlim',...
        [handles.vicon.time(handles.vicon.k)-5 handles.vicon.time(handles.vicon.k)+5]);
    set(handles.position,'xlim',...
        [handles.vicon.time(handles.vicon.k)-5 handles.vicon.time(handles.vicon.k)+5]);
    
end

% Number of data points archived
handles.vicon.k = handles.vicon.k+1;

%   toc


end
