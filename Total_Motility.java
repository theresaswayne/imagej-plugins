//start of Total_Motility.java 
import ij.IJ; 
import ij.ImagePlus; 
import ij.ImageStack; 
import ij.WindowManager; 
import ij.plugin.PlugIn; 
import ij.process.Blitter; 
import ij.process.ImageProcessor; 
import ij.process.ImageStatistics; 
import java.awt.image.ColorModel; 
/* 
* Total_Motility.java 
* 
* Created on April 17, 2006, 7:50 PM 
* 
* @author Kurt De Vos # 2006 
* 
* This program is free software; you can redistribute it and/or 
* modify it under the terms of the GNU General Public License 
* as published by the Free Software Foundation (http://www.gnu.org/licenses/gpl.txt) 
* 
* This program is distributed in the hope that it will be useful, 
* but WITHOUT ANY WARRANTY; without even the implied warranty of 
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
* See the GNU General Public License for more details. 
* 
* You should have received a copy of the GNU General Public License 

* along with this program; if not, write to the Free Software 
* Foundation, Inc., 59 Temple Place – Suite 330, Boston, MA 02111-1307, USA. 
*/ 
	public class Total_Motility implements PlugIn{ 
	ImagePlus img; 
	ImageStatistics imStats; 
	int stackSize; 
	/** 
	* Creates a new instance of Total_Motility 
	*/ 
	public Total_Motility() { 
	} 
	public void run(String arg){ 
		img = WindowManager.getCurrentImage(); 
		stackSize = img.getStackSize(); 
		if (img == null) { 
			IJ.noImage(); 
			return; 
		} 
		if (img.getStackSize() == 1){ 
			IJ.error("you need a stack"); 
			return; 
		} 
		if (!checkBinary()){ 
			IJ.error("you need a binary stack"); 
			return; 
		} 
		
		// First count the white pixels in the original stack... 
		int[] originalCounts = binaryCount(img); 
		
		//Do the subtraction 
		ImagePlus subtractedImg = subtractStack(img); 
		
		//Count the white pixels in the subtracted stack 
		int[] subtractedCounts = binaryCount(subtractedImg); 
		
		//Calculate the motility 
		doCalculations(originalCounts,subtractedCounts); 
	} 
		// check if the image is in binary format 
	public boolean checkBinary(){ 
		imStats = img.getStatistics(); 
		if (imStats.histogram[0] +imStats.histogram[255]==imStats.pixelCount){ 
			return true; 
		} 
		IJ.error("8-bit binary required – features in White!!"); 
		return false; 
	} 
		//Count white pixels 
	public int[] binaryCount(ImagePlus img){ 
		int[] counts = new int[img.getStackSize()]; 
		for (int i =1;i<=img.getStackSize();i++){ //walks through the stack and counts 
			IJ.showProgress((double)i/img.getStackSize()); 
			IJ.showStatus(i +"/"+img.getStackSize()); 
			img.setSlice(i); 
			imStats = img.getStatistics(); 
			counts[i-1] = imStats.histogram[255]; // only the white pixels... 
			System.out.println(img.getTitle() +" " +counts[i-1]); 
		} 
		img.setSlice(1); 
		return counts; 
	} 
		//subtract 
	public ImagePlus subtractStack(ImagePlus img){ 
		ImageStack stack = img.getStack(); 
		int stackSize = img.getStackSize(); 
		int currentSlice = img.getCurrentSlice(); 
		ColorModel colorMod = img.createLut().getColorModel(); 
		ImageStack newStack = new ImageStack(stack.getWidth(),stack.getHeight(),colorMod); 
		
		for(int i = 1;i<=stackSize-1;i++) { 
			IJ.showProgress((double)i/(double)(stackSize-1)); 
/*			IJ.showStatus(i+"/",+(stackSize-1)); **/
			img.setSlice(i); 
			ImageProcessor ip1 = img.getProcessor(); 
			ImageProcessor copyIp1 = ip1.duplicate(); 
			img.setSlice(i+1); 
			ImageProcessor ip2 = img.getProcessor(); 
			ImageProcessor copyIp2 = ip2.duplicate(); 
			copyIp2.copyBits(copyIp1, 0, 0, Blitter.SUBTRACT); 
			newStack.addSlice("", copyIp2); 
		} 
		ImagePlus sub = new ImagePlus(img.getTitle().substring(0, img.getTitle().lastIndexOf(".")) + "_subtracted", newStack); 
		sub.show(); 
		return sub; 
	} 
		// calculate and output 
	public void doCalculations(int[] counts1, int[] counts2){ 
		IJ.setColumnHeadings("Slice\tpercent"); 
		for (int i =0; i<counts2.length; i++){ 
			int j = i+1; 
			int slice = i+2; 
			double percent = (double)counts2[i]/(double)counts1[j]*100; 
			System.out.println("j ="+j+" double "+ percent+" = "+counts1[j]+" / "+ counts2[i]); 
			IJ.write(slice +"\t"+IJ.d2s(percent)); 
		} 
	} 
} 
//end of Total_Motility.java 