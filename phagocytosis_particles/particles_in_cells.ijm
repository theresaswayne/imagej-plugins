// @Integer(label = "Amount to enlarge nuclei", value = 15) enlargeRadius
// @File(label = "Output directory", style = "directory") outputdir

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameter

// particles_in_cells.ijm
// Counts cells and phagocytosed particles within and outside cells
// Cell area is defined by an enlarged nuclear mask

// Input: 3-channel single-z, single-time image
// Channels must be in order: nuclei, particles, other (any channels beyond 2 are not used)
// Outputs measurements to a table and CSV in the following format:
// Filename,CellCount,ParticleCount,ParticlesInside,ParticlesOutside,FractionInside,ParticlesPerCell

// written by Theresa Swayne for Irina Sosunova/Serge Przedborski, 2019


// adjustable parameters

NUCSIZE = 3500; // min. area of nuclei
 
// setup ===================

run("Input/Output...", "file=.csv copy_row save_column"); // saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area mean stack display redirect=None decimal=2"); 
run("Clear Results");
roiManager("reset");

getDimensions(width, height, channels, slices, frames);

id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
extension = substring(title, dotIndex);
basename = substring(title, 0, dotIndex);

//print("Title is",title);
//print("Basename is ",basename);
//print("Extension is",extension);

//setBatchMode(true);

for (timeIndex=1; timeIndex <= frames; timeIndex++) {

	roiManager("reset");

	// select timepoint
	run("Make Substack...", "channels=1-3 frames="+timeIndex);
	procName = basename + "-t" + timeIndex;
	rename(procName);
	run("Split Channels");
	
	// identify cells using smoothed nuclei
	selectWindow("C1-"+procName); // the -1 is appended to name when making the substack
	run("Gaussian Blur...", "sigma=10");
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", "size="+NUCSIZE+"-Infinity exclude summarize");
	
	// determine cell area by enlarging nuclei
	rename(procName + "-Nuclei"); // avoid confusion later
	run("Create Selection");
	run("Enlarge...", "enlarge="+enlargeRadius);
	roiManager("Add");
	run("Create Mask");
	selectWindow("Mask");
	saveAs("Tiff", outputdir + File.separator + procName + "-Nuclei");
	close();
	
	// identify particles
	selectWindow("C2-"+procName);
	run("Gaussian Blur...", "sigma=3");
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
	rename(procName + "-Particles");
	
	// count particles inside cells
	selectWindow(procName + "-Particles");
	rename(procName + "-Particles inside"); //kludge
	roiManager("Select", 0);
	run("Analyze Particles...", "size=0-Infinity show=Masks summarize"); // do not exclude on edges
	selectWindow("Mask of "+procName+ "-Particles inside");
	saveAs("Tiff", outputdir + File.separator + procName + "-Inside");
	close();
	
	// count total particles
	selectWindow(procName + "-Particles inside");
	run("Select None");
	//roiManager("Select", 0);
	//run("Make Inverse"); // selects everything outside
	rename(procName + "-Total particles"); //kludge
	run("Analyze Particles...", "size=0-Infinity show=Masks summarize"); // do not exclude on edges
	selectWindow("Mask of "+procName+ "-Total particles");
	saveAs("Tiff", outputdir + File.separator + procName + "-Total");
	close();

	
	// clean up
	selectWindow(procName + "-Total particles");
	close();
	selectWindow(procName + "-Nuclei");
	close();
	selectWindow("C3-"+procName);
	close();

}

// save results
Table.save(outputdir+File.separator+basename+"_Summary.csv","Summary");

//setBatchMode(false);
//print("Done.")