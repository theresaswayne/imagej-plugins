//@File(label = "Choose input folder:", style = "directory") myDir
//@Integer(label = "Channel1 min", value = 0) ch1min
//@String(label = "Channel1 max", value = "1000") ch1max
//@Integer(label = "Channel2 min", value = 0) ch2min
//@Integer(label = "Channel2 max", value = 4095) ch2max
//@Integer(label = "Channel3 min", value = 0) ch3min
//@Integer(label = "Channel3 max", value = 4095) ch3max
//@Integer(label = "Channel4 min", value = 0) ch4min
//@Integer(label = "Channel4 max", value = 4095) ch4max

// DO NOT MOVE OR DELETE THE FIRST FEW LINES! They supply essential parameters.

// ...................................
// Emilia Laura Munteanu // 10-30-2017
// ...................................
// This macro sets LUTs for each channel, creates RGB overlay and color image for eachchannel

// Used for 2,3 or 4 channel images


// ...... SETUP the LUTS ........

MINintens  = newArray(ch1min, ch2min, ch3min, ch4min);
MAXintens  = newArray(ch1max, ch2max, ch3max, ch4max);

//

dirIn = myDir + File.separator;
list = getFileList(dirIn); 
dirOut = dirIn + File.separator + "Output Tiffs" + File.separator;
File.makeDirectory(dirOut);

//

setBatchMode(true);

for (i=0; i<list.length; i++)
        { 
        	 if (File.isDirectory(dirIn+list[i])){}
        else{ 

        	path = dirIn+list[i];
        	print(path);
        	open(path);
        	//setBatchMode(true);
        	title = File.nameWithoutExtension;
        	
        	Stack.getDimensions(width, height, ch, s, frames);
        	print(ch+" channels");

if (ch > MINintens.length) {
print ("Error: too many channles. This macro can process 4 (or less) channel images");
}
else{
	for (j = 1; j < ch+1; j++) {
		Stack.setChannel(j);
		setMinAndMax(MINintens[j-1], MAXintens[j-1]);
		run("Duplicate...", " ");
		run("RGB Color");
		saveAs("Tiff", dirOut+title+"ch"+j+".tif");
		close();
	}
}
			//selectWindow(list[i]);
			Stack.setDisplayMode("composite");
			run("Stack to RGB");
			saveAs("Tiff", dirOut+title+"overlay.tif");
			close();

			close();
	
			//setBatchMode(false);
			
        }       	
}

