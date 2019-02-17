// ImageJ macro demonstrating how to retrieve points from a multi-point selection 
// and make a line between them


// For demonstration -- delete the code between the **** later

// *************

// open a sample image
run("AuPbSn 40 (56K)");

// make an example selection
xpoints = newArray(40, 440);
ypoints = newArray(50, 270);
makeSelection("point", xpoints, ypoints);
  
// *************

// Keep the code below to get and use the coordinates from YOUR multipoint selection.
// First make your selection, then run the macro.

Roi.getCoordinates(xpoints, ypoints); // store point coordinates
makeLine(xpoints[0],ypoints[0],xpoints[1],ypoints[1]); // make line
run("Measure"); // measure the line


