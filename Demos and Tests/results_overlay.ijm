run("Blobs (25K)");

xpoints = newArray(10, 20, 30);
ypoints = newArray(30, 20, 10);
zpoints = newArray(100,110,120);

setTool("multipoint");

run("Point Tool...", "type=Hybrid color=Yellow size=Small label show counter=0");
//setKeyDown("shift"); 
makeSelection("point", xpoints, ypoints);

//run("Point Tool...", "type=Hybrid color=Yellow size=Small label show counter=1");
//setKeyDown("shift"); 
makeSelection("point", ypoints, xpoints);

run("Point Tool...", "type=Hybrid color=Yellow size=Small label show counter=2");
//setKeyDown("shift"); 
makeSelection("point", xpoints, zpoints);

run("Properties... ", "show");
setFont("SanSerif", 12);
setColor("cyan");
Overlay.drawString("Counter 0:"+ getResult("Ctr 0",0) + ";  Counter 1: "+ getResult("Ctr 1", 0),100, 100, 0);
//Overlay.drawString("Counter 1", 100, 100, 0);
Overlay.show;

// I think it could possibly be done with `setFont("Monospaced", ...)` and some kludge-y method for adding leading spaces.
