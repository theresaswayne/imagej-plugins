

imp = IJ.createImage("imgSymm", "8-bit black", 16, 16, 1);
//IJ.setTool("rectangle");
imp.setRoi(0,7,1,1);
IJ.setBackgroundColor(255, 255, 255);
IJ.run(imp, "Clear", "slice");
imp.setRoi(0,8,1,1);
IJ.run(imp, "Clear", "slice");
//IJ.setTool("line");
imp.setRoi(new Line(0,0,0,6));
IJ.run(imp, "Plot Profile", "");
imp.setRoi(new Line(0,15,0,9));
IJ.run(imp, "Plot Profile", "");
imp.show();
