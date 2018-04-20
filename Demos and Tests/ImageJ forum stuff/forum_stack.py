from ij import IJ, WindowManager

def stack_images(infilelist):
    """
    Description of stack_image
    """
    infile_A = infilelist[0]
    infile_B = infilelist[1]
    infile_C = infilelist[2]
    imp = IJ.openImage(infile_A)
    imp.show()
    imp = IJ.openImage(infile_B)
    imp.show()
    imp = IJ.openImage(infile_C)
    imp.show()
    IJ.run(imp, "Images to Stack", "name=Stack title=[] use")
    imp2 = WindowManager.getCurrentImage()
    IJ.run(imp2, "Make Montage...", "columns=3 rows=1 scale=0.25  label")
    imp3 = WindowManager.getCurrentImage()
    IJ.run(imp3, "Save", "save=/Users/pdubois/Desktop/montage.tif")

def main():
    """
    Description of main
    """
    filelist = [ "/Users/pdubois/Desktop/FigA.png",
                 "/Users/pdubois/Desktop/FigB.png",
                 "/Userls/pdubois/Desktop/FigC.png"]

# for testing
#    filelist = [ "http://imagej.nih.gov/ij/images/Dot_Blot.jpg",
#                 "http://imagej.nih.gov/ij/images/Dot_Blot.jpg",
#                 "http://imagej.nih.gov/ij/images/Dot_Blot.jpg"]

    stack_images(filelist)


if __name__ == '__main__':
    main()