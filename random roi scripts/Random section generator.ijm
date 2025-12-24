#@ int(label="Width of tiles in pixels") tileWidth
#@ int(label="Number of ROIs to generate") RoisN
#@ Double (label="Minimum tile size (as a fraction of desired tile size)", style="slider", value = 0.2, min=0, max=1, stepSize=0.1) minSize
#@ File (label = "Output directory", style = "directory") path
#@ String (label = "Output file name:",choices={"Original name", "ROI number only"}, style="radioButtonHorizontal") outputName
#@ Double (label = "Pixel size in microns", value = 0.35) pixSize

// ImageJ macro for unbiased selection of tiles from a large image
// Tiles are non-overlapping and at least 1 image width apart.
// How to use: 
//     Open an image (recommended pixel size = 0.35 µm) and run the script, entering the parameters as prompted.
// Output: 
//	1) The requested number of randomly selected tiles from the image, with a 10-µm scale bar
//  2) ROI sets showing the selected section area, the full set of tiles, and the random subset

// ---- Setup ----

roiManager("reset");
// get image info
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
// Set image scale (scale will have been lost if the image was exported to jpg)
if (pixSize == 0) { // in case user entered 0 by mistake
	showMessage("Pixel size is not defined. Assuming 0.35 µm");
	pixPerUm = 2.8571;
}
else {
	pixPerUm = 1/pixSize;
}
run("Set Scale...", "distance=&pixSize known=1 unit=µm");


// ---- Run the functions ----

setBatchMode(true); // increases speed and reliability
makeGrid(tileWidth, minSize, basename, outputName, path);
selectAndSave(id, basename, RoisN, tileWidth, path); 
print("Saving to",path);
showMessage("Finished");
setBatchMode(false);

// ---- Functions ----

// function to help calculate how many tiles to make in a row or column
function ceiling(value, tolerance) {
	// find the ceiling (smallest integer larger than the value), 
	// EXCEPT if this would result in a tile smaller than the minimum size set by the user
	if (value - round(value) > tolerance) {
		return round(value)+1;
	} else {
		return round(value);
	}
}

// function to add ROIs to the ROI manager, with the correct name
function addRoi(name) {
	image = getTitle();
	roinum = roiManager("Count");
	// name ROIs either anonymously or with the original image name
	if (name == "ROI number only") {
		Roi.setName("ROI #"+(roinum+1));
		}
	else if (name == "Original name") {
		Roi.setName(image+" ROI #"+(roinum+1));
		}
	roiManager("Add");
}

// function to create and save a regular non-overlapping grid of ROIs of the selected size
// covering the bounding box of the user's selection
function makeGrid(selectedWidth, minimumSize, imageName, saveName, savePath) {

	run("Select None");
	setTool("polygon");
	waitForUser("Outline the section and click OK");
	
	// if there is no selection, use the whole image
	type = selectionType();
   	if (type==-1) {
		run("Select All");
   	}
	
	// record the tissue selection
	Roi.setName("Selected Area");
	roiManager("Add"); // this is ROI index 0
	

	// calculate how many boxes we will need based on the user-selected size 
	// regions at right and bottom edges may not not be included, based on minimum tile size set by user
	getSelectionBounds(x, y, width, height);
	nBoxesX = ceiling(width/selectedWidth, minimumSize);
	nBoxesY = ceiling(width/selectedWidth, minimumSize);
	
	// remove any old overlays
	run("Remove Overlay");

	// create the grid of ROIs
	for(j=0; j< nBoxesY; j++) {
		for(i=0; i< nBoxesX; i++) {
			makeRectangle(x+i*selectedWidth, y+j*selectedWidth, selectedWidth,selectedWidth);
			addRoi(saveName);
		}
	}

	// go through the grid and remove tiles whose centers are not in the selected tissue area
	numRois = roiManager("count");
	outsideTiles = newArray;
	outsideCount = 0;
	for (index = 1; index < numRois; index++) {
		roiManager("Select", index);
		Roi.getBounds(x, y, width, height);
		// find the center of the tile roi
		centerX = x + (width/2);
		centerY = y + (height/2);
		// activate the tissue selection
		roiManager("Select", 0); 
		if (selectionContains(centerX, centerY) == false) { // if tile center is outside the tissue
			outsideTiles = Array.concat(outsideTiles,index);
			outsideCount++;
		}
	}
	// delete any unneeded ROIs and rename the rest
	if (outsideCount > 0) {
		roiManager("select", outsideTiles);
		roiManager("delete");
		roiManager("Deselect");
	
		numRois = roiManager("count");
		for (index = 1; index < numRois; index++) {
			roiManager("Deselect");
			roiManager("Select", index);
			// name ROIs either anonymously or with the original image name
			if (saveName == "ROI number only") {
				roiManager("rename", "ROI #"+(index));
			}
			else if (saveName == "Original name") {
				roiManager("rename",imageName+" ROI #"+(index));
			}
		}
	}
	
	// save the ROIs for tissue area and the tiles inside it
	run("Select None");
	roiManager("Deselect");
	roiManager("save", savePath+File.separator+imageName+"_AllROIs.zip");
}


// function to select random ROIs with at least 1 tile width between them
function selectAndSave(id, basename, ROIsWanted, fieldWidth, savePath) {

	// make sure nothing is selected to begin with
	roiManager("Deselect");
	run("Select None");
	
	numTiles = roiManager("Count")-1; // -1 because one of the ROIs is the tissue area
	print("We have",numTiles,"ROIs and we want", ROIsWanted, "at least",tileWidth,"apart");
	// The number of ROIs should be small compared to the number of tiles.
	// It may be difficult or impossible to achieve the desired distance when picking 
	// > 1/8 the number of tiles in a rectangular grid
	
	if (ROIsWanted >= (0.125 * numTiles)) {
		showMessage("Not enough ROIs to select randomly with sufficient distance. Saving 1/8 of the tiles");
		ROIsWanted = floor(0.125 * numTiles);
		digits = 1 + Math.ceil((log(ROIsWanted)/log(10)));
		indicesAll = Array.getSequence(numTiles);
		indices = Array.resample(indicesAll,ROIsWanted);
		
		for (i = 0; i < indices.length; i++) {
			roiNumPad = IJ.pad(indices[i], digits);
			// set output image name
			if (outputName == "ROI number only") {
				cropName = "tile_"+roiNumPad;
			}
			else if (outputName == "Original name") {
				cropName = basename+"_tile_"+roiNumPad;
			}

			// create the image tile
			selectImage(id);
			roiManager("Deselect");
			roiManager("Select", indices[i]);
			run("Duplicate...", "title=&cropName duplicate");
			
			// add a 10 µm scale bar and save
			selectWindow(cropName);
			run("Scale Bar...", "width=10 height=1 thickness=5 font=14 color=Black background=None location=[Lower Right] horizontal hide");
			saveAs("tiff", savePath+File.separator+getTitle);
			close();
		}

	}
	else {
		
		// array to hold the accepted tiles
		indices = newArray;
		// calculate how much to pad the ROI numbers
		digits = 1 + Math.ceil((log(ROIsWanted)/log(10)));
		
		// select random tiles
		
		count = 0;
		pass = true;
		
		// select the 1st ROI
		index = floor(random * numTiles) + 1; // select from ROIs # 1 and up (ROI #0 is the tissue selection)
		print("First selected ROI",index);
		indices = Array.concat(indices, index);
		// find the center of the randomly selected roi
		roiManager("Deselect");
		roiManager("Select", index);
		Roi.getBounds(x, y, width, height);
		centerX = x + (width/2);
		centerY = y + (height/2);
		// create arrays to hold the accepted coordinates
		centersX = newArray;
		centersX = Array.concat(centersX, centerX);
		centersY = newArray;
		centersY = Array.concat(centersY,centerY);
		print("First center is",centersX[0],centersY[0]);
		roiNumPad = IJ.pad(count+1, digits);
		// set output image name
		if (outputName == "ROI number only") {
			cropName = "tile_"+roiNumPad;
		}
		else if (outputName == "Original name") {
			cropName = basename+"_tile_"+roiNumPad;
		}

		// create the image tile
		selectImage(id);
		roiManager("Deselect");
		roiManager("Select", index);
		run("Duplicate...", "title=&cropName duplicate");
		
		// add a 10 µm scale bar and save
		selectWindow(cropName);
		run("Scale Bar...", "width=10 height=1 thickness=5 font=14 color=Black background=None location=[Lower Right] horizontal hide");
		saveAs("tiff", savePath+File.separator+getTitle);
		close();
		
		count++;
		emergencyBrake = 0; // stops execution if it gets stuck in a long or infinite loop 
		while(count < ROIsWanted && emergencyBrake < 100) // loop until desired # ROIs is generated
			{ 
			index = floor(random * numTiles) + 1; // select from ROIs # 1 and up (ROI #0 is the tissue selection)
			print("Selected ROI",index);
			// find the center of the randomly selected roi
			roiManager("Deselect");
			roiManager("Select", index);
			Roi.getBounds(x, y, width, height);
			centerX = x + (width/2);
			centerY = y + (height/2);
			print("Center of ROI",index,"is",centerX,",",centerY);			
			// check if the center of this roi is at least 1 field away from the others
			for (i=0; i < count; i++) {
				//The euclidean distance between centers should be > 2w where w is the field width.
				dist = sqrt(pow(centerX-centersX[i],2) + pow(centerY-centersY[i],2));
				print("Distance between ROI",index,"and selected ROI",indices[i],"is",dist);
				if (dist <= 2*fieldWidth) { // too close
					pass = false;
					print("too close");
					break; // exit the for loop
				}
				else {
					print("far enough");
					pass = true;
					continue; // continue from top of for loop and check the next position
				}
			} // now we've checked all the existing ROIs
			if (pass == false) {
				continue; // go to top of while loop without incrementing; select another random tile
			}
			else { // must have passed
				//pass = true;
				indices = Array.concat(indices,index);
				centersX = Array.concat(centersX,centerX);
				centersY= Array.concat(centersY,centerY);
				print("ROI", index,"has been accepted");
				roiNumPad = IJ.pad(count+1, digits);
				// set output image name
				if (outputName == "ROI number only") {
					cropName = "tile_"+roiNumPad;
				}
				else if (outputName == "Original name") {
					cropName = basename+"_tile_"+roiNumPad;
				}

				// create the image tile
				selectImage(id);
				roiManager("Deselect");
				roiManager("Select", index);
				run("Duplicate...", "title=&cropName duplicate");
				
				// add a 10 µm scale bar and save
				selectWindow(cropName);
				run("Scale Bar...", "width=10 height=1 thickness=5 font=14 color=Black background=None location=[Lower Right] horizontal hide");
				saveAs("tiff", savePath+File.separator+getTitle);
				close();
				
				count++;
			}	
			emergencyBrake++;
			if (emergencyBrake == 100) {
				print("Exiting after failing to get enough tiles.");
			}
		}
	}
	// save the randomly selected ROIs
	run("Select None");
	roiManager("Deselect");
	// add back the tissue area
	indices = Array.concat(indices,0);
	roiManager("select", indices);
	roiManager("save selected", savePath+File.separator+basename+"_SelectedROIs.zip");
}
