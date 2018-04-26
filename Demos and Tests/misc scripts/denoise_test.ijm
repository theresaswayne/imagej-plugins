// IJ1 macro to test denoising methods
// Theresa Swayne, Columbia University, 2017
// usage: Have an image open. Then run this macro. Save resulting images if desired. 
// input: tested on single-channel single-slice images.
// output: series of images denoised by different methods


function process(id, method, params) {
	// id = integer, imageID of active image
	// method, params = strings specifying the method and parameters to use
	selectImage(id);
	newName = substring(method, 0, 3) + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + newName);
	selectWindow(newName);
	run(method, params);
	return;
	}

id = getImageID();

process(id, "Gaussian Blur...", "sigma=1");
process(id, "Median...", "radius=1");
process(id, "Smooth", "");
