# constructPerp.py
# given points a and b, 
# draws a line between them 
# and finds the endpoints c and d of a perpendicular line of length r, through point b 
# and draws that line

import random
import math

# establish the points a and b and the length r

# fixed numbers
# xa = 20.0
# xb = 30.0
# ya = 40.0
# yb = 50.0

random.seed(9)

xa = float(random.randrange(10,100))
ya = float(random.randrange(10,100))

xb = float(random.randrange(10,100))
yb = float(random.randrange(10,100))

r = 20.0

# check for boundary conditions -- horizontal or vertical line

if (xa-xb == 0): # vertical line, slope and intercept are undefined

	# slope of perp mp = 0
	# intercept of perp bp = yb 
	print("the line is vertical")
	
else if (ya - yb == 0): # horizontal line, slope and intercept of perp are undefined

	# get points c and d by simply adding 
	print("the line is horizontal")
	
else: # calculate slope and intercept of line ab in the normal way

	print("the line is diagonal")
	m = (yb-ya)/(xa-xb)

