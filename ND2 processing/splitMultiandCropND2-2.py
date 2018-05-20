#@ File (label = "Input file", style = "file") inputFile
#@ File (label = "Output directory", style = "directory") outputDir

# based on example by Harri Jäälinoja at http://imagej.net/Jython_Scripting_Examples#Open_all_series_in_a_LIF_file_with_Bio-Formats

from loci.plugins.in import ImagePlusReader,ImporterOptions,ImportProcess
from loci.plugins import BF

# parse metadata
from loci.formats import ImageReader
from loci.formats import MetadataTools
from loci.common import Region
from loci.plugins.in import ImagePlusReader, ImportProcess, ImporterOptions

inputFile = str(inputFile)

# TODO: get ranges from a dialog

options = ImporterOptions()
options.setId(inputFile)
options.setUngroupFiles(True)
options.setAutoscale(True)

options.setSpecifyRanges(True)

options.setCBegin(1, 1)
options.setCEnd(1, 1)
options.setCStep(1, 1)

options.setZBegin(1, 1)
options.setZEnd(1, 3)
options.setZStep(1, 1)

options.setTBegin(1, 1)
options.setTEnd(1, 8)
options.setTStep(1, 4)

# set up import process
process = ImportProcess(options)
process.execute()
nseries = process.getSeriesCount()
 
# reader belonging to the import process
reader = process.getReader()
 
# reader external to the import process
impReader = ImagePlusReader(process)
for i in range(0, nseries):
    print "%d/%d %s" % (i+1, nseries, process.getSeriesLabel(i))
     
    # activate series (same as checkbox in GUI)
    options.setSeriesOn(i,True)
 
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
    options.setSeriesOn(i, False)
