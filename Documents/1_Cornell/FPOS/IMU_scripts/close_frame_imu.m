function handles = close_frame_imu(handles)
%Writes all data from the log into a .CSV file and closes the command
%prompt window in the background.

%Inputs:
%handles -     the handles structure of the GUI.

%Close UDP Socket
fclose(handles.frame.u);

%Get the stop time
handles.frame.stopdate = datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF');
handles.frame.k
%Write Additional Information to Log
fprintf(handles.frame.fid,'Log Start,%s\n',handles.frame.startdate);
fprintf(handles.frame.fid,'Log End,%s\n',handles.frame.stopdate);
fprintf(handles.frame.fid,'Log Duration,%f\n',handles.frame.time(handles.frame.k-1));
fprintf(handles.frame.fid,'Sample Numbers (Start End),%f,%f\n',handles.frame.sample_num([1,handles.frame.k-1]));
fprintf(handles.frame.fid,'Common Time at First Sample,%f\n',handles.frame.start_time_common);
fprintf(handles.frame.fid,'Data Rate,%f,sps\n',(handles.frame.k-1)/handles.frame.time(handles.frame.k-1));
fclose(handles.frame.fid);
