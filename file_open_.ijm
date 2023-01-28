
// test methods of opening files to adapt to IJ-native and non-native formats
 
showMessage("On the next dialog please open the input file");
rawPath = File.openDialog("Select the raw data file corresponding to the ratio image");
open(rawPath); // open the file