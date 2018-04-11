
// split_image_.ijm
// by Curtis Rueden, IJ mailing list, 14 Jan 2013
// modified by TCS

run("Fluorescent Cells (400K)");
n = getNumber("How many divisions (e.g., 2 means quarters)?", 2); 
id = getImageID(); 
title = getTitle(); 
getLocationAndSize(locX, locY, sizeW, sizeH); 
width = getWidth(); 
height = getHeight(); 
tileWidth = width / n; 
tileHeight = height / n; 
for (y = 0; y < n; y++) { 
offsetY = y * height / n; 
 for (x = 0; x < n; x++) { 
offsetX = x * width / n; 
selectImage(id); 
 call("ij.gui.ImageWindow.setNextLocation", locX + offsetX, locY + offsetY); 
tileTitle = title + " [" + x + "," + y + "]"; 
 run("Duplicate...", "title=" + tileTitle +" duplicate"); 
makeRectangle(offsetX, offsetY, tileWidth, tileHeight); 
 run("Crop"); 
} 
} 
selectImage(id); 
close(); 
