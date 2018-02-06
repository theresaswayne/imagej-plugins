# @LogService logService
# @StatusService ss

# logs_messages.py
# Theresa Swayne, Feb. 2018
# Demonstrates logs and messages that can be displayed in ImageJ using python 
# Thanks to https://github.com/imagej/tutorials/blob/master/maven-projects/intro-to-imagej-api/src/main/java/IntroToImageJAPI.java
# 
# Watch the IJ toolbar when running this script!
#

import os, sys, time
from java.lang import Double, Integer
from ij import IJ, ImagePlus, ImageStack, Prefs
from ij.process import ImageProcessor, ImageConverter, LUT, ColorProcessor
from ij.io import FileSaver
import random

startTime = time.clock()

# imp = IJ.openImage("http://imagej.nih.gov/ij/images/blobs.gif");
progress = round(100*random.random())

# The ImageJ1 methods for showing messages include log, status, and error

# Prints to the ImageJ Log window (note this is an ImageJ1 function, and IJ2 functions are preferred) 
IJ.log("I'm an IJ.log message!")

# The error function produces a dialog with "OK" button 
IJ.error("I'm an IJ1 error! Watch the toolbar!")

# This shows a progress bar in the IJ toolbar.
IJ.showProgress(progress/200.0)

# The IJ1 status message shows up in the status bar (toolbar) until it is replaced by another message
IJ.showStatus("Here I am in the toolbar")
time.sleep(3) # pause so you can see the message

# The bar is erased if currentValue>=1.0
IJ.showProgress(1.0)

# Print statements show up in the script editor if it is open
# Don't know where they show up if the editor is not open...
print "I am appearing unobtrusively at the bottom of the Script Editor."

# The preferred IJ2 alternatives to the Log window are the Log Service and Status Service.  
# Log Service messages appear in the Console window and are more designed for programmers.
# Status Service messages can appear in different locations, and are more directed at end users.
# Note that the instances of the services are created at the top of the script using @Parameters.

# more info: http://forum.imagej.net/t/how-to-properly-use-the-logservice/8321/2

# Log Service has 5 levels: Error, Warn, Info, Debug, and Trace.
logService.warn("I'm showing up in the Console! I'm very important!")
logService.error("NOW you've done it!")
logService.info("Just sayin")

# By default, the DEBUG and TRACE levels do not show up in the console.
# You would have to set the log service verbosity level, possibly through command line.
logService.debug("Counting starts at 0, you know")
logService.trace("What does trace even do?")

# This is the IJ2 version of showing status, using the StatusService loaded in the script parameters
ss.showStatus(int(progress), 100, "Processing " + str(progress) + "%")
time.sleep(2) # pause so you can see the message
ss.showStatus(100, 100, "Processing complete")
time.sleep(2)

ss.showStatus("This status message will be replaced by the IJ version after I clear it.")
time.sleep(3)

ss.clearStatus()
time.sleep(1)

# The Status Service warning produces a dialog with "OK" button 
ss.warn("I'm an IJ2 warning. Bye!")

endTime = time.clock()
elapsedTime = endTime - startTime
logService.info("Finished in "+str(elapsedTime)+" seconds.")
