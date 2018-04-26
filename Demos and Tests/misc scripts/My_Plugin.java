import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.*;
import ij.plugin.frame.*;

public class My_Plugin implements PlugIn {

	public void run(String arg) {
		ImagePlus imp = IJ.getImage();
		IJ.run(imp, "Invert", "");
		IJ.wait(1000);
		IJ.run(imp, "Invert", "");
	}

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
}
