// Action Bar description file :BIOP_VSI_reader
// By Olivier Burri & Romain Guiet
// EPFL BIOP 2014

/*
 * DESCRIPTION: Simple Action Bar to open and make sense of the Olympus OlyVIA Slide Scanner
 * The macro works as follows
 * Uses Jerome Mutterer's Action Bar Plugin as the interface.
 * Takes advantage of the print "Update" Function as of IJ 1.38m to keep data in memory.
 * Uses LOCI BioFormats to read and parse the data from the VSI reader
 *
 * MOTIVATION: Images produced by the OlyVIA Scanner are extremely large (>48'000px)
 * The inherent limitation of Java (or IJ) for images is about 48'000px
 * Because the .vsi files have preview thumbnails, we want to use those in order to
 * navigate the data and open only the part of the image we're interested in.
 *
 *
 * DISCLAIMER: This is a work in progress and some bugs are bound to pop up, don't hesitate to contact us in case you have problems
 * at olivier.burri at epfl.ch
 * Last Update: January 2018
 * 	Change Log Jan 2018:
 * 		- Added possibility to save images in RGB or composite solely based on the metadata
 * 		  This removes the problem when exporting an entire folder of images with different image types	
 * 		  Before, one had to cheese Composite or RGB and all images were treated the same way, which was troublesome
 * 		- Changed name of menu item to BIOP VSI Reader
 * 		- Thumbnails now close when exporting all VSI files in batch
 * 		- Multichannel images forced to be saved as RGB are now composited then converted to RGB.
 * 
 */


// Action Bar settings
sep = File.separator;

// Install the BIOP Library
call("BIOP_LibInstaller.installLibrary", "BIOP"+sep+"BIOPLib.ijm");

runFrom = "jar:file:BIOP/BIOP_VSI_reader.jar!/BIOP_VSI_reader.ijm";

//////////////////////////////////////////////////////////////////////////////////////////////
// The line below is for debugging. Place this VSI file in the ActionBar folder within Plugins
//////////////////////////////////////////////////////////////////////////////////////////////
//runFrom = "/plugins/ActionBar/Debug/BIOP_VSI_reader.ijm";


//print("Running From: "+runFrom);

run("Action Bar", runFrom );


exit();
//Start of ActionBar

<codeLibrary>

/*
 * Must be set for the function library to work
 */
function toolName() {
return "VSI Reader";
}


/*
 * Flag to set for debugging
 */
function isDebug() {
	return false;
}


/*
 * Debug print. If a debug flag is set, then print, otherwise do nothing.
 */
function dprint(text) {
	 deb = isDebug();
	if (deb) {
		print(text);
	}
}

function internalSettings() {
	thumbSize = call("ij.Prefs.get", "vsireader.thumbsize", "Tiny");
	fixZ = call("ij.Prefs.get", "vsireader.fix.z.vsi", false);
	thumbSizes = newArray("Tiny", "Small", "Medium");
	
	Dialog.create("VSI Reader Internal Parameters");
	Dialog.addChoice("Thumbnail Size", thumbSizes, thumbSize);
	Dialog.addCheckbox("Fix VSI Z<->C Confusion", fixZ);

	Dialog.show();

	thumbSize = Dialog.getChoice();
	fixZ = Dialog.getCheckbox();

	call("ij.Prefs.set", "vsireader.thumbsize", thumbSize);
	call("ij.Prefs.set", "vsireader.fix.z.vsi", fixZ);
	
}
/*
 * isVSI just checks at the file extension
 */
function isVSI(filename) {
	if(endsWith(filename, ".vsi")) {
		return true;
	}
	return false;
}

function getThumbOffset() {
	thumbSize = call("ij.Prefs.get", "vsireader.thumbsize", "Tiny");

if ( thumbSize == "Small") {
	return 1;
} else if ( thumbSize == "Medium") {
	return 2;
}
	return 0;
}

function isFixZ() {
	fixZ = call("ij.Prefs.get", "vsireader.fix.z.vsi", false);

if ( thumbSize == "Small") {
	return 1;
} else if ( thumbSize == "Medium") {
	return 2;
}
	return 0;
}

/*
 * Setting and recovering the ID of the current file
 */
function getID() {
	id = getData("Series ID");
	return id;
}

function setFileID(id) {
	setData("Series ID",id);
	dir = substring(id, 0,lastIndexOf(id,File.separator)+1);
	setData("Image Folder",dir);

}

/*
 * Extracts the name of the image from its directory+file string
 */
function getImageName() {
	name = getID();
	name = substring(name, lastIndexOf(name, File.separator)+1,lengthOf(name));
	return name;
}
/* 
 * Extracts the directory 
 */
function getImageDirectory() {
	name = getData("Image Folder");
	dir = substring(name, 0, lastIndexOf(name, File.separator)+1);
	return dir;
}

/* 
 * For the BIOP Needs, this returns the available magnifications 
 * // IS THIS REALLY USEFUL?
 */
function getAvailableMagnifications() {
	return newArray(2, 4, 10, 20, 40);
}

/*
 * This function makes sense of the data inside the VSI file. How, you ask?
 * Oli will tell you. 
 * As of 20-10-2015 Loci Bioformats reads the contents of a VSI file as follows
 * There are up to 3 files with specific unique names
 * - label: A scan of the slide's label
 * - overview: a 4X overview of the slide
 * - macro image: a tiny thumbnail of the slide+label
 * 
 * The last one is usually always there, the other two are optional. 
 * 
 * After are the pyramidal files that make up the actual SERIES with the images the user wants to extract
 * These come in many flavors
 * 4x, 10x, 20x, and 40x are the names that appear on our systems
 * Other systems provide either a custom name or something else.
 * 
 * HOWEVER, the files after follow a nice understandable logic
 * As long as it is part of a pyramid, the files have the following nomenclature
 * 'filename'.vsi #'number' 
 * 
 * So it is easy to know when we are at the end of a pyramidal series, for example
 * A Typical VSI file has the following file names
 * Series: 0 Is called label
 * Series: 1 Is called Image_02.vsi #2
 * Series: 2 Is called Image_02.vsi #3
 * Series: 3 Is called Image_02.vsi #4
 * Series: 4 Is called Image_02.vsi #5
 * Series: 5 Is called Image_02.vsi #6
 * Series: 6 Is called overview
 * Series: 7 Is called Image_02.vsi #8
 * Series: 8 Is called Image_02.vsi #9
 * Series: 9 Is called Image_02.vsi #10
 * Series: 10 Is called Image_02.vsi #11
 * Series: 11 Is called Image_02.vsi #12
 * Series: 12 Is called Image_02.vsi #13
 * Series: 13 Is called 20x
 * Series: 14 Is called Image_02.vsi #15
 * Series: 15 Is called Image_02.vsi #16
 * Series: 16 Is called Image_02.vsi #17
 * Series: 17 Is called Image_02.vsi #18
 * Series: 18 Is called Image_02.vsi #19
 * Series: 19 Is called Image_02.vsi #20
 * Series: 20 Is called Image_02.vsi #21
 * Series: 21 Is called macro image
 * 
 * So we know that the label has 5 sub-images with Image_02.vsi #6 being the smallest pyramid
 * Here is what we do: 
 */
function parseSeriesData(fileID) {
	
	dprint("Parsing Series Data for "+fileID);
	start = getTime();
	// Run BioFormats Macro Extensions to read all series data
	run("Bio-Formats Macro Extensions");

	setFileID(fileID);

	// Set the file to use the Bioformats Macro Extensions
	Ext.setId(fileID);

	// Get the total number of images in the .VSI file.
	Ext.getSeriesCount(seriesCount);

	setData("totSeries", seriesCount);
 	dprint("Total number of series in VSI file: "+seriesCount);

	// For our needs, we will choose the series name based on the magnification value
	objectives_str = ".*\\d{1,2}x.*"; // anything followed by either 1 or 2 digits followed by an 'x' followed by anything.

	// REMOVED IN FAVOR OF A REGULAR EXPRESSION getAvailableMagnifications();

	// Starting the search for series based on name
	nSer = 0;
	hasLabel= false;
	hasOverview = false;
	hasMacro= false;
	hasMask = false;

	for(i=0; i<seriesCount; i++) {
		Ext.setSeries(i);
		Ext.getSeriesName(seriesName);
		dprint("Series: "+i+" Is called "+seriesName);

		// Take care of special cases
		if(seriesName == "label") {	hasLabel = true; }

		else if(seriesName == "overview") { hasOverview = true; }

		else if(seriesName == "macro image") { hasMacro = true; }

		else if(seriesName == "mask") { hasMask = true; }

		else { 		
			if(matches(seriesName, objectives_str)) {
				nSer++;
				dprint("   ^^^ This is a series");
			}
		}
	}

	// In case the series did not have the name we expected
	if (nSer == 0) {
		setData("Mode", "Basic");
		// try to locate the series by name, really simply.
		for(i=0; i<seriesCount; i++) {
			Ext.setSeries(i);
			Ext.getSeriesName(seriesName);
			dprint("Series: "+i+" Is called "+seriesName);
			
			// Take care of special cases
			if(seriesName == "label") {	hasLabel = true; }
	
			else if(seriesName == "overview") { hasOverview = true; }
	
			else if(seriesName == "macro image") { hasMacro = true; }
	
			else if(seriesName == "mask") { hasMask = true; }
	
			else {
				// If it does not end in .vsi # 'number', and was none of the above cases then it should be a series 
				if(!matches(seriesName, ".*\\.vsi #.*")) {
					nSer++;
					dprint("   ^^^ This is a series");
				}
			}
		}
	
	} else {
		setData("Mode", "Normal");
	}

	// Save these variables for later use
	setBool("Has Label", hasLabel);
	setBool("Has Overview", hasOverview);
	setBool("Has Macro Image", hasMacro);
	setBool("Has Mask", hasMask);
	setData("Number Of Series", nSer);
	end = getTime();
	dprint("Parsing Done, took "+d2s((end-start)/1000,2)+" s");

}

/*
 * GetPositionOfTag returns the series index needed for the Bioformats OpenImage command
 * It needs the name of the series ('mask', 'macro image', 'label', etc...)
 */
function getPositionOfTag(name) {
	run("Bio-Formats Macro Extensions");
	fileID = getID();
	Ext.setId(fileID);
	seriesCount = parseInt(getData("totSeries"));

	for(i=0; i<seriesCount; i++) {
		Ext.setSeries(i);
		Ext.getSeriesName(seriesName);
		if(seriesName == name) {
			return i;
		}
	}
	return -1;
}
/*
 * 
 */
function getPositionOfSeries(number) {
	run("Bio-Formats Macro Extensions");
	fileID = getID();
	Ext.setId(fileID);
	seriesCount = parseInt(getData("totSeries"));
	// The trick here is to check whether we are in Simple or Normal Mode.
	// In Normal Mode, we look for the series matching "ObjectiveMagx #.."
	// In Simple Mode, we look for something NOT called something.vsi # something.
	workMode = getData("Mode");



	if (workMode == "Normal") {
		// Start Number of Series
		nSer = 0;
		objectives_str = ".*\\d{1,2}x.*"; // anything followed by either 1 or 2 digits followed by an 'x' followed by anything.
			
		for(i=0; i<seriesCount; i++) {
			Ext.setSeries(i);
			Ext.getSeriesName(seriesName);
			if(matches(seriesName, objectives_str)) {
				nSer++;
				if(nSer == number) { return i; }
			}
		}

	} else {
		if (workMode == "Basic") {
			Ext.setSeries(0);
			Ext.getSizeX(prevSize);
			largeSerId = 0;
			nSer = 0;
			for(i=0; i<seriesCount; i++) {
				Ext.setSeries(i);
				Ext.getSeriesName(seriesName);
				dprint("Series: "+i+" Is called "+seriesName);
					
				if(seriesName == "label") {	dprint("Has Label"); }
		
				else if(seriesName == "overview") { dprint("Has Label"); }
		
				else if(seriesName == "macro image") { dprint("Has Macro Image"); }
		
				else if(seriesName == "mask") { dprint("Has Mask"); }
		
				else { 		
					// If it does not end in .vsi # 'number', and was none of the above cases then it should be a series 
					if(!matches(seriesName, ".*\\.vsi #.*")) {
						nSer++;
						if(nSer == number) { return i; }
					}
				}
			}
		}
	}
}

/*
 * Returns the raw position of the thumbnail for use when opening a series
 */
function getPositionOfThumbs(series) {
	offset = getThumbOffset();
	largeidx = getPositionOfSeries(series);
	seriesCount = parseInt(getData("totSeries"));
	Ext.setSeries(largeidx);
	Ext.getSeriesName(largeName);
	Ext.getSizeX(prevSize);
	Ext.setSeries(largeidx+1);
	Ext.getSeriesName(oriName);
	dprint("Next Series Name: "+oriName);
	// If there is something else under this series, then we know there is only one image, no pyramid
	if (!matches(oriName, ".*\\.vsi #.*")) {
		dprint("No pyramid for series "+series);
		return largeidx;
	}
	dprint("Looking for Thumbnail of series "+series);
	
	oriName = substring(oriName,0, indexOf(oriName, ".vsi"));

	for(i=largeidx+1; i<seriesCount; i++) {
		Ext.setSeries(i);
		Ext.getSizeX(sizeX);
		Ext.getSeriesName(seriesName);
		dprint("Series ID "+i+"("+seriesName+")"+" has size of "+sizeX+", compared to previous size "+prevSize);
		// If we change image name, the previous one was probably right...
		if(prevSize < sizeX || !matches(seriesName, oriName+".*")) {
			// We are done, return the index
			dprint("    Thumbnail found at position "+(i-1-offset));
			return i-1-offset;
		}
		prevSize = sizeX;
	}
	// If we are here we reached the bottom
}

/*
 * Provides what reductions are available for the given series
 */
function getResamplingRate(series) {
	largeIdx = getPositionOfSeries(series);
	smallIdx = getPositionOfThumbs(series);
	resampling = pow(2,(smallIdx-largeIdx));
	dprint("Resampled thumbnail os series "+series+" is at index "+smallIdx);
	dprint("Series is at index "+largeIdx);
	dprint("Resampling is "+resampling);
	
	return resampling;
}

/*
 * Convenience function for finding all sampling rates from the given largest rate
 */
function getAvailableRates(samplingRate) {
	n = log(samplingRate)/log(2);
	rates = newArray(n);
	for (i=0; i<n; i++) {
		rates[i] = ""+parseInt(pow(2,i));
	}
	return rates;
}

/*
 * Return an array containing the XYZCT sizes of a series
 */
function getSeriesSize(seriesPos) {
	Ext.setSeries(seriesPos);
	Ext.getSizeX(sizeX);
	Ext.getSizeY(sizeY);
	Ext.getSizeZ(sizeZ);
	Ext.getSizeC(sizeC);
	Ext.getSizeT(sizeT);

	sizes = newArray(sizeX, sizeY, sizeZ, sizeC, sizeT);

	return sizes;


}
/*
 * After the data is parsed, we can build a dialog to prompt the user for the series he wants to open.
 * 
 * 
 */
function generateDialogAndOpenSeries() {
	roiManager("Reset");
	mode = getData("Mode");
	
	theName = getImageName();
	Dialog.create(theName+": Pick Series");
	serN = parseInt(getData("Number Of Series"));

	hasLabel = getBool("Has Label");
	hasMask = getBool("Has Mask");
	hasPreview = getBool("Has Overview");
	hasOverview = getBool("Has Macro Image");

		
	if (hasLabel) {
		Dialog.addCheckbox("Label", false);
	}
	if (hasMask) {
		Dialog.addCheckbox("Mask", false);
	}
	 if(hasOverview) {
		Dialog.addCheckbox("Overview", false);
	}
	if (hasPreview) {
		Dialog.addCheckbox("Preview (2X)", false);
	}

	// suggested on May 1st 2017, if lots of series do not check them all. 
	ispreselect=true;
	if (serN > 4) 
		ispreselect = false;
	// Handle basic series
	for(i=1; i<serN+1; i++) {
		ser = getPositionOfSeries(i);
		Ext.setSeries(ser);
		Ext.getSizeX(sizeX);
		Ext.getSizeY(sizeY);
		Ext.getSeriesName(serName);
		Dialog.addCheckbox("Series #"+i+": "+serName+" ("+sizeX+", "+sizeY+")", ispreselect);
	}
	
	Dialog.show();
			
	if (hasLabel) {
		if(Dialog.getCheckbox()) {
			lab = getPositionOfTag("label");
			openLociStack("Label from "+theName, lab+3);
		}
	}
	if (hasMask) {
		if(Dialog.getCheckbox()) {
			maskPos = getPositionOfTag("mask");
			openLociStack("Mask from "+theName, maskPos);
		}
	}

	if (hasOverview) {
		// Check if we want to open the mini-preview
		if(Dialog.getCheckbox()) {
			overviewPos = getPositionOfTag("macro image");
			openLociStack("Overview from "+theName, overviewPos);
		}
	}

	if (hasPreview) {
		if(Dialog.getCheckbox()) {
			previewPos = getPositionOfTag("overview");
			openLociStack("2X Preview from "+theName, previewPos);
		}
	}
	//Now open the thumbnails
	count =0;
	for(i=1; i<=serN; i++) {
		if(Dialog.getCheckbox()) {
			openThumbnail(i);
			count++;
		}
	}
	if (count == 1) {
		name = getTitle();
		openRoiSet(name);
	}
}

// To open the Thumbnail of the selected series
function openThumbnail(series) {
	theName = getImageName();
	run("Bio-Formats Macro Extensions");
	dprint("Opening Thumbnail for series #"+(series));
	id = getID();
	Ext.setId(id);

	serThumb = getPositionOfThumbs(series);
	ser= getPositionOfSeries(series);
	
	Ext.setSeries(serThumb);
	Ext.getSizeX(sizeXT);
	Ext.getSizeY(sizeYT);
	
	 // Let's make the thumbnail the right size
	Ext.setSeries(ser);
	Ext.getSizeX(sizeX);
	Ext.getSizeY(sizeY);
	// Get Camera Value
	
	// Magic: This metadata gives us the Camera

	camera = getCamera(ser);

	// Get Series Name
	Ext.getSeriesName(serName);

	obj = substring(serName,0, indexOf(serName,"x")+1);
	mag = getResamplingRate(series);
	
	openLociSubStack(theName+ " - "+obj+" Series #"+series+" (Thumbnail)", serThumb, 0,0, (sizeXT), (sizeYT));

	run("Set Scale...", "distance=1 known="+(mag)+" pixel=1 unit=unit");
}
/*
 * GetCamera gets the camera and sets the mode for the series
 */
function getCamera(serPos) {
	Ext.setSeries(serPos);
	Ext.getSeriesMetadataValue( "Microscope Device Model #1", camera);
	Ext.getSeriesMetadataValue( "Microscope Device Model #01", camera2);

	// Just silly things to make sure that we get the camera right
	if(camera2 > camera) {
		camera = camera2;
	}
	dprint("Camera is: "+camera);
	
	// Because getSeriesMetadataValue can return a string or a number we need to be careful when comparing
	// We cannot use d2s in case because if it IS a string, there will be an error
	// and we cannot use if(camera == "VC50") directly because if it's a number, then there will be an error
	if (camera == 0) {
		setData("Camera Mode", "Unknown");
	} else {
		if(camera == "VC50") {
			setData("Camera Mode", "Brightfield");
		} else {
			setData("Camera Mode", "Fluorescence");
		}
	}
	return camera;
}

// Loads the current selection made on a thumbnail at 100% Size
function loadCurrentSelection(rescaling) {
	step = 1;
	run("Bio-Formats Macro Extensions");
	id = getID();
	Ext.setId(id);
	name = getTitle();
	vsiName = substring(name,0, lastIndexOf(name,".vsi")+4);
	series = parseInt(substring(name,lastIndexOf(name,"#")+1,lastIndexOf(name,"(")));
	dprint("Loading Selection of Series #"+series);

	//Get the coordinates of the box
	getSelectionBounds(x, y, width, height);
	//And the sizes of the image


	//Get the sampling factor of the thumbnail. This is actually the pixel size of the thumbnail.
	getPixelSize(unit, pixelWidth, pixelHeight);
	mag = parseInt(pixelWidth);
	dprint("Loading Selection of Series #"+series);
	serPos = getPositionOfSeries(series);

	// Magic: This metadata gives us the Camera
	camera = getCamera(serPos);
	
	if ( rescaling%2 == 0) {
		mag = mag/rescaling;
		serPos = serPos + round((log(rescaling)/log(2)));
	}
	dprint("Series Position at: "+serPos);
	
	
	// Get the size of the new series
	Ext.setSeries(serPos);
	Ext.getSizeX(sizeX);
	Ext.getSizeY(sizeY);

	oriX = round( (mag * (x)) * (1));
	oriY = round( (mag * (y)) * (1));
	oriW = ( floor(mag * (width) / step) ) * step;
	oriH = ( floor(mag * (height) / step) ) * step;

	// Resize in case the selection is too big in X
	if (oriX + oriW > sizeX) {
		neworiW = sizeX - oriX;
		print("Size of image exceeds image dimensions, cropping:");
		print("Original Width: "+oriW+" , New Width: "+neworiW);
		oriW = neworiW;
	}
	// Resize in case the selection is too big in Y
	if (oriY + oriH > sizeY) {
		neworiH = sizeY - oriY;
		print("Size of image exceeds image dimensions, cropping:");
		print("Original Height: "+oriH+" , New Height: "+neworiH);
		oriH = neworiH;
	}

	// Append rescaling factor to image name
	 if (rescaling != 1) {
		rescaleText = " Scaled "+rescaling;
	} else {
		rescaleText = "";
	}

	// Make sure that the chosen size is not larger than what imageJ can handle
	// NOTE, maybe this will change sometime...
	if( oriW * oriH > 42000*42000) {
		showMessage("Your selection is too large ("+oriX+"x"+oriY+" > 1.764e9 pixels)\nPlease select a smaller area");
	} else if(matches(name,".*Thumbnail.*")) {
		openLociSubStack(vsiName+ " - Series #"+series+" at ("+oriX+", "+oriY+")"+rescaleText, (serPos), oriX, oriY, oriW , oriH);
		calibrateImage(series, rescaling);
	} else {
		showMessage("Please Select a Thumbnail Image!");
	}

}

/*
 * Sets the calibration of the image based on the metadata
 */
function calibrateImage(series, rescaling) {
	// Get the magnification of this series from the name
	serPos = getPositionOfSeries(series);
	Ext.getPixelsPhysicalSizeX(sizeX);
	dprint("Pixel size for Series "+series+" is "+sizeX);
	
	cal = sizeX * rescaling;
		dprint("Calibrated image is "+cal+" because of rescaling "+rescaling);
	setVoxelSize(cal, cal, cal, "micron");
}

/*
 * openLociStack opens the stack at the given index. This index is the raw index of the image as interpreted by LOCI
 * It starts at 1 and should be used in conjuction with the "getSeriesIndex... series of functions to ensure it works properly
 * Based on an example by Wayne Rasband on the LOCI Website
*/
function openLociStack(name, index) {
	run("Bio-Formats Macro Extensions");
	id = getID();
	Ext.setId(id);

	// Place yourself at the desired series Index (starts at 0);
	Ext.setSeries(index);

	// Get ther dimensions
	Ext.getSizeC(sizeC);
	Ext.getSizeZ(sizeZ);
	Ext.getSizeT(sizeT);
	Ext.getSizeX(sizeX);
	Ext.getSizeY(sizeY);


	Ext.getImageCount(n);
	
	//Start opening the series
	setBatchMode(true);
	for (i=0; i<n; i++) {
		showProgress(i, n);

		Ext.openSubImage("Plane "+i, i, 0,0, sizeX, sizeY);
		//Ext.openImage("Plane "+i, i);

		if (i==0) {
			stack = getImageID;
		}else {
			run("Copy");
			close;
			selectImage(stack);
			run("Add Slice");
			run("Paste");
		}
	}
	//Rename it
	rename(name);
	if (nSlices>1) {
		Stack.setDimensions(sizeC, sizeZ, sizeT);
		if (sizeC>1) {
			if (sizeC==3&&sizeC==nSlices)
				mode = "Composite";
			else
				mode = "Color";

		 	run("Make Composite", "display="+mode);
		}
		setOption("OpenAsHyperStack", true);
	}
	setBatchMode(false);
	run("Select None");

}
/*
 * Same as above, but opens a sub-region of the image
*/
function openLociSubStack(name, index, posX, posY, w, h) {
	fixZ = call("ij.Prefs.get", "vsireader.fix.z.vsi", false);
	run("Bio-Formats Macro Extensions");
	id = getID();
	Ext.setId(id);
	dprint("Opening Series "+index+"-"+name+" ("+w+","+h+")");
	start = getTime();
	Ext.setSeries(index);
	Ext.getSizeC(sizeC);
	Ext.getSizeZ(sizeZ);
	Ext.getSizeT(sizeT);
	Ext.getImageCount(n);
	setBatchMode(true);
	// Correct channels and slices duplicated and messed up
	// Fix is have slices as channels
	if(sizeC == sizeZ && fixZ) {
		sizeZ=1;
		n = sizeC*sizeZ*sizeT;
	}
	for (c=0; c<sizeC; c++) {
		for (z=0; z<sizeZ; z++) {
			for (t=0; t<sizeT; t++) {
				if(fixZ) {
					Ext.getIndex(c, z, t, i);
				} else {
					Ext.getIndex(z, c, t, i);
				}
				showProgress(i, n);
				Ext.openSubImage("Plane"+i, i, posX , posY, w, h);
				if (i==0)
					stack = getImageID;
				else {
					run("Copy");
					close;
					selectImage(stack);
					run("Add Slice");
					run("Paste");
				}
			}
		}
	}
		
	if (nSlices>1) {
		cMode = getData("Camera Mode");
		Stack.setDimensions(sizeC, sizeZ, sizeT);
		if (sizeC>1 || sizeT>1) {
			if ( (sizeC==3&&sizeC==nSlices) || (sizeT==3&&sizeT==nSlices)) // BUG: TIME AS CHANNELS?
				mode = "Composite";
			else
		 		 mode = "Color";
			run("Make Composite", "display="+mode);

		}
		setOption("OpenAsHyperStack", true);
		if (cMode == "Brightfield") {
			for (i=0; i<sizeC; i++) {
				setSlice(i+1);
				setMinAndMax(0, 255);
			}
			run("RGB Color");
		}
	}

	rename(name);
	setBatchMode(false);
	run("Select None");
	end = getTime();
	dprint("Opening done, took "+d2s((end-start)/1000,2)+" s");
	


}
/*
 * Uses a macro to run an analysis on the currently selected image
 */
function measureCurrentImageWithMacro(){
	macroToMeasure = getData("Macro Image Processing and Measurement Path");
	macro_name = substring(macroToMeasure, lastIndexOf(macroToMeasure, "/"), lengthOf(macroToMeasure));
	image_name = getTitle();
	dprint("Running macro +"macro_name+" on image "+image_name);
	start = getTime();
	runMacro(macroToMeasure);
	end = getTime();
	dprint("Macro took "+d2s(((end-start)/1000),1)+"s");
}

/*
 * Creates a regular non-overlapping grid around the user's selection in tiles of selectedSize
 */
function makeGrid(selectedSize) {
	//Make grid based on selection or whole image
	getSelectionBounds(x, y, width, height);

	// Set Color
	color = "red";

	// Calculate how many boxes we will need based on a user-selected size

	// Then we need the calibration, which gives us the REAL pixel size
	getVoxelSize(px,py,pz,unit);

	// To get the size of the ROIs to draw on the image
	sizeOnThumb = selectedSize/px;

	// Thus we will need
	nBoxesX = ceiling(width/sizeOnThumb);
	nBoxesY = ceiling(height/sizeOnThumb);

	run("Remove Overlay");
	//roiManager("Reset"); // Removed to avoid resetting roi manager each time

	for(j=0; j<nBoxesY; j++) {
		for(i=0; i<nBoxesX; i++) {
			makeRectangle(x+i*sizeOnThumb, y+j*sizeOnThumb, sizeOnThumb,sizeOnThumb);

			addRoi(false);
		}
	}

	saveRois("Open");

	run("Select None");
}

/*
 * Helper function, find ceiling value of float
 */
function ceiling(value) {
	tol = 0.4;
	if (value - round(value) > tol) {
		return round(value)+1;
	} else {
		return round(value);
	}
}

/*
 * Counting the number or .zip files that the Roi folder contains, helpf for batch processing
 */
function countRoiFiles() {
	roiDir = getRoiFolder("Open");
	roiFiles = getFileList(roiDir);
	c=0;
	for(i=0; i<roiFiles.length; i++) {
		if (endsWith(roiFiles[i], ".zip"))
			c++;
	}
	return c;
}
/*
 * Convenience function for adding ROIs to the ROI manager, with the right name
 */
function addRoi(isSave) {
	image = getTitle();
	roinum = roiManager("Count");
	Roi.setName(image+" ROI #"+(roinum+1));
	roiManager("Add");
	if (isSave) {saveRois("Open"); }
}

/*
 * Big function to process all the ROIs of all the VSI files
 */
function processRois(mode, isSameFolder, downscaleFactor, isJpeg, RGBMode) {

	
	//Save as RGB or not
	cameraMode = getData("Camera Mode");
	if (cameraMode == "Brightfield") {
		RGB	= true;
	} else {
		RGB = RGBMode;
	}

	nRois = 0;
	nSer = 0;

	// Overwrite the setting to make sure it is opened as an RGB properly!
	//if(isBF) {
	//	setData("Camera Mode", "Brightfield");
	//}

	// First define the folder to use
	if (mode == "Current") {
		dir = getImageFolder();
		nRois = extractRois(dir, downscaleFactor, RGB, isJpeg, isSameFolder);
		nSer = 1;

	} else {
		dir = mode;
		// What we need to know is how many ROI files there are and open them
		// Which means get the file list of the Roi Set
		roiDir = getRoiFolder("Open");
		roiList = getFileList(roiDir);
		nSer = roiList.length;
		if (countRoiFiles() == 0)
			exit("No Rois");

		for (k = 0; k< roiList.length; k++) {
			if (endsWith(roiList[k], ".zip")) {
				roiManager("Reset");
				roiManager("Open", roiDir+roiList[k]);

				n = extractRois(dir, downscaleFactor, RGB, isJpeg, isSameFolder );
				nRois +=n;
				run("Close All");

			}
		}
	}
	showMessage("Extraction Done!\n"+nRois+" Rois in "+nSer+" Series");
}

/*
 * Gets ALL the series as an array, just as a convenience
 */
function getSeriesAsArray() {
	nSer = parseInt(getData("Number Of Series"));
	seriesArray = newArray(nSer);
	for(i=1;i<=nSer;i++) {
		seriesArray[i-1] = i;
	}
	return seriesArray;
}
/*
 * Extracts the ROIs of a given VSI file and returns the number of extracted ROIs
 */
function extractRois(dir, rescale, isRGB, isJpeg, isSameFolder ) {
		
			n = roiManager("count");
			if (n==0)
				exit("No ROIS");

			for (i=0; i<n; i++) {
				roiName = call("ij.plugin.frame.RoiManager.getName", i);
				// Extract the data from the name
				serNum = parseInt(substring(roiName, indexOf(roiName,"#")+1, lastIndexOf(roiName, "(")-1));
				fileName = substring(roiName, 0, indexOf(roiName,".vsi")+4);
				thumbName = substring(roiName, 0, lastIndexOf(roiName, ")")+1);
				obj = substring(roiName, lastIndexOf(roiName, " - ")+3, indexOf(roiName, " Series"));
				roiNum = substring(roiName, indexOf(roiName, "ROI #")+5, lengthOf(roiName));
				dprint(obj);
				id = dir+fileName;

				//parseSeriesData re-reads the .vsi file to make sure all the following functions are working properly.
				if( File.exists(id) ) {
					parseSeriesData(id);
	
	
					serPos=getPositionOfSeries(serNum);
	
					//Open the thumbnail of the series if it's not open
					if (!isOpen(thumbName)) {
						openThumbnail(serNum);
					}
	
					//Now we can start the extraction
					selectWindow(thumbName);
					roiManager("select", i);
					scale = downscaleFactor;
					loadCurrentSelection(scale);
					getVoxelSize(px,py,pz,u);
					getDimensions(nx,ny,nc,nz,nt);
	
					/* Images are loaded. Now what to do
					*1. Save original
					*2. Apply whatever macro (Macro should handle saving)
					*/
	
					// Saving
					sep = File.separator;
					if (isSameFolder) {
						savingPathName = dir+sep+"Extracted"+sep;
					} else {
						savingPathName = id+"_extracted"+sep;
					}
	
					File.makeDirectory(savingPathName);
					name = getTitle();
					if (indexOf(name, "Scaled") != -1) {
						scaling = "_"+replace(substring(name, indexOf(name, "Scaled"), lengthOf(name))," ", "_");
					} else {
						scaling = "";
					}
					if (isRGB || isJpeg) {
						name = getTitle();
						dprint("Composite: "+is("composite") );
						dprint("Bit-depth: "+bitDepth() );
						dprint("C Z T: "+nc+ ", "+nz+", "+nt );
						
						if(bitDepth() != 24 && nc>1) {
							run("Make Composite", "display=Composite");
							dprint("Made Composite");
						}
						
						run("RGB Color");
						setVoxelSize(px,py,pz,u);
						saveFile = savingPathName+fileName+"_"+obj+"_Series_"+serNum+"_ROI_"+roiNum+scaling+"_RGB";
						rgbName = getTitle();
						// Odd behaviour, RGB Conversion sometimes does not generate a new series...
						if (rgbName!=name) {
							close(name);
							selectImage(rgbName);
						}
	
					} else {
						saveFile = savingPathName+fileName+"_"+obj+"_Series_"+serNum+"_ROI_"+roiNum+scaling+"_Ori";
	
					}
	
					// Save proper
					if(isJpeg) {
						saveAs("Jpeg", saveFile+".jpeg");
					} else {
						saveAs("Tiff", saveFile+".tif");
					}
	
					close();
	
				} else {
					 print("File "+id+" was not found. Skipping...");
				}
			}
			return n;
}

/*
 * This function calls a macro that should create selections (to define ROIs automatically)
 * then renames the ROIs to match the requirements of the VSI reader
 */
function runRoiCreationMacro(isWholeImage, isDrawManual, path, allSeriesStatus, seriesSelectedByUserString) {
	////////////////////////////////////////////////////////////////////added by Romain 2014.03.26
	if (allSeriesStatus){
		selectedSeries = "all";
	}else{
		selectedSeries = split(seriesSelectedByUserString, ",");
	}

	macroFile = getData("Macro Path for ROI detection");
	if(macroFile == "" && !isWholeImage && !isDrawManual){
		macroFile = File.openDialog("Macro Path for ROI detection");
		setData("Macro Path for ROI detection", macroFile);
	}


	fileList = getFileList(path);
	for (fileIndex = 0 ; fileIndex < lengthOf(fileList);fileIndex++){
		if(isVSI(fileList[fileIndex])){
			
			id = path+fileList[fileIndex];
			//parseSeriesData re-reads the .vsi file to make sure all the following functions are working properly.
			parseSeriesData(id);

			if (allSeriesStatus) {
				// Get number of series
				selectedSeries = getSeriesAsArray();
			}
			for (index = 0 ; index <selectedSeries.length ;index++ ){
				roiManager("Reset");
				//serPos=getSeriesPos(serNum);
				//Open the thumbnail of the series if it's not open
				openThumbnail(selectedSeries[index]);

				image = getTitle();							// Rename this region of interest
				serNum = parseInt(substring(image, indexOf(image,"#")+1, lastIndexOf(image, "(")-1));//get image infos, series Number

				if(!isDrawManual) {
					if(!isWholeImage) {
						runMacro(macroFile);			// run the macro that create ROIs
						// For the newly created ROI
						

					} else {
						run("Select All");
						addRoi(true);
					}
				} else {
					waitForUser("Draw ROIs and use the \"Add ROI\" button or 't'.\nPress OK when done");
				}

				for (roiNum=0 ; roiNum <roiManager("Count") ; roiNum++){
					roiManager("select",roiNum);
					roiManager("Rename", image+" ROI #"+(roiNum));
				}
				saveRois("Open");
				
				close();
			}
		}
	}
}

</codeLibrary>


<line>
<button>
label=Select a VSI File
icon=icons/load-vsi-48.png
arg=<macro>
// Make sure that a new Parameters window is opened for each series
// This is what needs to be modified. We need to check
// What consequences this has.

winTitle = getWinTitle();
win = "["+winTitle+"]";
if(isOpen(winTitle)) {
	selectWindow(winTitle);
	run("Close");
	run("New... ", "name="+win+" type=Table");
	print(win, "\\Update0:This window contains data the macro needs. Please don't close it");
}


id = File.openDialog("Choose a Tile Scanner File");
parseSeriesData(id);
generateDialogAndOpenSeries();
</macro>


<button>
label=Extract current ROI
icon=icons/loadSelection-48.png
arg=<macro>
// Make a selection and import the series
loadCurrentSelection(1); // 1 here means at full scale
</macro>

<button>
label=Save As Tiff
icon=icons/saveAsTiff-48.png
arg=<macro>
// Just a simple button to call the Save As Tiff menu
run("Tiff...");
</macro>
</line>
<line>
<button>
label=Direct Simple Processing
icon=icons/batchFull-48.png
arg=<macro>
path = getDirectory("Select a folder containing VSI image(s)");


rescaleChoice = getAvailableRates(128);
//Save as RGB or not
cameraMode = getData("Camera Mode");
if (cameraMode == "Brightfield") {
	RGB	= true;
} else {
	RGB = false;
}


Dialog.create("Select series");
Dialog.addMessage("Select series from vsi you want to use");
Dialog.addCheckbox("On all series", true);
Dialog.addString("On serie(s) : ", "");

Dialog.addMessage("ROI Options");
Dialog.addCheckbox("Draw ROIs Manually?", false);

Dialog.addMessage("Saving Options");
Dialog.addCheckbox("Save all images in same folder?", true);
Dialog.addChoice("Downsample by a factor of", rescaleChoice, rescaleChoice[0]);
Dialog.addCheckbox("Save as RGB", false);
Dialog.addCheckbox("Save as JPEG only", false);
Dialog.addMessage("WARNING: Use 'Save as JPEG'\nonly if exporting for display and not for analysis!");
Dialog.show();

allSeriesStatus = Dialog.getCheckbox() ;
seriesSelectedByUserString = Dialog.getString();

isDrawManual = Dialog.getCheckbox() ;

isSameFolder= Dialog.getCheckbox();
downscaleFactor = parseInt(Dialog.getChoice());
RGB = Dialog.getCheckbox();
isJpeg = Dialog.getCheckbox();
	
runRoiCreationMacro(true, isDrawManual, path, allSeriesStatus, seriesSelectedByUserString);
processRois(path, isSameFolder, downscaleFactor, isJpeg, RGB);

</macro>

</line>

<line>
<button>
label=The buttons below offer extra functionality to manage your images.
icon=icons/extraTools-48.png
bgcolor=#efefef
arg=<macro>
internalSettings();
</macro>
</line>
<line>
<button>
label=Downsample Selection
icon=icons/Resize2-48.png
arg=<macro>
//Need width and height of current Image
run("Bio-Formats Macro Extensions");
id = getID();
Ext.setId(id);
name = getTitle();
serInd = parseInt(substring(name,indexOf(name,"#")+1,lengthOf(name)));
serPos = parseInt(substring(name,0,indexOf(name, "-")-1));
// Check if the calibration is there already

if(selectionType != -1) {
	//Get the coordinates of the box
	getSelectionBounds(x, y, width, height);
	mag = getResamplingRate(serInd);
	//And the sizes of the image

	oriX = mag * (x);
	oriY = mag * (y);
	oriW = mag * (width);
	oriH = mag * (height);

	rescaleChoice = getAvailableRates(mag);

	//Rescale factor
	continueRescale = false;

	
	Dialog.create("Downsampling");
	Dialog.addChoice("Downsample by a factor of", rescaleChoice, rescaleChoice[0]);
	Dialog.show();
	fac = parseInt(Dialog.getChoice());
	print("Original image: "+oriW+" x "+oriH+"px\n"+"will now be "+floor(oriW/fac)+" x "+floor(oriH/fac)+" px");
	loadCurrentSelection(fac);
}
</macro>


<button>
label=Place Scalebar
icon=icons/scale1-48.png
arg=<macro>
run("Scale Bar...");
</macro>
<button>
label=Convert to RGB
icon=icons/rgb-48.png
arg=<macro>
setBatchMode(true);
getVoxelSize(width, height, depth, unit);
showStatus("Converting to RGB...");
run("Flatten");
showStatus("Converting to RGB... Done");
// Set Scale
setVoxelSize(width, height, depth, unit);
setBatchMode(false);
</macro>
</line>

<line>
<button>
label=Use buttons below to manage your ROIs
icon=icons/roiManagement-48.png
bgcolor=#efefef
arg=<macro>
</macro>
</line>

<line>
<button>
label=Add ROI to manager
icon=icons/addRoi-48.png
arg=<macro>
// Add to Manager
addRoi(true);
</macro>

<button>
label=Delete Selected ROI
icon=icons/removeRoi-48.png
arg=<macro>
// Reseting the ROI manager
iRoi = roiManager("index");
if (iRoi >= 0) {
	roiManager("Select", iRoi);
	roiManager("Delete");
}

// Rename all ROIs below this one
nR = roiManager("count");
if (iRoi < (nR-1)) {
	for (i=iRoi; i<nR; i++) {
		roiManager("Select", i);
		name = Roi.getName;
		nameNoIdx = substring(name, 0, lastIndexOf(name,"#")+1);
		roiManager("Rename", nameNoIdx+(i+1));
	}
}
saveRois("Open");
</macro>


<button>
label=Clear All ROIs
icon=icons/clearRois-48.png
arg=<macro>
// Reseting the ROI manager
roiManager("reset");
</macro>

</line>
<line>

<button>
label=Load macro to detect ROI of extraction
icon=icons/LoadMacroDetection-48.png
arg=<macro>
macroFile = File.openDialog("Select the macro to run");
setData("Macro Path for ROI detection", macroFile);
</macro>


<button>
label = Run Macro (current image)
icon=icons/runMacro-48.png
arg=<macro>/////////////////////////////////////////////////////////////// added by Romain 2014.03.26
roiNumStartRename = roiManager("Count");				// get the number of existing ROI
macroFile = getData("Macro Path for ROI detection");			// get the macro
if(macroFile == ""){
	macroFile = File.openDialog("Select the macro to run");
	setData("Macro Path for ROI detection", macroFile);
}
image = getTitle();							// Rename this region of interest
serNum = parseInt(substring(image, indexOf(image,"#")+1, lastIndexOf(image, "(")-1));//get image infos, serie Number
getVoxelSize(cal,cal,bof,u);

runMacro(macroFile);							// run the macro that create ROIs

for (roiNum=roiNumStartRename ; roiNum <roiManager("count") ; roiNum++){// for the newly created ROI
	roiManager("select",roiNum);					// select the ROI
	roiManager("Rename", image+" ROI #"+(roiNum));	// rename it using informations
}
</macro>

<button>
label = Run Macro on Folder
icon=icons/runMacroFolder2-48.png
arg=<macro>
path = getDirectory("Select a folder containing VSI image(s)");

Dialog.create("Select series");
Dialog.addMessage("Select series from vsi you want to use");
Dialog.addCheckbox("On all series", true);
Dialog.addString("On serie(s) : ", "");
	
Dialog.show();

allSeriesStatus = Dialog.getCheckbox() ;
seriesSelectedByUserString = Dialog.getString();
	
runRoiCreationMacro(false, false, path, allSeriesStatus, seriesSelectedByUserString);
showMessage("ROI Creation done!");

</macro>
</line>
<line>
<button>
label = Make Grid From ROI
icon=icons/grid-48.png
arg=<macro>
boxSizes = newArray("1024", "2048", "4096");
Dialog.create("Make Grid");
Dialog.addChoice("Image size for XY [px]", boxSizes, boxSizes[0]);
Dialog.show();
boxSize = parseInt(Dialog.getChoice());
makeGrid(boxSize);
// Known BUG, when rescaling, the grid shows some overlap.
</macro>

<button>
label = ROI Create Folder
icon=icons/makeRoisFolder-48.png
arg=<macro>
path = getDirectory("Select a folder containing VSI image(s)");

Dialog.create("Select series");
Dialog.addMessage("Select series from vsi you want to use");
Dialog.addCheckbox("On all series", true);
Dialog.addString("On serie(s) : ", "");

Dialog.addMessage("ROI Options");
Dialog.addCheckbox("Draw ROIs Manually?", false);

Dialog.show();

allSeriesStatus = Dialog.getCheckbox() ;
seriesSelectedByUserString = Dialog.getString();

isDrawManually = Dialog.getCheckbox() ;


	
runRoiCreationMacro(true, isDrawManually, path, allSeriesStatus, seriesSelectedByUserString);
showMessage("ROI Creation done!");
</macro>
</line>

<line>
<button>
label=Extract Current ROIs
icon=icons/process-current-48.png
arg=<macro>
	rescaleChoice = getAvailableRates(128);
	// How to save the selections?
	//Save as RGB or not
	cameraMode = getData("Camera Mode");
	if (cameraMode == "Brightfield") {
		RGB	= true;
	} else {
		RGB = false;
	}

	Dialog.create("Save Images");
	Dialog.addCheckbox("Save all images in same folder?", true);
	Dialog.addChoice("Downsample by a factor of", rescaleChoice, rescaleChoice[0]);
	Dialog.addCheckbox("Save as RGB", RGB);
	Dialog.addCheckbox("Save as JPEG only", false);
	Dialog.addMessage("WARNING: Use 'Save as JPEG'\nonly if exporting for display and not for analysis!");
	Dialog.show();



	isSameFolder= Dialog.getCheckbox();
	downscaleFactor = parseInt(Dialog.getChoice());
	RGB = Dialog.getCheckbox();
	isJpeg = Dialog.getCheckbox();
	
processRois("Current", isSameFolder, downscaleFactor, isJpeg, RGB);
</macro>

<line>
<button>
label=Extract All In Folder
icon=icons/process-folder2-48.png
arg=<macro>
	path = getDirectory("Select a folder containing VSI image(s)");

	
	rescaleChoice = getAvailableRates(128);
	//Save as RGB or not
	cameraMode = getData("Camera Mode");
	if (cameraMode == "Brightfield") {
		RGB	= true;
	} else {
		RGB = false;
	}
	// How to save the selections?
	Dialog.create("Save Images");
	Dialog.addCheckbox("Save all images in same folder?", true);
	Dialog.addChoice("Downsample by a factor of", rescaleChoice, rescaleChoice[0]);
	Dialog.addCheckbox("Save as RGB", RGB);
	Dialog.addCheckbox("Save as JPEG only", false);
	Dialog.addMessage("WARNING: Use 'Save as JPEG'\nonly if exporting for display and not for analysis!");
	Dialog.show();



	isSameFolder= Dialog.getCheckbox();
	downscaleFactor = parseInt(Dialog.getChoice());
	RGB = Dialog.getCheckbox();
	//isBF = Dialog.getCheckbox();
	isJpeg = Dialog.getCheckbox();
	
processRois(path, isSameFolder, downscaleFactor, isJpeg, RGB);

</macro>

</line>