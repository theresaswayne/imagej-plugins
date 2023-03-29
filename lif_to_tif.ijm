// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String (label= "Stack output", choices={"Max projection", "Stack"}, style="radioButtonHorizontal") stackOption

/*
 * - converts LIF files into TIFF. 
 * - each series is saved as one tiff. The name of the series is appended to the file name.
 * 
 *  Based on a macro by Martin Hoehne, August 2015
 * 
 *  Update October 2015: works for Multichannel images as well
 *  Update October 2016 by azim58: works for lif which contain images that are not stacks.  The script will also not overwrite images if they have the same name.
 *  Update March 2017 by Theresa Swayne: bit depth is preserved, Z projection is optional 
 *  
 */

// ---- Setup ----

run("Bio-Formats Macro Extensions"); // enables access to macro commands
setBatchMode(true); 
n = 0;

// ---- Commands to run the processing functions ---

processFolder(inputdir, outputdir); // actually do the processing
showMessage("Finished.");
setBatchMode(false);
// clean up
while (nImages > 0) {
	close(); }
// run("Close All");


// ---- Function for processing folders ----
function processFolder(inputdir, outputdir) 
	{
	list = getFileList(inputdir);
	for (i=0; i<list.length; i++)  {
	    showProgress(i+1, list.length);
	    if(File.isDirectory(inputdir + File.separator + list[i])) { 
			processFolder("" + inputdir +File.separator+ list[i]); }
	    else if (endsWith(list[i], ".lif")) {
	       	processImage(inputdir, list[i], outputdir); 
	       	} 
		}
	}
	

// ------- Function for processing individual files

function processImage(inputdir, name, outputdir) 
	{
	// ---- Open image and get name, info
	imagePath = inputdir + File.separator + name;
	Ext.setId(imagePath);//-- Initializes the given path (filename).
	Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	
	print("Processing image", name);

	for (j=1; j<=seriesCount; j++) 
    	{
        run("Bio-Formats", "open=imagePath autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
        name=File.nameWithoutExtension;

	    //retrieve name of the series from metadata
        text=getMetadata("Info");
        n1=indexOf(text," Name = ")+8;// the Line in the Metadata reads "Series 0 Name = ". Complete line cannot be taken, because
                                      // The number changes of course. But at least in the current version of Metadata this line is the 
                                      // only occurence of " Name ="
        n2=indexOf(text,"SizeC = ");  // this is the next line in the Metadata
        seriesname=substring(text, n1, n2-2);
		seriesname=replace(seriesname,"/","-");
		rename(seriesname);
		
	    // project and save
    	getDimensions(width, height, channels, slices, frames); // check if is a stack of any kind
    	if (slices>1) // it is a z stack
    		{
        	if (stackOption == "Max projection")
        		{
        		run("Z Project...", "projection=[Max Intensity]");
        		selectWindow("MAX_"+seriesname);
        		seriesname = "MAX_"+seriesname;
        		}
	        saveAs("Tiff", outputdir+File.separator+name+"_"+seriesname+"_"+j+".tif");    
    		}
        else
        	{
	        saveAs("Tiff", outputdir+File.separator+name+"_"+seriesname+"_"+j+".tif");
        	}    
        run("Close All");
        run("Collect Garbage"); // free up memory
    	}
	} // end processImage function
   
	
