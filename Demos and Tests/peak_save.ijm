//@File(label = "Output directory", style = "directory") outputDir
//@File(label = "Image to analyze", style = "file") inputFile

print("Starting");
open(inputFile);

// from Abi
l = getWidth();
//---- VARIABLE: Depends how many lines you want -----//
k = 6;
// ---------------------------------------------------//
h = getHeight()/k;

for (i = 0; i < k; i++){
	plotNum = i+1;
	selectWindow("binary.tif");
	makeLine(0,h*i+h/2,l,h*i+h/2,1);
	// you can start measuring from any altitude you want by modifying the "+h/2" part. 
	//If you want to start at altitude of "0", simply delete the "+" portion
	run("Plot Profile");
	run("Find Peaks", "min._peak_amplitude=254.99 min._peak_distance=0 min._value=[] max._value=[] list");
	IJ.renameResults("Plot Values","Results");

	// from H Gluender
	myArray_1 = newArray(nResults);
	myArray_2 = newArray(nResults);
	// loop the table rows
	for ( j=0; j<nResults; j++ ) { 
		myArray_1[j] = getResult("XM", j);
		myArray_2[j] = getResult("YM", j);
		}
	// have a look at the arrays
	Array.print(myArray_1);
	Array.print(myArray_2);

	newName = "Peaks" + plotNum + ".csv";
	print("Saving ",newName);
	//run("Measure");
	saveAs("Results", outputDir+File.separator+newName);

	//close("Results");

	//close("Plot of binary");
	//close("Plot Values");
	selectWindow("binary.tif");
	drawLine(0,h*i+h/2,l,h*i+h/2);
	//close("Peaks in Plot of binary");
	}

myArray_1 = newArray(nResults);
myArray_2 = newArray(nResults);
// loop the table rows
for ( j=0; j<nResults; j++ ) { 
	myArray_1[j] = getResult("XM", j);
	myArray_2[j] = getResult("YM", j);
	}

//close("Results");
// have a look at the arrays
Array.print(myArray_1);
Array.print(myArray_2);
print("Done")
//close("binary");
//run("Close");