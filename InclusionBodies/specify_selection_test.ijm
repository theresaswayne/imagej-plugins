
backgroundDiam = 15;
middleSlice = 12;

run("Select None");
setTool("point");
waitForUser("Mark background", "Click a cytoplasmic background area, then click OK");

// make a circle around the clicked point
getSelectionCoordinates(px, py);
run("Specify...", "width="+backgroundDiam+" height="+backgroundDiam+" x="+px[0]+" y="+py[0]+" slice=12 oval constrain centered");

run("Measure");
