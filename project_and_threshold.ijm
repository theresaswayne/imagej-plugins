// take an open stack and:
//  -- generate a max projection and calculate auto threshold on it by intermodes method
//  -- generate rotated views of the stack and apply the previously determined threshold to them
// 	-- save the raw and thresholded rotated stacks for evaluation
//  -- works in batch macro window

// Note: the raw images are 12-bit but the rotated projections are automatically generated in 8-bit.
// To keep images comparable, display is scaled before projection, 
// and the threshold obtained is scaled to the 8-bit range

// a refractive correction is applied when projecting

path = getDirectory("image");
id = getImageID();
title = getTitle();
// print("title is",title);
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
getVoxelSize(width, height, depth, unit);
//print(width, height, depth, unit)
newDepth = depth*(1.35/1.5);
print(newDepth);

method = "Intermodes";

function tryThresh(method)
	{
	// generates a max projection, auto-thresholds the projection by method,
	// returns the threshold used
	run("Z Project...", "projection=[Max Intensity]");
	setAutoThreshold(method+" dark");
	getThreshold(lower, upper); // a 16-bit threshold
	selectWindow("MAX_"+title);
	close();
	return lower
	}

selectWindow(title);
threshold = tryThresh(method);
print(method,threshold); // should be 69 for image a01 Intermodes

// generate Y rotations 
selectWindow(title);
projName = basename+"_Yproj.tif"
setMinAndMax(0, 4095); // make sure all images are scaled equally
//run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice="+newDepth+" initial=0 total=180 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate")
run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice=.27 initial=0 total=180 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate");
saveAs("tiff", path+projName);

// apply the threshold to the Y rotations

selectWindow(projName);
newName = basename+"_Y_IM";
//	print("new name = ",newName);
run("Duplicate...", "title=&newName& duplicate");
//	run("Duplicate...", "title=" + "["+newName+"] duplicate");
lower = (threshold/4096)*256;
//	print("scaled threshold =",lower);
setThreshold(lower, 255);
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Dark black");
//	run("Make Binary", "background=Dark black");
saveAs("tiff", path+newName+".tif");
close();

selectWindow(projName);
close();

// generate the X rotations
selectWindow(title);
projName = basename+"_Xproj.tif"
//run("3D Project...", "projection=[Brightest Point] axis=X-Axis slice="+newDepth+" initial=0 total=180 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate")
setMinAndMax(0, 4095); // make sure all images are scaled equally
run("3D Project...", "projection=[Brightest Point] axis=X-Axis slice=.27 initial=0 total=180 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate");
saveAs("tiff", path+projName);

// apply the threshold to the X rotations

selectWindow(projName);
newName = basename+"_X_IM";
//print("new name = ",newName);
run("Duplicate...", "title=&newName& duplicate");
lower = (threshold/4096)*256;
//print("scaled threshold =",lower);
setThreshold(lower, 255);
run("Convert to Mask", "method=Default background=Dark black");
//	run("Make Binary", "background=Dark black");
saveAs("tiff", path+newName+".tif");
close();

selectWindow(projName);
close();
selectWindow(title);
close();

