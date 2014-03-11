from PIL import Image
import os, sys

gaussian = len(sys.argv) > 1 and sys.argv[1] == '-g'
print ("gaussian" if gaussian else "not gaussian")

L = 2 #sqrt(resolution increase)

LR_DIM = (2592, 1944)
HR_DIM = (LR_DIM[0]*L, LR_DIM[1]*L)

HR = [0] * (HR_DIM[0] * HR_DIM[1]) 

#include low-res files
LR = []
for i in range(L):
	for j in range(L):
		filename = "imgs/{0}-{1}.png".format(i,j)
		print "Opening " + filename
		img = Image.open(filename)
		in_pixels = img.getdata()
		for x in range(LR_DIM[0]):
			for y in range(LR_DIM[1]):
				hr_x = x*L + i
				hr_y = (y*L + j)*L*LR_DIM[0]


				in_color = in_pixels[x + LR_DIM[0]*y]
				HR[hr_x + hr_y] += int(.8*in_color)

				if gaussian:
					up = (y*L + j - 1)*L*LR_DIM[0]
					down = (y*L + j + 1)*L*LR_DIM[0]
					right = hr_x + 1
					left = hr_x - 1

					if 0 <= left < HR_DIM[0]: HR[left + hr_y] += int(.05*in_color)
					if 0 <= right < HR_DIM[0] : HR[right + hr_y] += int(.05*in_color)
					if 0 <= up < HR_DIM[1]: HR[hr_x + up] += int(.05*in_color)
					if 0 <= down < HR_DIM[1]: HR[hr_x + down] += int(.05*in_color)


outimg = Image.new('L', HR_DIM)
outimg.putdata(HR)
outimg.save("HR{0}.png".format("-gaussian" if gaussian else ""))