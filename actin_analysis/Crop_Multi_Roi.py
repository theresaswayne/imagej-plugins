# @Boolean(label="Do you want to display cropped images ?", required=False) show_cropped
# @Boolean(label="Do you want to save cropped images ?", required=False) save_cropped

# @ImageJ ij
# @Dataset dataset
# @OpService ops
# @DatasetIOService ioservice
# @DatasetService datasetservice

from net.imglib2.util import Intervals
from net.imagej.axis import Axes

from ij.plugin.frame import RoiManager

import os


def main():

    # Get image path
    fname = dataset.getSource()
    dir_path = os.path.dirname(fname)

    if not fname:
        ij.ui().showDialog('Source image needs to match a file on the system.'
                           'Please save your image on the disk.')
        return

    # Get ROIManager
    rm = RoiManager.getInstance()
    if not rm:
        ij.ui().showDialog("Use ROI Manager tool (Analyze>Tools>ROI Manager...).")
        return

    # Get image info
    x_len = dataset.dimension(dataset.dimensionIndex(Axes.X))
    y_len = dataset.dimension(dataset.dimensionIndex(Axes.Y))
    z_len = dataset.dimension(dataset.dimensionIndex(Axes.Z))
    c_len = dataset.dimension(dataset.dimensionIndex(Axes.CHANNEL))
    t_len = dataset.dimension(dataset.dimensionIndex(Axes.TIME))

    print(dataset.dimensionIndex(Axes.X))

    ij.log().info('Image filename is %s' % fname)
    ij.log().info('Detected dimensions : ')
    ij.log().info('\tx = %i\n\ty = %i\n\tz = %i\n\tc = %i\n\tt = %i' % (x_len, y_len,
                                                                         z_len, c_len,
                                                                         t_len))
                                                                         
    rois = rm.getRoisAsArray()
    ij.log().info("Detected %i ROIs" % len(rois))
    ij.log().info("Start cropping")

    img = dataset.getImgPlus()
    
    for i, roi in enumerate(rois):

        crop_id = i + 1
        ij.log().info("Croping %i / %i" % (crop_id, len(rois)))

        # Get filename and basename of the current cropped image
        crop_basename = "crop%i_%s" % (crop_id, dataset.getName())
        crop_basename = os.path.splitext(crop_basename)[0] + ".ome.tif"
        crop_fname = os.path.join(os.path.dirname(fname), crop_basename)

        # Get bounds and crop
        bounds = roi.getBounds()

        x1 = bounds.x
        y1 = bounds.y
        x2 = x1 + bounds.width
        y2 = y1 + bounds.height

        # TODO: dynamic intervals for cropping any n-D stack images
        intervals = Intervals.createMinMax(x1, y1, 0, x2, y2, t_len - 1)
        cropped_img = ops.image().crop(img, intervals)
        cropped_img.setName(crop_basename)

        cropped_dataset = datasetservice.create(cropped_img)

        # Show cropped image
        if show_cropped:
            ij.ui().show(cropped_dataset)

        # Save cropped image
        if save_cropped:
            ij.log().info("Saving crop to %s" % crop_fname)
            ioservice.save(cropped_dataset, crop_fname)

    ij.log().info("%i crop images have been saved in %s" % (len(rois), os.path.dirname(fname)))
    ij.log().info('Done.')

main()