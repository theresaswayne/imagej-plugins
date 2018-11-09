//@ File (label = "Input directory", style = "file") inputDir
//@ File (label = "Output directory", style = "directory") outputDir


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
 
for (i=0; i<list.length; i++) 
	{
    showProgress(i+1, list.length);
    print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);
    path=dir1+list[i];

	inputName = File.getName(inputDir);
	// create folders for the tifs

	dir2 = inputParent+File.separator+inputName+"_XYPoints";
	if (File.exists(dir2)==false) 
		{
		File.makeDirectory(dir2); // new directory for tiff
	    }

    //how many series in this ND2 file?
    Ext.setId(path);//-- Initializes the given path (filename).
    Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.

	// what order of magnitude is the # of series? 
	// find the log10 of the # of series, and pad so that up to 10 images will be padded to 2 digits, 100 to 3, etc.
    seriesPadding = 2 + floor(log(seriesCount)/log(10));  // because log10(n) = log(n)/log(10)
    for (j=1; j<=seriesCount; j++) 
    	{
        run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
        name=File.nameWithoutExtension;

		// generate the series number by padding appropriately
		seriesname = IJ.pad(j, seriesPadding)
		rename(seriesname);
		
	    // project and save
    	getDimensions(width, height, channels, slices, frames); // check if is a stack of any kind
    	if (slices>1) // it is a z stack
    		{
        	if (Z_PROJECT == "True")
        		{
        		run("Z Project...", "projection=[Max Intensity]");
        		selectWindow("MAX_"+seriesname);
        		}
	        saveAs("Tiff", dir2+File.separator+name+"_"+seriesname+"_MIP_.tif");    
    		}
        else
        	{
	        saveAs("Tiff", dir2+File.separator+name+"_"+seriesname+"_MIP_.tif");
        	}    
        run("Close All");
        run("Collect Garbage");
    	}
	}
showMessage(" -- finished --");    
run("Close All");
setBatchMode(false);

} // macro
