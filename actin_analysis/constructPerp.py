# constructPerp.py
# given points a and b, 
# and finds the endpoints c and d of a perpendicular line of length r, through point b 

import random
import math

# establish the points a and b and the length r

# fixed numbers
xa = 20.0
ya = 45.0
xb = 60.0
yb = 75.0

random.seed(9)

#xa = float(random.randrange(10,100))
#ya = float(random.randrange(10,100))

#xb = float(random.randrange(10,100))
#yb = float(random.randrange(10,100))

profileLength = 20.0

print(xa, ya, xb, yb)

# get equations for the line and perpendicular, checking for boundary conditions
# Line ab: y = m * x + b
# Perpendicular line: y = mp * x + bp
# calculate endpoints of new perpendicular line of length r: (xc,yc) and (xd,yd)
 
if (xa-xb == 0.0): # vertical line, slope and intercept are undefined

	print("the original line is vertical")
	# slope m is undefined, slope of perp mp = 0
	mp = 0.0
	# intercept b is undefined, intercept of perp bp = yb
	bp = yb

	# find points c and d on the horizontal line
	xc = xb + profileLength/2.0
	yc = yb

	xd = xb - profileLength/2.0
	yd = yb
	
	
elif (ya - yb == 0.0): # horizontal line, slope and intercept of perp are undefined

	print("the original line is horizontal")
	# slope m is 0, slope of perp mp = undefined
	m = 0.0
	# intercept b is yb, intercept of perp bp is undefined
	b = yb

	# find points c and d on the vertical line
	xc = xb
	yc = yb + profileLength/2.0

	xd = xb
	yd = yb - profileLength/2.0

	
else: # calculate slopes and intercepts in the normal way

	# slope m is change in y over change in x
	m = (yb-ya)/(xa-xb)
	# intercept b is obtained by solving the equation
	b = yb - (m*xb)
	print("original line slope = "+str(m)+", intercept = "+str(b))

	mp = -1/m
	bp = xb * ((m**2+1.0)/m) + b # must use ## not ^!
	print("perpendicular line slope = "+str(mp)+", intercept = "+str(bp))

	# find points c and d on the perpendicular unit vector through point b
	# thanks to David Nehme on Stack Overflow

	abDist = math.sqrt((xb-xa)**2 + (yb-ya)**2)

	dx = (xb-xa)/abDist
	dy = (yb-ya)/abDist

	xc = xb + (profileLength/2)*dy
	yc = yb - (profileLength/2)*dx

	xd = xb - (profileLength/2)*dy
	yd = yb + (profileLength/2)*dx

print(xa, ya, xb, yb)
print(xc, yc, xd, yd)
