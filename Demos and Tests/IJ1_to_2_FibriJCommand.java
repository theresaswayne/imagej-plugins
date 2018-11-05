package com.tnia.commands;

// example of converting IJ1 plugin to IJ2 style
// from brian northan https://github.com/True-North-Intelligent-Algorithms/FibrilTool2/blob/master/src/main/java/com/tnia/commands/FibriJCommand.java
// see discussion here https://forum.image.sc/t/studying-plugins-where-can-i-find-a-simple-imagej2-style-plugin-in-the-current-1-51s-version-of-fiji/8494/3

import com.tnia.ops.transform.InterpolateViaTransformOp;

import net.imagej.ImgPlus;
import net.imagej.ops.OpService;
import net.imagej.ops.special.computer.BinaryComputerOp;
import net.imagej.ops.special.computer.Computers;
import net.imglib2.IterableInterval;
import net.imglib2.RandomAccessibleInterval;
import net.imglib2.img.Img;
import net.imglib2.realtransform.AffineTransform2D;
import net.imglib2.type.NativeType;
import net.imglib2.type.numeric.RealType;
import net.imglib2.type.numeric.real.FloatType;

import org.scijava.ItemIO;
import org.scijava.command.Command;
import org.scijava.log.LogService;
import org.scijava.plugin.Parameter;
import org.scijava.plugin.Plugin;
import org.scijava.ui.UIService;

@Plugin(type = Command.class, headless = true, menuPath = "Plugins>FibriJ")
public class FibriJCommand<T extends RealType<T> & NativeType<T>> implements Command {

	@Parameter
	OpService ops;

	@Parameter
	LogService log;

	@Parameter
	UIService ui;

	@Parameter
	ImgPlus img;

	@Parameter(type = ItemIO.OUTPUT)
	Double averageOrientation;

	@Parameter(type = ItemIO.OUTPUT)
	Double quality;

	BinaryComputerOp<RandomAccessibleInterval<FloatType>, AffineTransform2D, IterableInterval<FloatType>> transformOp = null;

	public void run() {
		
		//averageOrientation=

		try {
			transformOp = (BinaryComputerOp) Computers.binary(ops, InterpolateViaTransformOp.class,
					IterableInterval.class, RandomAccessibleInterval.class, AffineTransform2D.class);
		} catch (Exception ex) {
			log.info(ex);
		}

		System.out.println(img.dimension(2));

		// get pixel size
		// pixelWidth=...;

		double scale = 1.0;
		
		// convert image to float 32
		Img<FloatType> imgf=ops.convert().float32(img);

		// compute x-gradient in "x"
		// selectWindow("Temp");
		// run("Duplicate...","title=x");
		// run("32-bit");
		// run("Translate...", "x=-0.5 y=0 interpolation=Bicubic");
		// run ("Duplicate...","title=x1");
		// run("Translate...", "x=1 y=0 interpolation=None");
		// imageCalculator("substract","x","x1");
		// selectWindow("x1");
		// close();

		// compute x gradient by shifting -0.5 and 0.5 pixels
		
		// first create images that will hold the shifted data
		IterableInterval<FloatType> xm = ops.create().img(imgf);
		IterableInterval<FloatType> xp = ops.create().img(imgf);

		// define a affine transform to do the negative shift
		AffineTransform2D transmx = new AffineTransform2D();
		transmx.translate(0.5, 0);
		transformOp.compute(imgf, transmx, xm);
		
		//ui.show(xm);

		// define a affine transform to do the positive shift
		AffineTransform2D transpx = new AffineTransform2D();
		transpx.translate(-0.5, 0);
		transformOp.compute(imgf, transpx, xp);

		IterableInterval<FloatType> dx = ops.math().subtract(xp, xm);
		
		//ui.show(xp);

		//ui.show("dx", dx);

		// compute y-gradient in "y"
		// selectWindow("Temp");
		// run ("Duplicate...","title=y");
		// run("32-bit");
		// run("Translate...", "x=0 y=-0.5 interpolation=Bicubic");
		// run ("Duplicate...","title=y1");
		// run("Translate...", "x=0 y=1 interpolation=None");
		// imageCalculator("substract","y","y1");
		// selectWindow("y1");
		// close();

		// compute y gradient
		IterableInterval<FloatType> ym = ops.create().img(imgf);
		IterableInterval<FloatType> yp = ops.create().img(imgf);

		// define a affine transform
		AffineTransform2D transmy = new AffineTransform2D();
		transmy.translate(0, 0.5);
		transformOp.compute(imgf, transmy, ym);

		// define a affine transform
		AffineTransform2D transpy = new AffineTransform2D();
		transpy.translate(0, -0.5);
		transformOp.compute(imgf, transpy, yp);

		IterableInterval<FloatType> dy = ops.math().subtract(yp,  ym);

		//ui.show("dy", dy);

		// compute norm of gradient in "g"
		// selectWindow("x");
		// run("Duplicate...","title=g");
		// imageCalculator("multiply","g","x");
		IterableInterval<FloatType> dxSquared =  ops.math().multiply( dx,  dx);

		// selectWindow("y");
		// run("Duplicate...","title=gp");
		// imageCalculator("multiply","gp","y");
		IterableInterval<FloatType> dySquared =  ops.math().multiply(dy, dy);

		// imageCalculator("add","g","gp");
		// selectWindow("gp");
		// close();
		IterableInterval<FloatType> dxSquaredPlusdySquared =  ops.math().add( dxSquared,
				 dySquared);

		// selectWindow("g");
		// w = getWidth(); h = getHeight();
		// for (y=0; y<h; y++) {
		// for (x=0; x<w; x++){
		// setPixel(x, y, sqrt( getPixel(x, y)));
		// }
		// }
		for (FloatType f : dxSquaredPlusdySquared) {
			double val = f.getRealDouble();
			val = Math.sqrt(val);
			f.setReal(val);
		}

		// set the effect of the gradient to 1/255 when too low ; threshold =
		// thresh
		// double thresh=2.0;
		// selectWindow("g");
		// for (y=0; y<h; y++) {
		// for (x=0; x<w; x++){
		// if (getPixel(x,y) < thresh)
		// setPixel(x, y, 255);
		// }
		// }
		double thresh = 2.0;
		for (FloatType f : dxSquaredPlusdySquared) {
			if (f.getRealDouble() < thresh) {
				f.setReal(255.);
			}
		}

		// normalize "x" and "y" to components of normal
		// imageCalculator("divide","x","g");
		dx =  ops.math().divide(dx, dxSquaredPlusdySquared);

		// imageCalculator("divide","y","g");
		dy =  ops.math().divide(dy, dxSquaredPlusdySquared);

		// compute nxx
		// selectWindow("x");
		// run("Duplicate...","title=nxx");
		// imageCalculator("multiply","nxx","x");
		IterableInterval<FloatType> dxx=ops.math().multiply(dx, dx);

		// compute nxy
		// selectWindow("x");
		// run("Duplicate...","title=nxy");
		// imageCalculator("multiply","nxy","y");
		IterableInterval<FloatType> dxy=ops.math().multiply(dx, dy);


		// compute nyy
		// selectWindow("y");
		// run("Duplicate...","title=nyy");
		// imageCalculator("multiply","nyy","y");
		IterableInterval<FloatType> dyy=ops.math().multiply(dy, dy);
		
		//ui.show("dxx", dxx);
		//ui.show("dxy", dxy);
		//ui.show("dyy", dyy);

		// closing
		// selectWindow("Temp");
		// close();
		// selectWindow("x");
		// close();
		// selectWindow("y");
		// close();
		// selectWindow("g");
		// close();

		// averaging nematic tensor
		// selectWindow("nxx");
		// makeSelection("polygon",vertxloc,vertyloc);
		// getRawStatistics(area,xx);
		// close();
		double xx=ops.stats().mean(dxx).getRealDouble();
		
		// selectWindow("nxy");
		// makeSelection("polygon",vertxloc,vertyloc);
		// getRawStatistics(area,xy);
		// close();
		double xy=ops.stats().mean(dxy).getRealDouble();

		// selectWindow("nyy");
		// makeSelection("polygon",vertxloc,vertyloc);
		// getRawStatistics(area,yy);
		// close();
		double yy=ops.stats().mean(dyy).getRealDouble();

		// eigenvalues and eigenvector of texture tensor
		double m = (xx + yy) / 2;
		double d = (xx - yy) / 2;
		double v1 = m + Math.sqrt(xy*xy + d*d);
		double v2 = m - Math.sqrt(xy*xy + d*d);
		
		// direction
		double tn = - Math.atan((v2 - xx) / xy);
		// score
		// was double scoren = ...
		quality = Math.abs((v1-v2) / 2 / m);
		
		// output
		// was double tsn
		averageOrientation=tn*180/Math.PI;
		// nematic tensor tensor
		// sortie = sortie+"\t"+d2s(tsn,pr)+"\t"+d2s(scoren,2*pr);

		// polygon coordinates (may not be needed)
		// np = vertx.length;
		// for (i=0; i<np; i++){
		// xp = vertx[i]; yp = verty[i];
		// sortie = sortie+"\t"+d2s(xp,pr)+"\t"+d2s(yp,pr);

	}

}
