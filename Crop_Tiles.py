#@ Dataset data
#@OUTPUT Dataset output
#@ DatasetService ds
#@ OpService ops
#@File(label="Output directory",style="directory") out_dir
#@ int(label="What size tiles would you like (pixel dimensions?") tileSize

from net.imagej.axis import Axes
from net.imglib2.util import Intervals
import csv, os
from ij import IJ, ImagePlus


# This function helps to crop a Dataset along an arbitrary number of Axes.
# Intervals to crop are specified easily as a Python dict.


def get_axis(axis_type):
    return {
        'X': Axes.X,
        'Y': Axes.Y,
        'Z': Axes.Z,
        'TIME': Axes.TIME,
        'CHANNEL': Axes.CHANNEL,
    }.get(axis_type, Axes.Z)

def crop(ops, data, intervals):
    """Crop along a one or more axis.

    Parameters
    ----------
    intervals : Dict specifying which axis to crop and with what intervals.
                Example :
                intervals = {'X' : [0, 50],
                             'Y' : [0, 50]}
    """

    intervals_start = [data.min(d) for d in range(0, data.numDimensions())]
    intervals_end = [data.max(d) for d in range(0, data.numDimensions())]

    for axis_type, interval in intervals.items():
        index = data.dimensionIndex(get_axis(axis_type))
        intervals_start[index] = interval[0]
        intervals_end[index] = interval[1]

    intervals = Intervals.createMinMax(*intervals_start + intervals_end)

    output = ops.run("transform.crop", data, intervals, True)

    return output


# Define the intervals to be cropped
intervals = {'X': [10, 50],
    'Y': [0, 50]}

# Crop the Dataset
output = crop(ops, data, intervals)

# Create output Dataset
output = ds.create(output)
