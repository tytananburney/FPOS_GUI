#!/usr/bin/env python

import serial # 3rd party module download at https://pypi.python.org/pypi/pyserial
import struct
import string
import time
import argparse
import os
import imu_g362_drv_frame as imu

t0 = time.time() #Time the script starts
print(t0)

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--serial_port", help="specifies COMxx or /dev/ttyUSBx to use", type=str, default="")
parser.add_argument("-b", "--baud_rate", help="specifies baudrate to use", type=int, choices=[460800, 230400, 115200], default=460800)
parser.add_argument("-t", "--sec_duration", help="specifies time duration of execution in seconds",type=float, default=10)
parser.add_argument("-o", "--ofilename", help="specifies full filename with extension to override internally generated \
                    filename for CSV log", type=str,default="CSVDATA.csv")
parser.add_argument("-d", "--drate", help="specifies output data rate in sps, otherwise \
                    use default of 1000sps", type=float, choices=[1000, 500, 250, 125, 62.5, 31.25], default=1000)
parser.add_argument("-l", "--listserial", help="specifies to list of available COM ports", action="store_true")
parser.add_argument("-f", "--flight_label", help="specifies a label for the flight log", type=float, default=0)
parser.add_argument("-z", "--downsample", help="specifics how often to send data to the UDP socket", type=float, default=1)
args = parser.parse_args()

if args.drate:
    drate = args.drate
    mv_avg_filter = "MV_AVG32"

if (args.listserial or args.serial_port == ""):
    print ("Available COM ports:", list(imu.serial_ports()))
else:
    if os.name == 'nt':
        pass
    else:
        # unix
        #olinano.export_pins(2)
        #olinano.setpindirection(2, "out")
        #olinano.writepins(2, 0) #assert IMU_HW_RESET
        #olinano.writepins(2, 1) #assert IMU_HW_RESET
        #time.sleep(1)
        pass
    imu.init_serial(args.serial_port, args.baud_rate) # use /dev/ttyUSBx for Linux
    imu.initcheck()
    imu.selftest()
    imu.softreset()
    #imu.flashtest()
    #imu.flashbackup() # No need to wearout NVRAM write cycles
    #imu.regdump()

    imu.setOutputRate(args.drate)   #Set Data Rate
    imu.setFilter(mv_avg_filter)    #Set Filter based on Data Rate
    imu.setUartMode(1)              #0=UART_AUTO Mode 1=AUTO_START
    imu.setFlagOut(0)               #Tells it to not raise a flag when a measurment is taken
    imu.setTempOut(1)               #Tells it to record Temperature
    imu.setGyroOut(1)               #Tells it to record gyroscope data
    imu.setAcclOut(1)               #Tells it to record accelerometer data
    imu.setGpioOut(0)               #Tells it to not read GPIO Outputs
    imu.setCountOut(1)              #Tells it to record Counter Values
    imu.setChksmOut(0)              #Tells it to not record the results of checksum
    imu.setTemp32Out(1)             #Set Output to 32 bit
    imu.setGyro32Out(1)             #Set Output to 32 bit
    imu.setAccl32Out(1)             #Set Output to 32 bit
    imu.setExtSel('Counter')        #Configure EXT pin?
    imu.setExtPolarity(0)           #Configure EXT pin polarity?
    imu.getMode()                   #MODE_STATE 0 = Sampling 1= Configuration
    
    t1 = time.time() #Time data collection begins

    #flabel = ""
    #if args.flight_label > 0:
    #    flabel = chr(64 + args.flight_label) + "_"
    
    #log_day = time.strftime("%b_%d")
    #log_time = time.strftime("%H_%M_%S")
    #log_filename = "Test_Data/"+log_day+"/FlightLogs/"+flabel+log_time+"_frame_log.csv"
    directory = os.path.dirname(args.ofilename)

    if not os.path.exists(directory):
        os.makedirs(directory)

    imu.csvStreamSample32(args.sec_duration,1,args.ofilename,args.downsample) #arg1 = time in seconds, arg2 = mode

    imu.close_serial()

    #timeToData = t1-t0;
    #with open('IMU_Time.txt',"a") as myfile:
    #    myfile.write(args.ofilename+','+str(timeToData)+',')
    #with open('temp_time.txt',"a") as myfile:
    #    myfile.write(','+str(t0))

print("Data Collection Complete")

#imu.getMode()
#imu.csvStreamSample32(5,1,'FirstData') # arg1 = time in seconds, arg2 = mode
#In get Sample, mode: 0 = Formatted Data with Units 1 = Raw Voltage Data
#Data Collection Options:
#   getSample32(1) = Returns one set of data as an array
#   getStreamSample32(duration,1) = Prints data in real time to the command window
#   csvStreamSample32(duration,1) = Writes data to an CSV text file

    
