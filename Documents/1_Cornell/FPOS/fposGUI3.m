function varargout = fposGUI3(varargin)
%%% LAST UPDATED: 3/20/2017 11:18 AM PST
% FPOSGUI3 MATLAB code for fposGUI3.fig

% Last Modified by GUIDE v2.5 01-Mar-2017 15:14:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @fposGUI3_OpeningFcn, ...
    'gui_OutputFcn',  @fposGUI3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before fposGUI3 is made visible.
function fposGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fposGUI3 (see VARARGIN)

% Choose default command line output for fposGUI3
handles.output = hObject;

% Create plot titles, axes, and labels
handles = setup_Frame_Plots(handles);
handles = setup_OSA_Plots(handles);
handles = setup_SROA_Plots(handles);
handles = setup_Vicon_Plots(handles);

%Declare variables tracking experiment event buttons
handles.OSA_SROA_contact = [];
handles.OSA_capture = [];
handles.IFA_bump = [];
handles.OSA_bump = [];
handles.good_test = [];

% Set default values for which sensors to collect data from
set(handles.magnetometer_check,'Value',1);
handles.mag.on = 0;
set(handles.SROA_check,'Value',1);
handles.sroa.on = 0;
set(handles.vicon_check,'Value',1);
handles.vicon.on = 0;
set(handles.ifa_check,'Value',1);
handles.frame.on = 0;
set(handles.osa_check,'Value',1);
handles.osa.on = 0;

% Start time
c = clock();
handles.common_start_time = [c(4) c(5) c(6)];
common_time = common_clock(handles.common_start_time);
set(handles.common_time,'String',sprintf('%05.2f s',common_time));

% Default variables
handles.trial_num = 0;
handles.experiment_name = 'default';

%Open log
handles.experiment_fid = fopen('experiment_log.csv','a');

%data file
handles.data_folder = ['Test_Data\',datestr(now,'mmm_dd')];
if ~exist(handles.data_folder,'dir')
    mkdir(handles.data_folder);
end

%Prepend a letter in front of filename names corresponding to a log file
temp_num = length(dir([handles.data_folder,'\FlightLogs\*frame_log.csv']))+1;
flog_symbol = '';
if temp_num > 0
    for i = 1:floor(temp_num/26)+1
        flog_symbol = [flog_symbol,char(mod(temp_num, 26) + 64)];
    end
    flog_symbol = [flog_symbol,'_'];
end
handles.flog_symbol = flog_symbol;

%Start DAQ when GUI is created
if handles.sroa.on
    handles.daqSession = cdaq_init();
    handles.daqSession.Rate = 10;
    handles.daqSession.IsContinuous = true;
end

% Update handles structure
guidata(hObject, handles);

% addpath('C:\Users\user\Box Sync\SPECTRE\Code and Sensors\GUI\SROA_scripts')
% addpath('C:\Users\user\Box Sync\SPECTRE\Code and Sensors\GUI\IMU_scripts')
% addpath('C:\Users\user\Box Sync\SPECTRE\Code and Sensors\GUI\Vicon_scripts\Given Library');

% UIWAIT makes fposGUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fposGUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(hObject, 'String');
disp(str);

if strcmp(str, 'GO')
    
    %Initialize timing scripts
    low = tic;
    timer_fid = fopen('time_recorder.txt','w');
    fprintf(timer_fid,'frame\tosa\tsroa\tvicon\tdraw\ttotal\n');
    frame_timer_fid = fopen('time_recorder_frame.txt','w');
    fprintf(frame_timer_fid,'start\tflush\tread\tconvert\t\tparse\ttotal\n');
    osa_timer_fid = fopen('time_recorder_osa.txt','w');
    fprintf(osa_timer_fid,'start\tflush\tread\tconvert\t\tparse\ttotal\n');
    
    % Change GO to STOP and reset buttons
    set(hObject, 'String', 'STOP');
    set(handles.contact_button, 'Value', 0);
    set(handles.capture_button, 'Value', 0);
    set(handles.bump_button, 'Value', 0);
    set(handles.impact_button, 'Value', 0);
    set(handles.good_run, 'Value', 0);
    set(handles.notes_box, 'String', '-');
    
    %Reset button entrees
    handles.OSA_SROA_contact = [];
    handles.OSA_capture = [];
    handles.IFA_bump = [];
    handles.OSA_bump = [];
    handles.good_test = [];
    
    % Update trial number and filename
    handles.trial_num = handles.trial_num + 1;
    set(handles.run_num, 'String', handles.trial_num);
    d = get(handles.distance, 'String');
    a = get(handles.angle, 'String');
    handles.filename = [handles.experiment_name,'_',d,'_',a,'_',int2str(handles.trial_num)];
    set(handles.name, 'String', handles.filename);
    
    % Update log files to output to and reset plots
    if handles.osa.on
        handles.osa.filename = [handles.data_folder,'\',handles.flog_symbol,handles.filename,'_OSA.csv'];
        handles = reset_OSA_imu(handles);
    end
    if handles.frame.on
        handles.frame.filename = [handles.data_folder,'\',handles.flog_symbol,handles.filename,'_IFA.csv'];
        handles = reset_frame_imu(handles);
    end
    if handles.sroa.on
        handles.sroa_fid = fopen([handles.data_folder,'\',handles.flog_symbol,handles.filename,'_SROA.txt'],'w');
        
        fprintf(handles.sroa_fid,'Time [sec]\tCold tip [K]\tSC diode 1 [K]\tSC diode 2 [K]\tSC diode 3 [K]\tPressure [Torr]\tThermocouple 1 [C]\tThermocouple 2 [C]\n');
        handles = reset_sroa_data(handles);
                
    end
    
    %Update GUI before reading from VICON
    guidata(hObject,handles);
    if handles.vicon.on
        Vicon_init;
        %Refresh handles
        handles = guidata(hObject);
        handles.vicon.file_idx = 1;
        handles.vicon_fid = fopen([handles.data_folder,'\',handles.flog_symbol,handles.filename,'_VICON.txt'],'w');
        fprintf(handles.vicon_fid,'Timestamp \t Frame # \t OSA Translation \t\t\t\t\t OSA Inertial EulerXYZ \t\t\t\t\t OSA Inertial Quaternion \t\t\t\t\t\t OSA Body Euler Angles \t\t\t\t OSA Body Quaternion \t\t\t\t\t\t SROA Translation \t\t\t\t\t SROA EulerXYZ \t\t\t\t\t\t\t SROA Quaternion\n');
        handles = reset_vicon(handles);
    end
    count = 0;
    
    %Update clock on screen
    c = clock();
    handles.common_start_time = [c(4) c(5) c(6)];
    common_time = common_clock(handles.common_start_time);
    set(handles.common_time,'String',sprintf('%05.2f s',common_time));
    
    guidata(hObject, handles);
    
    %Time before data plotting starts
    goInitTime = toc(low);
    disp(goInitTime);
    
    % start collecting data from all sensors
    while strcmp(get(hObject, 'String'), 'STOP')
        
        handles = guidata(hObject);
        
        %Update clock
        common_time = common_clock(handles.common_start_time);
        set(handles.common_time,'String',sprintf('%05.2f s',common_time));
        
        high = tic;
        
        %disp('mark');
        count = count+1;
        
        % Collect and plot Frame IMU
        low = tic;
        if handles.frame.on && mod(count-1,1) == 0
            handles = update_frame_plot(handles,frame_timer_fid);
        end
        loop_time = posixtime(datetime('now','TimeZone','UTC'));
        frame_time = toc(low);
        
        % Collect and plot OSA IMU
        low = tic;
        if handles.osa.on && mod(count-1,1) == 0
            handles = update_osa_plots(handles,osa_timer_fid);
        end
        osa_time = toc(low);
        
        % SROA Temperature and Pressure
        low = tic;
        if handles.sroa.on
            % DAQ
            common_time = common_clock(handles.common_start_time);
            set(handles.common_time,'String',sprintf('%05.2f s',common_time));
            if mod(count-1,10) == 0 %abs(mod(common_time,1/handles.sroa.plotDownSample)) < 1e-2
                %get data
                raw_data = handles.daqSession.inputSingleScan;
                handles.SROA_data = SROA_conversion(raw_data);
                t = datestr(now, 'dd/mm/yy HH:MM:SS.FFF');
                %log data
                fprintf(handles.sroa_fid,'%s \t %f \t %f \t %f \t %f \t %f \t %f \t %f \n',t,handles.SROA_data);
                %plot data
                %               disp('SROA Data Collected');
                handles = update_sroa_plot(handles,common_time);
            end
        end
        sroa_time = toc(low);
        
        guidata(hObject,handles);
        
        % Vicon
        low = tic;
        if handles.vicon.on
            %grab data
            Vicon_grab
%             fprintf(handles.vicon_fid,'%s \t %d \t %8.4f \t %8.4f \t %8.4f \t %8.4f \t %8.4f \t %8.4f \t %6.4f \t %6.4f \t %6.4f \t %6.4f \t %8.4f \t %8.4f \t %8.4f \t %8.4f \t %8.4f \t %8.4f \t %8.4f \t %6.4f \t %6.4f \t %6.4f \t %8.4f \t %8.4f \t %8.4f \t %6.4f \t %6.4f \t %6.4f \t %6.4f \n',...
%                 handles.ViconTime,...
%                 handles.ViconFrame,...
%                 handles.ViconOSA.Position,...
%                 handles.ViconOSA.EulerAngGlobal,...
%                 handles.ViconOSA.QuaternionGlobal,...
%                 handles.ViconOSA.EulerAngBody,...
%                 handles.ViconOSA.QuaternionLocal,...
%                 handles.ViconSROA.Position,...
%                 handles.ViconSROA.EulerAngGlobal,...
%                 handles.ViconSROA.QuaternionGlobal);
            % Update plots
            handles = update_vicon_plot(handles,common_time);
            %end
        end
        vicon_time = toc(low);
        
        %Redraw plots
        low = tic;
        if mod(count-1,10) == 0
           drawnow;
        end
        
        %Update GUI handles structure (so other functions can use it too)
        guidata(hObject,handles);
        
        draw_time = toc(low);
        total_time = toc(high);
        
        fprintf(timer_fid,'%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%14.3f\n',...
            frame_time,osa_time,sroa_time,vicon_time,draw_time,total_time,loop_time);
        
    end
    
    fclose(frame_timer_fid);
    fclose(osa_timer_fid);
    fclose(timer_fid);
    
elseif strcmp(str, 'STOP')
    set(hObject, 'String', 'GO');
    
    % Close sockets and files
    if handles.frame.on
        handles = close_frame_imu(handles);
    end
    if handles.osa.on
        handles = close_OSA_imu(handles);
    end
    if handles.sroa.on
        % Close DAQ session
        fclose(handles.sroa_fid);
    end
    if handles.vicon.on
        fclose(handles.vicon_fid);
    end
    guidata(hObject,handles);
    
    % Record events to experiment log
    t = datestr(now, 'dd/mm/yy HH:MM:SS.FFF');
    
    % Append to excel file
    %exc = actxserver('Excel.Application');
    %exc.Visible = 1;
    %xlsappend('experiment_log.xls', {handles.filename t fco fca fe fb fi get(handles.notes_box,'String')}, 1);
    
    fprintf(handles.experiment_fid,'%s,%s,%s,%s,%s,%s,%s,%s\n',...
        handles.filename, t, handles.OSA_SROA_contact, handles.OSA_capture,...
        handles.IFA_bump, handles.OSA_bump, handles.good_test,...
        get(handles.notes_box,'String'));
    
end


% --- Executes on button press in start_button.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
state = get(hObject,'Value');

if state == get(hObject,'Max')
    disp('start down');
    if handles.osa.on
        handles = init_OSA_imu(handles,7200);
    end
    if handles.frame.on
        handles = init_frame_imu(handles,7200);
    end
    if handles.vicon.on
        % Start Vicon data collection when user presses start
        !Vicon_scripts\CPP files\SPECTRE.exe &
        c = clock();
        if c(4) >= 19
            c(4) = c(4)-24;
        end
        find_str = ['Vicon_log_' num2str(c(4)-1) '_' num2str(c(5)) '*']
        Vicon_file = dir(find_str);
        handles.Vicon_log_name = Vicon_file.name;
    end
elseif state == get(hObject,'Min')
    disp('start up');
end

guidata(hObject,handles);


% --- Executes on button press in ifa_check.
function ifa_check_Callback(hObject, eventdata, handles)
% hObject    handle to ifa_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ifa_check
if get(hObject,'Value') == 1
    handles.frame.on = 1;
else
    handles.frame.on = 0;
end
guidata(hObject,handles);

% --- Executes on button press in osa_check.
function osa_check_Callback(hObject, eventdata, handles)
% hObject    handle to osa_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of osa_check
if get(hObject,'Value') == 1
    handles.osa.on = 1;
else
    handles.osa.on = 0;
end
guidata(hObject,handles);

% --- Executes on button press in magnetometer_check.
function magnetometer_check_Callback(hObject, eventdata, handles)
% hObject    handle to magnetometer_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of magnetometer_check
if get(hObject,'Value') == 1
    handles.mag.on = 1;
else
    handles.mag.on = 0;
end
guidata(hObject,handles);

% --- Executes on button press in vicon_check.
function vicon_check_Callback(hObject, eventdata, handles)
% hObject    handle to vicon_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vicon_check
if get(hObject,'Value') == 1
    handles.vicon.on = 1;
else
    handles.vicon.on = 0;
end
guidata(hObject,handles);

% --- Executes on button press in SROA_check.
function SROA_check_Callback(hObject, eventdata, handles)
% hObject    handle to SROA_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SROA_check
if get(hObject,'Value') == 1
    handles.sroa.on = 1;
else
    handles.sroa.on = 0;
end
guidata(hObject,handles);


% --- Executes on button press in contact_button.
function contact_button_Callback(hObject, eventdata, handles)
% hObject    handle to contact_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of contact_button
handles.OSA_SROA_contact = [handles.OSA_SROA_contact,datestr(now, 'HH:MM:SS.FFF'),';'];
guidata(hObject,handles);

% --- Executes on button press in capture_button.
function capture_button_Callback(hObject, eventdata, handles)
% hObject    handle to capture_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of capture_button
handles.OSA_capture = [handles.OSA_capture,datestr(now, 'HH:MM:SS.FFF'),';'];
guidata(hObject,handles);

% --- Executes on button press in bump_button.
function bump_button_Callback(hObject, eventdata, handles)
% hObject    handle to bump_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bump_button
handles.IFA_bump = [handles.IFA_bump,datestr(now, 'HH:MM:SS.FFF'),';'];
guidata(hObject,handles);

% --- Executes on button press in impact_button.
function impact_button_Callback(hObject, eventdata, handles)
% hObject    handle to impact_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of impact_button
handles.OSA_bump = [handles.OSA_bump,datestr(now, 'HH:MM:SS.FFF'),';'];
guidata(hObject,handles);

% --- Executes on button press in good_run.
function good_run_Callback(hObject, eventdata, handles)
% hObject    handle to good_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of good_run
handles.good_test = [handles.good_test,datestr(now, 'HH:MM:SS.FFF'),';'];
guidata(hObject,handles);

function notes_box_Callback(hObject, eventdata, handles)
% hObject    handle to notes_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of notes_box as text
%        str2double(get(hObject,'String')) returns contents of notes_box as a double

% --- Executes during object creation, after setting all properties.
function notes_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function distance_Callback(hObject, eventdata, handles)
% hObject    handle to distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of distance as text
%        str2double(get(hObject,'String')) returns contents of distance as a double

% --- Executes during object creation, after setting all properties.
function distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function angle_Callback(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of angle as text
%        str2double(get(hObject,'String')) returns contents of angle as a double

% --- Executes during object creation, after setting all properties.
function angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% a = instrfindall;
% fclose(a(:));

if isfield(handles,'experiment_fid')
    fclose(handles.experiment_fid);
end
if isfield(handles,'osa') && handles.osa.on
    delete(handles.osa.u);
end
if isfield(handles,'frame') && handles.frame.on
    delete(handles.frame.u);
end
if isfield(handles,'sroa') && handles.sroa.on
    handles.daqSession.stop;
    handles.daqSession.release;
end

fclose('all');


% --- Executes when selected object is changed in exp_type.
function exp_type_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in exp_type
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag')
    case 'exp_type_default'
        handles.experiment_name = 'default';
    case 'exp_type_capture'
        handles.experiment_name = 'capture';
    case 'exp_type_closeEQ'
        handles.experiment_name = 'closeEQ';
    case 'exp_type_SOI'
        handles.experiment_name = 'SOI';
end
guidata(hObject, handles);
disp(handles.experiment_name);
