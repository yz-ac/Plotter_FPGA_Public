import sys
import tkinter as tk
import numpy as np
from PIL import Image, ImageTk

SCREEN_W = 640
SCREEN_H = 480
DELAY = 0

class App(tk.Tk):
	def __init__(self, path):
		tk.Tk.__init__(self)
		self._path = path
		self._canvas = tk.Canvas(master=self, height=SCREEN_H, width=SCREEN_W)
		self._canvas.pack()

	def parse_pixel(self, line):
		r = line[0]
		g = line[1]
		b = line[2]

		return (r, g, b)

	def get_pixels(self):
		pixels = []
		with open(self._path, "rb") as ifd:
			line = ifd.read(3)
			while line:
				pixels.append(self.parse_pixel(line))
				line = ifd.read(3)

		return pixels

	def pixels_to_images(self, pixels):
		num_images = len(pixels) % (SCREEN_W * SCREEN_H)
		num_pixels = num_images * SCREEN_W * SCREEN_H
		arr = np.array(pixels)[:num_pixels]
		images = np.split(arr, num_images)
		return images

	def draw_image(self, img):
		self._canvas.delete("all")
		img_2d = img.reshape(SCREEN_H, SCREEN_W, 3)
		pil_image = Image.fromarray(img_2d, "RGB")
		tk_image = ImageTk.PhotoImage(image=pil_image)
		# Fixes reference to array inside class so it is not deleted at the end of the scope
		self._image = tk_image
		self._canvas.create_image(0, 0, anchor=tk.NW, image=self._image)

	def draw_all(self, cmd_delay):
		delay = 0
		pixels = self.get_pixels()
		images = self.pixels_to_images(pixels)
		for img in images:
			self.after(delay, self.draw_image, img)
			delay += cmd_delay

		self.after(delay, print("DONE!"))

def main(path):
	app = App(path)
	app.draw_all(DELAY)
	app.mainloop()

USAGE = """
python {0} <vga_signals_file>
	
	vga_signals_file - File with VGA simulation signals of the form "R:G:B"
"""

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print(USAGE.format(sys.argv[0]))
	else:
		main(sys.argv[1])
