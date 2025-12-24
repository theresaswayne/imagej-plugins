// clean up first
run("Close All");
run("Clear Results");
setBatchMode(true);
// open a the Mitosis example image
run("Mitosis (5D stack)");
//open("/Users/theresaswayne/Desktop/mitosis.tif"); // save time by saving locally

run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
// push current Z-stack image to GPU memory
input = getTitle();
//Stack.setChannel(1);
//Ext.CLIJ2_pushCurrentZStack(input);
//Ext.CLIJ2_maximumZProjection(input, max_projection_c1);
//Ext.CLIJ2_pull(max_projection_c1);
//run("Red");
//selectWindow(input);
//Stack.setChannel(2);
//Ext.CLIJ2_pushCurrentZStack(input);
//Ext.CLIJ2_maximumZProjection(input, max_projection_c2);
//Ext.CLIJ2_pull(max_projection_c2);
//run("Green");


selectWindow(input);
// find out how many frames the time-lapse has
getDimensions(_, _, _, slices, frames);

// loop over time points
for (t = 0; t < frames; t += 5) {
	// move forward in time in the dataset
	selectWindow(input);
	Stack.setFrame(t + 1); // ImageJ's frame-counter is 1-based
	
	// process channel 1
	Stack.setChannel(1);
	Ext.CLIJ2_pushCurrentZStack(input);
	Ext.CLIJ2_maximumZProjection(input, max_projection_c1);
	Ext.CLIJ2_pull(max_projection_c1);
	run("Red");
	
	// process channel 2
	selectWindow(input);
	Stack.setChannel(2);
	Ext.CLIJ2_pushCurrentZStack(input);
	Ext.CLIJ2_maximumZProjection(input, max_projection_c2);
	Ext.CLIJ2_pull(max_projection_c2);
	run("Green");

	// merge channels
	run("Merge Channels...", "c1=" + max_projection_c1 + " c2=" + max_projection_c2 + " create");
	rename("merged t"+t); 
}
setBatchMode("exit and display");