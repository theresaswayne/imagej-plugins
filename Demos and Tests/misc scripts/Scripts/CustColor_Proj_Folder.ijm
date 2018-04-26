// Macro template to process multiple images in a folder
// macro by Theresa Swayne tcs6@cumc.columbia.edu for Eileen Guilfoyle, 2015
// opens image, sets colors to grey, green, red, blue, max projects, saves as rgb tiff

input = getDirectory("Input directory");
output = getDirectory("Output directory");

Dialog.create("File type");
Dialog.addString("File suffix: ", ".nd2", 5);
Dialog.show();
suffix = Dialog.getString();

processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// do the processing here by replacing
	// the following two lines by your own code
	print("Processing: " + input + "[" + file + "]");
	run("Bio-Formats Importer", "open=[" +input+ file + "] color_mode=Custom view=Hyperstack stack_order=XYCZT series_0_channel_0_red=255 series_0_channel_0_green=255 series_0_channel_0_blue=255 series_0_channel_1_red=0 series_0_channel_1_green=255 series_0_channel_1_blue=0 series_0_channel_2_red=255 series_0_channel_2_green=0 series_0_channel_2_blue=0 series_0_channel_3_red=0 series_0_channel_3_green=0 series_0_channel_3_blue=255");
	run("Z Project...", "projection=[Max Intensity]");
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels("1111");
	run("RGB Color");
	saveAs("Tiff", output + file + ".tif");
	print("Saving to: " + output);
}
