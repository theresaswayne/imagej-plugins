# @File(label = "Input directory", style = "directory") inputDir
# @File(label = "Output directory", style = "directory") outputDir

# Note: Do not change or remove the first two lines! They provide essential parameters.

# summarize_Results.py
# Jython script by Theresa Swayne, Columbia University, 2017 
# usage: open in Fiji script editor, and run (note jython uses python 2.7 as of this writing) 

# Input: 3 csv files in the input directory: 
# C1_results, C2_results, Coloc (the beginning of the filename must be as given)
# Output: one csv file containing summarized data
# If the output file exists, then more data is appended to it

# The input files should be written by the batch cfos-Arc analysis script.
# For each image this script gives the cell count, average and SD of area, mean, intden, and rawintden
# as well as the whole-image measurement for channel 1 and the colocalization data.

# -------------  Required input columns: 
# for channel results:
# 0 rownumber, 1 label, 2 area, 3 mean, 4 min, 5 max, 6 x, 7 y, 8 intden, 9 rawintden
# the label field has the filename; the first 3 chars are the channel (C1-), the last 9 chars are the ROI (:0000-0000)
# C1 and C2 are in separate files

# for coloc results:
# 0 Filename, 1 Channel, 2 Total Cells, 3 Colocalized Cells, 4 Fraction Colocalized

# ----------------- Output columns:
# 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
# 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
# 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)
# 22 Overlapping nuclei, 23 Fraction C1 with C2, 24 Fraction C2 with C1

# ------------------- SETUP

import os, csv, math, sys
NUMCHANNELS = 2 # number of channels in the data

# for testing outside Fiji
#input_ = "/Users/confocal/Desktop/input"
#output_ = "/Users/confocal/Desktop/ output"

# most methods require directory names to be expressed as strings
input_ = str(inputDir) # underscore to avoid using the name of a function
output_ = str(outputDir)

# setup output file
csvPath = output_ + os.sep + "Measurement_Summary.csv"
csvExists = os.path.exists(csvPath)
csvFile = open(csvPath, 'ab') # creates the file. a for append, b for binary (avoiding potential problems with ascii)
csvWriter = csv.writer(csvFile) # this object is able to write to the output file

# add headers to output file
if not csvExists: # avoids appending multiple headers
    headers1 = ['Filename','C1 Whole Image Mean','C1 Whole Image IntDen','C1 Whole Image RawIntDen']
    headers2 = ['C1 Nuc Count','C1 Ave Nuc Area','C1 StdDev Nuc Area','C1 Ave Nuc Mean','C1 StdDev Nuc Mean','C1 Ave Nuc IntDen','C1 StdDev Nuc IntDen','C1 Ave Nuc RawIntDen','C1 StdDev Nuc RawIntDen']
    headers3 = ['C2 Nuc Count','C2 Ave Nuc Area','C2 StdDev Nuc Area','C2 Ave Nuc Mean','C2 StdDev Nuc Mean','C2 Ave Nuc IntDen','C2 StdDev Nuc IntDen','C2 Ave Nuc RawIntDen','C2 StdDev Nuc RawIntDen']
    headers4 = ['Overlapping Nuclei','Fraction C1 with C2','Fraction C2 with C1']
    csvWriter.writerow(headers1+headers2+headers3+headers4)
else:
    print("Appending to existing file.")

# ---- helper functions for making file lists

def uniqueElements(seq):
    '''
    helper function 1 of 2 for removing duplicates in a list
    seq: a list
    returns: a list of unique elements of seq, 
    preserving the order in which they were encountered
    '''
    return list(_uniqueElements(seq))

def _uniqueElements(seq):
    '''
    helper function 2 of 2 for removing duplicates in a list
    seq: a list
    yields: a list of unique elements of seq, 
    preserving the order in which they were encountered
    '''
    seen = set()
    for x in seq:
        if x in seen:
            continue
        seen.add(x)
        yield x

# ---- helper functions for statistics

def MeanOfList(a):
    '''
    calculates the average
    a: list of numbers
    returns a float, or "undefined" if list is empty
    '''
    if len(a) == 0: # avoid div by 0 error with empty list
        return "undefined"

    result = 0.0 # the decimal makes it a float
    total = 0.0
    for num in a:
        total += float(num)
    result = total/(len(a))
    return result

def StdDevOfList(a):
    '''
    calculates the standard deviation
    = square root of variance
    variance is defined as the average of the squared deviations from the mean
    Note: this is the same as Excel STDEV.P -- uncorrected population stdev
    a: list of numbers
    returns: float
    '''
    if len(a) == 0: # avoid div by 0 error with empty list
        return "undefined"

    result = 0.0
    sampleMean = MeanOfList(a)
    sqDevs = 0.0
    
    for num in a:
        sqDevs += (math.fabs(float(num)-sampleMean))**2 # fabs = absolute value
    
    result = math.sqrt(sqDevs/len(a))
        
    return result

# ------------------ READING DATA
 
def getInputFiles(input_dir,channel):
    '''
    Finds, checks, and reads channel results files.
    This is not necessary if the filenames are simple, 
    but it could be helpful if implementing batch mode later.
    input_dir: the directory containing the files, a string
        ** the filenames must begin with "C1_results", "C2_results", etc.
    channel: the channel number, an integer
    returns: the filename for the indicated channel
    If the format is incorrect, the script ends.
    '''
    # required headers for the results file
    DESIREDHEADERS = ["", "Label", "Area", "Mean", "Min", "Max", "X", "Y", "IntDen", "RawIntDen"]

    # channel name we are looking for
    prefix = "C"+str(channel)+"_results"
    
    # search input directory and subdirectories
    for dirpath, dirnames, resultNames in os.walk(input_dir):

        # find channel file
        for f in resultNames:
            if f.startswith(prefix):
                CFilename = f
    
    # open file
    CPath = os.path.join(input_,CFilename)
    with open(CPath, 'rU') as CFile: # r = read-only, U = universal newline format, 'with' to auto-close file
        CReader = csv.reader(CFile)
    
        # gather headers from results file
        CHeaders = []
        i = 0
        for row in CReader:
            if i == 0:
                CHeaders = row
                break # avoids reading entire file
            i += 1
            
        # verify columns exist in required order
        for i in range(len(CHeaders)):
            try:
                if CHeaders[i] != DESIREDHEADERS[i]:
                    raise ValueError, ("Results table is in unexpected order: at column",i,"expected",DESIREDHEADERS[i],", found",CHeaders[i])
                    print("Ending script")
                    sys.exit()
            except IndexError:
                print("Results table has unexpected headers: expected",len(DESIREDHEADERS),", found",len(CHeaders))
                print("Ending script")
                sys.exit()

    return CFilename


Filenames = [] # channel result filenames
for i in range (1, NUMCHANNELS+1):
    Filenames.append(getInputFiles(input_,i))

# Read C1 data
C1Filename = Filenames[0]
C1Path = os.path.join(input_,C1Filename)
C1Data = []
with open(C1Path, 'rU') as C1File: # r for read-only, U = universal newline format, 'with' to auto-close file
    C1Reader = csv.reader(C1File)
    C1Reader.next() # skip header row
    for row in C1Reader:
        C1Data.append(row)
        
# Read C2 data
C2Filename = Filenames[1]
C2Path = os.path.join(input_,C2Filename)
C2Data = []
with open(C2Path, 'rU') as C2File: # r for read-only, U = universal newline format, 'with' to auto-close file
    C2Reader = csv.reader(C2File)
    C2Reader.next() # skip header row
    for row in C2Reader:
        C2Data.append(row)

# Read Coloc data
ColocPath = os.path.join(input_,"Coloc.csv")
ColocData = []
with open(ColocPath, 'rU') as ColocFile: # r for read-only, U = universal newline format, 'with' to auto-close file
    ColocReader = csv.reader(ColocFile)
    ColocReader.next() # skip header row
    for row in ColocReader:
        ColocData.append(row)

# ------------------- TRANSFERRING DATA 

# collect image names from both channel files
Labels = []
for row in C1Data:
    imageName = row[1] # 2nd column
    try:
        if imageName[-10] == ":" : # it is an ROI measurement
            imageName = imageName[3:-10] # take off channel number and roi info
        else: # it is a whole-image measurement
            imageName = imageName[3:]
    except IndexError: # in case the whole filename is shorter than 10
        imageName = imageName[3:]
    Labels.append(imageName)
    
for row in C2Data:
    imageName = row[1] # 2nd column
    try:
        if imageName[-10] == ":" : # it is an ROI measurement
            imageName = imageName[3:-10] # take off channel number and roi info
    except IndexError: # in case the whole filename is shorter than 10
        imageName = imageName[3:]
    Labels.append(imageName)

# remove duplicates from the list
imageList = uniqueElements(Labels)
numRows = len(Labels)
numFiles = len(imageList)

# consolidate all the data from each image
for image in imageList:  # each loop collects data from one image file

    print("processing", image)

    # summary of all data for an image, filled with zeroes so we can fill in specific columns
    imageSummary = [0 for i in range(25)] # number of columns in desired output

    # fill in the image name
    imageSummary[0] = image

    # collect C1 data
    
    C1nucAreas = []
    C1nucMeans = []
    C1nucIDs = []
    C1nucRIDs = []

    for row in C1Data: 
        imageLabel = row[1]
        # check if filename is the same 
        if (imageLabel[3:-10] == image or imageLabel[3:] == image):
            # get the data
            if ":" in imageLabel: # it's a nucleus
                C1nucAreas.append(row[2])
                C1nucMeans.append(row[3])
                C1nucIDs.append(row[8])
                C1nucRIDs.append(row[9])
            elif imageLabel[3:] == image: # it's the whole image measurement
                imageSummary[1] = row[3] # whole image mean, id, rid
                imageSummary[2] = row[8]
                imageSummary[3] = row[9]    

        # finished collecting data from this image
        # will cycle through all rows then go to the next image name
    
    # collect C2 data

    C2nucAreas = []
    C2nucMeans = []
    C2nucIDs = []
    C2nucRIDs = []
    
    for row in C2Data: 
        imageLabel = row[1]
        # check if filename is the same 
        if (imageLabel[3:-10] == image):
            # get the data
            if ":" in imageLabel: # it's a nucleus
                C2nucAreas.append(row[2])
                C2nucMeans.append(row[3])
                C2nucIDs.append(row[8])
                C2nucRIDs.append(row[9])  

    # collect Coloc data
    
    for row in ColocData:
        imageLabel = row[0]
        if (imageLabel[3:] == image):
            if row[1] == "1":
                imageSummary[22] = row[3] # colocalized cells
                imageSummary[23] = row[4] # C1 with C2
            elif row [1] == "2":
                imageSummary[24] = row[4] # C2 with C1
        
    # ------------------ CALCULATING STATISTICS
    # Output columns:
    # 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
    # 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)

    imageSummary[4] = len(C1nucAreas)
    imageSummary[5] = MeanOfList(C1nucAreas)
    imageSummary[6] = StdDevOfList(C1nucAreas)
    imageSummary[7] = MeanOfList(C1nucMeans)
    imageSummary[8] = StdDevOfList(C1nucMeans)
    imageSummary[9] = MeanOfList(C1nucIDs)
    imageSummary[10] = StdDevOfList(C1nucIDs)
    imageSummary[11] = MeanOfList(C1nucRIDs)
    imageSummary[12] = StdDevOfList(C1nucRIDs)
    
    imageSummary[13] = len(C2nucAreas)
    imageSummary[14] = MeanOfList(C2nucAreas)
    imageSummary[15] = StdDevOfList(C2nucAreas)
    imageSummary[16] = MeanOfList(C2nucMeans)
    imageSummary[17] = StdDevOfList(C2nucMeans)
    imageSummary[18] = MeanOfList(C2nucIDs)
    imageSummary[19] = StdDevOfList(C2nucIDs)
    imageSummary[20] = MeanOfList(C2nucRIDs)
    imageSummary[21] = StdDevOfList(C2nucRIDs)

	# ----------------- WRITING DATA 
    csvWriter.writerow(imageSummary)

# ----------------- FINISHING

csvFile.close() # closes the output file so it can be used elsewhere

print("Finished.")




        