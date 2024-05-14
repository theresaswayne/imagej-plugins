#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output


// Merge_channels_mod.ijm
// based on a post in the image.sc forum https://forum.image.sc/t/batch-merging-macro-on-fiji/51727/5
// modified by Theresa Swayne: used IJ Macro template to add script parameters; added scaling
// limitations: not recursive 


// Create the arrays first
red = newArray(0);
green = newArray(0);
blue = newArray(0);

// edit pixel size as needed
pixSize = 0.32;

list = getFileList(input);
list = Array.sort(list);
for (i = 0; i < list.length; i++) {
	if (endsWith(list[i], "Red_001.tif")) {
       red = Array.concat(red, list[i]); 
    } else if (endsWith(list[i], "Green_001.tif")) { 
    	green = Array.concat(green, list[i]); 
    } else if (endsWith(list[i], "Blue_001.tif")) { 
         blue = Array.concat(blue, list[i]); 
    }
}
      
setBatchMode(true);

// A safeguard. If one channel image is missing, we would fail somewhere
if ((blue.length != red.length) || (green.length != red.length) || (blue.length != green.length)) {
   exit("Unequal number of channel images found");
}


// Loop over the images
for (i = 0; i < red.length; i++) {
   redChannel = red[i];
   greenChannel = green[i];
   blueChannel = blue[i];
   open(input+File.separator+redChannel);
   open(input+File.separator+greenChannel);
   open(input+File.separator+blueChannel);
   run("Merge Channels...", "c1=&redChannel c2=&greenChannel c3=&blueChannel create");
   run("RGB Color");
   //Stack.setXUnit("um"); this doesn't work on older IJ
   run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=&pixSize pixel_height=&pixSize voxel_depth=1");
   fileName = substring(blueChannel, 0, lastIndexOf(blueChannel, "_Blue"))+"_RGB.tif";
   saveAs("tiff", output + File.separator+fileName);
   close();
}

setBatchMode(false);
print("Done");




// function to scan folders/subfolders/files to populate channel arrays
function scanFolder(input, red, green, blue) {
	returnLists = newArray(3);
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			scanFolder(input + File.separator + list[i], red, green, blue);
		
	}
}

