#@ File (label = "Input file", style = "file") inputFile
#@ File (label = "Output directory", style = "directory") outputDir

# based on example by C. Rueden at https://gist.github.com/ctrueden/6282856

# WARNING -- with options, fails. Without options, out of memory

import time
import os.path
from loci.plugins import BF
from loci.common import Region
from loci.plugins.in import ImporterOptions
from loci.formats import ImageReader, MetadataTools
from ij import IJ

startTime = time.clock()

inputFile = str(inputFile)
outputDir = str(outputDir)

reader = ImageReader()
omeMeta = MetadataTools.createOMEXMLMetadata()
reader.setMetadataStore(omeMeta)
reader.setId(inputFile)
seriesCount = reader.getSeriesCount()
channels = reader.getSizeC()
slices = reader.getSizeZ()
frames = reader.getSizeT()
reader.close()

print(seriesCount, channels, slices, frames)

options = ImporterOptions()

options.setId(inputFile)
options.setAutoscale(True)

#options.clearSeries()
seriesNum = 1 # TESTING -- single series. TODO: add loop

options.setSeriesOn(seriesNum, True) 
options.setVirtual(True) # TESTING -- remove when setting range

# TODO: get ranges from a dialog

#options.setSpecifyRanges(True)

#options.setCBegin(seriesNum, channels)
#options.setCEnd(seriesNum, channels-1)
#options.setCStep(seriesNum, 1)

#options.setZBegin(seriesNum, 1)
#options.setZEnd(seriesNum, slices)
#options.setZStep(seriesNum, 1)

#options.setTBegin(seriesNum, 1)
#options.setTEnd(seriesNum, frames)
#options.setTStep(seriesNum, 4)

imps = BF.openImagePlus(options) # a list

for imp in imps:
	seriesName = imp.getTitle()
	print("Processing series " + seriesName)
	outputName = seriesName + ".tif"
	IJ.saveAsTiff(imp, os.path.join(outputDir, outputName))

endTime = time.clock()
print("Finished in " + str(endTime-startTime) + " s.")