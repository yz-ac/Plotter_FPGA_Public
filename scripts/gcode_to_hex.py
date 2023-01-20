import sys
import re

class ArgTooBig(Exception):
	pass

class Position(object):
	def __init__(self, x, y, is_absolute=True):
		self.x = x
		self.y = y
		self.absolute = is_absolute

	def move(self, x, y):
		if self.absolute:
			self.x = x
			self.y = y
		else:
			self.x = self.x + x
			self.y = self.y + y

POS = Position(0, 0, True)

def parse_linear(line):
	match = re.match(r"^G\d\d.*?X ([0-9\.\-]+).*?Y ([0-9\.\-]+).*?$", line)
	if not match:
		raise ParseError(line)

	x = float(match.groups()[0])
	y = float(match.groups()[1])

	POS.move(int(x * 1e4), int(y * 1e4))

	return int(x), int(y), 0, 0, 0

def get_quadrant(x, y):
	if x >= 0 and y >= 0:
		return 1
	elif x < 0 and y >= 0:
		return 2
	elif x < 0 and y < 0:
		return 3
	else:
		return 4

def check_number(num):
	if num > 0x7ff:
		raise ArgTooBig("{0}".format(num))

def parse_circular(line):
	match = re.match(r"^G\d\d.*?X ([0-9\.\-]+).*?Y ([0-9\.\-]+).*?I ([0-9\.\-]+).*?J ([0-9\.\-]+).*?$", line)
	if not match:
		raise ParseError(line)

	x = float(match.groups()[0])
	y = float(match.groups()[1])
	i = float(match.groups()[2])
	j = float(match.groups()[3])
	try:
		check_number(x)
		check_number(y)
		check_number(i)
		check_number(j)
	except ArgTooBig:
		POS.move(int(x * 1e4), int(y * 1e4))
		return int(x), int(y), 0, 0, 0

	x = int(x * 1e4)
	y = int(y * 1e4)
	i = int(i * 1e4)
	j = int(j * 1e4)
	flags = 0

	start_x = POS.x
	start_y = POS.y
	end_x = x
	end_y = y
	if not POS.absolute:
		end_x = start_x + x
		end_y = start_y + y
	center_x = start_x + i
	center_y = start_y + j

	rel_start_x = start_x - center_x
	rel_start_y = start_y - center_y
	rel_end_x = end_x - center_x
	rel_end_y = end_y - center_y

	start_quadrant = get_quadrant(rel_start_x, rel_start_y)
	end_quadrant = get_quadrant(rel_end_x, rel_end_y)

	is_axis_crossing = False
	is_full_circle = False
	if start_quadrant != end_quadrant:
		is_axis_crossing = True
	else:
		abs_start_x = abs(rel_start_x)
		abs_start_y = abs(rel_start_y)
		abs_end_x = abs(rel_end_x)
		abs_end_y = abs(rel_end_y)

		if start_quadrant == 1:
			if abs_end_x > abs_start_x or abs_end_y < abs_start_y:
				is_axis_crossing = True
		elif start_quadrant == 2:
			if abs_end_x < abs_start_x or abs_end_y > abs_start_y:
				is_axis_crossing = True
		elif start_quadrant == 3:
			if abs_end_x > abs_start_x or abs_end_y < abs_start_y:
				is_axis_crossing = True
		else:
			if abs_end_x < abs_start_x or abs_end_y > abs_start_y:
				is_axis_crossing = True

		if rel_start_x == rel_end_x and rel_start_y == rel_end_y and (i != 0 and j != 0):
			is_axis_crossing = True
			is_full_circle = True

	if is_axis_crossing:
		flags |= 1

	if is_full_circle:
		flags |= 2

	POS.move(x, y)

	return int(x / 1e4), int(y / 1e4), int(i / 1e4), int(j / 1e4), flags

def parse_absolute(line):
	POS.absolute = True
	return 0, 0, 0, 0, 0

def parse_not_absolute(line):
	POS.absolute = False
	return 0, 0, 0, 0, 0

CMDS = {
		"G00": (0, parse_linear),
		"G01": (1, parse_linear),
		"G02": (2, parse_circular),
		"G03": (3, parse_circular),
		"G90": (4, parse_absolute),
		"G91": (5, parse_not_absolute)
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
	flags = 0

	try:
		if CMDS[code][1] is not None:
			arg1, arg2, arg3, arg4, flags = CMDS[code][1](line)
	except ParseError:
		return

	op = (cmd & 0b11111111) << 56
	op |= (arg1 & 0b111111111111) << 44
	op |= (arg2 & 0b111111111111) << 32
	op |= (arg3 & 0b111111111111) << 20
	op |= (arg4 & 0b111111111111) << 8
	op |= (flags & 0b11111111)

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
