import ctypes
dwf = ctypes.cdll.LoadLibrary("dwf.dll")
print ("Encontrou a biblioteca dwf.dll")

from WF_SDK import device
dev = device.open()
from WF_SDK.protocol import uart
uart.open(dev, rx=0, tx=1, baud_rate=9600, parity=None, data_bits=8, stop_bits=1) #rx = 0; tx = 1;

def open(device_data, rx, tx, baud_rate=9600, parity=None, data_bits=8, stop_bits=1):
    """
        initializes UART communication
 
        parameters: - device data
                    - rx (DIO line used to receive data)
                    - tx (DIO line used to send data)
                    - baud_rate (communication speed, default is 9600 bits/s)
                    - parity possible: None (default), True means even, False means odd
                    - data_bits (default is 8)
                    - stop_bits (default is 1)
    """
    # set baud rate
    dwf.FDwfDigitalUartRateSet(device_data.handle, ctypes.c_double(baud_rate))
 
    # set communication channels
    dwf.FDwfDigitalUartTxSet(device_data.handle, ctypes.c_int(tx))
    dwf.FDwfDigitalUartRxSet(device_data.handle, ctypes.c_int(rx))
 
    # set data bit count
    dwf.FDwfDigitalUartBitsSet(device_data.handle, ctypes.c_int(data_bits))
 
    # set parity bit requirements
    if parity == True:
        parity = 2
    elif parity == False:
        parity = 1
    else:
        parity = 0
    dwf.FDwfDigitalUartParitySet(device_data.handle, ctypes.c_int(parity))
 
    # set stop bit count
    dwf.FDwfDigitalUartStopSet(device_data.handle, ctypes.c_double(stop_bits))
 
    # initialize channels with idle levels
 
    # dummy read
    dummy_buffer = ctypes.create_string_buffer(0)
    dummy_buffer = ctypes.c_int(0)
    dummy_parity_flag = ctypes.c_int(0)
    dwf.FDwfDigitalUartRx(device_data.handle, dummy_buffer, ctypes.c_int(0), ctypes.byref(dummy_buffer), ctypes.byref(dummy_parity_flag))
 
    # dummy write
    dwf.FDwfDigitalUartTx(device_data.handle, dummy_buffer, ctypes.c_int(0))
    return

def read(device_data):
    """
        receives data from UART
 
        parameters: - device data
        return:     - integer list containing the received bytes
                    - error message or empty string
    """
    # variable to store results
    error = ""
    rx_data = []
 
    # create empty string buffer
    data = (ctypes.c_ubyte * 8193)()
 
    # character counter
    count = ctypes.c_int(0)
 
    # parity flag
    parity_flag= ctypes.c_int(0)
 
    # read up to 8k characters
    dwf.FDwfDigitalUartRx(device_data.handle, data, ctypes.c_int(ctypes.sizeof(data)-1), ctypes.byref(count), ctypes.byref(parity_flag))
 
    # append current data chunks
    for index in range(0, count.value):
        rx_data.append(int(data[index]))
 
    # ensure data integrity
    while count.value > 0:
        # create empty string buffer
        data = (ctypes.c_ubyte * 8193)()
 
        # character counter
        count = ctypes.c_int(0)
 
        # parity flag
        parity_flag= ctypes.c_int(0)
 
        # read up to 8k characters
        dwf.FDwfDigitalUartRx(device_data.handle, data, ctypes.c_int(ctypes.sizeof(data)-1), ctypes.byref(count), ctypes.byref(parity_flag))
        # append current data chunks
        for index in range(0, count.value):
            rx_data.append(int(data[index]))
 
        # check for not acknowledged
        if error == "":
            if parity_flag.value < 0:
                error = "Buffer overflow"
            elif parity_flag.value > 0:
                error = "Parity error: index {}".format(parity_flag.value)
    return rx_data,

def close(device_data):
    """
        reset the uart interface
    """
    dwf.FDwfDigitalUartReset(device_data.handle)
    return

# como foi uma implementação inicial descartada, nao foi criada uma main, mas as funcoes open, read e close 
# podem ser usadas para controlar a comunicacao UART do Analog Discovery.