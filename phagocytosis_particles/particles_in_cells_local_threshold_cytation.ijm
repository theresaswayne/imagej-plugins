// @File(label = "Input directory", style = "directory") inputdir
// @String(label = "Well to process", value = "A1") wellNumber
// @Integer(label = "Amount to enlarge nuclei (pixels)", value = 15) enlargeRadius
// @File(label = "Output directory", style = "directory") outputdir

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameter

// particles_in_cells_local_threshold_cytation.ijm
// Counts cells and phagocytosed particles within and outside cells
// Cell area is defined by an enlarged nuclear mask

// Input: 3-channel single-z, time-lapse image
// Channels must be in order: nuclei, particles, other (any channels beyond 2 are not used)
// Outputs measurements to a table and CSV

// Naming style: C6_-3_1_1_ZProj[Stitched[Deconvolved[Texas Red 586,647]]]_001.tif
// {well}_{-3}_{1}_{chnum}_{proc}[{chname}]_{t}.tif

// written by Theresa Swayne for Irina Sosunova/Serge Przedborski, 2019


// adjustable parameters ==============

NUCMIN = 3500; // min. area of nuclei in pixels. For 60x Cytation images, 1 pixel = 0.19 um. 
PARTICLEMIN = 10; // min. area of a phagocytosed particle in pixels.
PARTICLEMAX = 1500; // min. area of a phagocytosed particle in pixels.
 
// setup ===================

run("Input/Output...", "file=.csv copy_row save_column"); // saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area mean stack display redirect=None decimal=2"); 
run("Clear Results");
roiManager("reset");

// Load images ====================
// open one well, one channel, all timepoints 
// in Cytation, ch2 = green particles, ch 3 = dapi
// in the macro, ch1 is nuclei, ch2 is particles

// Cannot open all timepoints and channels in a single stack because of naming conventions:
//	(virtual stack must be in XYCZT order, but images are in XYZTC order)

for (channelNumber = 2; channelNumber <= 3; channelNumber ++) {

	print("Loading channel",channelNumber);
	run("Image Sequence...", "open=["+inputdir+"] file=(^"+wellNumber+".{0,8}"+channelNumber+"_ZProj) sort use"); // regex in parentheses
	
	id = getImageID();
	title = getTitle();
	print("Image Title is",title);

	// swap frames and slices because virtual stack loads them incorrectly
	run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	getDimensions(width, height, channels, slices, frames);
	print("we now have",channels, "channels and",frames,"frames");

	// name the image after its channel
	rename("C"+channelNumber+"-"+title);
	print("Image Title is now",getTitle());

	}

// merge the channels to make a single time series that will be the basis for the next steps
// in the macro, ch1 is nuclei, ch2 is particles

run("Merge Channels...", "c1=C3-"+title+" c2=C2-"+title+" create");

//setBatchMode(true);

for (timeIndex=1; timeIndex <= frames; timeIndex++) {

	roiManager("reset");

	// retrieve individual channels for the timepoint
	run("Make Substack...", "channels=1-2 frames="+timeIndex);
	procName = title + "_" + wellNumber + "-t" + timeIndex;
	rename(procName);
	print("Image Title is now",getTitle());
	run("Split Channels");
	
	// identify cells using smoothed nuclei
	selectWindow("C1-"+procName); // the -1 is appended to name when making the substack
	run("Gaussian Blur...", "sigma=5");
	run("8-bit"); // required for local threshold
	run("Auto Local Threshold", "method=Niblack radius=100 parameter_1=0 parameter_2=0 white");
	//setOption("BlackBackground", true);
	//run("Convert to Mask");
	run("Watershed");
	rename(procName + "-Nuclei"); // avoid confusion later
	run("Analyze Particles...", "size="+NUCMIN+"-Infinity pixel exclude summarize");
	
	// determine cell area by enlarging nuclei
	// Note that enlargeRadius is in pixels. For 60x Cytation images, 1 pixel = 0.19 um. 
	run("Create Selection");
	run("Enlarge...", "enlarge="+enlargeRadius+" pixel");
	roiManager("Add");
	run("Create Mask");
	selectWindow("Mask");
	saveAs("Tiff", outputdir + File.separator + procName + "-Cells");
	close();
	
	// identify particles
	selectWindow("C2-"+procName);
	//run("Gaussian Blur...", "sigma=2");
	run("8-bit");
	run("Auto Local Threshold", "method=Bernsen radius=15 parameter_1=50 parameter_2=0 white");
	// possible binary open
	run("Watershed");
	rename(procName + "-Particles");
	
	// count particles inside cells
	selectWindow(procName + "-Particles");
	rename(procName + "-Particles inside"); //kludge
	roiManager("Select", 0);
	run("Analyze Particles...", "size="+PARTICLEMIN+"-"+PARTICLEMAX+" pixel show=Masks summarize"); // do NOT exclude on edges
	selectWindow("Mask of "+procName+ "-Particles inside");
	saveAs("Tiff", outputdir + File.separator + procName + "-Inside");
	close();
	
	// count total particles
	selectWindow(procName + "-Particles inside");
	run("Select None");
	//roiManager("Select", 0);
	//run("Make Inverse"); // selects everything outside
	rename(procName + "-Total particles"); //kludge
	run("Analyze Particles...", "size="+PARTICLEMIN+"-"+PARTICLEMAX+" pixel show=Masks summarize"); // do not exclude on edges
	selectWindow("Mask of "+procName+ "-Total particles");
	saveAs("Tiff", outputdir + File.separator + procName + "-Total");
	close();

	// clean up
	selectWindow(procName + "-Total particles");
	close();
	selectWindow(procName + "-Nuclei");
	close();
	
}

// clean up
selectWindow("Merged");
close();

// save results
Table.save(outputdir+File.separator+title+"_"+wellNumber+"_Summary.csv","Summary");

//setBatchMode(false);
//print("Done.")