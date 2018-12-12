#Create fake data to send, simulating the Frame
import socket
import sys
import time
import argparse
from math import *

#Create a UDP Socket to funnel data to MATLAB
my_sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
my_sock.connect(('127.0.0.1',9556))

print 'Frame IMU Running'

#Instantiate Variables
count = 0
sample_count = 0
start_time = time.time()

try:
     while time.time()-start_time < 60:
     
          #Make Fake Data
          sample_count += 1
          current_time = time.time()-start_time
          gx = 25*sin(current_time*2*pi/3)+100
          gy = 25*sin(current_time*2*pi/6)
          gz = 25*sin(current_time*2*pi/9)-100
          ax = 250*cos(current_time*2*pi)+500
          ay = 250*cos(current_time*2*pi/3)
          az = 250*cos(current_time*2*pi/6)-500
          temp = current_time
          current_time += start_time
          
          count += 50
          if count > 65535:
               count = 0
          
          #Format Data
          data = "{:07.0f},{:+012.6f},{:+012.6f},{:+012.6f},{:+012.6f},{:+012.6f},{:+012.6f},{:012.6f},{:05.0f},{:14.3f}".format(\
                    sample_count, gx, gy, gz, ax, ay, az, temp, count, current_time)   
          #print data 
          
          #Write to a backup log file that save everything
          with open('frame_imu.log',"a") as myfile:
               myfile.write(data)
               myfile.write('\n')
          
          if count%10 == 0:
              #Send data to MATLAB
              my_sock.send(data)
              print time.time() - current_time


#Press Ctrl-C to stop prematurely          
except KeyboardInterrupt:
     pass

my_sock.close()
print 'frame_imu done printing'




