// @File(label = "Input directory", style = "directory") input
// @File(label = "Output directory", style = "directory") output
// @File(label="Weka model", description="Select the Weka model to apply") modelPath
// @String(label = "File suffix", value = ".tif") suffix
// @String(label="Result mode",choices={"Labels","Probabilities"}) resultMode

// macro to apply a saved Trainable Weka Segmentation (2D) classifier to a folder of images
// UNDER CONSTRUCTION -- DOES NOT WORK YET

// set result mode flag

// start plugin
run("Trainable Weka Segmentation");
 
// wait for the plugin to load
wait(3000);

probabilityMaps = "true"; // default value
if(resultMode == "Labels")
	probabilityMaps = "false";

// process images
processFolder(input);

function processFolder(input) {
// scan folders/subfolders/files to find files with correct suffix

	list = getFileList(input);
	list = Array.sort(list);
	for (i=0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
// process each file

	call("trainableSegmentation.Weka_Segmentation.applyClassifier", input, file, "showResults=true", "storeResults=true", "probabilityMaps="+probabilityMaps, output);
	print("Processing: " + input + file);
	print("Saving to: " + output);
}


