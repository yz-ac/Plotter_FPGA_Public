import sys
import subprocess

BAUD = 115200
PARITY = "n"
DATA = 8
DTR = "off"
RTS = "off"

# WARNING: Uses vulnerable "shell=True", not for production environments.
def main(com, path):
	handle = subprocess.Popen([
		"mode",
		com,
		"BAUD={0}".format(BAUD),
		"PARITY={0}".format(PARITY),
		"DATA={0}".format(DATA),
		"DTR={0}".format(DTR),
		"RTS={0}".format(RTS)], shell=True, stdout=subprocess.PIPE)

	handle.wait()
	print(handle.stdout.read().decode("utf-8"))

	handle = subprocess.Popen([
		"cp",
		path,
		r"\\.\{0}".format(com)
		], shell=True, stdout=subprocess.PIPE)

	handle.wait()
	print(handle.stdout.read().decode("utf-8"))

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
