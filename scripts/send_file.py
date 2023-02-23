import sys
import serial

BAUD = 115200
PARITY = "N"
DATA = 8
DTR = False
RTS = False

def main(com, path):
	ser = serial.Serial()
	ser.port = com
	ser.baudrate = BAUD
	ser.parity = PARITY
	ser.dtr = DTR
	ser.rts = RTS

	ser.open()
	ser.write(open(path, "rb").read())
	ser.close()

USAGE = """
python {0} <com_port> <file>

	com_port - The COM port name (ex. 'COM5').
	file - Path to the file to send.
"""

if __name__ == "__main__":
	if len(sys.argv) != 3:
		print(USAGE.format(sys.argv[0]))
	else:
		main(sys.argv[1], sys.argv[2])
