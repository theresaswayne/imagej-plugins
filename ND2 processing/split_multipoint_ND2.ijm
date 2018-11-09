//@ File (label = "Input directory", style = "file") inputDir
//@ File (label = "Output directory", style = "directory") outputParent


// split_multipoint_ND2.ijm
/*
 * - opens multi-point ND2 files and saves individual TIFs for each point 
 * - Updated to simplify and use script parameters by Theresa Swayne, Columbia University. 
 * - Based on a macro for LIF processing by Martin Hoehne and azim58, on ImageJ forum
 * - the macro asks for an input folder that should contain 1 or more multipoint ND2 files. Nothing else.
 * - each series is saved as one tiff. The point number is appended to the file name. 
 */


run("Bio-Formats Macro Extensions"); // enables access to macro commands

list = getFileList(inputDir);

setBatchMode(true);
 
for (i=0; i<list.length; i++) // loop through all files in the folder
	{
    showProgress(i+1, list.length);
    print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);

    inputFile = list[i];
	path = inputDir + File.separator + inputFile;

	inputName = File.getName(inputFile); // necessary?
	
	// create a folder for the points for each file

	outputName = inputName + "_XYpoints";
	outputDir = outputParent + File.separator + outputName;
	
	if (File.exists(outputDir)==false) 
		{
		File.makeDirectory(outputDir); // new directory for tiff
	    }

    //how many series in this ND2 file?
    Ext.setId(path);//-- Initializes the given path (filename).
    Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.

	// what order of magnitude is the # of series? 
	// find the log10 of the # of series, and pad so that up to 10 images will be padded to 2 digits, 100 to 3, etc.
	// IJ macro language uses natural log so we convert to log10
    seriesPadding = 2 + floor(log(seriesCount)/log(10));  // because log10(n) = log(n)/log(10)

    for (j=1; j<=seriesCount; j++) // open each series 
    	{
        run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
        name=File.nameWithoutExtension;

		// generate the series number by padding appropriately
		seriesname = IJ.pad(j, seriesPadding);
		rename(seriesname);
		
        saveAs("Tiff", outputDir + File.separator + name + "_XY" + seriesname + ".tif");    
        run("Close All");
        run("Collect Garbage");
    	}
	}
showMessage(" -- finished --");    
run("Close All");
setBatchMode(false);

