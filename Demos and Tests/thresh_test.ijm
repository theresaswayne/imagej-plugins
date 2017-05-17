// IJ1 macro to test thresholding methods
// usage:  have an image open, run macro
// input: tested on single-channel single-slice images.
// output: series of masks thresholded by different methods 
// (use thresh_eval.ijm to generate ROIs to overlay on the original image)


function localthresh(id, method) {
	// id = integer, imageID of active image
	// method = string specifying the method and parameters to use
	selectImage(id);
	newName = substring(method, 0, 3) + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + "["+newName+"]");
	selectWindow(newName);

//	setAutoThreshold(method);
	run("Auto Local Threshold", "method="+method+" radius=40 parameter_1=0 parameter_2=0 white");
	run("Convert to Mask");
//	save();
	return;
	}


function globalthresh(id, method) {
	// id = integer, imageID of active image
	// method = string specifying the method and parameters to use
	selectImage(id);
	newName = substring(method, 0, 3) + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + "["+newName+"]");
	selectWindow(newName);

//	setAutoThreshold(method);
	run("Auto Threshold", "method="+method+" white");
	run("Convert to Mask");
//	save();
	return;
	}

	
LOCALMETHODS = newArray("Bernsen","Phansalkar","MidGrey");
GLOBALMETHODS = newArray("Mean","Percentile","Shanbhag","Moments");

id = getImageID();

// pre-processing -- adjust as needed
run("Subtract Background...", "rolling=50");
run("Gaussian Blur...", "sigma=1");
run("Enhance Local Contrast (CLAHE)", "blocksize=49 histogram=256 maximum=3 mask=*None*");

// local thresholding
for (i = 0; i < LOCALMETHODS.length; i++) 
	{
	localthresh(id, LOCALMETHODS[i]);
	}

// global threhsolding
for (i = 0; i < GLOBALMETHODS.length; i++) 
	{
	globalthresh(id, GLOBALMETHODS[i]);
	}

run("Tile");



//thresh(id, "Default dark");
//thresh(id, "IsoData dark");
//thresh(id, "Otsu dark");
//thresh(id, "Triangle dark");
//thresh(id, "Huang dark");


//run("GreyWhiteTopHatByReconstruction ");
//run("GreyscaleReconstruct ", "mask=[C2-aCC-1 - Arc + cfos_1_1L 01 bgsub.tif] seed=[C2-aCC-1 - Arc + cfos_1_1L 06 gaus 1 Maxima.tif] create 4");
//run("Find Maxima...", "noise=20 output=[Single Points]");
