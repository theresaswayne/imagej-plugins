//This macro will open all of the single channel z-series images in the input 
//directory, convert these images to a maximum intensity projection, apply the 
//"fire" LUT, and save these images in the tiff format in the output directory.

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output


function MIP_Fire(input, output, filename) {
		filepath = input + File.separator + filename;
		print("Opening",filepath);
		run("Bio-Formats", "open=filepath autoscale color_mode=Default view=Hyperstack"); // supports more formats
        run("Z Project...", "projection=[Max Intensity]");
		run("Fire");
		saveAs("Tiff", output + File.separator + filename);
		close();
		close(); // added to take care of extra image
}

//input = //indicate the input directory here; // replaced with script parameters for direct user choice
//output = //indicate the output directory here;

setBatchMode(true);
run("Bio-Formats Macro Extensions"); // to support more formats
list = getFileList(input);
for (i = 0; i < list.length; i++)
		MIP_Fire(input, output, list[i]);
setBatchMode(false);