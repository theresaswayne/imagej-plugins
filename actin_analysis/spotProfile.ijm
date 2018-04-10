// @File(label = "Input file") input
// @String(label = "Tolerance",description="Tolerance for Find Peaks", value = "2000") tol
// @String(label = "Total Line Length (pixels)", value = "12") lineSize
// @String(label = "GoF cutoff",description="R-squared cutoff for gaussian fit", value = "0.85", persist = false) gof
// @String(label = "Estimated FWHM (calibrated units)",description="If the calculated FWHM is greater than 10x this value it is considered an outlier and excluded. Set to zero to ignore.", value = "0.1") estSize
// @Boolean(label = "Mark excluded?",description="Adds an overlay to the image to indicate excluded points and outliers", value = false) markSpots
// @Boolean(label = "Show range?",description="Adds an overlay to the image to indicate points within a specific range of sizes.") markRange
// @Boolean(label = "Open the spot navigator?", value = false, persist=false) spotNav
// @Boolean(label = "Verbose", description="Prints a report to the log window",value = false) verbose

/*
 *		MEASURE FWHM OF SPOTS
 * 
 * 		Script to iterate through the results of a 'Find Peaks', plot a profile and fit a gaussian to calculate the FWHM of each spot.
 * 		
 * 		Includes a cut off for quality of fit and optional outlier exclusion.
 * 		
 * 		
 * 												
 * 												Dave Mason [dnmason@liv.ac.uk] August 2017
 * 												Centre for Cell Imaging [http://cci.liv.ac.uk]
 * 												University of Liverpool
 * 												
 *										 		Provided under a CCBY 4.0 Licence
 *										 		[https://creativecommons.org/licenses/by/4.0/]
 *
 */

//-- Initialise settings
setBatchMode(true);
lineSize=floor(lineSize/2);
count=0; //-- count value for included spots
close("*");


//-- If requested, get spot range
if (markRange==true){
	 spotMin=getNumber("Lower bound on spot size in um\n(for display only)", 0);
	 spotMax=getNumber("Upper bound on spot size in um\n(for display only)", 0.05);
}else{
	//-- allocate values here so the variables exist later
	spotMin=0;
	spotMax=0;
}

//-- CLear and close results table if open
if (isOpen("FWHM")){
selectWindow("FWHM");
run("Close");
}

open(input);
title=getTitle;

//-- Get dimensions from last opened image
getPixelSize(unit, pixelWidth, pixelHeight);
getDimensions(width, height, channels, slices, frames);

//-- Record processing to the log
if (verbose==true){
print("-------------------------------------------------");
print("Processing: "+title);
print("Dimensions: "+width+"x"+height+" ("+pixelWidth+" "+unit+" / pixel)");
print("-------------------------------------------------");
print("Options");
print("input: "+input);
print("Tolerance: "+tol);
print("Line Size: "+lineSize*2);
print("R^2: "+gof);
print("Estimated size: "+estSize);
print("Marking Spots?: "+markSpots);
print("-------------------------------------------------");
}


run("Find Maxima...", "noise="+tol+" output=[Point Selection]");
getSelectionCoordinates(x, y);

//-- Make an array to store matching FWHM sizes
arrFWHM=newArray(x.length);

//Array.show(x,y); //-- used for debugging problems
run("Select None");
if (verbose==true){
print("Found "+x.length+" points");
print("-------------------------------------------------");
}

//-- Loop through each of the points
for (j=0;j<x.length;j++){

//-- Try a horzontal line first
makeLine(x[j]-lineSize,y[j],x[j]+lineSize,y[j]);
Y=getProfile();
len=Y.length;
X=newArray(len);

//-- Populate X in calibrated units
for(i=0;i<len;i++){
	X[i]=i*pixelHeight;
}

Fit.doFit("Gaussian", X, Y);
r2=Fit.rSquared;

//-- Check for goodness of fit. If poor, try a vertical line
if (r2<gof){
//	if (verbose==true){print("Poor Fit ("+r2+") at coordinates: "+d2s(x[j],0)+"_"+d2s(y[j],0)+" trying vertical line");}
//-- vertical line
makeLine(x[j],y[j]-lineSize,x[j],y[j]+lineSize);
Y=getProfile();
len=Y.length;
X=newArray(len);

//-- Populate X in calibrated units (shouldn't need to do this again but keep in case diff pixel dimensions)
for(i=0;i<len;i++){
	X[i]=i*pixelHeight;
}
Fit.doFit("Gaussian", X, Y);
r2=Fit.rSquared;
if(r2>gof){
if (verbose==true){print("Coordinates: "+d2s(x[j],0)+"_"+d2s(y[j],0)+" found VERTICAL fit ("+r2+")");}
}
}else{
if (verbose==true){print("Coordinates: "+d2s(x[j],0)+"_"+d2s(y[j],0)+" found HORIZONTAL fit ("+r2+")");}
}

//-- Check r^2 again, and only include if fit is good
//-- NOTE: does not catch erroneous but well fitting points!
if(r2>gof){
sigma=Fit.p(3);
FWHM=abs(2*sqrt(2*log(2))*sigma);
name=""+d2s(x[j],0)+"_"+d2s(y[j],0);
count++;
//-- If estsize is set to zero, then include everything
if (estSize==0){estSize=99999999;}
//-- Catch issues with good fit but erroneous data (usally caused by lineSize being too small)
if (FWHM<10*estSize){
	//-- Record the spot both to table and array
	myTable(count,x[j],y[j],FWHM,unit);
	arrFWHM[j]=FWHM;
	//-- optionally demark the spot if it's within range and user wants to show spots (markRange)
	if (markRange==true && FWHM>=spotMin && FWHM<=spotMax){
	makeRectangle(x[j]-lineSize,y[j]-lineSize, lineSize*2, lineSize*2);
	Overlay.addSelection("magenta");
	}
	
}else{
if (verbose==true){print("Coordinates: "+d2s(x[j],0)+"_"+d2s(y[j],0)+" Excluded as OUTLIER (yellow) FWHM="+FWHM);}
if (markSpots==true){
makeRectangle(x[j]-lineSize,y[j]-lineSize, lineSize*2, lineSize*2);
Overlay.addSelection("yellow");	
}
}

}else{
//-- Optionally mark the spots as an overlay if they're excluded from both checks	
if (verbose==true){print("Coordinates: "+d2s(x[j],0)+"_"+d2s(y[j],0)+" Excluded as NO FIT (red)");}
if (markSpots==true){
makeRectangle(x[j]-lineSize,y[j]-lineSize, lineSize*2, lineSize*2);
Overlay.addSelection("red");
}

}

selectImage(title);

}
run("Select None");
setBatchMode(false);

//-- Select results table if open (prevents error if no spots are found
if (isOpen("FWHM")){
selectWindow("FWHM");
}

if (verbose==true){
print("-------------------------------------------------");
print("Included points: ["+getValue("results.count")+" of "+x.length+"] ~ "+d2s(getValue("results.count")*100/x.length,1)+"%");
print("-------------------------------------------------");
}

if (spotNav==true){
//--------------------------------------------------------------------------------------
//-- SPOT NAVIGATOR
//--------------------------------------------------------------------------------------

//-- Pull the values back out of the results table
//-- Find the last value

outX=newArray(parseInt(count));
outY=newArray(parseInt(count));
outFWHM=newArray(parseInt(count));


for (i=0;i<count;i++){
	outX[i]=getResult("xPos",i);
	outY[i]=getResult("yPos",i);
	outFWHM[i]=getResult("FWHM",i);
	}

//-- now make the label then dialog
padding=5;
spotsize=lineSize*2.5;
labels=newArray(outX.length);
for (i=0;i<outX.length;i++){
	labels[i]=""+IJ.pad(i+1,padding)+": X="+outX[i]+" Y="+outY[i]+" Size="+outFWHM[i];
}
default=labels[0];

//-- Make an infinite loop to update spots until user hits 'close'
do while(true) {
Dialog.create("Spot Navigator");
Dialog.addChoice("Select Spot by Coordinates", labels,default);
Dialog.addMessage("Hit Cancel to exit Spot Navigator");
Dialog.show()
id=parseInt(substring(Dialog.getChoice(),0,padding))-1;

//print(id);
default=labels[id];
//print("Default= "+labels[id]);

makeOval(x[id]-spotsize/2, y[id]-spotsize/2, spotsize, spotsize);
run("To Selection");
run("Out [-]");run("Out [-]");run("Out [-]");
run("Remove Overlay");
Overlay.addSelection("magenta");
run("Select None");
if (verbose==true){print("Inspecting: "+labels[id]);}
}

}//-- end spotNav loop


//--------------------------------------------------------------------------------------
//-- FUNCTIONS
//--------------------------------------------------------------------------------------
function myTable(n,a1,a2,b,c){
	title1="FWHM";
	title2="["+title1+"]";
	if (isOpen(title1)){
   		print(title2, n+"\t"+a1+"\t"+a2+"\t"+b+"\t"+c);
	}
	else{
   		run("Table...", "name="+title2+" width=300 height=600");
   		print(title2, "\\Headings:num\txPos\tyPos\tFWHM\tUnit");
   		print(title2, n+"\t"+a1+"\t"+a2+"\t"+b+"\t"+c);
	}
}
