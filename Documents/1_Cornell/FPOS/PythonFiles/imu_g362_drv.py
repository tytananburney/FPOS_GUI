#!/usr/bin/env python

import serial # 3rd party module download at https://pypi.python.org/pypi/pyserial
import struct
import string
import time
import datetime
import csv
import sys
import os

from serial.tools import list_ports
from imu_g362_g352_def import *

serial_epson = 0
my_osa_sock = 0

# G362 specific constants
SF_GYRO = 0.005 # dps/bit
SF_ACCL = 0.125 # mg/bit
SF_TEMP = 0.0042725 # degC/bit
TEMP16_25C = 15214 # offset in 16bit mode @ 25C
TEMP32_25C = 997064704 # offset in 32bit mode @ 25C

# End-Of-Command Byte is appended to every command
BURST_MARKER = 0x80
DELIMITER = 0x0D

def init_serial(comport, baudrate):
    global serial_epson #must be declared in each fxn used
    serial_epson = serial.Serial()
    serial_epson.baudrate = baudrate
    serial_epson.port = comport # usually /dev/ttyUSB0 for linux
    serial_epson.timeout = 1
    serial_epson.writeTimeout = 1
    serial_epson.parity = serial.PARITY_NONE
    serial_epson.stopbits = serial.STOPBITS_ONE
    serial_epson.bytesize = serial.EIGHTBITS
    serial_epson.open()

    if serial_epson.isOpen():
        print "Open: " + serial_epson.portstr + ", " + str(serial_epson.baudrate)


    
def close_serial():
    global serial_epson #must be declared in each fxn used
    serial_epson.close()
    print "Close: " + serial_epson.portstr + ", " + str(serial_epson.baudrate)



def serial_ports():
    """
    Returns a generator for all available serial ports
    """
    if os.name == 'nt':
        # windows
        for i in range(256):
            try:
                s = serial.Serial(i)
                s.close()
                yield 'COM' + str(i + 1)
            except serial.SerialException:
                pass
    else:
        # unix
        for port in list_ports.comports():
            yield port[0]


def get( winnum, regaddr, verbose=0):
    "Returns the 16-bit register data from regaddr (must be even)"

    # Parameter 1 = Set Window, Parameter 2 = Register Read Address (must be EVEN)
    write_bytes = bytearray((0xFE,
                            winnum,
                            DELIMITER))
    serial_epson.write(write_bytes)

    write_bytes = bytearray((regaddr,
                            0x00,
                            DELIMITER))
    serial_epson.write(write_bytes)

    # Read the bytes returned from the serial
    data_struct = struct.Struct('>BHB') # format must conform to the expected data
    data_str = serial_epson.read(data_struct.size)

    # The data must be flipped to little endian to be read correctly
    data = data_struct.unpack(data_str)
    
    if (verbose != 0):
        print "REG[{0:#02x}, W({1:X})] -> {2:#04x}".format( regaddr&0xFE, winnum, data[1] )
    #print("Return Data:  {0:#x}, {1:#x}, {2:#x}".format(data[0], data[1], data[2]))

    # Close the serial
    # serial_epson.close()

    return data[1]


def set( winnum, regaddr, regbyte, verbose=0 ):
    "Writes 1 byte to specified REGADDR (odd or even)"

    # Parameter 1 = Set Window, Parameter 2 = Register Address Byte, Parameter 3 = Register Write Byte
    write_bytes = bytearray((0xFE,
                            winnum,
                            DELIMITER))
    serial_epson.write(write_bytes)

    write_bytes = bytearray((regaddr&0xFF|0x80,
                            regbyte,
                            DELIMITER))
    serial_epson.write(write_bytes)

    if (verbose != 0):
        print "REG[{0:#02x}, W({1:X})] <- {2:#04x}".format( regaddr&0xFF, winnum, regbyte )

    # Close the serial
    # serial_epson.close()

    return

def initcheck():
    "Check for HARD_ERR "
    print "IMU Startup Check ********** Begin"

    result = 0
    while (result&0x0400 != 0):
        result = get(RegAddr.GLOB_CMD[0], RegAddr.GLOB_CMD[1])
        #print "Wait for NOT_READY"

    result = get(RegAddr.DIAG_STAT[0], RegAddr.DIAG_STAT[1])
    if (result&0x0060 != 0):
        print "Hardware Failure. HARD_ERR bits"

    print "IMU Startup Check ******************** Done"
    return result

def selftest():
    "Initiate Self Test"
    print "IMU Self Test ********** Begin"

    set(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[2], 0x04)
    result = 0x0400
    while (result&0x0400 != 0):
        result = get(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1])
        #print "Wait for SELF_TEST = 0"

    result = get(RegAddr.DIAG_STAT[0], RegAddr.DIAG_STAT[1])
    if (result&0x7800 != 0):
        print "Self Test Failure. ST_ERR bits"

    print "IMU Self Test ******************** Done"
    return result

def softreset():
    "Initiate Software Reset"
    print "IMU Software Reset ********** Begin"

    set(RegAddr.GLOB_CMD[0], RegAddr.GLOB_CMD[1], 0x80)
    time.sleep(1)
    print "IMU Self Test ******************** Done"
    return

def flashtest():
    "Initiate Flash Test"
    print "IMU Flash Test ********** Begin"

    set(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[2], 0x08)
    time.sleep(1)
    result = 0x0800
    while (result&0x0800 != 0):
        result = get(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1])
        print "Wait for FLASH_TEST = 0"

    result = get(RegAddr.DIAG_STAT[0], RegAddr.DIAG_STAT[1])
    if (result&0x0004 != 0):
        print "Flash Test Failure. FLASH_ERR bits"

    print "IMU Flash Test ******************** Done"
    return result

def flashbackup():
    "Initiate Flash Backup"
    print "IMU Flash Backup ********** Begin"

    set(RegAddr.GLOB_CMD[0], RegAddr.GLOB_CMD[1], 0x08)
    time.sleep(1)
    result = 0x0008
    while (result&0x0008 != 0):
        result = get(RegAddr.GLOB_CMD[0], RegAddr.GLOB_CMD[1])
        print "Wait for FLASH_BACKUP = 0"

    result = get(RegAddr.DIAG_STAT[0], RegAddr.DIAG_STAT[1])
    if (result&0x0001 != 0):
        print "Flash Backup Failure. FLASH_BU_ERR bit"

    print "IMU Flash Backup ******************** Done"
    return result

def regdump():
    "Initiate Register Dump"
    print "IMU Register Dump ********** Begin"

    get(RegAddr.MODE_CTRL[0], RegAddr.MODE_CTRL[1], 1)
    get(RegAddr.DIAG_STAT[0], RegAddr.DIAG_STAT[1], 1)
    get(RegAddr.FLAG[0], RegAddr.FLAG[1], 1)
    get(RegAddr.GPIO[0], RegAddr.GPIO[1], 1)
    get(RegAddr.COUNT[0], RegAddr.COUNT[1], 1)
    get(RegAddr.TEMP_HIGH[0], RegAddr.TEMP_HIGH[1], 1)
    get(RegAddr.TEMP_LOW[0], RegAddr.TEMP_LOW[1], 1)
    get(RegAddr.XGYRO_HIGH[0], RegAddr.XGYRO_HIGH[1], 1)
    get(RegAddr.XGYRO_LOW[0], RegAddr.XGYRO_LOW[1], 1)
    get(RegAddr.YGYRO_HIGH[0], RegAddr.YGYRO_HIGH[1], 1)
    get(RegAddr.YGYRO_LOW[0], RegAddr.YGYRO_LOW[1], 1)
    get(RegAddr.ZGYRO_HIGH[0], RegAddr.ZGYRO_HIGH[1], 1)
    get(RegAddr.ZGYRO_LOW[0], RegAddr.ZGYRO_LOW[1], 1)
    get(RegAddr.XACCL_HIGH[0], RegAddr.XACCL_HIGH[1], 1)
    get(RegAddr.XACCL_LOW[0], RegAddr.XACCL_LOW[1], 1)
    get(RegAddr.YACCL_HIGH[0], RegAddr.YACCL_HIGH[1], 1)
    get(RegAddr.YACCL_LOW[0], RegAddr.YACCL_LOW[1], 1)
    get(RegAddr.ZACCL_HIGH[0], RegAddr.ZACCL_HIGH[1], 1)
    get(RegAddr.ZACCL_LOW[0], RegAddr.ZACCL_LOW[1], 1)

    get(RegAddr.SIG_CTRL[0], RegAddr.SIG_CTRL[1], 1)
    get(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1], 1)
    get(RegAddr.SMPL_CTRL[0], RegAddr.SMPL_CTRL[1], 1)
    get(RegAddr.FILTER_CTRL[0], RegAddr.FILTER_CTRL[1], 1)
    get(RegAddr.UART_CTRL[0], RegAddr.UART_CTRL[1], 1)
    get(RegAddr.GLOB_CMD[0], RegAddr.GLOB_CMD[1], 1)
    get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1], 1)
    get(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[1], 1)

    print "IMU Register Dump ******************** Done"
    return

def setBaudRate(param1):
    "Configure Baud Rate NOTE: this change occurs immediately and will break communication"
    print "IMU Set BAUD Rate = {0} ********** Begin".format(param1)

    if param1 in BAUD_RATE.sel:
        writebyte = BAUD_RATE.val[BAUD_RATE.sel.index(param1)]
        #print DOUT_RATE.val[DOUT_RATE.sel.index(param1)]
        set(RegAddr.UART_CTRL[0], RegAddr.UART_CTRL[2], writebyte)
        print "IMU Set Baud Rate = {0} ******************** Done".format(param1)
    return


def setOutputRate(param1):
    "Configure Output Data Rate DOUT_RATE"
    print "IMU Set Output Rate = {0} ********** Begin".format(param1)

    if param1 in DOUT_RATE.sel:
        writebyte = DOUT_RATE.val[DOUT_RATE.sel.index(param1)]
        #print DOUT_RATE.val[DOUT_RATE.sel.index(param1)]
        set(RegAddr.SMPL_CTRL[0], RegAddr.SMPL_CTRL[2], writebyte)
        print "IMU Set Output Rate = {0} ******************** Done".format(param1)
    return

def setFilter(param1):
    "Configure Filter Type FILTER_SEL"
    print "IMU Filter Type = {0} ********** Begin".format(param1)

    if param1 in FILTER_SEL.sel:
        writebyte = FILTER_SEL.val[FILTER_SEL.sel.index(param1)]
        set(RegAddr.FILTER_CTRL[0], RegAddr.FILTER_CTRL[1], writebyte)
        result = 0x0020
        while (result&0x0020 != 0):
            result = get(RegAddr.FILTER_CTRL[0], RegAddr.FILTER_CTRL[1])
            print "Wait for FILTER_STAT = 0"
        print "IMU Filter Type = {0} ******************** Done".format(param1)
    return

def setUartMode(param1):
    "Configure UART Mode"
    print "IMU UART Mode = {0} ********** Begin".format(param1)
    # bit 0 = UART_AUTO MODE
    # bit 1 = AUTO_START
    set(RegAddr.UART_CTRL[0], RegAddr.UART_CTRL[1], param1&0x03)
    print "IMU UART Mode = {0} ******************** Done".format(param1)
    return

def setFlagOut(param1):
    "Configure Flag Output"
    print "IMU FLAG_OUT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1])
    if param1:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8|0x80)
    else:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8&0x70)
    print "IMU FLAG_OUT = {0} ******************** Done".format(param1)
    return

def setTempOut(param1):
    "Configure TempC Output"
    print "IMU TEMP_OUT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1])
    if param1:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8|0x40)
    else:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8&0xB0)
    print "IMU TEMP_OUT = {0} ******************** Done".format(param1)
    return

def setGyroOut(param1):
    "Configure Gyro Output"
    print "IMU GYRO_OUT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1])
    if param1:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8|0x20)
    else:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8&0xD0)
    print "IMU GYRO_OUT = {0} ******************** Done".format(param1)
    return

def setAcclOut(param1):
    "Configure Accel Output"
    print "IMU ACCL_OUT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1])
    if param1:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8|0x10)
    else:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[2], tmp>>8&0xE0)
    print "IMU ACCEL_OUT = {0} ******************** Done".format(param1)
    return

def setGpioOut(param1):
    "Configure GPIO Output"
    print "IMU GPIO_OUT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1])
    if param1:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1], tmp&0x07|0x04)
    else:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1], tmp&0x07&0x03)
    print "IMU GPIO_OUT = {0} ******************** Done".format(param1)
    return

def setCountOut(param1):
    "Configure COUNT Output"
    print "IMU COUNT_OUT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1])
    if param1:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1], tmp&0x07|0x02)
    else:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1], tmp&0x07&0x05)
    print "IMU COUNT_OUT = {0} ******************** Done".format(param1)
    return

def setChksmOut(param1):
    "Configure CHKSM Output"
    print "IMU CHKSM_OUT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1])
    if param1:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1], tmp&0x07|0x01)
    else:
        set(RegAddr.BURST_CTRL1[0], RegAddr.BURST_CTRL1[1], tmp&0x07&0x06)
    print "IMU CHKSM_OUT = {0} ******************** Done".format(param1)
    return

def setTemp32Out(param1):
    "Configure TEMP Output 32/16 bit"
    print "IMU TEMP_BIT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[1])
    if param1:
        set(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[2], tmp>>8|0x40)
    else:
        set(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[2], tmp>>8&0x30)
    print "IMU TEMP_BIT = {0} ******************** Done".format(param1)
    return

def setGyro32Out(param1):
    "Configure Gyro Output 32/16 bit"
    print "IMU GYRO_BIT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[1])
    if param1:
        set(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[2], tmp>>8|0x20)
    else:
        set(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[2], tmp>>8&0x50)
    print "IMU GYRO_BIT = {0} ******************** Done".format(param1)
    return

def setAccl32Out(param1):
    "Configure Accel Output 32/16 bit"
    print "IMU ACCL_BIT = {0} ********** Begin".format(param1)
    tmp = get(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[1])
    if param1:
        set(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[2], tmp>>8|0x10)
    else:
        set(RegAddr.BURST_CTRL2[0], RegAddr.BURST_CTRL2[2], tmp>>8&0x60)
    print "IMU ACCL_BIT = {0} ******************** Done".format(param1)
    return

def setExtSel(param1):
    "Configure EXT pin function"
    print "IMU EXT_SEL = {0} ********** Begin".format(param1)

    if param1 in EXT_SEL.sel:
        writebyte = EXT_SEL.val[EXT_SEL.sel.index(param1)]
        #print DOUT_RATE.val[DOUT_RATE.sel.index(param1)]
        tmp = get(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1])
        set(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1], tmp&0x26|writebyte<<6)
        print "IMU EXT_SEL = {0} ******************** Done".format(param1)
    return

def setExtPolarity(param1):
    "Configure EXT pin Polarity"
    print "IMU EXT_POL = {0} ********** Begin".format(param1)

    tmp = get(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1])
    if param1:
        set(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1], tmp&0xFF|0x20)
    else:
        set(RegAddr.MSC_CTRL[0], RegAddr.MSC_CTRL[1], tmp&0xC6)
    print "IMU EXT_POL = {0} ******************** Done".format(param1)
    return

def gotoMode(param1):
    "Set MODE_CMD"
    print "IMU MODE_CMD = {0} ********** Begin".format(param1)

    if param1 in MODE_CMD.sel:
        writebyte = MODE_CMD.val[MODE_CMD.sel.index(param1)]
        set(RegAddr.MODE_CTRL[0], RegAddr.MODE_CTRL[2], writebyte)
    print "IMU MODE_CMD = {0} ******************** Done".format(param1)
    return

def getMode():
    "Return MODE_STAT bit 0 = Sampling , 1 = Config"
    print "IMU Get Mode Status ********** Begin"

    result = get(RegAddr.MODE_CTRL[0], RegAddr.MODE_CTRL[1])
    if (result&0x0400 == 0x0400):
        print "Config Mode"
    else:
        print "Sampling Mode"
    print "IMU Get Mode Status ******************** Done"
    return result

def getSample32(mode):
    "Returns one Burst Read of IMU data with scale factor NOTE: Does not poll DRDY"

    # Assumes, No Flags, Temp32, Gyro32, Accl32, Count16, No Checksum

    # Read the bytes returned from the serial
    # B = unsigned char , i = int (4 byte), H = unsigned short (2 byte)
    # return is Burst Byte + 32-tempC + 32-gyroX + 32-gyroY + 32-gyroZ + 32-accX + 32-accY + 32-accZ + 16-count + 0x0D terminator
    data_struct = struct.Struct('>BiiiiiiiHB') # format must conform to the expected data

    # Parameter 1 = Set Window, Parameter 2 = Register Read Address (must be EVEN)
    write_bytes = bytearray((0xFE,
                            0x00,
                            DELIMITER))
    serial_epson.write(write_bytes)

    write_bytes = bytearray((BURST_MARKER,
                            0x00,
                            DELIMITER))
    serial_epson.write(write_bytes)

    ts = datetime.datetime.now()
    data_str = serial_epson.read(data_struct.size)

    # The data must be flipped to little endian to be read correctly
    data = data_struct.unpack(data_str)

    if mode == 1:
        #print data
        temp = (( data[1] + TEMP32_25C ) * SF_TEMP / 65536 ) + 25
        gx = ( data[2] * SF_GYRO / 65536 )
        gy = ( data[3] * SF_GYRO / 65536 )
        gz = ( data[4] * SF_GYRO / 65536 )
        ax = ( data[5] * SF_ACCL / 65536 )
        ay = ( data[6] * SF_ACCL / 65536 )
        az = ( data[7] * SF_ACCL / 65536 )
        print("{0},{1:+05.6f},{2:+05.6f},{3:+05.6f},{4:+05.6f},{5:+05.6f},{6:+05.6f},{7:+05.6f},{8:05d}".format(ts, gx, gy, gz, ax, ay, az, temp, data[8]))
    elif mode == 2:
        print("{:+09},{:+09},{:+09},{:+09},{:+09},{:+09},{:+09},{:05d}".format(data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8]))
    else:
        pass

    
    return data


def getSample16(mode):
    "Returns one Burst Read of IMU data NOTE: Does not poll DRDY"
    # Assumes, No Flags, Temp16, Gyro16, Accl16, Count16, No Checksum

    # Read the bytes returned from the serial
    # B = unsigned char , i = int (4 byte), h = short (2 byte), H = unsigned short (2 byte)
    # return is Burst Byte + 16-tempC + 16-gyroX + 16-gyroY + 16-gyroZ + 16-accX + 16-accY + 16-accZ + 16-count + 0x0D terminator
    data_struct = struct.Struct('>BhhhhhhhHB') # format must conform to the expected data

    # Parameter 1 = Set Window, Parameter 2 = Register Read Address (must be EVEN)
    write_bytes = bytearray((0xFE,
                            0x00,
                            DELIMITER))
    serial_epson.write(write_bytes)

    write_bytes = bytearray((BURST_MARKER,
                            0x00,
                            DELIMITER))
    serial_epson.write(write_bytes)

    ts = datetime.datetime.now()
    data_str = serial_epson.read(data_struct.size)

    # The data must be flipped to little endian to be read correctly
    data = data_struct.unpack(data_str)

    if mode == 1:
        temp = (( data[1] + TEMP16_25C ) * SF_TEMP ) + 25
        gx = ( data[2] * SF_GYRO )
        gy = ( data[3] * SF_GYRO )
        gz = ( data[4] * SF_GYRO )
        ax = ( data[5] * SF_ACCL )
        ay = ( data[6] * SF_ACCL )
        az = ( data[7] * SF_ACCL )
        print("{0},{1:+05.6f},{2:+05.6f},{3:+05.6f},{4:+05.6f},{5:+05.6f},{6:+05.6f},{7:+05.6f},{8:05d}".format(ts, gx, gy, gz, ax, ay, az, temp, data[8]))
    elif mode == 2:
        print("{:+09},{:+09},{:+09},{:+09},{:+09},{:+09},{:+09},{:05d}".format(data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8]))
    else:
        pass
    return data


def csvStreamSample16(SAMPLE_DURATION, mode, csv_ofname):
    "Creates a CSV log file with Burst Read of IMU data for specified seconds will check if BURST marker and DELIMITER is present"

    # Assumes, No Flags, Temp16, Gyro16, Accl16, Count16, No Checksum
    # Prep CSV file
    timestr = time.strftime("%Y%m%d-%H%M%S")
    fname = timestr + "_M-G362.csv"
    if csv_ofname:
        fname = csv_ofname
    csv_out = open(fname, 'wb')
    csv_writer = csv.writer(csv_out)

    # Write Header Row
    csv_writer.writerow(["M-G362 CSV Log File created by Python","Log Duration (sec): {:05.3f}".format(SAMPLE_DURATION),"Press CTRL-C to exit early","","","","","","",""])
    csv_writer.writerow(["Creation Date:",str(datetime.datetime.now()),"","","","","","","",""])
    if mode == 1:
        csv_writer.writerow(["Scaled 16-bit Data","SF_GYRO={:+01.4f} dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f} mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f} degC/lsb".format(SF_TEMP),"","","","","",""])
        csv_writer.writerow(["Sample No.","Gx[dps]","Gy[dps]","Gz[dps]","Ax[mG]","Ay[mG]","Az[mG]","Ts[deg.C]","Counter[dec]","Error"])
    else:
        csv_writer.writerow(["Raw Digital Data","SF_GYRO={:+01.4f} dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f} mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f} degC/lsb".format(SF_TEMP),"","","","","",""])
        csv_writer.writerow(["Sample No.","Gx[dec]","Gy[dec]","Gz[dec]","Ax[dec]","Ay[dec]","Az[dec]","Ts[dec]","Counter[dec]","Error"])

    # Read the bytes returned from the serial
    # B = unsigned char , i = int (4 byte), H = unsigned short (2 byte)
    # return is Burst Byte + 16-tempC + 16-gyroX + 16-gyroY + 16-gyroZ + 16-accX + 16-accY + 16-accZ + 16-count + 0x0D terminator
    data_struct = struct.Struct('>BhhhhhhhHB') # format must conform to the expected data
    sample_count = 0
    ng_count = 0
    flag_resync = False
    gotoMode('Sampling')
    start_time = time.time()
    current_time = time.time()
    start_date = datetime.datetime.now()
    print("Start Log:"),
    print start_date
    try:
        while (SAMPLE_DURATION > current_time-start_time):
            current_time = time.time()
            if (serial_epson.inWaiting() >= data_struct.size):
                sample_count += 1
                if (flag_resync == False):
                    data_str = serial_epson.read(data_struct.size) # Read full packet of data
                    data = data_struct.unpack(data_str)
                else:
                    data_str = serial_epson.read((data_struct.size) - 1) # Read full packet of data minus BURST marker (dtected already from findSync())
                    data = data_sync + struct.unpack('>hhhhhhhHB',data_str)
                flag_resync = False
                if (data[0] == BURST_MARKER) and (data[9] == DELIMITER):
                    if mode == 1:
                        temp = (( data[1] + TEMP16_25C ) * SF_TEMP ) + 25
                        gx = ( data[2] * SF_GYRO )
                        gy = ( data[3] * SF_GYRO )
                        gz = ( data[4] * SF_GYRO )
                        ax = ( data[5] * SF_ACCL )
                        ay = ( data[6] * SF_ACCL )
                        az = ( data[7] * SF_ACCL )
                        csv_writer.writerow(["{:09d}".format(sample_count),"{:+05.6f}".format(gx),"{:+05.6f}".format(gy),"{:+05.6f}".format(gz),\
                                            "{:+05.6f}".format(ax),"{:+05.6f}".format(ay),"{:+05.6f}".format(az),"{:+05.06f}".format(temp),\
                                            "{:05d}".format(data[8]),""])
                    else:
                        csv_writer.writerow([sample_count, data[2], data[3], data[4], data[5], data[6], data[7], data[1], data[8],""]);
                    sys.stdout.write('.')
                    #print ("."),
                else:
                    temp = (( data[1] + TEMP16_25C ) * SF_TEMP ) + 25
                    gx = ( data[2] * SF_GYRO )
                    gy = ( data[3] * SF_GYRO )
                    gz = ( data[4] * SF_GYRO )
                    ax = ( data[5] * SF_ACCL )
                    ay = ( data[6] * SF_ACCL )
                    az = ( data[7] * SF_ACCL )
                    csv_writer.writerow(["{:09d}".format(sample_count),"{:+05.6f}".format(gx),"{:+05.6f}".format(gy),"{:+05.6f}".format(gz),\
                                            "{:+05.6f}".format(ax),"{:+05.6f}".format(ay),"{:+05.6f}".format(az),"{:+05.06f}".format(temp),\
                                            "{:05d}".format(data[8]),"!"])
                    sys.stdout.write('!')
                    ng_count += 1
                    # When DELIMITER and BURSTMARKER is not found in the data read packet, packet is discarded and search for RESYNC
                    # NOTE: This may cause multiple burst samples to be lost as it tries to resync to the BURST MARKER and DELIMITER
                    data_sync = findSync()
                    flag_resync = True
    except KeyboardInterrupt:
        pass
    end_date = datetime.datetime.now()
    delta_date = end_date - start_date
    gotoMode('Config')
    print("\nSummary")
    print("Log Filename:\t" + fname)
    print("Log Start:\t" + str(start_date))
    print("Log End:\t" + str(end_date))
    print("Log Duration:\t" + str(delta_date.total_seconds()))
    print("Sample Count:\t{0}".format(sample_count))
    print("Error Count:\t{0}".format(ng_count))
    print("Sample Rate:\t{:8.3f} Sps".format(sample_count/delta_date.total_seconds()))
    print("Sample Period:\t{:8.4f} sec/Sample".format(delta_date.total_seconds()/sample_count))
    csv_writer.writerow((["Log Start", str(start_date), "", "","","","","","",""]));
    csv_writer.writerow((["Log End", str(end_date), "", "","","","","","",""]));
    csv_writer.writerow((["Log Duration", str(delta_date.total_seconds()), "", "","","","","","",""]));
    csv_writer.writerow((["Sample Count", "{:09d}".format(sample_count), "", "","","","","","",""]));
    csv_writer.writerow((["Sample Error Count", "{:09d}".format(ng_count), "", "","","","","","",""]));
    csv_writer.writerow((["Data Rate", str(sample_count/delta_date.total_seconds()), "sps", "","","","","","",""]));
    csv_out.close()
    return

def getStreamSample16(SAMPLE_DURATION, mode):
    "Parses Burst Read of IMU data for specified seconds will check if BURST marker and DELIMITER is present"

    # Assumes, No Flags, Temp16, Gyro16, Accl16, Count16, No Checksum
    # Print Header Row
    print("M-G362 CSV Log File created by Python","Log Duration (sec): {:05.3f}".format(SAMPLE_DURATION),"Press CTRL-C to exit early","","","","","","")
    print("Creation Date:",str(datetime.datetime.now()),"","","","","","","")
    if mode == 1:
        print("Scaled 16-bit Data","SF_GYRO={:+01.4f} dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f} mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f} degC/lsb".format(SF_TEMP),"","","","","","")
        print("Sample No.","Gx[dps]","Gy[dps]","Gz[dps]","Ax[mG]","Ay[mG]","Az[mG]","Ts[deg.C]","Counter[dec]")
    else:
        print("Raw 16-bit Data","SF_GYRO={:+01.4f} dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f} mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f} degC/lsb".format(SF_TEMP),"","","","","","")
        print("Sample No.","Gx[dec]","Gy[dec]","Gz[dec]","Ax[dec]","Ay[dec]","Az[dec]","Ts[dec]","Counter[dec]")

    # Read the bytes returned from the serial
    # B = unsigned char , i = int (4 byte), H = unsigned short (2 byte)
    # return is Burst Byte + 16-tempC + 16-gyroX + 16-gyroY + 16-gyroZ + 16-accX + 16-accY + 16-accZ + 16-count + 0x0D terminator
    data_struct = struct.Struct('>BhhhhhhhHB') # format must conform to the expected data
    sample_count = 0
    ng_count = 0
    flag_resync = False
    gotoMode('Sampling')
    start_time = time.time()
    current_time = time.time()
    start_date = datetime.datetime.now()
    print("Start Log:"),
    print start_date
    try:
        while (SAMPLE_DURATION > current_time-start_time):
            current_time = time.time()
            if (serial_epson.inWaiting() >= data_struct.size):
                sample_count += 1
                if (flag_resync == False):
                    data_str = serial_epson.read(data_struct.size)
                    data = data_struct.unpack(data_str)
                else:
                    data_str = serial_epson.read((data_struct.size) - 1)
                    data = data_sync + struct.unpack('>hhhhhhhHB',data_str)
                flag_resync = False
                if (data[0] == BURST_MARKER) and (data[9] == DELIMITER):
                    if mode == 1:
                        temp = (( data[1] + TEMP16_25C ) * SF_TEMP ) + 25
                        gx = ( data[2] * SF_GYRO )
                        gy = ( data[3] * SF_GYRO )
                        gz = ( data[4] * SF_GYRO )
                        ax = ( data[5] * SF_ACCL )
                        ay = ( data[6] * SF_ACCL )
                        az = ( data[7] * SF_ACCL )
                        print("{:09d},{:+05.06f},{:+05.6f},{:+05.6f},{:+05.6f},{:+05.6f},{:+05.6f},{:+05.6f},{:05d}".format(sample_count, gx, gy, gz, ax, ay, az, temp, data[8]))
                    else:
                        print("{:09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09},{:05d}".format(sample_count, data[2], data[3], data[4], data[5], data[6], data[7], data[1], data[8]))
                else:
                    print("NG-{:09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:05d}".format(sample_count, data[2], data[3], data[4], data[5], data[6], data[7], data[1], data[8]))
                    ng_count += 1
                    # When DELIMITER and BURSTMARKER is not found in the data read packet, packet is discarded and search for RESYNC
                    # NOTE: This may cause multiple burst samples to be lost as it tries to resync to the BURST MARKER and DELIMITER
                    data_sync = findSync()
                    flag_resync = True
    except KeyboardInterrupt:
        pass
    end_date = datetime.datetime.now()
    delta_date = end_date - start_date
    gotoMode('Config')
    print("\nSummary")
    print("Log Start:\t" + str(start_date))
    print("Log End:\t" + str(end_date))
    print("Log Duration:\t" + str(delta_date))
    print("Sample Count:\t{0}".format(sample_count))
    print("Error Count:\t{0}".format(ng_count))
    print("Sample Rate:\t{:8.3f} Sps".format(sample_count/delta_date.total_seconds()))
    print("Sample Period:\t{:8.4f} seconds/Sample".format(delta_date.total_seconds()/sample_count))
    return

def csvStreamSample32(SAMPLE_DURATION, mode, csv_ofname):
    "Creates a CSV log file with Burst Read of IMU data for specified seconds will check if BURST marker and DELIMITER is present"
    #print time.time()
    #first = 1

    # Assumes, No Flags, Temp32, Gyro32, Accl32, Count16, No Checksum
    # Prep CSV file
    timestr = time.strftime("%Y%m%d-%H%M%S")
    fname = timestr + "_M-G362.csv"
    if csv_ofname:
        fname = csv_ofname
    csv_out = open(fname, 'wb')
    csv_writer = csv.writer(csv_out)

    # Write Header Row
    csv_writer.writerow(["M-G362 CSV Log File created by Python","Log Duration (sec): {:05.3f}".format(SAMPLE_DURATION),"Press CTRL-C to exit early","","","","","","",""])
    csv_writer.writerow(["Creation Date:",str(datetime.datetime.now()),"","","","","","","","",""])
    if mode == 1:
        csv_writer.writerow(["Scaled 32-bit Data","SF_GYRO={:+01.4f}/2^16 dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f}/2^16 mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f}/2^16 degC/lsb".format(SF_TEMP),"","","","","",""])
        csv_writer.writerow(["Sample No.","Gx[dps]","Gy[dps]","Gz[dps]","Ax[mG]","Ay[mG]","Az[mG]","Ts[deg.C]","Counter[dec]","Error"])
    else:
        csv_writer.writerow(["Raw 32-bit Data","SF_GYRO={:+01.4f}/2^16 dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f}/2^16 mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f}/2^16 degC/lsb".format(SF_TEMP),"","","","","",""])
        csv_writer.writerow(["Sample No.","Gx[dps]","Gy[dps]","Gz[dps]","Ax[mG]","Ay[mG]","Az[mG]","Ts[deg.C]","Counter[dec]","Error"])

    # Read the bytes returned from the serial
    # B = unsigned char , i = int (4 byte), H = unsigned short (2 byte)
    # return is Burst Byte + 32-tempC + 32-gyroX + 32-gyroY + 32-gyroZ + 32-accX + 32-accY + 32-accZ + 16-count + 0x0D terminator
    data_struct = struct.Struct('>BiiiiiiiHB') # format must conform to the expected data
    sample_count = 0
    ng_count = 0
    flag_resync = False
    gotoMode('Sampling')
    start_time = time.time()
    #print start_time
    current_time = time.time()
    start_date = datetime.datetime.now()
    print("Start Log:"),
    print start_date
    try:
        while (SAMPLE_DURATION > current_time-start_time):
            if (serial_epson.inWaiting() >= data_struct.size):
                sample_count += 1
                if (flag_resync == False):
                    data_str = serial_epson.read(data_struct.size)
                    data = data_struct.unpack(data_str)
                else:
                    data_str = serial_epson.read((data_struct.size) - 1)
                    data = data_sync + struct.unpack('>iiiiiiiHB',data_str)  # less the BURST MARKER
                flag_resync = False
                current_time = time.time()
                if (data[0] == BURST_MARKER) and (data[9] == DELIMITER):
                    if mode == 1:
                        temp = (( data[1] + TEMP32_25C ) * SF_TEMP / 65536 ) + 25
                        gx = ( data[2] * SF_GYRO / 65536 )
                        gy = ( data[3] * SF_GYRO / 65536 )
                        gz = ( data[4] * SF_GYRO / 65536 )
                        ax = ( data[5] * SF_ACCL / 65536 )
                        ay = ( data[6] * SF_ACCL / 65536 )
                        az = ( data[7] * SF_ACCL / 65536 )
                        csv_writer.writerow(["{:09d}".format(sample_count),"{:+05.6f}".format(gx),"{:+05.6f}".format(gy),"{:+05.6f}".format(gz),\
                                            "{:+05.6f}".format(ax),"{:+05.6f}".format(ay),"{:+05.6f}".format(az),"{:+05.06f}".format(temp),\
                                            "{:05d}".format(data[8]),"","{:05.6f}".format(current_time)])
                    else:
                        csv_writer.writerow([sample_count, data[2], data[3], data[4], data[5], data[6], data[7], data[1], data[8],""]);
                    sys.stdout.write('.')
                else:
                    temp = (( data[1] + TEMP32_25C ) * SF_TEMP / 65536 ) + 25
                    gx = ( data[2] * SF_GYRO / 65536 )
                    gy = ( data[3] * SF_GYRO / 65536 )
                    gz = ( data[4] * SF_GYRO / 65536 )
                    ax = ( data[5] * SF_ACCL / 65536 )
                    ay = ( data[6] * SF_ACCL / 65536 )
                    az = ( data[7] * SF_ACCL / 65536 )
                    csv_writer.writerow(["{:09d}".format(sample_count),"{:+05.6f}".format(gx),"{:+05.6f}".format(gy),"{:+05.6f}".format(gz),\
                                            "{:+05.6f}".format(ax),"{:+05.6f}".format(ay),"{:+05.6f}".format(az),"{:+05.06f}".format(temp),\
                                            "{:05d}".format(data[8]),"!","{:05.6f}".format(current_time)])
                    sys.stdout.write('!')
                    ng_count += 1
                    # When DELIMITER and BURSTMARKER is not found in the data read packet, packet is discarded and search for RESYNC
                    # NOTE: This may cause multiple burst samples to be lost as it tries to resync to the BURST MARKER and DELIMITER
                    data_sync = findSync()
                    flag_resync = True
                #if first == 1:
                #    print time.time()
                #    first = 0
                
    except KeyboardInterrupt:
        pass
    end_date = datetime.datetime.now()
    delta_date = end_date - start_date
    print("Done")
    gotoMode('Config')
    print("\nSummary")
    print("Log Filename:\t" + fname)
    print("Log Start:\t" + str(start_date))
    print("Log End:\t" + str(end_date))
    print("Log Duration:\t" + str(delta_date.total_seconds()))
    print("Sample Count:\t{0}".format(sample_count))
    print("Error Count:\t{0}".format(ng_count))
    print("Sample Rate:\t{:8.3f} Sps".format(sample_count/delta_date.total_seconds()))
    print("Sample Period:\t{:8.4f} sec/Sample".format(delta_date.total_seconds()/sample_count))
    csv_writer.writerow((["Log Start", str(start_date), "", "","","","","","",""]));
    csv_writer.writerow((["Log End", str(end_date), "", "","","","","","",""]));
    csv_writer.writerow((["Log Duration", str(delta_date.total_seconds()), "", "","","","","","",""]));
    csv_writer.writerow((["Sample Count", "{:09d}".format(sample_count), "", "","","","","","",""]));
    csv_writer.writerow((["Sample Error Count", "{:09d}".format(ng_count), "", "","","","","","",""]));
    csv_writer.writerow((["Data Rate", str(sample_count/delta_date.total_seconds()), "sps", "","","","","","",""]));
    csv_out.close()

    with open('temp_time.txt',"w") as myfile:
        myfile.write(str(start_time))
    
    return


def getStreamSample32(SAMPLE_DURATION, mode):
    "Parses Burst Read of IMU data for specified seconds will check if BURST marker and DELIMITER is present"

    #Activate Magnetometer


    # Assumes, No Flags, Temp32, Gyro32, Accl32, Count16, No Checksum
    # Print Header Row
    print("M-G362 CSV Log File created by Python","Log Duration (sec): {:05.3f}".format(SAMPLE_DURATION),"Press CTRL-C to exit early","","","","","","")
    print("Creation Date:",str(datetime.datetime.now()),"","","","","","","")
    
    if mode == 1:
        print("Scaled 32-bit Data","SF_GYRO={:+01.4f}/2^16 dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f}/2^16 mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f}/2^16 degC/lsb".format(SF_TEMP),"","","","","","")
        print("Sample No.","Gx[dps]","Gy[dps]","Gz[dps]","Ax[mG]","Ay[mG]","Az[mG]","Ts[deg.C]","Counter[dec]")
    else:
        print("Raw 32-bit Data","SF_GYRO={:+01.4f}/2^16 dps/lsb".format(SF_GYRO),"SF_ACCL={:+01.3f}/2^16 mg/lsb".format(SF_ACCL),"SF_TEMP={:+01.7f}/2^16 degC/lsb".format(SF_TEMP),"","","","","","")
        print("Sample No.","Gx[dec]","Gy[dec]","Gz[dec]","Ax[dec]","Ay[dec]","Az[dec]","Ts[dec]","Counter[dec]")

    # Read the bytes returned from the serial
    # B = unsigned char , i = int (4 byte), H = unsigned short (2 byte)
    # return is Burst Byte + 32-tempC + 32-gyroX + 32-gyroY + 32-gyroZ + 32-accX + 32-accY + 32-accZ + 16-count + 0x0D terminator
    
    data_struct = struct.Struct('>BiiiiiiiHB') # format must conform to the expected data
    sample_count = 0
    ng_count = 0
    flag_resync = False

    gotoMode('Sampling')

    start_time = time.time()
    current_time = time.time()
    start_date = datetime.datetime.now()

    print("Start Log:"),
    print start_date

    try:
        while (SAMPLE_DURATION > current_time-start_time):
            current_time = time.time()

            if (serial_epson.inWaiting() >= data_struct.size):
                sample_count += 1

                if (flag_resync == False):
                    data_str = serial_epson.read(data_struct.size)
                    data = data_struct.unpack(data_str)
                else:
                    data_str = serial_epson.read((data_struct.size) - 1)
                    data = data_sync + struct.unpack('>iiiiiiiHB',data_str)  # less the BURST MARKER
                
                flag_resync = False
                if (data[0] == BURST_MARKER) and (data[9] == DELIMITER):
                    if mode == 1:
                        temp = (( data[1] + TEMP32_25C ) * SF_TEMP / 65536 ) + 25
                        gx = ( data[2] * SF_GYRO / 65536 )
                        gy = ( data[3] * SF_GYRO / 65536 )
                        gz = ( data[4] * SF_GYRO / 65536 )
                        ax = ( data[5] * SF_ACCL / 65536 )
                        ay = ( data[6] * SF_ACCL / 65536 )
                        az = ( data[7] * SF_ACCL / 65536 )
                        
                        data = "{:09d},{:+05.6f},{:+05.6f},{:+05.6f},{:+05.6f},{:+05.6f},{:+05.6f},{:+05.6f},{:05d},{:05.6f}".format(sample_count, gx, gy, gz, ax, ay, az, temp, data[8],current_time)
                        print(data)
                        

                        with open('OSA_IMU_dataLog.csv',"a") as myfile:
                            myfile.write(data)
                            myfile.write('\n')

                    else:
                        print("{:09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09},{:05d},{:05.6f}".format(sample_count, data[2], data[3], data[4], data[5], data[6], data[7], data[1], data[8], current_time))
                    
                else:
                    print("NG-{:09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09},{:05d},{:05.6f}".format(sample_count, data[2], data[3], data[4], data[5], data[6], data[7], data[1], data[8], current_time))
                    ng_count += 1
                    # When DELIMITER and BURSTMARKER is not found in the data read packet, packet is discarded and search for RESYNC
                    # NOTE: This may cause multiple burst samples to be lost as it tries to resync to the BURST MARKER and DELIMITER
                    data_sync = findSync()
                    flag_resync = True
           

    except KeyboardInterrupt:
        pass
    end_date = datetime.datetime.now()
    delta_date = end_date - start_date
    gotoMode('Config')
    print("\nSummary")
    print("Log Start:\t" + str(start_date))
    print("Log End:\t" + str(end_date))
    print("Log Duration:\t" + str(delta_date.total_seconds()))
    print("Sample Count:\t{0}".format(sample_count))
    print("Error Count:\t{0}".format(ng_count))
    print("Sample Rate:\t{:8.3f} Sps".format(sample_count/delta_date.total_seconds()))
    print("Sample Period:\t{:8.4f} seconds/Sample".format(delta_date.total_seconds()/sample_count))
   
    return

def findSync():
    "Tries to find SYNC (0x0D & 0x20) in the stream"
    #data_struct = struct.Struct('>HhhhhhhhHHB') # format must conform to the expected data
    count = 0
    flag_foundSync = False
    while (flag_foundSync != True):
        #sys.stdout.write('?')
        #print count
        if (serial_epson.inWaiting() > 0):
            data = struct.unpack('B',serial_epson.read(1))
            count = count + 1
            if (data[0] == DELIMITER):
                #print ("Found {:#02x}".format(DELIMITER))
                data = struct.unpack('B',serial_epson.read(1))
                count = count + 1
                if (data[0] == BURST_MARKER):
                    #print ("Found {:#02x}".format(BURST_MARKER))
                    #if serial_epson.inWaiting() >= data_struct.size:
                     #   data_str = serial_epson.read(data_struct.size)
                     #   data = data + data_struct.unpack(data_str) # The data must be flipped to little endian to be read correctly
                        #print("{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:+09d},{:05d}".format(data[3], data[4], data[5], data[6], data[7], data[8], data[2], data[10]))
                        #print data
                    flag_foundSync = True
                    count = 0
                    #sys.stdout.write('!\n')
    return data
