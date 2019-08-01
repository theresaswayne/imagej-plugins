// @File(label = "Output folder:", style = "directory") outputdir
// @Byte(label = "Mito channel", style = "spinner", value = 1) mfbChannel
// @Byte(label = "Brightfield channel", style = "spinner", value = 1) BfChannel

// DO NOT MOVE OR DELETE THE FIRST FEW LINES! They supply essential parameters.
//

///////////////  SETUP  /////////////////////////////////////////////////////
print("\\Clear");
roiManager("reset");
run("Clear Results");
run("Collect Garbage");

cellID = 1;


//----------------------------------------------------------------------------

run("Select None");
Stack.getDimensions(width, height, ch, slices, frames);
run("Set Measurements...", "bounding redirect=None decimal=9");
run("Measure");
px = width / getResult("Width");
var px = px;

bit = bitDepth();
if (mfbChannel > ch) {
	showMessage("There are not enough channels in the dataset. Check the mito channel and re-run the macro.");
	exit;
}
//----------------------------------------------------------------------------

var id = getImageID(); //selectImage(id);
var title = getTitle();  //selectWindow(title);m
var dotIndex = lastIndexOf(title, ".");
if (isNaN(dotIndex) ) { var basename = title; }
else {var basename = substring(title, 0, dotIndex); }

selectImage(id);
Stack.setChannel(mfbChannel); run("Green"); resetMinAndMax();
Stack.setChannel(BfChannel);  run("Grays"); setMinAndMax(1000,5000);

//// create max projection, find background outside cells, save value
selectImage(id);
run("Z Project...", "projection=[Max Intensity]");
Stack.setDisplayMode("color");
Stack.setChannel(mfbChannel);
setAutoThreshold("Default dark");
run("Create Mask");
run("Options...", "iterations=1 count=1 black pad do=Nothing");
run("Close-");
run("Fill Holes");
run("Create Selection");
run("Make Inverse");
roiManager("Add");

run("Select None");
saveAs("tiff", outputdir+File.separator+basename+"_cell mask");
close();

//selectImage(id); Stack.setChannel(mfbChannel);

resetThreshold();
run("Select None");
roiManager("Select", 0);
run("Set Measurements...", "mean redirect=None decimal=9");
run("Measure");
var bkg = getResult("Mean"); print("Background ,"+bkg);
run("Select None");
roiManager("Delete");

/////////////////////////////////////////////////////////////////////////////

//draw line on a relevant cell: click on mother tip, nech and bud tip (doubleclick here to finich the line)

//// 1. create max projection, adjust contrast, display as composite only the relevant channels
//selectImage(id);
//run("Z Project...", "projection=[Max Intensity]");
var channels = ""; 
for(i = 1; i <= ch; i++) {                      // loop through channels, adjust color / contrast / brightness 
		Stack.setChannel(i);
		if (i == mfbChannel ) {
			run("Set Measurements...", "min redirect=None decimal=9");
			run("Measure");
			setMinAndMax(getResult("Min")*1.5, getResult("Max")/3);
			}
		if (i == mfbChannel || i == BfChannel) { channels = channels+"1"; }
		else {  setMinAndMax(pow(2, bit), pow(2, bit));
		        channels = channels+"0";
		     }	
}
Stack.setDisplayMode("composite");
Stack.setActiveChannels(channels);
run("Stack to RGB");

//// 2. draw line along mother and bud
run("Select None");
setTool("line"); run("Line Width...", "line=1");
waitForUser("Draw a line along mother axis. Click OK when done.");
roiManager("Add");
roiManager("Show All");
waitForUser("Draw a line along bud axis. Click OK when done.");
roiManager("Add");

// create and save a merged image with the cell ID, and the two drawn lines
//run("Stack to RGB");
setForegroundColor(255, 255, 0);
run("Line Width...", "line=2");
roiManager("Select", 0);
run("Fill", "slice");
getLine(x1, y1, x2, y2, lineWidth);
drawString(cellID, x1-15, y1+15, "black");
roiManager("Select", 1);
run("Fill", "slice");

saveAs("tiff", outputdir+File.separator+basename+"_cell"+cellID);
close();
close();

//// 4. crop and center mother; calculate background and subtract, rotate, create and measure 3 ROIs
//// crop area with mother
selectImage(id);
roiManager("Show None");
roiManager("Select", 0);
run("Set Measurements...", "redirect=None decimal=9"); run("Measure");
var M_angle = getResult("Angle");
var M_length = getResult("Length");
print("mother length (um), "+ M_length);
getLine(x1, y1, x2, y2, lineWidth);
makeRectangle( (x1+x2)/2-(M_length*px)/2, (y1+y2)/2-(M_length*px)/2, M_length*px, M_length*px);
run("Duplicate...", "duplicate");
var idMother = getImageID();
Stack.setDisplayMode("composite");
Stack.setActiveChannels(channels);

//// rotate
run("Rotate... ", "angle="+M_angle+" grid=1 interpolation=Bilinear");

//// draw roi around mother
run("Z Project...", "projection=[Max Intensity]");
setLocation(500, 500, 600, 600);
Stack.setChannel(mfbChannel); 
run("Set Measurements...", "min redirect=None decimal=9"); run("Measure");
setMinAndMax(bkg*1.5, getResult("Max"));

setTool("freehand");
waitForUser("Draw a outline of mother cell. Press OK when you are done drawing the line");
roiManager("Add");
close();

//// substract extracellular background from the green channel, create sum projection, clear pixels outside mother roi
selectImage(idMother);
run("Select None");
run("Duplicate...", "duplicate channels="+mfbChannel);
run("Subtract...", "value=" + bkg + " stack");
run("Z Project...", "projection=[Sum Slices]");
roiManager("Select", 2);
run("Clear Outside");
setLocation(500, 500, 600, 600);

//// create the rois for tip: center and neck area; measure; add to results
run("Set Measurements...", "area mean standard min integrated limit redirect=None decimal=9");
for (r = 1; r <=3 ; r++) {
	makeRectangle(((M_length*px)/3)*(r-1), 0, (M_length*px)/3, M_length*px);
	roiManager("Add");
	roiManager("Select", newArray(2,3+2*(r-1)));
	roiManager("AND");
	roiManager("Add");
	setThreshold(5300.0000, 1000000000000000000000000000000.0000);
	run("Measure");
}
roiManager("Show None")
roiManager("Select", 4);
run("Flatten");
roiManager("Select", 6);
run("Flatten");
roiManager("Select", 8);
run("Flatten");
saveAs("tiff", outputdir+File.separator+basename+"_cell"+cellID+"_motherROIs");
close();
close();
close();
close();
close();
close();

m = nResults;
Table.deleteRows(0, m-4);
selectWindow("Results");
saveAs("txt", outputdir+File.separator+basename+"_cell"+cellID+"_ResultsMother");

//// 5. crop and center bud; subtract background , rotate, create and measure 2 ROIs
//// crop area with bud
selectImage(id);
roiManager("Show None");
roiManager("Select", 1);
run("Set Measurements...", "redirect=None decimal=9"); run("Measure");
var B_angle = getResult("Angle");
var B_length = getResult("Length");
print("bud length (um), "+ B_length);
getLine(x1, y1, x2, y2, lineWidth);
makeRectangle( (x1+x2)/2-(B_length*px)/2, (y1+y2)/2-(B_length*px)/2, B_length*px, B_length*px);
run("Duplicate...", "duplicate");
var idBud = getImageID();
Stack.setDisplayMode("composite");
Stack.setActiveChannels(channels);

//// rotate
run("Rotate... ", "angle="+B_angle+" grid=1 interpolation=Bilinear");

//// draw roi around mother
run("Z Project...", "projection=[Max Intensity]");
setLocation(500, 500, 600, 600);
Stack.setChannel(mfbChannel); 
run("Set Measurements...", "min redirect=None decimal=9"); run("Measure");
setMinAndMax(bkg*1.5, getResult("Max"));

setTool("freehand");
waitForUser("Draw a outline of mother cell. Press OK when you are done drawing the line");
roiManager("Add");
close();

//// substract extracellular background from the green channel, create sum projection, clear pixels outside mother roi
selectImage(idBud);
run("Select None");
run("Duplicate...", "duplicate channels="+mfbChannel);
run("Subtract...", "value=" + bkg + " stack");
run("Z Project...", "projection=[Sum Slices]");
roiManager("Select", 9);
run("Clear Outside");
setLocation(500, 500, 600, 600);

//// create the rois for tip: center and neck area; measure; add to results
run("Set Measurements...", "area mean standard min integrated limit redirect=None decimal=9");
for (r = 1; r <=2 ; r++) {
	makeRectangle(((B_length*px)/2)*(r-1), 0, (B_length*px)/2, B_length*px);
	roiManager("Add");
	roiManager("Select", newArray(9,3+9*(r-1)));
	roiManager("AND");
	roiManager("Add");
	setThreshold(5300.0000, 1000000000000000000000000000000.0000);
	run("Measure");
}
roiManager("Show None")
roiManager("Select", 11);
run("Flatten");
roiManager("Select", 13);
run("Flatten");

saveAs("tiff", outputdir+File.separator+basename+"_cell"+cellID+"_budROIs");
close();
close();
close();
close();
close();
close();

m = nResults;
Table.deleteRows(0, m-3);
selectWindow("Results");
saveAs("txt", outputdir+File.separator+basename+"_cell"+cellID+"_ResultsBud");


selectWindow("Log");
saveAs("txt", outputdir+File.separator+basename+"_cell"+cellID+"_log");
close("Log");

