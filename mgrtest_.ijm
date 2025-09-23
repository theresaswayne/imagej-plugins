//-- Create a test image
newImage("Untitled", "8-bit noise", 200, 200, 1);
//-- Draw a "cell" and "nucleus"
makeRectangle(36, 39, 118, 111);
roiManager("Add");
makeOval(66, 78, 47, 44);
roiManager("Add");

makeRectangle(50, 69, 138, 131);
roiManager("Add");
makeOval(86, 108, 77, 54);
roiManager("Add");


//-- adapted code from OP
roiManager("Select", 0);
roiManager("measure");

roiManager("Select", 1);
roiManager("measure");

roiManager("Select", newArray(0,1));
roiManager("XOR");
roiManager("Add"); //-- add to ROI manager
roiManager("Select", roiManager("count")-1); //-- select the new XOR selection
roiManager("Rename", "cyto");

roiManager("Deselect");
roiManager("Select", newArray(2,3));
roiManager("XOR");
roiManager("Add"); //-- add to ROI manager
roiManager("Select", roiManager("count")-1); //-- select the new XOR selection
roiManager("Rename", "cyto2");