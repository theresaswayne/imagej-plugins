// concatenate_stacks.ijm
// for testing stack concatenation with unlike dimensions


run("Bat Cochlea Volume (19K)");
run("Gaussian Blur...", "sigma=6 stack");
rename("Stack3");

run("Bat Cochlea Volume (19K)");
run("Add Noise", "stack");
rename("Stack4");

run("Bat Cochlea Volume (19K)");
rename("Stack1");

run("Bat Cochlea Volume (19K)");
run("Invert", "stack");
rename("Stack2");

run("Concatenate...", "all_open title=boo open"); // (this strings the stacks together as time -- in order of opening not filename)

// run("Concatenate...", "  title=[combined] keep open image1=Stack"+str(i)+" image2=HUVECs-Rac002.nd2"); // here you have to specify each name
// run("Concatenate...", "all_open title=combo"); // (this strings the stacks together as z)
