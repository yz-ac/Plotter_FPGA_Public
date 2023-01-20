import sys
import tkinter as tk

MIN_W = 0
MAX_W = 512
MIN_H = 0
MAX_H = 512

class Position(object):
	def __init__(self, x=0, y=0, absolute=True):
		self.x = x
		self.y = y
		self.absolute = absolute

class App(tk.Tk):
	def __init__(self, path, pos):
		tk.Tk.__init__(self)
		self._pos = pos
		self._canvas = tk.Canvas(master=self, height=MAX_H, width=MAX_W)
		self._canvas.pack()
		self._path = path
		self._op_counter = 0

	def move(self, x, y, pen_down=True):
		if pen_down:
			self._canvas.create_line(self._pos.x, MAX_H - self._pos.y, x, MAX_H - y)
		self._pos.x = x
		self._pos.y = y

	def parse_line(self, line):
		op = int(line, 16)
		cmd = (op >> 56) & 0xff
		arg_1 = (op >> 44) & 0xfff
		arg_2 = (op >> 32) & 0xfff
		arg_3 = (op >> 20) & 0xfff
		arg_4 = (op >> 8) & 0xfff
		flags = (op) & 0xff

		if cmd not in App.HANDLERS:
			return

		App.HANDLERS[cmd](self, arg_1, arg_2, arg_3, arg_4, flags)
		self._op_counter += 1

	def parse_all(self, cmd_delay=0):
		delay = 0
		with open(self._path, "r") as ifd:
			line = ifd.readline()
			while line:
				line = line.strip()
				self.after(delay, self.parse_line, line)
				delay += cmd_delay
				line = ifd.readline()

		self.after(delay, print, "DONE!")

	def _parse_arg(self, arg):
		if arg > 0x7ff:
			return arg - 0x1000
		return arg

	def do_G00(self, arg1, arg2, arg3, arg4, flags):
		x = self._parse_arg(arg1)
		y = self._parse_arg(arg2)

		if self._pos.absolute:
			self.move(x, y, pen_down=False)
		else:
			self.move(self._pos.x + x, self._pos.y + y, pen_down=False)

	def do_G01(self, arg1, arg2, arg3, arg4, flags):
		x = self._parse_arg(arg1)
		y = self._parse_arg(arg2)

		if self._pos.absolute:
			self.move(x, y, pen_down=True)
		else:
			self.move(self._pos.x + x, self._pos.y + y, pen_down=True)

	def _find_quadrant(self, rel_x, rel_y):
		if (rel_x >= 0) and (rel_y >= 0):
			return 1
		elif (rel_x < 0) and (rel_y >= 0):
			return 2
		elif (rel_x < 0) and (rel_y < 0):
			return 3
		else:
			return 4

	def _isqrt(self, num):
		if num <= 1:
			return num
		l = 1
		r = num + 1

		while (l != r - 1):
			m = (l + r) >> 1
			if (m * m <= num):
				l = m
			else:
				r = m

		return l

	def _find_direction(self, rel_x, rel_y, r2, is_ccw):
		quadrant = self._find_quadrant(rel_x, rel_y)
		cur_r2 = (rel_x * rel_x) + (rel_y * rel_y)

		if is_ccw:
			if quadrant == 1:
				direction = "up"
				if cur_r2 >= r2:
					direction = "left"
			elif quadrant == 2:
				direction = "down"
				if cur_r2 < r2:
					direction = "left"
			elif quadrant == 3:
				direction = "down"
				if cur_r2 >= r2:
					direction = "right"
			else:
				direction = "up"
				if cur_r2 < r2:
					direction = "right"
		else:
			if quadrant == 1:
				direction = "right"
				if cur_r2 >= r2:
					direction = "down"
			elif quadrant == 2:
				direction = "right"
				if cur_r2 < r2:
					direction = "up"
			elif quadrant == 3:
				direction = "left"
				if cur_r2 >= r2:
					direction = "up"
			else:
				direction = "left"
				if cur_r2 < r2:
					direction = "down"

		return direction

	def _do_step(self, direction):
		if direction == "up":
			self.move(self._pos.x, self._pos.y + 1, True)
		elif direction == "down":
			self.move(self._pos.x, self._pos.y - 1, True)
		elif direction == "left":
			self.move(self._pos.x - 1, self._pos.y, True)
		else:
			self.move(self._pos.x + 1, self._pos.y, True)

	def _find_num_steps_ccw(self, x, y, i, j, r):
		start_x = self._pos.x
		start_y = self._pos.y
		end_x = x
		end_y = y
		if not self._pos.absolute:
			end_x = self._pos.x + x
			end_y = self._pos.y + y

		center_x = self._pos.x + i
		center_y = self._pos.y + j

		rel_start_x = start_x - center_x
		rel_start_y = start_y - center_y

		rel_end_x = end_x - center_x
		rel_end_y = end_y - center_y

		start_quadrant = self._find_quadrant(rel_start_x, rel_start_y)
		end_quadrant = self._find_quadrant(rel_end_x, rel_end_y)

		abs_start_x = abs(rel_start_x)
		abs_end_x = abs(rel_end_x)
		abs_start_y = abs(rel_start_y)
		abs_end_y = abs(rel_end_y)

		is_axis_crossing = False
		if end_quadrant == start_quadrant:
			if start_quadrant == 1:
				if abs_end_x >= abs_start_x or abs_end_y <= abs_start_y:
					is_axis_crossing = True
			elif start_quadrant == 2:
				if abs_end_x <= abs_start_x or abs_end_y >= abs_start_y:
					is_axis_crossing = True
			elif start_quadrant == 3:
				if abs_end_x >= abs_start_x or abs_end_y <= abs_start_y:
					is_axis_crossing = True
			else:
				if abs_end_x <= abs_start_x or abs_end_y >= abs_start_y:
					is_axis_crossing = True

		else:
			is_axis_crossing = True

		if is_axis_crossing:
			tmp_end_quadrant = end_quadrant
			if end_quadrant <= start_quadrant:
				tmp_end_quadrant += 4

			num_steps = (tmp_end_quadrant - start_quadrant - 1) * 2 * r

			if start_quadrant == 1:
				num_steps += abs_start_x + r - abs_start_y
			elif start_quadrant == 2:
				num_steps += r - abs_start_x + abs_start_y
			elif start_quadrant == 3:
				num_steps += abs_start_x + r - abs_start_y
			else:
				num_steps += r - abs_start_x + abs_start_y

			if end_quadrant == 1:
				num_steps += r - abs_end_x + abs_end_y
			elif end_quadrant == 2:
				num_steps += abs_end_x + r - abs_end_y
			elif end_quadrant == 3:
				num_steps += r - abs_end_x + abs_end_y
			else:
				num_steps += abs_end_x + r - abs_end_y
		else:
			num_steps = abs(rel_end_x - rel_start_x) + abs(rel_end_y - rel_start_y)

		return num_steps

	def _find_num_steps(self, x, y, i, j, r, is_ccw):
		num_steps_ccw = self._find_num_steps_ccw(x, y, i, j, r)
		num_steps_cw = 8 * r - num_steps_ccw
		if num_steps_ccw == 8 * r:
			num_steps_cw = num_steps_ccw

		if is_ccw:
			return num_steps_ccw
		return num_steps_cw

	def _do_circular_mvt(self, arg1, arg2, arg3, arg4, flags, is_ccw):
		x = self._parse_arg(arg1)
		y = self._parse_arg(arg2)
		i = self._parse_arg(arg3)
		j = self._parse_arg(arg4)

		end_x = x
		end_y = y
		if not self._pos.absolute:
			end_x = self._pos.x + x
			end_y = self._pos.y + y

		center_x = self._pos.x + i
		center_y = self._pos.y + j

		r2 = (i * i) + (j * j)
		r = self._isqrt(r2)

		num_steps = self._find_num_steps(x, y, i, j, r, is_ccw)
		for step in range(num_steps):
			rel_x = self._pos.x - center_x
			rel_y = self._pos.y - center_y
			direction = self._find_direction(rel_x, rel_y, r2, is_ccw)
			self._do_step(direction)

		self.move(end_x, end_y, True)

	def do_G02(self, arg1, arg2, arg3, arg4, flags):
		self._do_circular_mvt(arg1, arg2, arg3, arg4, flags, False)

	def do_G03(self, arg1, arg2, arg3, arg4, flags):
		self._do_circular_mvt(arg1, arg2, arg3, arg4, flags, True)

	def do_G90(self, arg1, arg2, arg3, arg4, flags):
		self._pos.absolute = True

	def do_G91(self, arg1, arg2, arg3, arg4, flags):
		self._pos.absolute = False

	HANDLERS = {
			0: do_G00,
			1: do_G01,
			2: do_G02,
			3: do_G03,
			4: do_G90,
			5: do_G91
			}


def main(path, cmd_delay):
	app = App(path, Position(0, 0, True))
	app.parse_all(cmd_delay)
	app.mainloop()

USAGE = """
python {0} <path> [cmd_delay]
	path - path to hex .mem file with opcodes
	cmd_delay - optional delay for drawing
"""

if __name__ == "__main__":
	if len(sys.argv) < 2:
		print(USAGE.format(sys.argv[0]))
	else:
		cmd_delay = 0
		if len(sys.argv) > 2:
			cmd_delay = int(sys.argv[2])
		main(sys.argv[1], cmd_delay)
