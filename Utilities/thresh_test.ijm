// IJ1 macro to test thresholding methods
// usage:  have an image open, run macro
// input: tested on single-channel single-slice images.
// output: series of images thresholded by different methods


function thresh(id, method) {
	// id = integer, imageID of active image
	// method = string specifying the method and parameters to use
	selectImage(id);
	newName = substring(method, 0, 3) + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + "["+newName+"]");
	selectWindow(newName);
	run("Subtract Background...", "rolling=50");
	run("Gaussian Blur...", "sigma=1");
	run("Enhance Local Contrast (CLAHE)", "blocksize=49 histogram=256 maximum=3 mask=*None*");

//	setAutoThreshold(method);
	run("Auto Local Threshold", "method="+method+" radius=40 parameter_1=0 parameter_2=0 white");
	run("Convert to Mask");
//	save();
	return;
	}

id = getImageID();

thresh(id, "Bernsen");
thresh(id, "Phansalkar");
thresh(id, "MidGrey");



//thresh(id, "Default dark");
//thresh(id, "IsoData dark");
//thresh(id, "Otsu dark");
//thresh(id, "Triangle dark");
//thresh(id, "Huang dark");


//run("GreyWhiteTopHatByReconstruction ");
//run("GreyscaleReconstruct ", "mask=[C2-aCC-1 - Arc + cfos_1_1L 01 bgsub.tif] seed=[C2-aCC-1 - Arc + cfos_1_1L 06 gaus 1 Maxima.tif] create 4");
//run("Find Maxima...", "noise=20 output=[Single Points]");
