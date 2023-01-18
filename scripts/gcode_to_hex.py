import sys
import re

REGEXP = r"^(G\d\d).*?(?:X ([0-9\.\-]+)).*?(?:Y ([0-9\.\-]+)).*?(?:I ([0-9\.\-]+)).*?(?:J ([0-9\.\-]+)).*?$"
CMDS = {
		"G00": 0,
		"G01": 1,
		"G02": 2,
		"G03": 3,
		"G90": 4,
		"G91": 5
		}

class ParseError(Exception):
	pass

def parse_line(line):
	match = re.match(REGEXP, line)
	if not match:
		return
	code = match.groups()[0]
	x = 0
	y = 0
	i = 0
	j = 0

	try:
		x = int(float(match.groups()[1]))
		y = int(float(match.groups()[2]))
		i = int(float(match.groups()[3]))
		j = int(float(match.groups()[4]))
	except IndexError:
		pass

	cmd = CMDS.get(code)
	if cmd is None:
		return

	op = (cmd & 0b11111111) << 56
	op |= (x & 0b111111111111) << 44
	op |= (y & 0b111111111111) << 32
	op |= (i & 0b111111111111) << 20
	op |= (j & 0b111111111111) << 8

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
