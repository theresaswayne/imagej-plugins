// split_Channels.ijm
// Theresa Swayne, Columbia University, 2017
// Input: folder containing multi-channel composite images
// Output: individual channel images.
// Based on IJ batch processing template
// This macro processes all the images in a folder and any subfolders.


  extension = ".tif";
  dir1 = getDirectory("Choose Source Directory "); // note that on Mac as of 2017 the dialog titles are not visible.
  dir2 = getDirectory("Choose Destination Directory "); 
  //     path = getDirectory("image");
  setBatchMode(true);
  n = 0;
  processFolder(dir1);

  function processFolder(dir1) {
     list = getFileList(dir1);
     for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFolder(dir1+list[i]);
          else if (endsWith(list[i], extension))
             processImage(dir1, list[i]);
      }
  }

  function processImage(dir1, name) {
     open(dir1+name);
     print(n++, name);

     id = getImageID();
     title = getTitle();
     dotIndex = indexOf(title, ".");
     basename = substring(title, 0, dotIndex);
     // add code here to analyze or process the image
     run("Split Channels");
	 while (nImages > 0) { // works on any number of channels
		saveAs ("tiff", dir2+getTitle);				// save every picture
		close();
    	}
  }
 

