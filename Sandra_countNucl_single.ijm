//// count nuclei with Find maxima
//// worka on single stack
//// 2020-01-2020

title = getTitle();
dotIndex = lastIndexOf(title, ".");
filename = substring(title, 0, dotIndex);

Stack.getDimensions(width, height, ch, slices, frames);
//Stack.setChannel(2);

run("Duplicate...", "duplicate channels=2");
run("Gaussian Blur...", "sigma=2 stack");

for (i = 1; i <= frames; i++) {
	Stack.setFrame(i);
	run("Find Maxima...", "prominence=300 output=Count");	
}

saveAs("results","/Users/elm2157/Desktop/Sandra"+File.separator+filename+"_Results.txt");
close();