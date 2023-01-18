import sys
import re

def parse_linear(line):
	match = re.match(r"^G\d\d.*?X ([0-9\.\-]+).*?Y ([0-9\.\-]+).*?$", line)
	if not match:
		raise ParseError(line)

	x = int(float(match.groups()[0]))
	y = int(float(match.groups()[1]))

	return x, y, 0, 0

def parse_circular(line):
	match = re.match(r"^G\d\d.*?X ([0-9\.\-]+).*?Y ([0-9\.\-]+).*?I ([0-9\.\-]+).*?J ([0-9\.\-]+).*?$", line)
	if not match:
		raise ParseError(line)

	x = int(float(match.groups()[0]))
	y = int(float(match.groups()[1]))
	i = int(float(match.groups()[2]))
	j = int(float(match.groups()[3]))

	return x, y, i, j

CMDS = {
		"G00": (0, parse_linear),
		"G01": (1, parse_linear),
		"G02": (2, parse_circular),
		"G03": (3, parse_circular),
		"G90": (4, None),
		"G91": (5, None)
		}

class ParseError(Exception):
	pass

def parse_line(line):
	match = re.match(r"^(G\d\d).*?$", line)
	if not match:
		return
	code = match.groups()[0]
	if code not in CMDS:
		return

	cmd = CMDS[code][0]
	arg1 = 0
	arg2 = 0
	arg3 = 0
	arg4 = 0

	try:
		if CMDS[code][1] is not None:
			arg1, arg2, arg3, arg4 = CMDS[code][1](line)
	except ParseError:
		return

	op = (cmd & 0b11111111) << 56
	op |= (arg1 & 0b111111111111) << 44
	op |= (arg2 & 0b111111111111) << 32
	op |= (arg3 & 0b111111111111) << 20
	op |= (arg4 & 0b111111111111) << 8

	hex_op = hex(op)[2:].rjust(16, "0")

	return hex_op

def parse(ifd, ofd):
	line = ifd.readline()
	while line:
		line = line.strip()
		hex_op = parse_line(line)
		if hex_op:
			ofd.write(hex_op + "\n")
		line = ifd.readline()

def main(src, dst):
	with open(src, "r") as ifd:
		with open(dst, "w") as ofd:
			parse(ifd, ofd)

USAGE = """
python {0} <src> <dst>
	src - Gcode file
	dst - Result text file with hex opcodes
"""

if __name__ == "__main__":
	if len(sys.argv) != 3:
		print(USAGE.format(sys.argv[0]))
	else:
		main(sys.argv[1], sys.argv[2])
