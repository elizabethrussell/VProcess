import math, random
from itertools import permutations
from threading import Thread

L = 4.0 #ratio of HR/LR pixels
L_range = range(-int(L), int(L))
WIDTH = 2592
HEIGHT = 1944

P = 1 #number of pictures

"""
Constants for W. Presently Gaussian constants for approximation.
"""
mu = 0
sigma = L/5
sigma_squared = sigma*sigma
gauss_exp_denom = -1/(sigma_squared*2)
gaussian_first_part = 1/(sigma * math.sqrt(2*math.pi))

def W_calc(i, j):
	"""
	Returns the Gaussian weight centered about 0 of i, j
	"""
	first = gaussian_first_part * math.exp(((i-mu)**2))*gauss_exp_denom
	second = gaussian_first_part * math.exp(((j-mu)**2))*gauss_exp_denom
	return first*second

#calculate full Gaussian, never call W_calc again unless L changes
W = {}
for i in L_range:
	for j in L_range:
		W[(i,j)] = W_calc(i,j)


def xPrime(Y, pix, h, v, width, height):
	"""
	Attempts to reconstruct the LR pixel based on the nearby HR pixels.
		Y: proposed picture data
		pix: LR pixel index
		h: horizontal offset of LR image
		v: vertical offset of LR image
		width: width of LR image in pixels
		height: height of LR image in pixels
	"""
	y = pix/width
	x = pix%width

	if (pix%1000 == 0): print str(pix) + "/" + str(len(Y)) + ": " + str(100.0*pix/len(Y)) + "%"

	locX = int(x*L + h)
	locY = int(y*L + v)

	
	xPrime = 0
	for i in L_range:
		for j in L_range:
			if i in range(width) and j in range(height):
				xPrime += Y[int((x*L+i) + (y*L+j)*width*L)]*W[(i,j)]
	
	#xPrime = sum([Y[int((x*L+i) + (y*L+j)*width*L)]*W[(i,j)] for (i, j) in permutations(L_range,2)\
	#	if (i in range(width)) and (j in range(height))])

	return xPrime

def cost_over_range(Y, X, H, V, rng, results, index):
	p = len(X)
	M = len(X[0])
	results[index] = 0
	for k in range(p):
		for i in rng:
			results[index] += (X[0][i] - xPrime(Y, i, H[k], V[k], WIDTH, HEIGHT))**2


alpha = 1.0
def cost(Y, X, H, V):
	"""
	Cost function for a given Y, with other data
	"""
	"""
	p = len(X)
	M = len(X[0])
	s = 0
	for k in range(p):
		for i in range(M):
			s += (X[0][i] - xPrime(Y, i, H[k], V[k], WIDTH, HEIGHT))**2
	s /= 2
	"""
	threads = [None] * 2
	results = [None] * 2
	range_size = len(X[0])/len(threads)

	for i in range(len(threads)):
		threads[i] = Thread(target=cost_over_range, args=(Y, X, H, V, range(range_size*i, range_size*(i+1)), results, i))
		threads[i].start()
		print "Thread " + str(i) + " has range(" + str((range_size*i, range_size*(i+1)))

	for i in range(len(threads)):
		threads[i].join()

	# TODO : Second cost term



def main():
	images = []
	for k in range(P):
		images.append([(WIDTH+HEIGHT+k)%256 for _ in range(WIDTH*HEIGHT)])
		print k

	Y = [(WIDTH+HEIGHT+5)%256 for _ in range(WIDTH*HEIGHT)]
	H = range(P)
	V = range(P)
	print cost(Y, images, H, V)

if __name__ == '__main__':main()