# summarize_Results.py
#  take results written by the batch cfos-Arc analysis macro and summarize:
# for each image: count particles, and calculate average and SD of (area, mean, intden, rawintden)
# results are in csv format: 
# 0 rownumber, 1 label, 2 area, 3 mean, 4 min, 5 max, 6 x, 7 y, 8 intden, 9 rawintden
# the label field has the filename; the first 3 chars are the channel (C1-), the last 9 chars are the ROI (:0000-0000)
# C1 and C2 are in separate files

# TODO: rethink this, do we really want one line per image?  actually just one line right??

# desired output format
# 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
# 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
# 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)


# ideally add the coloc into this -- next...

# write headers of output csv file

# read in the data (as strings presumably)

# read: first row is headers; use for catching errors (at each step if not the expected header say "file is in wrong format")

# create arrays for C1 and C2 data

# for each line of data:

	# discard the rownumber
	# read the label, take the slice [2:-9] and append to a list of filenames
	# 
