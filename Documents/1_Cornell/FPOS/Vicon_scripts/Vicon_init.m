% Object names
OSA = 'OSA_3_20_1720_15m';
SROA = 'SROA';

% Program options
HapticOnList = {'ViconAP_001';'ViconAP_002'};
bReadCentroids = false;

% Load the SDK
% fprintf( 'Loading SDK...' );
Client.LoadViconDataStreamSDK();
% fprintf( 'done\n' );

% Program options
HostName = 'localhost:801';

% Make a new client
MyClient = Client();

% Connect to a server
% fprintf( 'Connecting to %s ...', HostName );
while ~MyClient.IsConnected().Connected
    % Direct connection
    MyClient.Connect( HostName );
    
%     fprintf( '.' );
end
% fprintf( '\n' );

% Enable some different data types
MyClient.EnableSegmentData();
% MyClient.EnableMarkerData();
% MyClient.EnableUnlabeledMarkerData();
% MyClient.EnableDeviceData();

if bReadCentroids
    MyClient.EnableCentroidData();
end

% fprintf( 'Segment Data Enabled: %s\n',          AdaptBool( MyClient.IsSegmentDataEnabled().Enabled ) );

% Set the streaming mode
% MyClient.SetStreamMode( StreamMode.ClientPull );
% MyClient.SetStreamMode( StreamMode.ClientPullPreFetch );
MyClient.SetStreamMode( StreamMode.ServerPush );

% Set the global up axis
MyClient.SetAxisMapping( Direction.Forward, ...
    Direction.Left,    ...
    Direction.Up );    % Z-up


Output_GetAxisMapping = MyClient.GetAxisMapping();
% fprintf( 'Axis Mapping: X-%s Y-%s Z-%s\n', Output_GetAxisMapping.XAxis.ToString(), ...
%     Output_GetAxisMapping.YAxis.ToString(), ...
%     Output_GetAxisMapping.ZAxis.ToString() );
% 
% fprintf('\n\n Running DataStream...\n\n');

vicon_update_rate = 5;

%Vicon_fid=fopen('test_VICON.txt','w');
% Declare contents of data file
%fprintf(Vicon_fid,'Timestamp \t Frame # \t OSA Translation \t\t\t\t\t OSA Inertial EulerXYZ \t\t\t\t\t OSA Inertial Quaternion \t\t\t\t\t\t OSA Body Euler Angles \t\t\t\t OSA Body Quaternion \t\t\t\t\t\t SROA Translation \t\t\t\t\t SROA EulerXYZ \t\t\t\t\t\t\t SROA Quaternion\n');
