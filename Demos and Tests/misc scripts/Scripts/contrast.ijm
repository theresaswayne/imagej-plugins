
// written by Theresa Swayne for StackOverflow poster EaudeRoche http://stackoverflow.com/questions/35325100/how-can-i-modify-the-brightnesscontrast-automatically-on-my-images-with-fiji-ma
// February 18, 2016

dir  = getDirectory("Select input directory"); out  = getDirectory("Select destination directory");
files  = getFileList(dir);

//foreach tiff couple files

for (j=0; j<lengthOf(files);j+=2) { //fixed loop length and incrementor
    channel1 = dir+files[j];
    channel2 = dir+files[j+1];

    open(channel1);
	image1 = getTitle(); // get the window name

	open(channel2);
	image2 = getTitle(); // get the window name

	selectWindow(image1); // focus on the first channel
    run("Enhance Contrast", "saturated=0.35 process_all"); // process all slices
    getMinAndMax(min,max);  // get display range
    if (min != 0 && max != 255) {  // check if the display has been changed
    run("Apply LUT", "stack");
    }
	selectWindow(image2); // repeating for the 2nd channel
    run("Enhance Contrast", "saturated=0.35 process_all"); // // process all slices
    getMinAndMax(min,max); // get display range
    if (min != 0 && max != 255) {  // check if the display has been changed
    run("Apply LUT", "stack");
    }

    run("Merge Channels...", "c1="+image1+" c2="+image2); // use window names rather than full paths
    run("Z Project...", "projection=[Sum Slices]");
    saveAs("Tiff", out+"merge"+files[j]);
//    run("Close");
    run("Close All"); // make sure everything is closed
}
