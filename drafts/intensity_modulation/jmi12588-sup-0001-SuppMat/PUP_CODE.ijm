//Acts on two 8-bit images.  Images should use full dynamic range and be thresholded prior to running this code.

// ---------------------------Initialization--------------------------------

//Checks if images are already open....
openimages = newArray(nImages); 
for (i=0; i < openimages.length; i++) { 
	selectImage(i+1);   // selects (i+1)st image 
	openimages[i] = getTitle(); 
} 

if (openimages.length == 2) {
	checkerrors();
}

if (openimages.length == 0) {
	waitForUser("Welcome to PUP Display...", "Open two, 8-bit images and then press OK...");
	openimages = newArray(nImages); 
	for (i=0; i < openimages.length; i++) { 
		selectImage(i+1);   // selects (i+1)st image 
		openimages[i] = getTitle(); 
	}
	if (openimages.length == 1 || openimages.length >2 ) {
		print("Error: Exactly two images must be open");
		exit();
	}
	checkerrors();
}

if (openimages.length == 1 || openimages.length >2 ) {
	print("Error: Exactly two images must be open");
	exit();
}


// ---------------------------Dialog box--------------------------------
types = newArray("Broad Merge", "Narrow Merge", "Colocalization", "Ratio");

Dialog.create("Create PUP Display...");
Dialog.addChoice("Select Ch1 Image: ", openimages);
Dialog.addChoice("Select Ch2 Image: ", openimages);
Dialog.addChoice("Select display type:", types);
Dialog.show();

ch1img = Dialog.getChoice();
ch2img = Dialog.getChoice();
type = Dialog.getChoice();


//--------------------------Processing----------------------------

setBatchMode(true);

selectWindow(ch1img);
run("8-bit");
selectWindow(ch2img);
run("8-bit");

selectWindow(ch1img);
//Assume ch1 and ch2 are of the same dimensions
width = getWidth();
height = getHeight();

//Creates the indexed image to which hues will be applied through LUT
newImage("PUP", "32-bit", width, height, 1);

//Creates the luminosity image....
newImage("Lum", "32-bit", width, height, 1);

//Faster to build both images within a single loop
for (x=0; x<width; x++) {
	for (y=0; y<height; y++) {

	//Loops through the input images.....

		selectWindow(ch1img);
		ch1p = getPixel(x,y);

		selectWindow(ch2img);
		ch2p = getPixel(x,y);

	//Builds an indexed image of pixel intensity ratios onto which uniform hues are mapped using a LUT

		if (ch1p == 0 && ch2p > 0) {  //Numerator = 0

			coloc = 0;	

			selectWindow("PUP");
			setPixel(x,y, coloc);

		}
	
		if (ch2p == 0 && ch1p > 0) {  //Denominator = 0

			coloc = 254;  //255 is reserved for true black
			
			selectWindow("PUP");
			setPixel(x,y, coloc);

		}

		if (ch1p > 0 && ch2p > 0) {

			//Assigns hue according to angle (ratio)
			//Index values set in this section range from 1 to 253 after rounding
			coloc = 161.5*atan(ch1p/ch2p);  // atan returns radians and is btwn 0.0039 and 1.567.  The scaling factor determines the final range of indexs produced
			coloc = round(coloc);  //Round = closest integer
			selectWindow("PUP");
			setPixel(x,y, coloc);
		}

		if (ch1p == 0 && ch2p == 0) {

			selectWindow("PUP");
			setPixel(x,y, 255);  //gives a true black background

		}
			

	//Builds the luminosity image according to the display type......
	
		//Merge Display Luminosity Mapping...
		if (type == "Broad Merge" || type == "Narrow Merge") {

			if (ch1p > ch2p) {

				dist = ch1p;  //Max dist is 255			

			} else {

				dist = ch2p;  //Max dist is 255	

			}

			//Scales the intensities (0-255) into luminosities (0-100)
			//The luminosity per distance has to be set such than the luminosity never gets too high for the least luminous color
			lumperdist = 0.30;  // =75/255 Luminosity can not exceed 75 or the LAB hues get too far out of RGB gamut
			lumval = lumperdist * dist;
			selectWindow("Lum");
			setPixel(x,y, lumval);
		}
		
		//Colocalization Display Luminosity Mapping...
		if (type == "Colocalization") {

			if (ch1p > ch2p) {

				dist = (1 - (abs(ch2p-ch1p)/ch1p)) - 0.5;  //Dist is a value between -0.5->+0.5 where +0.5 means the point falls on the line y=x  

				func = 1 / (1 + exp(-7*dist));  //Func is the logistic function.  6 is a constant that determines the steepness of the curve
	
			} else {

				dist = (1 - (abs(ch2p-ch1p)/ch2p)) - 0.5;

				func = 1 / (1 + exp(-7*dist));
		
			}

			// Luminosity can never exceed 100 and usually it should be somewhat less than 100 so that the hues don't get too far out of gamut during the iterations below to fix the luminosity...				
			// The constants shift and scale the value of func.
			m = 90;  
			b = 10;
			lumval = m * func + b;
			selectWindow("Lum");
			setPixel(x,y, lumval);

		}

		//Ratio Display Luminosity Mapping...
		if (type == "Ratio") {

			projdist = ch1p;  //Max distance is 255, Ch1 is denominator			

			//The luminosity per distance has to be set such than the luminosity never gets too high for the least luminous color
			lumperdist = 0.390; // =100/255 Ensures luminosity won't get too high in regions of less luminous AB (max luminosity value for red =52)
			lumval = lumperdist * projdist;
			selectWindow("Lum");
			setPixel(x,y, lumval);		

		}

	}  //end for
}  //end for


//Converts the indexed AB image to 8-bit...
selectWindow("PUP");
setMinAndMax(0, 255);  // Covers the full range of possible scaled angular measures.
run("8-bit");

//Applies the LMD AB LUT
//Colors are applied via an LUT because the colors have no simple mathematical relationship in RGB.  It is much easier to generate the colors once and then read then out of a table.
//Opens the LUTs....
lutpath = getDirectory("luts"); 

//Sets the LUT according to the type of display...
if (type == "Broad Merge") 
	run("LUT... ", "open="+lutpath+"PUP_BR.lut");
if (type == "Narrow Merge") 
	run("LUT... ", "open="+lutpath+"PUP_NR.lut");
if (type == "Colocalization") 
	run("LUT... ", "open="+lutpath+"PUP_BR.lut");
if (type == "Ratio") 
	run("LUT... ", "open="+lutpath+"PUP_BR.lut");

run("RGB Color");

//run("Duplicate...", "title=PUP_Hues");  //Uncomment this line to display the Hue image

//Iteratively resets the luminance until the RGB image has the desired luminance profile....
for (z=0; z<5; z++) {

	selectWindow("PUP");

	//REQUIRES color plugin from .... https://sourceforge.net/projects/ij-plugins/files/ij-plugins_toolkit/v.1.9.1/
	//The native ImageJ 'RGB Color' command does not make an approximation when Lab values are out of gamut.
	run("RGB to L*a*b* stack");  // New image generated is renamed "original - L*a*b*"

	//Closes the input 'PUP' image
	selectWindow("PUP");
	close();

	selectWindow("Lum");
	run("Select All");
	run("Copy");

	//Pastes the denom luminosity values back into the luminosity channel of the ratio image....
	selectWindow("PUP - L*a*b*");  //The new image from above
	rename("PUP");  //LAB
	setSlice(1); 
	run("Paste");
	run("Select None");

	//Converts Lab back to RGB...
	//REQUIRES color plugin from .... https://sourceforge.net/projects/ij-plugins/files/ij-plugins_toolkit/v.1.9.1/
	run("L*a*b* stack to RGB");  // The new image is renamed "original - RGB"

	//Closes the input 'PUP' image
	selectWindow("PUP");
	close();

	selectWindow("PUP - RGB");
	rename("PUP");  //RGB

}

selectWindow("Lum");
close();  //Comment out this line to show the Luminosity image


setBatchMode("exit and display");


function checkerrors() {
	
	//Checks bit depth...
	selectWindow(openimages[0]);
	if (bitDepth() != 8) {
		print("Error:  Image is not 8-bit");
		exit();
	}
	selectWindow(openimages[1]);
	if (bitDepth() != 8) {
		print("Error:  Image is not 8-bit");
		exit();
	}
	return;

}


