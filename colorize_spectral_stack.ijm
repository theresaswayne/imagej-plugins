

// WAVELENGTH TO RGB CONVERSION IMAGEJ MACRO
// Colorizes images in Zeiss LSM lambda stack according to wavelength.
// Extracts central wavelength of each image from the title.
//
// g.esteban.fernandez@gmail.com, 11-Sep-2012
// added turning off (black) of transmitted channels 11-Apr-2013
//
// Used colorizing scheme from
http://www.efg2.com/Lab/ScienceAndEngineering/Spectra.htm,
// which is based on http://www.physics.sfasu.edu/astro/color/spectra.html.
//

// TO DO: brightness control for transmitted
//


// set unintelligible lambdas (e.g. transmitted channel) to either black
(off) or white (e.g. for
// overlaying fluorescence onto transmitted image)
nonLambdaChannelsWhite = false;  //true for white, false for black (off)

name = getTitle();

// separate stack into individual images to colorize differently
run("Stack to Images");

for(id = 1.0; id <= nImages; id++){
selectImage(id);
lambdaString = getTitle();  //title is the central wavelength (string)
lambda = parseFloat(lambdaString);  //turn string into float

//380-439 nm colorization
if((lambda >= 380) && (lambda < 440)){
redFactor = -(lambda - 440) / (440 - 380);
greenFactor = 0.0;
blueFactor = 1.0;
}

//440-489 nm colorization
else if((lambda >= 440) && (lambda < 490)){
redFactor = 0.0;
greenFactor = (lambda - 440) / (490 - 440);
blueFactor = 1.0;
}
//490-509 nm colorization
else if((lambda >= 490) && (lambda < 510)){
redFactor = 0.0;
greenFactor = 1.0;
blueFactor = -(lambda - 510) / (510 - 490);
}
//510-579 nm colorization
else if((lambda >= 510) && (lambda < 580)){
redFactor = (lambda - 510) / (580 - 510);
greenFactor = 1.0;
blueFactor = 0.0;
}

//580-644 nm colorization
else if((lambda >= 580) && (lambda < 645)){
redFactor = 1.0;
greenFactor = -(lambda - 645) / (645 - 580);
blueFactor = 0.0;
}

//645-780 nm colorization
else if((lambda >= 645) && (lambda <= 780)){
redFactor = 1.0;
greenFactor = 0.0;
blueFactor = 0.0;
}
//all other lambdas, including outside of VIS range, default to black
else if((lambda < 380) || (lambda > 780)){
redFactor = 0.0;
greenFactor = 0.0;
blueFactor = 0.0;
}
//unintelligible lambdas (e.g. transmitted channel) white if flagged so at
top of macro...
else if(nonLambdaChannelsWhite){
redFactor = 1.0;
greenFactor = 1.0;
blueFactor = 1.0;
}
else{
redFactor = 0.0;
greenFactor = 0.0;
blueFactor = 0.0;
}

// Let the intensity fall off near the vision limits
if((lambda >=380) && (lambda < 420)){
masterFactor = 0.3 + 0.7*(lambda - 380) / (420 - 380);
}
else if((lambda >= 701) && (lambda <=780)){
masterFactor = 0.3 + 0.7*(780 - lambda) / (780 - 700);
}
else if((lambda >= 420) && (lambda <= 700)){
masterFactor = 1.0;
}
else{
masterFactor = 1.0;
}

maxRed = redFactor * masterFactor;
maxGreen = greenFactor * masterFactor;
maxBlue = blueFactor * masterFactor;

//arrays for LUT
redArray = initializeArray(maxRed);  //initializeArray is defined below
greenArray = initializeArray(maxGreen);
blueArray = initializeArray(maxBlue);
setLut(redArray, greenArray, blueArray);

run("RGB Color");
}

run("Images to Stack", "name="+ name +" title=[] use")
;

run("Z Project...", "projection=[Max Intensity]");


///////////////////////////////
function initializeArray(max)
///////////////////////////////
{
array = newArray(256);
for(i = 0; i <= 255; i++){
array[i] = i * max;
}

return array;
}
