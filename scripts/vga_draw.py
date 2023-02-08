import sys
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

SCREEN_W = 640
SCREEN_H = 480
DELAY = 1000

class App(object):
	def __init__(self, path):
		self._path = path

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
		num_images = len(pixels) // (SCREEN_W * SCREEN_H)
		num_pixels = num_images * SCREEN_W * SCREEN_H
		arr = np.array(pixels)[:num_pixels].astype("uint8")
		images = np.split(arr, num_images)
		return images

	def draw_all(self, cmd_delay):
		pixels = self.get_pixels()
		images = self.pixels_to_images(pixels)
		fig = plt.figure()
		frames = [[plt.imshow(im.reshape(SCREEN_H, SCREEN_W, 3), animated=True, origin="lower")] for im in images]
		ani = animation.ArtistAnimation(fig, frames, interval=cmd_delay, blit=True, repeat_delay=1000)

		plt.axis("off")
		plt.show()

def main(path):
	app = App(path)
	app.draw_all(DELAY)

USAGE = """
python {0} <vga_signals_file>
	
	vga_signals_file - File with VGA simulation signals in a png form (RGB as byte triplets)
"""

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print(USAGE.format(sys.argv[0]))
	else:
		main(sys.argv[1])
