 
 /* 
 * Close image or nonimage window
 */
 function closeAll(type) { 
		if (type=="nonimage") {
			liste = getList("window.titles");
			if (liste.length==0)
	     			print("No non-image windows are open");
	 		else {
			     print("Non-image windows:");
				for (i=0; i<liste.length; i++) {
					
					//print(liste[i]);
					selectWindow(liste[i]);
					if (liste[i] != "Common Tools" && !endsWith(liste[i],".ijm"))
						run("Close");
				}
			}
		} 
		if(type=="image"){
			while (nImages!=0) {
		        	selectImage(1);
		        	close();
			}
		}
}

 
 
 /* 
 * Returns the name of the parameters window, as we cannot use global variables,  
 * we just define a function that can act as a global variable 
 */ 
function getWinTitle() { 
   win_title= toolName(); 
   // If something is already open, keep it as-is. 
	if(!isOpen(win_title)) { 
		run("New... ", "name=["+win_title+"] type=Table"); 
		print("["+win_title+"]", "\\Update0:This window contains data "+win_title+" needs."); 
		print("["+win_title+"]", "\\Update1:Please do not close it."); 
	} 
	return win_title; 
} 
     
/* 
 * Based on an example by Wayne Rasband, we use the "getData" and "setData" functions to  
 * read and write data to and from an opened text window. This allows us to save parameters 
 * for an ActionBar in a visible way for the user, instead of relying on IJ.prefs., for example 
 */ 
function getData(key) { 
 
	winTitle = getWinTitle(); 
	win = "["+winTitle+"]"; 
 
	selectWindow(winTitle); 
	lines = split(getInfo(),'\n'); 
	i=0; 
	done=false; 
	value = ""; 
	while (!done && i < lines.length) { 
		// The structure for the data is "key : value", so we use a regex to find the key and place ourselves after the " : " 
		if(matches(lines[i], ".*"+key+".*")) { 
			value = substring(lines[i], indexOf(lines[i]," : ")+3,lengthOf(lines[i])); 
			done = true; 
		 
		} else { 
			i++; 
		}	 
	} 
 
	return value; 
} 
 
/* Like getData, but takes a default argument 
 * and returns it if the key is not found 
*/ 
function getDataD(key, default) { 
	value = getData(key); 
	if (value == "") { 
		return default; 
	} else { 
		return value; 
	} 
} 
 
/*  
 *  Setter for the data on an open text window 
 */ 
function setData(key, value) { 
    	//Open the file and parse the data 
	winTitle = getWinTitle(); 
	win = "["+winTitle+"]"; 
 
	selectWindow(winTitle); 
	lines = split(getInfo(),'\n'); 
	i=0; 
	done=false; 
	if (lines.length > 0) { 
		while (!done && i < lines.length) { 
			if(matches(lines[i], ".*"+key+".*")) { 
				done=true; 
			} else { 
				i++; 
			}		 
		} 
			print(win, "\\Update"+i+":"+key+" : "+value); 
	} else {  
		// The key did not exist 
		print(win, key+" : "+value); 
	} 
} 
 
/* 
 * Setter for boolean values 
 */ 
function setBool(key, bool) { 
	if (bool) { 
		setData(key, "Yes"); 
	} else { 
		setData(key, "No"); 
	} 
} 
 
/* 
 * Getter for boolean values 
 */ 
function getBool(key) { 
	val = getData(key); 
	if (val == "Yes") { 
		val = true; 
	} else if (val == "No") { 
		val=false; 
	} 
 else { 
		val = NaN; 
	} 
	return val; 
} 
/* 
 * Getter for boolean values with defaults 
 */ 
function getBoolD(key, default) { 
 
	val = getBool(key); 
	if(isNaN(val))  
		val = default; 
	return val; 
} 
 
/* 
 * Setter for array, please specifify the separator. 
 */ 
function setDataArray(key,array, separator){ 
	data = ""+array[0]; 
	for (i=1 ; i< lengthOf(array) ;i++){ 
		data = data + separator + array[i]; 
	} 
	setData(key,data); 
} 
 
/* 
 *  Getter for array, please specifify the separator.  
 */ 
function getDataArray(key,separator) { 
    stringFromKey = getData(key); 
    arrayFromString = split(stringFromKey,separator); 
	return arrayFromString; 
} 
/* 
 *  Getter for array with defaults 
 */ 
function getDataArrayD(key,separator, defaultArray) { 
    stringFromKey = getData(key); 
    if(stringFromKey=="") { 
    	arrayFromString = defaultArray; 
    } else { 
    	arrayFromString = split(stringFromKey,separator); 
    } 
	return arrayFromString; 
} 
 
/*   
 *   Creates a dialog using the given names. Types are  
 *     "s" : String 
 *     "c" : Checkbox 
 *     "n" : Number 
 *     "m" : Message 
 *     "l" : List
 *   "thr" : Threshold List
 *   "lut" : LUT List
 *   Needs default values 
 *   All three arguments must be provided as arrays 
 *   The function handles recovery of defaults, creating the dialog 
 *   and saving the values back. 
 */ 
function promptParameters(names, types, defaults) { 
	lists_sel = newArray(lengthOf(names));
	
	for (i=0; i< names.length; i++) { 
		 
		if (types[i] =="c") { 
			boolval = getBoolD(names[i], defaults[i]); 
			defaults[i] = boolval;
		} else if (types[i] =="l") {
			vals = getDataD(names[i], defaults[i]);
			valsA = split(vals,",");
			lists_sel[i] = valsA[0];
		} else {
			val = getDataD(names[i], defaults[i]); 
			defaults[i] = val; 
		}
	} 
	 
	 
	Dialog.create(toolName()+" Settings"); 
	for (i=0; i< names.length; i++) { 
		if(types[i] == "n") { 
			Dialog.addNumber(names[i],defaults[i]); 
		} else if(types[i] == "s") { 
			Dialog.addString(names[i], defaults[i]); 
		} else if(types[i] == "c") { 
			Dialog.addCheckbox(names[i],defaults[i]); 
		} else if(types[i] == "m") { 
			Dialog.addMessage(names[i]); 
		} else if(types[i] == "l") {
			arrA = split(defaults[i],","); 
			Dialog.addChoice(names[i], arrA,lists_sel[i]);
		} else if(types[i] == "thr") { 
			thresholds = getList("threshold.methods"); 
			Dialog.addChoice(names[i], thresholds, defaults[i]); 
		} else if(types[i] == "lut") {
			luts = getList("luts"); 
			Dialog.addChoice(names[i], luts, defaults[i]); 		
		}
	} 
 
	Dialog.show(); 
 
	for (i=0; i< names.length; i++) { 
		if(types[i] == "n") { 
			data = Dialog.getNumber(); 
			setData(names[i], data); 
		} else if(types[i] == "s") { 
			data = Dialog.getString(); 
			setData(names[i], data); 
		} else if(types[i] == "c") {
			data = Dialog.getCheckbox(); 
			setBool(names[i], data);  
		} else if(types[i] == "l") {
			data = Dialog.getChoice(); 
			setData(names[i], data);
		} else if (types[i] == "thr" || types[i] == "lut" ) { 
			data = Dialog.getChoice(); 
			setData(names[i], data); 
		} 
 
		 
	} 
} 
 
 
/* 
 * Functions to read and write from a text file to a parameters window 
 * These are sued by the Save Parameters and Load Parameters Buttons 
 */ 
function loadParameters() { 
	// Get the file 
	file = File.openDialog("Select Parameters File"); 
	 
	//Get the contents 
	filestr = File.openAsString(file); 
	lines = split(filestr, "\n"); 
	 
	//Open the file and parse the data 
	settingName = getWinTitle();
	 
	t = "["+settingName+"]"; 
	 
	// If something is already open, keep it as-is. 
	if(!isOpen(settingName)) { 
		run("New... ", "name="+t+" type=Table"); 
	} 
	selectWindow(settingName); 
	for (i=0; i<lines.length; i++) { 
		print(t, "\\Update"+i+":"+lines[i]); 
	} 
} 
/* 
 * Helper function, not very useful on its own. 
 */ 
function openParamsIfNeeded() { 
	winTitle = getWinTitle(); 
	t = "["+winTitle+"]"; 
	// If something is already open, keep it as-is. 
	if(!isOpen(winTitle)) { 
		run("New... ", "name="+t+" type=Table"); 
		print(t, "\\Update0:This window contains data the macro needs. Please don't close it"); 
	} 
} 
 
/* 
 * Same as above. 
*/ 
function saveParameters() { 
	winName = getWinTitle();
	selectWindow(winName);
	saveAs("Text", ""); 
} 
 
/*  
 *  isImage lets you know whether the current file is an image. 
 */ 
function isImage(filename) { 
	extensions= newArray("lsm", "lei", "lif", "tif", "ics", "bmp", "jpg", "png", "TIF", "tiff", "czi", "zvi", "nd2", "nd", "ims"); 
	for (i=0; i<extensions.length; i++) { 
		if(endsWith(filename, "."+extensions[i])) { 
			return true; 
		} 
	} 
	return false; 
} 
 
 
/* 
 *  getImageFolder returns the current value of the 'Image Folder' key  
 *  in the parameters window. If it's not set, it calls setImageFolder.
 */  
function getImageFolder() { 
	dir = getData("Image Folder"); 
	if(dir=="") { 
		dir = setImageFolder("Image Folder"); 
	} 
	return dir; 
} 
 
/*  
 * Display a getDirectory dialog box and save the value under the  
 * 'Image Folder' key in the parameters window. 
*/ 
function setImageFolder(title) { 
	dir = getDirectory(title); 
	setData("Image Folder", dir); 
	wait(50); 
	setSaveFolder(); 
 
	return dir; 
} 
 
 /* 
  * getSaveFolder returns the current value of the 'Save Folder' key  
  * in the parameters window. If it's not set, it calls setSaveFolder below.
  */ 
function getSaveFolder() { 
	dir = getData("Save Folder"); 
	if(dir=="") { 
		dir = setSaveFolder(); 
	} 
	return dir; 
} 
 
/* 
 * Sets the Save folder as a subfolder of the Image Folder 
 * 'Save Folder' key in the parameters window. 
 */ 
function setSaveFolder() { 
	dir = getImageFolder(); 
	saveFolder = dir+"Processed"+File.separator; 
	setData("Save Folder", saveFolder); 
	File.makeDirectory(saveFolder); 
	return dir; 
} 
 
/* 
 * By using isImage above, this function counts how many images are currently in the selected 
 * image folder (The folder is defined in the parameters window  
 */  
function getNumberImages() { 
	dir = getImageFolder(); 
	file = getFileList(dir); 
	n=0; 
	for (i=0; i<file.length;i++) { 
		if (isImage(file[i])) { 
			n++; 
		} 
	} 
	return n; 
} 
 
/* 
 * By using isImage and getNumberImages, we can now open the nth image from a folder easily 
 * This is useful when running a batch on a folder 
*/ 
function openImage(n) { 
	nFiles=-1; 
	dir = getImageFolder(); 
	file = getFileList(dir); 
	nI = getNumberImages(); 
	for (i=0; i<lengthOf(file); i++) { 
		if(isImage(file[i])) { 
			 nFiles++; 
			 if (nFiles==n) { 
				open(dir+file[i]); 
				//Check if the image has a ROI set and open it 
				openRoiSet(file[i]); 
			} 
		} 
	} 
} 
 
/* 
 * Mainly used for the selectImageDialog function,  
 * this function returns a list of image names from 
 * the current image folder. Again using isImage 
 */ 
function getImagesList() { 
	dir = getImageFolder(); 
	 
	list = getFileList(dir); 
 
	images = newArray(lengthOf(list)); 
	k=0; 
	// Check things in the list 
	for (i=0; i<list.length; i++) { 
		if(isImage(list[i])) { 
			images[k] = list[i]; 
			k++; 
		} 
	} 
	images = Array.trim(images,k); 
	return images; 
	 
} 
 
 
/* 
 * Simple dialog to open images and RoiSets in the current folder. 
 */ 
function selectImageDialog() { 
	//Find out how many images there are 
	dir = getImageFolder(); 
	 
	list = getImagesList(); 
 
	// Also check for associated ROI sets 
	roiDir = getRoiFolder("Open"); 
 
	// Account for the option "None" 
	images = newArray(lengthOf(list)+1); 
	images[0] = "None"; 
	// Build the dialog 
	Dialog.create("Select File To Open"); 
	 
	for (i=0; i<list.length; i++) { 
		 
		images[i+1] =  list[i]; 
		 
		//Check if it has an associated ROI Set and show it. 
		hasRoi = hasRoiSet(list[i]);	 
		if(hasRoi) 
			images[i+1] = images[i+1]+" (Has ROI Set)"; 
			 
	} 
	Dialog.addChoice("Label", images) ; 
 
	// Show it 
	Dialog.show(); 
	file = Dialog.getChoice(); 
 
	// Now openthe images, if the user selected something other than "None" 
	if (!matches(file, "None")) { 
		if(endsWith(file,"(Has ROI Set)") ) { 
			 
			// Remove the "(Has ROI Set)" text to recover the filename 
			fileName = substring(file,0,lengthOf(file)-14); 
			// Open the file and its ROI set 
			open(dir+fileName); 
			openRoiSet(fileName); 
		 
		} else { 
			fileName = file; 
			open(dir+fileName); 
		} 
	} 
} 
 
/*  
 * Simple function to check the presence of a ROI set 
 * The macros here use a function called getRoiDir to get which is the folder that should contain the ROI sets 
 * The ROI set must have EXACTLY the same name as the filename and end in '.zip' 
*/ 
function hasRoiSet(file) { 
	 
	roiDir = getRoiFolder("Open"); 
	file = getFileNameNoExt(file); 
	 
	if (File.exists(roiDir+file+".zip")) { 
		return true; 
	} else { 
		return false; 
	}
} 
 
/* 
 * openRoiSet simply opens the ROIs associated with the image 'file' if it exists 
 */  
function openRoiSet(file) { 
	if (hasRoiSet(file)) { 
		roiDir = getRoiFolder("Open"); 
		//Load ROI. set 
		file = getFileNameNoExt(file); 
		roiManager("reset"); 
		roiManager("Open", roiDir+file+".zip") 
		roiManager("Show All"); 
	} 
} 
 
/* 
 * returns the directory where the ROIs are stored, a subfolder of the image folder. 
 * mode is either "Open" which returns the ROIset Directory from the original images 
 * or "save" which returns the ROIset Directory from the processed images. 
 */ 
function getRoiFolder(mode) { 
	// Feel free to rename it if you like that sort of thing. 
	dirName = "ROI Sets"; 
	if (mode == "Open") { 
		dir = getImageFolder(); 
	} else { 
		dir = getSaveFolder(); 
	} 
	roiDir = dir+dirName+File.separator; 
	File.makeDirectory(dir); 
	File.makeDirectory(roiDir); 
	 
	return roiDir; 
} 
 
 
/* 
 * Saves the ROIs of the current image 
 * mode is either "Open", which saves the ROIs and associates them with the original images 
 * or "Save" which saves the ROIs in the Processed folder and associates them with the processed image. 
 */  
function saveRois(mode) { 
	name = getTitle(); 
	roiDir = getRoiFolder(mode); 
	// If image has an extension, remove it. 
	name = getFileNameNoExt(name); 
	nR = roiManager("Count"); 
 
	// if there are ROIs save them 
	if (nR > 0) { 
		//Save Roi Set 
		File.makeDirectory(roiDir); 
		roiManager("Save", roiDir+name+".zip"); 
		print("ROI Set Saved for image "+name); 
	} 
} 
/* 
 * Allows for easily renaming the last added ROI 
 */ 
function renameLastRoi(name) { 
	nRois = roiManager("Count"); 
	roiManager("Select", nRois-1); 
	roiManager("Rename", name); 
} 
 
/* add on 2014.12.01 
 * Allows for easily renaming ROIs ,  
 * from the firtROI to the lastRoi(included) 
 * using patternName 
 */ 
function renameROI(firstROI,lastRoi,patternName,separator, padding){ 
	counter=1; 
	for (currentROI = firstROI ; currentROI <= lastRoi ;currentROI++){ 
		counterPad = IJ.pad(counter, padding); 
		roiManager("select", currentROI); 
		roiManager("Rename", patternName+separator+counterPad); 
		counter++; 
	} 
} 
 
/* 
 * Returns index of first ROI that matches  
 * the given regular expression 
 */ 
function findRoiWithName(roiName) { 
	nR = roiManager("Count"); 
 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName)) { 
			return i; 
		} 
	} 
	return -1; 
} 
 
/* 
 * Returns an array of indexes of ROIs that match  
 * the given regular expression 
 */ 
function findRoisWithName(roiName) { 
	nR = roiManager("Count"); 
	roiIdx = newArray(nR); 
	k=0; 
	clippedIdx = newArray(0); 
	 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName) ) { 
			roiIdx[k] = i; 
			k++; 
		} 
	} 
	if (k>0) { 
		clippedIdx = Array.trim(roiIdx,k); 
	} 
	 
	return clippedIdx; 
} 
 
 
/* 
 * Saves the current image as a TIFF in the SaveFolder
 */  
function saveCurrentImage() { 
	name = getTitle(); 
	dir = getSaveFolder(); 
	File.makeDirectory(dir); 
	name = getFileNameNoExt(name); 
	saveAs("TIFF", dir+name+".tif"); 
	
} 

/* 
 * Saves the current image as a Specified Format in the SaveFolder
 */  
function saveCurrentImageAs(fileFormat) { 
	name = getTitle(); 
	name = getFileNameNoExt(name); 
	
	dir = getSaveFolder(); 
	File.makeDirectory(dir); 
	
	run("Bio-Formats Exporter", "save=["+dir+name+"."+fileFormat+"]");
} 
 
/* 
 *  Returns the file name witout the extension 
 */  
function getFileNameNoExt(file) { 
		// Get the file name without the extension, regex 
	if (matches(file,".+\\.\\w{3,4}")) { 
		file = substring(file,0,lastIndexOf(file,".")); 
	} 
	return file; 
} 
 
/* 
 * Generic function to calculate the calibration of the image based on the  
 * CCD Pixel size, Magnification, c-mount and binning 
*/ 
function setCalibration() { 
	go = true; 
	 
	// Check if the image is calibrated already 
	getVoxelSize(width, height, depth, unit); 
	if( unit != "pixel") { 
		go = getBoolean("Image already has a calibration. Continue?"); 
	} 
 
	// Prompt for acquisition details to set calibration 
	if (go) { 
   	//Calibration for the image 
   	Dialog.create("Set Pixel Size for your data"); 
	Dialog.addNumber("Magnification", 63, 0,5,"x"); 
	Dialog.addNumber("Binning", 1,0,5,"x"); 
	Dialog.addNumber("CCD Size", 6.45, 2,5,"microns"); 
	Dialog.addNumber("c-Mount Size", 1.0, 1,5,"x");		 
	 
	Dialog.show(); 
 
	// Recover the values for magnification 
	mag = Dialog.getNumber(); 
	bin = Dialog.getNumber(); 
	ccd = Dialog.getNumber(); 
	cm = Dialog.getNumber(); 
 
	// Basic formula for calculating pixel size of a camera 
	pixelSize=(ccd*bin)/(mag*cm); 
 
	// If we decided not to set the calibration but use the already existing one 
	} else { 
		pixelSize=width; 
	} 
 
	// Set the Pixel Size in the Log Window and return it if needed. 
	setData("Pixel Size", pixelSize); 
	return pixelSize; 
	//Does nothing to the image.  
} 
 
/* 
 * This function writes a result to a results table called 'tableName', at : 
 *  - a specified row (specify a number) 
 *  or 
 *  - the current row (nResults-1) 
 *  or  
 *  - the next row (nResults) 
 */ 
function writeResults(tableName, column, row, value) { 
	if(isOpen("Results")) { 
		IJ.renameResults("Results","Temp"); 
	} 
	if(isOpen(tableName)) { 
		// The only way to write to a results table in macro language is to  
		// have the table be called "Results", so we rename it if it already exists 
		IJ.renameResults(tableName,"Results"); 
	}else{ 
		run("Set Measurements...", "  display redirect=None decimal=5"); 
		run("Measure"); 
		IJ.deleteRows(0, 0); 
		updateResults(); 
	}	 
	 
		 
		// Now we can set the data 
		if(row == "Current"){ 
			if( nResults == 0) {
				setResult(column, nResults,value); // Special case, no results table is open
			} else {
				setResult(column, (nResults-1),value); 
			}
		} else if(row == "Next"){ 
			setResult(column, nResults,value); 
		} else { 
			setResult(column, row,value); 
		}	 
		// Call updateResults to have the table appear if it's new
		updateResults(); 
 
		// And rename the results to 'tableName' 
		IJ.renameResults("Results", tableName); 
		 
	if(isOpen("Temp")) { 
		IJ.renameResults("Temp","Results"); 
	} 
		 
} 
 
/* 
 * Prepare a new table or an existing table to receive results. 
 */ 
function prepareTable(tableName) { 
		updateResults(); 
		if(isOpen("Results")) { IJ.renameResults("Results","Temp"); updateResults();} 
		if(isOpen(tableName)) { IJ.renameResults(tableName,"Results"); updateResults();} 
 
} 
 
/* 
 * Once we are done updating the results, close the results table 
 and give it its final name 
 */ 
function closeTable(tableName) { 
		updateResults(); 
		if(isOpen("Results")){ IJ.renameResults("Results",tableName); updateResults();} 
		if(isOpen("Temp")) { IJ.renameResults("Temp","Results"); updateResults();} 
} 
 
/* 
 * Function to draw ROIs using right click button. Give it a category name and it will do the rest. 
 */ 
function DrawRoisL(category) { 
	//defaultROIcolor = Roi.getDefaultColor; 
	if (getVersion>="1.37r") 
        	setOption("DisablePopupMenu", true); 
	 
	// Setup some variables. Basically these numbers 
	// Represent an action that has taken place (it's the action's ID) 
	shift=1; 
	ctrl=2;  
	rightButton=4; 
	alt=8; 
	leftButton=16; 
	insideROI = 32; // requires 1.42i or later 

	// Now we initialize the ROI counts and check if there are already ROIs with this name.  
	nRois = roiManager("count"); 
	roiNum = 0; 
	for (i=0; i<nRois; i++) { 
		name = call("ij.plugin.frame.RoiManager.getName", i); 
		expr = category+" #\\d+"; 
		if (matches(name, expr)) { 
			roiNum++; 
		} 
	} 
	print("\nThere are "+roiNum+" ROIs of category '"+category+"'"); 

	 pad = parseInt(getDataD("Padding", 0));
	 
	// done boolean to stop the loop that checks the mouse's location
	done=false; 
 
	// rightClicked to make sure the function saves the ROI ONCE and not 
	// continuously while "right click" is presed 
	rightClicked = false; 
	print("Started mouse tracking for "+category+", \nRigth-clic to add, \nPress 'ALT' to stop"); 
	while(!done) { 
		// getCursorLoc gives the x,y,z position of the mouse and the flags associated 
		// to see if a particular action has happened, say a left click while shift is  
		// pressed, you do it like this:  
		// if (flags&leftButton!=0 && flags&shift!=0) { blah blah... } 
		 
		getCursorLoc(x,y,z,flags); 
		// print(x,y,z,flags); 
		//If a freehand selection exists and the right button was clicked AND that right click was not pressed before already 
		if (flags&rightButton!=0 && selectionType!=-1 && !rightClicked) { 
			// set rightCLicked to true to stop this condition from writing several times the same ROI 
			rightClicked = true; 
			 
			// get color of the ROI 
			colorROI = getData("Color for "+category); 
			Roi.setStrokeColor(colorROI); 
			strokeWidth	=	getData("Stroke width"); 
			Roi.setStrokeWidth(strokeWidth); 
			// Add the ROI to the manager 
			roiManager("Add"); 
 
			newName = category+" #"+IJ.pad( (roiNum+1), pad); // added by Romain 20160318 !!!!!!!!!!!!!!!!!!!!!!!!!!
			renameLastRoi(newName); 
			roiManager("Sort"); 
			roiNum++; 
			print(roiNum+" saved."); 
			wait(50); 
		} 
 
		// Once we stopped pressing the right mouse button, we can then click it again and add a new ROI 
		if (flags&rightButton==0) { 
			rightClicked = false; 
		} 
		 
		//We stop the loop when the user presses ALT 
		if(isKeyDown("alt")) { 
			done=true; 
			print("ALT Pressed: Done"); 
			setKeyDown("none"); 
		} 
 
		// This wait of 10ms is just to avoid checking the mouse position too often 
		wait(10); 
	} 
	// Here we are out of the drawROI loop, so you can do some post processing already here if you want 
	 
}


/* To store data in multiple tables faster than using the ImageJ Results tables we can write directly a row within a file.
 * The function  initializeResultsFile() initializes such a file, using an array containing the Columns names. 
 * 
 * Th function requires the function(s) :
 * - getSaveFolder();
 * 
 * The required arguments are: 
 * - the fileName (as a string)
 * - the columns names (as a array) 
 * 
 * The function :
 * - deletes the file if it already exists !
 * - makes a string from the array 
 * - appends this string to the file that makes it the 1st row of the file!
 * 
 */
function initializeResultsFile(savingPath, fileName, columnsNamesArray){ // fileName string and columnsNamesArray an array
	// On 02.03.2016, savingPath set as an argument 
	// because getSaveFolder slow down too much the macro!
	// savingPath = getSaveFolder();
	f = savingPath + fileName;
	if ( File.exists(f) ){
		File.delete(f);
	}
	columnSplitter 	= "," ;
	currentRow = columnsNamesArray[0];
	for(columnIndex = 1 ; columnIndex < lengthOf(columnsNamesArray) ; columnIndex++){
		currentRow = currentRow  + columnSplitter + columnsNamesArray[columnIndex] ;
	}
	File.append(currentRow, f);
}

/* To store data in multiple tables faster than using the ImageJ Results tables we can write directly a row within a file.
 * The function appendRowToResultsFile, appends an array to the existing file.
 * 
 * Th function requires the function(s) :
 * - getSaveFolder();
 * 
 * The required arguments are: 
 * - the fileName (as a string)
 * - the results for each columns (as an array)
 * 
 * The function :
 * - makes a string from the array 
 * - appends this string to the file
 * 
 * 
 */
function appendRowToResultsFile(savingPath, fileName, array){ // resultsFileName string and an array of value
	// On 02.03.2016, savingPath set as an argument 
	// because getSaveFolder slow down too much the macro!
	// savingPath = getSaveFolder()
	f = savingPath + fileName;
	columnSplitter 	= "," ;
	currentRow 		= ""+array[0];
	for(columnIndex = 1 ; columnIndex < lengthOf(array) ; columnIndex++){
		currentRow = currentRow + columnSplitter + array[columnIndex] ;
	}
	File.append(currentRow, f);
}

/* To store data in multiple tables faster than using the ImageJ Results tables we can write directly a row within a file.
 * The function  initializeResultsFile() initializes such a file, using an array containing the Columns names. 
 * 
 * Th function requires the function(s) :
 * - getSaveFolder();
 * 
 * The required arguments are: 
 * - the fileName (as a string)
 * - the columns names (as a array) 
 * 
 * The function :
 * - deletes the file if it already exists !
 * - makes a string from the array 
 * - appends this string to the file that makes it the 1st row of the file!
 * 
 */
function initializeTabbedResultsFile(savingPath, fileName, columnsNamesArray){ // fileName string and columnsNamesArray an array
	// On 02.03.2016, savingPath set as an argument 
	// because getSaveFolder slow down too much the macro!
	// savingPath = getSaveFolder();
	f = savingPath + fileName;
	if ( File.exists(f) ){
		File.delete(f);
	}
	columnSplitter 	= "\t" ;
	currentRow = columnsNamesArray[0];
	for(columnIndex = 1 ; columnIndex < lengthOf(columnsNamesArray) ; columnIndex++){
		currentRow = currentRow  + columnSplitter + columnsNamesArray[columnIndex] ;
	}
	File.append(currentRow, f);
}

/* To store data in multiple tables faster than using the ImageJ Results tables we can write directly a row within a file.
 * The function appendRowToResultsFile, appends an array to the existing file.
 * 
 * Th function requires the function(s) :
 * - getSaveFolder();
 * 
 * The required arguments are: 
 * - the fileName (as a string)
 * - the results for each columns (as an array)
 * 
 * The function :
 * - makes a string from the array 
 * - appends this string to the file
 * 
 * 
 */
function appendRowToTabbedResultsFile(savingPath, fileName, array){ // resultsFileName string and an array of value
	// On 02.03.2016, savingPath set as an argument 
	// because getSaveFolder slow down too much the macro!
	// savingPath = getSaveFolder()
	f = savingPath + fileName;
	columnSplitter 	= "\t" ;
	currentRow 		= ""+array[0];
	for(columnIndex = 1 ; columnIndex < lengthOf(array) ; columnIndex++){
		currentRow = currentRow + columnSplitter + array[columnIndex] ;
	}
	File.append(currentRow, f);
}



/* To store data in multiple tables faster than using the ImageJ Results tables we can write directly a row within a file.
 * We need to manipulate arrays.
 * 
 * getValueFromArray can be a usefull function to retrieve a value if you know the :
 * - the columns names 
 * - the key for the value of interest
 * 
 */
function getValueFromArray(key,columnNames,array){
	/*
	 * needs function findIndex(key,columnNames);
	 */
	index = findIndex(key,columnNames);		// find index of the key in columnNames 
	value = array[index];					// set value in array[index]
	return value ;							// return the array
}


/* To store data in multiple tables faster than using the ImageJ Results tables we can write directly a row within a file.
 * We need to manipulate arrays.
 * 
 * setValueFromArray can be a usefull function to store a value in an array if you know the :
 * - the columns names 
 * - the key for the value of interest
 * 
 */
function setValueInArray(key,value,columnNames, array){
	/*
	 * needs function findIndex(key,columnNames);
	 */
	// Array.print(columnNames);
	index = findIndex(key,columnNames);		// find index of the Key, in columnNames 
	if (index < lengthOf(array) ){
		array[index]= value	;				// set value in array[index]
		return array ;
	}else{
		showMessage("index larger than array size");
	}
	// return the array
}

/* To store data in multiple tables faster than using the ImageJ Results tables we can write directly a row within a file.
 * We need to manipulate arrays.
 * 
 * 
 * findIndex can be a usefull function to store/retrieve a value in an array if you know the :
 * - the columns names 
 * - the key for the value of interest
 * 
 */

function findIndex(key,columnNames){
	found = false;
	index = 0;
	// find index of key, in columnNames
	while ( !found && (index < lengthOf(columnNames) )) {
		if(columnNames[index] == key) {
			found = true;
		} else {
			index++;
		}
	}
		
	if(found){
		return index;		
	} else{
		showMessage(key+" not found");
	}
}

/*
 * This function calculates the convex hull of each ROI in the RoiManager and updates them
 */
function convexHullEachRoi() {
	nR = roiManager("Count");
	
	for(i=0; i<nR;i++) {
		roiManager("Select", i);
		run("Convex Hull");
		roiManager("Update");
	}
}

/*
 * returns the index of the element in array that matches the given regular expression
 */
 function findArrayIndex(search, array) {
 	for(i=0; i<array.length;i++) {
 		if (matches(array[i], search)) {
 			return i;
 		}
 	}
 }
 
/*
 * returns all indexes of the element in array that matches the given regular expression
 */
 function findArrayIndexes(search, array) {
 	foundIdx = newArray(0);
 	for(i=0; i<array.length;i++) {
 		if (matches(array[i], search)) {
 			foundIdx = Array.concat(foundIdx,i);
 		}
 	}
 	return foundIdx;
 }


/*
 * return string with hours:min:second
 */
function now(){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	nowValue = ""+IJ.pad(hour,2)+":"+IJ.pad(minute,2)+":"+IJ.pad(second,2);
	return nowValue;
}


