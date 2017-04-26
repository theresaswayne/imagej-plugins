# @File(label = "Input directory", style = "directory") inputDir
# @File(label = "Output directory", style = "directory") outputDir

# Note: Do not change or remove the first two lines! They provide essential parameters.

# summarize_Results.py
# jython script  by Theresa Swayne, Columbia University, 2017 
# usage: open in Fiji script editor and run (note jython is python 2.7 as of this writing) 

# input: 3 csv files, C1_results, C2_results, [possibly in future, Coloc] (the beginning of the filename must be as given)
# output: one csv file containing summarized data

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

# most methods require directory names to be expressed as strings
input_ = str(inputDir) # underscore to avoid using the name of a function
output_ = str(outputDir)

# setup for output csv file in output directory
csvPath = output_ + os.sep + "Measurement_Summary.csv"
csvExists = os.path.exists(csvPath)
csvFile = open(csvPath, 'ab') # creates the file. a for append, b for binary (avoiding certain potential problems with ascii)
csvWriter = csv.writer(csvFile) # this object is able to write to the output file

# write headers of output file
if not csvExists: # avoids appending multiple headers
    headers = ['Original path','Processed path']
    csvWriter.writerow(headers)

# ------------------ READING DATA

# get all the filenames in the input directory
for dirpath, dirnames, resultNames in os.walk(input_):

	# find C1 file: look for csv with name starting with C1_results
	for f in resultNames:
		if f.startswith("C1_results"):
			C1Filename = f
		elif f.startswith("C2_results"):
			C2Filename = f

# open the C1 file read-only
C1Path = os.path.join(input_,C1Filename)
C1File = open(C1Path, 'rU') # r for read-only, b for binary (avoiding certain potential problems with ascii), U = universal newline format
C1Reader = csv.reader(C1File)

# check that the results are in the correct format
C1Headers = []
i = 0
for row in C1Reader:
	if i == 0:
		C1Headers = row
		break # avoids reading entire file
	i += 1

desiredHeaders = ["", "Label", "Area", "Mean", "Min", "Max", "X", "Y", "IntDen", "RawIntDen"]
for i in range(len(C1Headers)):
	if C1Headers[i] != desiredHeaders[i]:
		raise ValueError, ("Results table is in unexpected order: at column",i,"expected",desiredHeaders[i],", found",C1Headers[i])


print("table is in good format")
# create empty list to hold C1 image names
C1Labels = []
# read the labels which should be column 0
#	C1labels.append


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
C1File.close() # closes the input file 




        