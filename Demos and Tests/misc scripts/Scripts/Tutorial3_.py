from ij import IJ
from ij.process import ImageStatistics as IS
import os


options=IS.MEAN|IS.MEDIAN|IS.MIN_MAX

def getStatistics(imp):
        global options
        ip=imp.getProcessor()
        stats=IS.getStatistics(ip,options,imp.getCalibration())
        return stats.mean,stats.median,stats.min,stats.max

folder="/Users/confocal/Desktop/jython"

for filename in os.listdir(folder):
        if filename.endswith(".tif"):
                print "now processing",filename
                imp=IJ.openImage(os.path.join(folder,filename))
                if imp is None: # ends with tif but has no image
                        print "where's my file",filename, "dude"
                        continue # goes out of this .tif loop and to the else
                mean,median,min,max=getStatistics(imp) #call the function
                print "Image statistics for",imp.title
                print "mean",mean
                print "median",median
                print "min and max:", min,"-",max
        else:
                print "ignoring",filename # does not end with tif