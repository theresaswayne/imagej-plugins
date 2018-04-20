run("Blobs (25K)");
setOption("BlackBackground", true);
run("Make Binary");
rename("image1");

run("Duplicate...", "title=image2");
run("Rotate 90 Degrees Left"); // image2 is rotated version of image1

imageCalculator("OR create", "image1","image2"); // image3
selectWindow("Result of image1");
rename("image3");

run("Duplicate...", "title=Union RGB");
run("RGB Color");
rename("Union RGB"); // RGB version of image3


imageCalculator("AND create", "image1","image2"); // image4
selectWindow("Result of image1");
rename("image4");

run("Duplicate...", "title=red-blue");
run("Merge Channels...", "c1=red-blue c3=red-blue"); // creates image titled "RGB"

imageCalculator("Difference create", "image3","image4");  // combining 8-bit binary images
rename("difference of binary images");
 
imageCalculator("Difference create", "Union RGB","RGB");  // combining rgb images 
rename("difference of RGB images");