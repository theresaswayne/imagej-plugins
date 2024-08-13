#@ Dataset data
#@OUTPUT Dataset output
#@ OpService ops
#@ DatasetService ds

from net.imagej.axis import Axes
from net.imagej.ops import Ops


# TODO: Find number of slices


# Write the output dimensions
new_dimensions = [data.dimension(d) for d in range(0, data.numDimensions()) if d != dim]

# Create the output image
middleSlice = ops.create().img(new_dimensions)

# Create the op and run it
proj_op = ops.op(getattr(Ops.Stats, projection_type), data)
ops.transform().project(projected, data, proj_op, dim)

# Create the output Dataset
output = ds.create(projected)

imp = new Duplicator().run(imp, 1, 2, 14, 14, 1, 1)
IJ.saveAs(imp, "Tiff", "C:/Users/Ben/Downloads/Sci Re pictures/Cropped ROI images/Single slice images/hsp104del_satd_osm_35hs_60REC-001_crop1.tif");