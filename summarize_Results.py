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
# the input results are in csv format: 
# 0 rownumber, 1 label, 2 area, 3 mean, 4 min, 5 max, 6 x, 7 y, 8 intden, 9 rawintden
# the label field has the filename; the first 3 chars are the channel (C1-), the last 9 chars are the ROI (:0000-0000)
# C1 and C2 are in separate files

# desired output format
# 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
# 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
# 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)

# TODO: include coloc data 

# ------------------- SETUP

import os, csv

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
    headers = ['This','That']
    csvWriter.writerow(headers)
else:
    print("Cannot write to existing file.")

def uniqueElements(seq):
    '''
    helper functions for removing duplicates in a list
    seq: a list
    returns: a list of unique elements of seq, 
    preserving the order in which they were encountered
    '''
    return list(_uniqueElements(seq))

def _uniqueElements(seq):
    seen = set()
    for x in seq:
        if x in seen:
            continue
        seen.add(x)
        yield x

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
      
# TODO: consider creating an object for each image, and storing attributes therein. after all we are collecting exactly that, attributes of an image. 
# including sub-objects = channels, and each channel has a bunch of similar attributes

# create empty list to hold C1 image names
C1Labels = []
# read the labels which should be column 1
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

# TODO : gather the data from one image -- rows with same image name
AllImagesNucArea = []
ImageNucArea = []
AllImagesMean = []
for image in imageList:
    for row in C1Data:
        imageName = row[1]
        #print(imageName)
        if ":" in imageName: # it's a nucleus
            if imageName[3:-10] == image: # it's the same image
                ImageNucArea.append(row[2])
        elif imageName[3:] == image:
            AllImagesMean.append(row[3])
    AllImagesNucArea.append(ImageNucArea)
    
print(AllImagesMean)
# TODO: check these values, make sure they are getting the correct rows and columns!


# ------------------- TRANSFERRING DATA 
# for each line of data:

    # discard the rownumber
    # read the label, take the slice [2:-9] and append to a list of filenames


# ------------------CALCULATING STATISTICS

# for each image (matching filename in the results, if it is an roi and not the whole image):
# count particles, and calculate average and SD of (area, mean, intden, rawintden)
# use the data arrays previously obtained

# write the derived values into the data table

# ----------------- FINISHING

csvFile.close() # closes the output file so it can be used elsewhere





        