from ij import IJ

from ij import WindowManager as WM

imps=map(WM.getImage, WM.getIDList())

def area(imp):
    return imp.width*imp.height

def match(imp):
    """ returns true if the image title contains the word cochlea """
    return imp.title.find("cochlea") > -1

matching = filter(match,imps)

def smallestImage(imp1, imp2):
    return imp1 if area(imp1) < area(imp2) else imp2

smallest = reduce(smallestImage, imps)

print smallest
