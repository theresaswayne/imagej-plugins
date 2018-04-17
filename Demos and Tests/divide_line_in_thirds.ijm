// ImageJ macro to mark off a line selection in thirds
// requires a segmented line selection
// written by Theresa Swayne (tcs6@columbia.edu), August 2012

// TODO 2018 -- since the spline is not very close to the original, should now rewrite using get interpolated Polygon (not avail in macro lang)

run("Fit Spline","straighten");
getSelectionCoordinates(x,y);
//	for (i=0; i<x.length; i++)
//    	print(i+" "+x[i]+" "+y[i]);
oneThird=round(x.length/3);
twoThirds=round(2*x.length/3);
// Overlay.remove;
Overlay.drawString("o",x[oneThird], y[oneThird]);
Overlay.drawString("o",x[twoThirds], y[twoThirds]);
Overlay.show;
