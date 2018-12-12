"""Constant and definition for IMU Gseries."""


class RegAddr:
    """Address for Register Map"""
    BURST = (0,0x00)
    MODE_CTRL = (0,0x02,0x03)
    DIAG_STAT = (0,0x04)
    FLAG = (0,0x06)
    GPIO = (0,0x08,0x09)
    COUNT = (0,0x0A)
    TEMP_HIGH = (0,0x0E)
    TEMP_LOW = (0,0x10)
    XGYRO_HIGH = (0,0x12)
    XGYRO_LOW = (0,0x14)
    YGYRO_HIGH = (0,0x16)
    YGYRO_LOW = (0,0x18)
    ZGYRO_HIGH = (0,0x1A)
    ZGYRO_LOW = (0,0x1C)
    XACCL_HIGH = (0,0x1E)
    XACCL_LOW = (0,0x20)
    YACCL_HIGH = (0,0x22)
    YACCL_LOW = (0,0x24)
    ZACCL_HIGH = (0,0x26)
    ZACCL_LOW = (0,0x28)
    SIG_CTRL = (1,0x00,0x01)
    MSC_CTRL = (1,0x02,0x03)
    SMPL_CTRL = (1,0x04,0x05)
    FILTER_CTRL = (1,0x06,0x07)
    UART_CTRL = (1,0x08,0x09)
    GLOB_CMD = (1,0x0A,0x0B)
    BURST_CTRL1 = (1,0x0C,0x0D)
    BURST_CTRL2 = (1,0x0E,0x0F)
    PROD_ID1 = (1,0x6A,0x6B)
    PROD_ID2 = (1,0x6C,0x6D)
    PROD_ID3 = (1,0x6E,0x6F)
    PROD_ID4 = (1,0x70,0x71)
    FIRM_VER = (1,0x72,0x73)
    SER_NUM1 = (1,0x74,0x75)
    SER_NUM2 = (1,0x76,0x77)
    SER_NUM3 = (1,0x78,0x79)
    SER_NUM4 = (1,0x7A,0x7B)
    WIN_CTRL = (0,0x7E)
    
class DOUT_RATE:
    """Values for a given register"""
    val = (0x01,0x02,0x03,0x04,0x05,0x06,0x07)
    sel = (2000,1000,500,250,125,62.5,31.25)

class FILTER_SEL:
    """Values for a given register"""
    val = (0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,
            0x08,0x09,0x0A,0x0B,
            0x0C,0x0D,0x0E,0x0F,
            0x10,0x11,0x12,0x13)
    sel = ('NONE','MV_AVG2','MV_AVG4','MV_AVG8','MV_AVG16','MV_AVG32','MV_AVG64','MV_AVG128',
            'K32_FC50','K32_FC100','K32_FC200','K32_FC400',
            'K64_FC50','K64_FC100','K64_FC200','K64_FC400',
            'K128_FC50','K128_FC100','K128_FC200','K128_FC400')

class EXT_SEL:
    """Values for a given register"""
    val = (0x00,0x01,0x02)
    sel = ('GPIO','Counter','Trigger')

class MODE_CMD:
    """Values for a given register"""
    val = (0x01,0x02)
    sel = ('Sampling','Config')

class BAUD_RATE:
    """Values for a given register"""
    val = (0x00,0x01,0x02,0x03)
    sel = (0,115200,230400,460800)
