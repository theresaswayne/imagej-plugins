// from https://raw.githubusercontent.com/NicoKiaru/LimeSeg/master/src/main/resources/script-templates/LimeSeg/MacroSegCElegans_1Timepoint.ijm

waitForUser("IJPB-Plugins Update site needs to be enabled!");
run("Show GUI"); // Initializes LimeSeg
run("Clear all"); // Clear previous LimeSeg outputs

// modified -- uses current open image
// Fetch C Elegans example image
//waitForUser("Fetch C Elegans example image");
//open("https://raw.githubusercontent.com/NicoKiaru/TestImages/master/CElegans/dub19-half.tif");
// Stores Image ID
idImage=getImageID();

// Looks for seeds:
waitForUser("Looks for seeds");

//	Duplicates, Blur, Binarize, Find connected components and computes centers of mass
waitForUser("Duplicates, Blur, Binarize, Find connected components and computes centers of mass");
run("Duplicate...", "title=yoda-half-GaussianBlurred.tif duplicate");
run("Gaussian Blur 3D...", "x=4 y=4 z=0.5");
//run("Gaussian Blur 3D...", "x=4 y=4 z=0.5");
run("Invert", "stack");
run("3D Objects Counter", "threshold=245 slice=17 min.=10 max.=3244032 centres_of_masses statistics");
// Closes uselesse image
close();


// Radius of the initial seed for LimeSeg
radius=10;

// Stores results into ROI Manager
waitForUser("Store results into ROI Manager");
//IJ.renameResults("Results");
Table.rename("Statistics for dub19-half-GaussianBlurred.tif", "Results");


for (i=0;i<nResults;i++) {
	xp=getResult("XM", i);	
	yp=getResult("YM", i);	
	zp=getResult("ZM", i);
	setSlice(zp+1);	
	makeOval(xp-radius,yp-radius,2*radius,2*radius);
	Roi.setPosition(1, zp+1, 1);
	roiManager("Add");
}
close();
// Prepare to work on the initial CElegans image
selectImage(idImage);

run("Sphere Seg", "d_0=3.5 f_pressure=0.015 z_scale=3.5 range_in_d0_units=1.5 samecell=false show3d=true numberofintegrationstep=-1 realxypixelsize=0.133");
