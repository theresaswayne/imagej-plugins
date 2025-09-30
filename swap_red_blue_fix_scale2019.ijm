
// swap_red_blue_fix_scale.ijm
// Use this code in the Process > Batch > Macro... command 
// Swaps the red and blue channels and sets scale to 2.55595 pixels/um
// Use for cervical whole-slide VSI images where colors are not rendered properly
 
run("Make Composite");
Stack.setDisplayMode("color");
Stack.setChannel(1);
run("Blue");
Stack.setChannel(3);
run("Red");
Stack.setDisplayMode("composite");
run("Stack to RGB");
run("Set Scale...", "distance=1 known=2.5595 pixel=1 unit=um");
