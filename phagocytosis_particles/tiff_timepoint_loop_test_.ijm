// @File(label = "Input directory", style = "directory") inputdir
// @String(label = "Well to process", value = "A1") wellNumber
// @Integer(label = "Amount to enlarge nuclei (pixels)", value = 15) enlargeRadius
// @Integer(label = "Number of timepoints", value = 2) frames
// @File(label = "Output directory", style = "directory") outputdir


// Naming style: C6_-3_1_1_ZProj[Stitched[Deconvolved[Texas Red 586,647]]]_001.tif
// {well}_{-3}_{1}_{chnum}_{proc}[{chname}]_{t}.tif


for (timeIndex=1; timeIndex <= frames; timeIndex++) {

	// how the time index will look in the filename
	timeString = IJ.pad(timeIndex, 3);

	// open one well, one channel, one timepoint 
	// in Cytation, ch2 = gfp, ch 3 = dapi
	for (channelNumber = 2; channelNumber <= 3; channelNumber ++) {
	
		print("Loading channel",channelNumber);
		run("Image Sequence...", "open=["+inputdir+"] file=(^"+wellNumber+".{0,8}"+channelNumber+"_ZProj.*]_"+timeString+"\\.tif") sort use"); // regex in parentheses
		
		id = getImageID();
		title = getTitle();
		print("Image Title is",title);
	
		
		getDimensions(width, height, channels, slices, frames);
		print("we have",channels, "channels and",frames,"frames");
	
		run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
		getDimensions(width, height, channels, slices, frames);
		print("we now have",channels, "channels and",frames,"frames");
		
	
		rename("C"+channelNumber+"-"+title);
		print("Image Title is now",getTitle());
	
		}
	// retrieve individual channels for the timepoint
	run("Make Substack...", "channels=1-3 frames="+timeIndex);
	procName = basename + "-t" + timeIndex;
	rename(procName);
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
	saveAs("Tiff", outputdir + File.separator + procName + "-Nuclei");
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
	selectWindow("C3-"+procName);
	close();

}

// save results
Table.save(outputdir+File.separator+basename+"_"+wellNumber+"_Summary.csv","Summary");

//setBatchMode(false);
//print("Done.")



// TODO: renumber channels in main macro so nuclei detected in C3

// ^C6.{0,8}2_ZProj
// TODO: merge channels using updated names
// run("Merge Channels...", "c2=#1971632616_ZProj c3=#1971632616_ZProj create");



