L = 5.0 #ratio of HR/LR pixels

WIDTH = #todo
HEIGHT = #todo

mu = 0
sigma = L/5
sigma_squared = sigma*sigma
gauss_exp_denom = -1/(sigma_squared*2)
gaussian_first_part = 1/(sigma * math.sqrt(2*math.pi))

alpha = 1

"""
Returns the Gaussian weight centered about 0 of i, j
"""
def W(i, j):
	first = gaussian_first_part * math.exp(((i-mu)**2))*gauss_exp_denom)
	second = gaussian_first_part * math.exp(((j-mu)**2))*gauss_exp_denom)
	return first*second



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
	y = pix/WIDTH
	x = pix%WIDTH
	locX = math.round(x*L + h)
	locY = math.round(y*L + v)

	xPrime = 0
	for i in range(-L, L):
		for j in range(-L, L):
			xPrime += Y[(x*L+i) + (y*L+j)*WIDTH*L]*W(i,j)

	return xPrime

def cost(Y, X, H, V, M):
	"""
	Cost function for a given Y, with other data
	"""
	p = len(X)
	s = 0
	for k in range(p):
		for i in range(M):
			s += (X[0][i] - xPrime(Y, i, H[k], V[k], WIDTH, HEIGHT))
	s /= 2

	# TODO : Second cost term