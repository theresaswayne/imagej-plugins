#@ File (label = "Input file", style = "file") inputFile
#@ File (label = "Output directory", style = "directory") outputDir

# based on example by C. Rueden at https://gist.github.com/ctrueden/6282856

from loci.plugins import BF

# parse metadata
from loci.formats import ImageReader
from loci.formats import MetadataTools

inputFile = str(inputFile)

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

# TODO: get ranges from a dialog

# read in and display ImagePlus(es) with arguments
from loci.common import Region
from loci.plugins.in import ImporterOptions
options = ImporterOptions()

options.setId(inputFile)
options.setAutoscale(true)

#options.clearSeries()
options.setSeriesOn(1, True)

options.setSpecifyRanges(True)

options.setCBegin(1, channels)
options.setCEnd(1, channels)
options.setCStep(1, 1)

options.setZBegin(1, 1)
options.setZEnd(1, slices-1)
options.setZStep(1, 1)

options.setTBegin(1, 1)
options.setTEnd(1, frames-1)
options.setTStep(1, 4)

#imps = BF.openImagePlus(options) # a list
#for imp in imps:
#    imp.show()

# print out series count from two different places (they should always match!)
from ij import IJ
imageCount = omeMeta.getImageCount()
IJ.log("Total # of image series (from BF reader): " + str(seriesCount))
IJ.log("Total # of image series (from OME metadata): " + str(imageCount))


# from Harri Jäälinoja
 
# set up import process
process = ImportProcess(opts)
process.execute()
nseries = process.getSeriesCount()
 
# reader belonging to the import process
reader = process.getReader()
 
# reader external to the import process
impReader = ImagePlusReader(process)
for i in range(0, nseries):
    print "%d/%d %s" % (i+1, nseries, process.getSeriesLabel(i))
     
    # activate series (same as checkbox in GUI)
    opts.setSeriesOn(i,True)
 
    # point import process reader to this series
    reader.setSeries(i)
 
    # read and process all images in series
    imps = impReader.openImagePlus()
    for imp in imps:
        imp.show()
        wait = Wait(str(i) + imp.getTitle())
        wait.show()
        imp.close()
 
    # deactivate series (otherwise next iteration will have +1 active series)
    opts.setSeriesOn(i, False)
