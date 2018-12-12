function handles = Vicon_grab_log(handles)
%disp('VICON mark');
%tic
[fileID,msg] = fopen(handles.Vicon_log_name,'r');
%toc
string = '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ';

%tic
A = textscan(fileID, string);
%toc
%tic
handles.ViconTime = strcat(A{1,3}(end),'.',num2str(mod(str2double(A{1,2}(end)),1e6)));
handles.ViconFrame = str2double(A{1,1}(end));
handles.ViconOSA.Position = str2double([A{1,4}(end) A{1,5}(end) A{1,6}(end)]);
handles.ViconOSA.QuaternionGlobal = str2double([A{1,8}(end) A{1,9}(end) A{1,10}(end) A{1,11}(end)]);
handles.ViconOSA.EulerAngGlobal = str2double([A{1,13}(end) A{1,14}(end) A{1,15}(end)]);
handles.ViconOSA.QuaternionLocal = str2double([A{1,17}(end) A{1,18}(end) A{1,19}(end) A{1,20}(end)]);
handles.ViconOSA.EulerAngBody = str2double([A{1,22}(end) A{1,23}(end) A{1,24}(end)]);
handles.ViconSROA.Position = str2double([A{1,26}(end) A{1,27}(end) A{1,28}(end)]);
handles.ViconSROA.QuaternionGlobal = str2double([A{1,30}(end) A{1,31}(end) A{1,32}(end) A{1,33}(end)]);
handles.ViconSROA.EulerAngGlobal = str2double([A{1,35}(end) A{1,36}(end) A{1,37}(end)]);
%toc

%tic
fclose(fileID);
%toc