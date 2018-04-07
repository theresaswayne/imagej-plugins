/*
 * Simple bissection tool. By Olivier Burri at the BioImaging and Optics Platform
 * Provided as-is based on a request of the ImageJ Forum: http://forum.imagej.net/t/how-do-you-measure-the-angle-of-curvature-of-a-claw
 * 
 * Mouse listening code based on imageJ example
 * https://imagej.nih.gov/ij/macros//GetCursorLocDemo.txt
 * 
 * To install, use 'Plugins > Macros > Install...' and select this file
 * 
 * To run, create a line selection and press F2.
 * You will be prompted to name your line
 * It will create an overlay whose length depends on the distance to your
 * curve's midpoint
 * 
 * When you are happy with the length, left-click
 * 
 * A new selection is created. 
 */
macro "Bissect [F2]" {
	// Single Curve, start end
	getSelectionCoordinates(x,y);
	name = getString("Name your ROI","");
	Roi.setName(name);
	roiManager("Add");
	// Get position 90 degrees off and passing by center of selection
	xs = x[0];
	ys = y[0];
	xe = x[1];
	ye = y[1];

	// point m
	xm = (xs + xe) /2;
	ym = (ys + ye) /2;

	// Find perpendicular

	// 1. Vector representing line
	d = dist(xs,ys,xe,ye);
	u = ( xe - xs );
	v = ( ye - ys );

	// 2. Dot product = 0, passing by some arbitrary point
	// u.x + v.y = 0
	// x = 1;
	// y = - u / v;

	// New vector
	k = 100;
	l = (u*(-1)*k) / v;

	d2 = sqrt(k*k+l*l);
	//k /= d2;
	//l /= d2;

	drawInterface(xm, ym, k, l, name);
	
	
	
	
}

function dist(x,y,x2,y2) {
	return sqrt(pow(x-x2,2) + pow(y-y2,2));
}

function drawInterface(px, py, u, v, name) {
	// Setup some variables. Basically these numbers 
	// Represent an action that has taken place (it's the action's ID) 
	shift=1; 
	ctrl=2;  
	rightButton=4; 
	alt=8; 
	leftButton=16; 
	insideROI = 32; // requires 1.42i or later 

	// Normalize u and v
	d = dist(0,0,u,v);

	u /= d;
	v /= d;

	leftClicked = false; 
	while(!leftClicked) { 
		// getCursorLoc gives the x,y,z position of the mouse and the flags associated 
		// to see if a particular action has happened, say a left click while shift is  
		// pressed, you do it like this:  
		// if (flags&leftButton!=0 && flags&shift!=0) { blah blah... } 
		Overlay.clear;
		
		getCursorLoc(x,y,z,flags);

		// Get distance between xm ym and the cursor
		d = dist(xm, ym, x, y);
		
		p1x =  xm+u*d;
		p2x =  xm-u*d;
		p1y =  ym+v*d;
		p2y =  ym-v*d;
		

		Overlay.drawLine(p1x, p1y, p2x, p2y);
		Overlay.show();

		
		
		//If a freehand selection exists and the right button was clicked AND that right click was not pressed before already 
		if (flags&leftButton!=0 && !leftClicked) { 
			// set rightCLicked to true to stop this condition from writing several times the same ROI 
			leftClicked = true; 
			makeLine(p1x, p1y, p2x, p2y);
			wait(50); 
			Roi.setName("Bissection of "+name);
			roiManager("Add");
			Overlay.clear;
		} 
 
		// This wait of 10ms is just to avoid checking the mouse position too often 
		wait(10); 
	} 
	// Here we are out of the drawROI loop, so you can do some post processing already here if you want 
	 
}