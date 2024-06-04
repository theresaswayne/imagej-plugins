// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String (label= "Stack output", choices={"Max projection", "Stack"}, style="radioButtonHorizontal") stackOption

/*
 * - converts LIF files into TIFF. 
 * - each series is saved as one tiff. The name of the series is appended to the file name.
 * 
 *  Based on a macro by Martin Hoehne, August 2015
 *  Update October 2015: works for Multichannel images as well
 *  Update October 2016 by azim58: works for lif which contain images that are not stacks.  The script will also not overwrite images if they have the same name.
 *  Update March 2017 by Theresa Swayne: bit depth is preserved, Z projection is optional 
 *  Update 2023, Theresa Swayne: use script parameters, use standard batch functions to process folder and image
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
	orderOfMag = floor(log(seriesCount)/log(10)) + 1; // log10 of the series count to tell us how many digits to pad to
	    
	print("Processing image", name);

	for (j=1; j<=seriesCount; j++) 
    	{

			run("Bio-Formats", "open=imagePath autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
			name=File.nameWithoutExtension;
    		padCount = IJ.pad(j, orderOfMag);
		
			//retrieve name of the series from metadata
			// alternate code? 				
			//      Ext.setSeries(i);
			//		Ext.getSeriesName(name);
			// text = "blah blah Series 1010 Name = 129Sv_EGFP_proSPC_U Merged_Crop001 blah blah SizeC = gurrk";
			text=getMetadata("Info");
			// TODO: Adapt for tile images. Line looks like  Series 0 Name = 129Sv_EGFP_NC/Region 1 and they are all the same for each tile. AND sizeC comes AFTER Name.
			// Possible: If the text contains "/Region" near the beginning of the file (1st 100 chars eg) then look for Name as everything up to the newline
			// Also these series (in the event you need the infivitual tiles) should be exported with the tile name probably detected by some other means -- or, more easily, add a numerical suffix to the name to force uniqueness
			tileTest = indexOf(text, "/Region"); // -1 if "Region" is not found
			n1=indexOf(text," Name = ")+8;// the Line in the Metadata reads "Series 0 Name = ". Complete line cannot be taken, because
										  // The number changes of course. But at least in the current version of Metadata this line is the 
										  // only occurence of " Name ="
//		    if (tileTest >= 0) {
//				textAfterName = substring(text, n1); // starting at n1 and going to the end of the string
//				n2 = indexOf(textAfterName, "\n") + n1; // first match
//				seriesname=substring(text, n1, n2-2);
//			}
//			else {
				n2=indexOf(text,"SizeC = ");  // this is the next line in the Metadata for non-tile images
				seriesname=substring(text, n1, n2-2);
//			}
			seriesname=substring(text, n1, n2-2);
			seriesname=replace(seriesname,"/","-");
			// print(tileTest, n1, n2, seriesname);
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
				saveAs("Tiff", outputdir+File.separator+name+"_"+seriesname+"_"+padCount+".tif");    
				}
			else
				{
				saveAs("Tiff", outputdir+File.separator+name+"_"+seriesname+"_"+padCount+".tif");
				}    
			run("Close All");
			run("Collect Garbage"); // free up memory
        
    	} // series loop
	} // end processImage function
   
	
