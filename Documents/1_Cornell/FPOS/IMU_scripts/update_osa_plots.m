function handles = update_osa_plots(handles,osa_fid)
%Update function for the OSA IMU. Reads a putty generated log file that is
%independent of data collection, and updates the plots of the GUI.

%Inputs:
%   handles -       The structure containing all of the handles in the GUI.

%Outputs:
%   handles -       An updated structure containing all of the updated handles in the GUI

lower = tic;
higher = tic;

%Remove backlog since init_OSA_imu was called
if handles.osa.starttime == -1
    flushinput(handles.osa.u);
    handles.osa.starttime = 0;
    handles.osa.start_time_common = common_clock(handles.common_start_time);
end
start_time = toc(lower);

%if handles.osa.u.BytesAvailable >= 119
    lower = tic;
    flushinput(handles.osa.u);
    pause(0.002);
    flush_time = toc(lower);
    
    %% Read Data
    %tic
    lower = tic;
    try
        single_measurement = fread(handles.osa.u); %<- this line is the bottleneck
        
        if strcmp(char(single_measurement(1:4)'),'Done') == 1
            set(handles.go, 'String','GO');
            guidata(gcbo,handles);
            return
        end
        
    catch ME
        disp(ME.message);
        single_measurement = [];
    end
    read_time = toc(lower);
    
    lower = tic;
    A = sscanf(char(single_measurement'),'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f');
    convert_time = toc(lower);

    lower = tic;
    %% Assign to Pre-allocated Variables
    if length(A) == 10
    %tic
    
    %Save starting time
    if handles.osa.starttime == 0
        handles.osa.starttime = A(10);
    end
    
    %Assignments   
    handles.osa.sample_num(handles.osa.k) = A(1);
    handles.osa.time(handles.osa.k) = A(10)-handles.osa.starttime;
    handles.osa.Gx(handles.osa.k) = A(2);
    handles.osa.Gy(handles.osa.k) = A(3);
    handles.osa.Gz(handles.osa.k) = A(4);
    handles.osa.Ax(handles.osa.k) = A(5);
    handles.osa.Ay(handles.osa.k) = A(6);
    handles.osa.Az(handles.osa.k) = A(7);

    %Save to log 
    try
        fprintf(handles.osa.fid, '%d,%f,%f,%f,%f,%f,%f,%f,%d,,%f\n', A);
    catch ME
        disp(ME.message);
    end
    %toc
    
    %% Plot data
    %tic
    %if mod(A(1),handles.osa.plotDownSample) == 0 && handles.osa.on == 1
        
        % Update plot x and y axes
        set(handles.osa.Ax_axis,...
            'Xdata',handles.osa.time(handles.osa.lefttime:handles.osa.k),...
            'Ydata',handles.osa.Ax(handles.osa.lefttime:handles.osa.k));
        set(handles.osa.Ay_axis,...
            'Xdata',handles.osa.time(handles.osa.lefttime:handles.osa.k),...
            'Ydata',handles.osa.Ay(handles.osa.lefttime:handles.osa.k));
        set(handles.osa.Az_axis,...
            'Xdata',handles.osa.time(handles.osa.lefttime:handles.osa.k),...
            'Ydata',handles.osa.Az(handles.osa.lefttime:handles.osa.k));
        
        set(handles.osa.Gx_axis,...
            'Xdata',handles.osa.time(handles.osa.lefttime:handles.osa.k),...
            'Ydata',handles.osa.Gx(handles.osa.lefttime:handles.osa.k));
        set(handles.osa.Gy_axis,...
            'Xdata',handles.osa.time(handles.osa.lefttime:handles.osa.k),...
            'Ydata',handles.osa.Gy(handles.osa.lefttime:handles.osa.k));
        set(handles.osa.Gz_axis,...
            'Xdata',handles.osa.time(handles.osa.lefttime:handles.osa.k),...
            'Ydata',handles.osa.Gz(handles.osa.lefttime:handles.osa.k));

        %Update time series
        if handles.osa.time(handles.osa.k) - handles.osa.time(handles.osa.lefttime) > 10
            
            handles.osa.lefttime = floor((handles.osa.lefttime + handles.osa.k)/2);
            
            set(handles.angv_time,...
                'xlim',[handles.osa.time(handles.osa.k)-5, handles.osa.time(handles.osa.k)+5]);
            set(handles.oacc_time,...
                'xlim',[handles.osa.time(handles.osa.k)-5, handles.osa.time(handles.osa.k)+5]);
        
        end

    %end
%toc
    
%   Number of data points archived
    handles.osa.k = handles.osa.k+1;
    
    %% Allocate More Space (if needed)
    
    %Increase the size of these arrays by 5000 spots if already full
    if handles.osa.k == length(handles.osa.time)
        handles.osa.sample_num = [handles.osa.sample_num, zeros(1,5000)];
        handles.osa.time = [handles.osa.time, zeros(1,5000)];
        handles.osa.Ax = [handles.osa.Ax, zeros(1,5000)];
        handles.osa.Ay = [handles.osa.Ay, zeros(1,5000)];
        handles.osa.Az = [handles.osa.Az, zeros(1,5000)];
        handles.osa.Gx = [handles.osa.Gx, zeros(1,5000)];
        handles.osa.Gy = [handles.osa.Gy, zeros(1,5000)];
        handles.osa.Gz = [handles.osa.Gz, zeros(1,5000)];
        handles.osa.temp = [handles.osa.temp, zeros(1,5000)];
    end
    
    %toc
    else
        disp('OSA Error');
        disp(A);
    end
    parse_time = toc(lower);
    osa_time = toc(higher);
    
    fprintf(osa_fid,'%f\t%f\t%f\t%f\t%f\t%f\n',...
        start_time,flush_time,read_time,convert_time,parse_time,osa_time);
end
%end


