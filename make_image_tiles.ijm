// macro to divide image into a specified number of tiles
// based on IJ forum thread http://forum.imagej.net/t/macro-for-automatic-saving-and-filename-designation/1966 

n = getNumber("How many divisions (e.g., 2 means quarters)?", 2);
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
path = getDirectory("image");
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
    tileTitle = basename + "[" + x + "," + y + "].tif";
    // using the ampersand allows spaces in the tileTitle to be handled correctly 
    run("Duplicate...", "title=&tileTitle");
    makeRectangle(offsetX, offsetY, tileWidth, tileHeight);
    run("Crop");
    selectWindow(tileTitle);
    saveAs("tiff",path+tileTitle);
    close();
    }
  }
selectImage(id);
close();