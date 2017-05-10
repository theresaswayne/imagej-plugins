# @File(label = "Input directory", style = "directory") inputDir
# @File(label = "Output directory", style = "directory") outputDir

# Note: Do not change or remove the first two lines! They provide essential parameters.

# summarize_Results.py
# jython script  by Theresa Swayne, Columbia University, 2017 
# usage: open in Fiji script editor and run (note jython is python 2.7 as of this writing) 

# input: 3 csv files, C1_results, C2_results, [possibly in future, Coloc] (the beginning of the filename must be as given)
# output: one csv file containing summarized data
# if the output file exists then nothing is written to it

# takes results written by the batch cfos-Arc analysis macro and summarize:
# for each image: count particles, and calculate average and SD of (area, mean, intden, rawintden)
# -------------  the input format: 
# 0 rownumber, 1 label, 2 area, 3 mean, 4 min, 5 max, 6 x, 7 y, 8 intden, 9 rawintden
# the label field has the filename; the first 3 chars are the channel (C1-), the last 9 chars are the ROI (:0000-0000)
# C1 and C2 are in separate files

# ----------------- output format
# 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
# 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
# 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)

# TODO: include coloc data 

# ------------------- SETUP

import os, csv, math

NUMCHANNELS = 2 # number of channels in the data

# directory names for testing in Spyder
input_ = "/Users/confocal/Desktop/input"
output_ = "/Users/confocal/Desktop/ output"

# most methods require directory names to be expressed as strings
#input_ = str(inputDir) # underscore to avoid using the name of a function
#output_ = str(outputDir)

# setup for output csv file in output directory
csvPath = output_ + os.sep + "Measurement_Summary.csv"
csvExists = os.path.exists(csvPath)
csvFile = open(csvPath, 'ab') # creates the file. a for append, b for binary (avoiding potential problems with ascii)
csvWriter = csv.writer(csvFile) # this object is able to write to the output file

# write headers of output file
if not csvExists: # avoids appending multiple headers
    headers1 = ['Filename','C1 Whole Image Mean','C1 Whole Image IntDen','C1 Whole Image RawIntDen']
    headers2 = ['C1 Nuc Count','C1 Ave Nuc Area','C1 StdDev Nuc Area','C1 Ave Nuc Mean','C1 StdDev Nuc Mean','C1 Ave Nuc IntDen','C1 StdDev Nuc IntDen','C1 Ave Nuc RawIntDen','C1 StdDev Nuc RawIntDen']
    headers3 = ['C2 Nuc Count','C2 Ave Nuc Area','C2 StdDev Nuc Area','C2 Ave Nuc Mean','C2 StdDev Nuc Mean','C2 Ave Nuc IntDen','C2 StdDev Nuc IntDen','C2 Ave Nuc RawIntDen','C2 StdDev Nuc RawIntDen']
    csvWriter.writerow(headers1+headers2+headers3)
else:
    print("Cannot write to existing file.")

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
    returns a float
    '''
    result = 0.0 # have to use the decimal to make it a float
    total = 0.0
    for num in a:
        total += float(num)
    result = total/(len(a))
    return result

def StdDevOfList(a):
    '''
    calculates the standard deviation
    which is the square root of the variance
    The variance is the average of the squared deviations from the mean
    a: list of numbers
    returns a float
    '''
    
    result = 0.0
    sampleMean = MeanOfList(a)
    sqDevs = 0.0
    
    for num in a:
        sqDevs += (math.fabs(float(num)-sampleMean))**2 # fabs = absolute value
    
    result = math.sqrt(sqDevs/len(a))
        
    return result

# ------------------ READING DATA

# function to find files, create readers, and check the header format
# this will be called twice
 
def getInputFiles(input_dir,channel):
    '''
    finds, checks, and reads input files
    input_dir: the directory containing the files, a string
        ** the filenames must begin with "C1_results", "C2_results", etc.
    channel: the channel number, an integer
    returns the filename for the indicated channel
    this is not necessary if the filenames are simple, 
    but it could be helpful if implementing batch mode later
    '''

    # the correct headers for the table
    DESIREDHEADERS = ["", "Label", "Area", "Mean", "Min", "Max", "X", "Y", "IntDen", "RawIntDen"]

    # the channel name we are looking for
    prefix = "C"+str(channel)+"_results"
    #print("prefix =",prefix)
    
    # search the input directory and subdirectories
    for dirpath, dirnames, resultNames in os.walk(input_dir):

        # find channel file
        for f in resultNames:
            if f.startswith(prefix):
                CFilename = f
    
    # open the file read-only
    CPath = os.path.join(input_,CFilename)
    with open(CPath, 'rU') as CFile: # r for read-only, U = universal newline format, 'with' to auto-close file
        CReader = csv.reader(CFile)
    
        # check that the results are in the correct format
        CHeaders = []
        i = 0
        for row in CReader:
            if i == 0:
                CHeaders = row
                break # avoids reading entire file
            i += 1
        
        for i in range(len(CHeaders)):
            if CHeaders[i] != DESIREDHEADERS[i]:
                raise ValueError, ("Results table is in unexpected order: at column",i,"expected",DESIREDHEADERS[i],", found",CHeaders[i])
        # print("table for channel",str(channel),"is in good format")

    return CFilename

Filenames = [] # a list to store the channel result filenames and access them by index
for i in range (1, NUMCHANNELS+1):
    #print("reading channel",i)
    Filenames.append(getInputFiles(input_,i))

# open the C1 file and read the data into a list
C1Filename = Filenames[0]
C1Path = os.path.join(input_,C1Filename)
C1Data = []
with open(C1Path, 'rU') as C1File: # r for read-only, U = universal newline format, 'with' to auto-close file
    C1Reader = csv.reader(C1File)
    C1Reader.next() # skip the header row
    for row in C1Reader:
        C1Data.append(row)
        
# open the C2 file and read the data into a list
C2Filename = Filenames[1]
C2Path = os.path.join(input_,C2Filename)
C2Data = []
with open(C2Path, 'rU') as C2File: # r for read-only, U = universal newline format, 'with' to auto-close file
    C2Reader = csv.reader(C2File)
    C2Reader.next() # skip the header row
    for row in C2Reader:
        C2Data.append(row)

# ------------------- TRANSFERRING DATA 

# TODO: What if an image has no nuclei in C1? Need to collect all the filenames from both channels

# collect image names
C1Labels = []

for row in C1Data:
    imageName = row[1] # 2nd column
    #print("label=",imageName)
    try:
        if imageName[-10] == ":" : # it is an ROI measurement
            imageName = imageName[3:-10] # take off channel number and roi info
        else: # it is a whole-image measurement
            imageName = imageName[3:]
    except IndexError: # in case the whole filename is shorter than 10
        imageName = imageName[3:]
    C1Labels.append(imageName)

# get a list of unique filenames
imageList = uniqueElements(C1Labels)
numRows = len(C1Labels)
numFiles = len(imageList)
#print("In",numRows,"rows of data there are",numFiles,"unique filenames")
print(imageList)


# gather the data from one image -- rows with same image name
for image in imageList:  # each file in the data batch

    #Start a list to hold the summary data row. It should be filled with zeroes so we can fill in data for it of order
    imageSummary = [0 for i in range(22)] # number of columns in desired output
    imageSummary[0] = image

    print("beginning image loop for:", image)
    #print(imageSummary)

    # ---- collect data

    # Collect C1 data
    
    #Start lists to hold nuclei data per image -- mean, area, id, rid
    C1nucAreas = []
    C1nucMeans = []
    C1nucIDs = []
    C1nucRIDs = []

    for row in C1Data: 
        imageLabel = row[1]
        # check if filename is the same 
        if (imageLabel[3:-10] == image or imageLabel[3:] == image):
            # print(imageLabel,"is from image",image)
            # now get the data
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
        # cycle through all the rows then go to the next image name (inefficient but it works)
    
    # collect C2 data

    #Start lists to hold nuclei data per image -- mean, area, id, rid
    C2nucAreas = []
    C2nucMeans = []
    C2nucIDs = []
    C2nucRIDs = []
    
    for row in C2Data: 
        imageLabel = row[1]
        # check if filename is the same 
        if (imageLabel[3:-10] == image):
            # print(imageLabel,"is from image",image)
            # now get the data
            if ":" in imageLabel: # it's a nucleus
                C2nucAreas.append(row[2])
                C2nucMeans.append(row[3])
                C2nucIDs.append(row[8])
                C2nucRIDs.append(row[9])  

        # finished collecting data from this image
        
    # ------------------CALCULATING STATISTICS
    # 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
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

    csvWriter.writerow(imageSummary)





# TODO: clean up and add comments as needed

# ----------------- FINISHING

csvFile.close() # closes the output file so it can be used elsewhere





        