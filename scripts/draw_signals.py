import sys
import tkinter as tk
import re

MIN_X = 0
MAX_X = 512
MIN_Y = 0
MAX_Y = 512

DELAY_MS = 5

class ParseError(Exception):
	pass

class Position(object):
	def __init__(self, x, y):
		self.x = x
		self.y = y

class DrawCommand(object):
	def __init__(self, t, axis, direction, draw):
		self.t = t
		self.axis = axis
		self.direction = direction
		self.draw = draw

def parse_line(line):
	match = re.match(r"^\s+(\d+)\s+:\s+([XY])\s+:\s+([01])\s+:\s+([01])$", line)
	if not match:
		raise ParseError("'{0}'".format(line))

	t, axis, direction, draw = match.groups()
	t = int(t)
	direction = int(direction)
	draw = int(draw)

	return DrawCommand(t, axis, direction, draw)

def draw_once(canvas, pos, cmd):
	nxt_x = pos.x
	nxt_y = pos.y
	if cmd.direction:
		if cmd.axis == "X":
			nxt_x -= 1
		else:
			nxt_y -= 1
	else:
		if cmd.axis == "X":
			nxt_x += 1
		else:
			nxt_y += 1
	if (cmd.draw):
		canvas.create_line(pos.x, MAX_Y - pos.y, nxt_x, MAX_Y - nxt_y)
	pos.x = nxt_x
	pos.y = nxt_y

def main(path, should_delay=False):
	pos = Position(0, 0)
	delay = 0

	root = tk.Tk()
	canvas = tk.Canvas(master=root, width=MAX_X, height=MAX_Y)
	canvas.pack()

	with open(path, "r") as fd:
		lines = fd.read().splitlines()
		cmds = []
		for l in lines:
			cmds.append(parse_line(l))

		cmds.sort(key=lambda x: x.t)
		for cmd in cmds:
			if should_delay:
				root.after(delay, draw_once, canvas, pos, cmd)
			else:
				draw_once(canvas, pos, cmd)
			delay += DELAY_MS

		if should_delay:
			root.after(delay, print, "DONE")

	root.mainloop()

USAGE = """
python {0} <signals_file.txt> [delay]
	signals_file - file of motor signals after simulation
	delay - should use delayed drawing
"""

if __name__ == "__main__":
	if len(sys.argv) < 2:
		print(USAGE.format(sys.argv[0]))
	else:
		should_delay = False
		if len(sys.argv) == 3:
			should_delay = True
		main(sys.argv[1], should_delay)
