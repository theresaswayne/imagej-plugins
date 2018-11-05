#@ int(label="How many divisions (e.g., 2 means quarters)?") n

// This macro chops an image into NxN tiles, where N is the number
// of divisions chosen by the user.

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
 run("Duplicate...", "title=" + tileTitle); 
makeRectangle(offsetX, offsetY, tileWidth, tileHeight); 
 run("Crop"); 
} 
} 
selectImage(id); 
close();
