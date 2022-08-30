//This macro will open all of the single channel z-series images in the input 
//directory, convert these images to inverted grey-scale images, and save these 
//images in the tiff format in the output directory.


#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output

function Invert_Gray(input, output, filename) {
		filepath = input + File.separator + filename;
		print("Opening",filepath);
		run("Bio-Formats", "open=filepath autoscale color_mode=Default view=Hyperstack"); // supports more formats
        //open(input + filename);
		run("Grays");
		run("Invert", "stack");
		//saveAs("Tiff", output + filename);
		saveAs("Tiff", output + File.separator + filename);
		close();
}

//input = //indicate the input directory here; // replaced with script parameters for direct user choice
//output = //indicate the output directory here;

setBatchMode(true);
run("Bio-Formats Macro Extensions"); // to support more formats
list = getFileList(input);
for (i = 0; i < list.length; i++)
		Invert_Gray(input, output, list[i]);
setBatchMode(false);