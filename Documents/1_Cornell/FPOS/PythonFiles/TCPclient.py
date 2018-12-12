import socket
import sys
import time
import argparse

#Start Time
t0 = time.time()

#Parse Input Arguments
parser = argparse.ArgumentParser()
parser.add_argument("-t", "--sec_duration", help="specifies time duration of execution in seconds",type=float, default=10)
parser.add_argument("-o", "--ofilename", help="specifies full filename with extension to override internally generated \
                    filename for CSV log", type=str,default="CSVDATA.csv")
parser.add_argument("-d", "--drate", help="specifies output data rate in sps, otherwise \
                    use default of 1000sps", type=float, choices=[1000, 500, 250, 125, 62.5, 31.25], default=1000)
args = parser.parse_args()


#Create TCP Socket ("SOCK_STREAM" => TCP, "SOCK_DGRAM" => UDP)
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error, msg:
    print 'Failed to create socket. Error code: ' + str(msg[0]) + ' , ' + str(msg[1])
    sys.exit();

print 'Socket Created'


#Establish Connection with the Raspberry Pi
host_ip = '10.0.0.200'
s.connect((host_ip,2222))

#How long to make the connection
t1 = time.time() 

#Send Data to the Raspberry Pi
message = "-t "+str(args.sec_duration)+" -o "+args.ofilename+" -d "+str(args.drate)

try:
    s.sendall(message)
except socket.error:
    print 'Send Failed'
    sys.exit()

print 'Command Sent'

#How long it took to send a message
t2 = time.time() 

#Recieve Data from the Raspberry Pi.
reply = s.recv(1024)

#How long until a message was recieved
t3 = time.time()

#Close Connection
s.close()

#Finish Time
t4 = time.time()
 
with open('MATLAB_Time.txt',"a") as myfile:
    myfile.write(str(t4-t0)+','+str(t1)+','+str(t2)+','+str(t3)+',')
    

