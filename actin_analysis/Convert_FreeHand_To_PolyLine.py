# @Integer(label="Points Density", value=20) points_density
# @Boolean(label="Smooth Line", value=True) smooth
# @StatusService status

from ij.plugin.frame import RoiManager
from ij.gui import Roi
from ij.gui import PolygonRoi


def main():
	
	rm = RoiManager.getInstance()
	rm.runCommand("Deselect")
	if not rm:
		status.warn("Use ROI Manager tool (Analyze>Tools>ROI Manager...).")
		return False
	
	if len(rm.getRoisAsArray()) == 0:
		status.warn("ROI Manager does not have any ROI.")
		return False

	newRois = []
	for i, roi in enumerate(rm.getRoisAsArray()):
		
		# Select only FreeLine/FreeHand ROIs
		if roi.type == Roi.FREELINE:
		
			fp = roi.getInterpolatedPolygon()
			fp = roi.getInterpolatedPolygon(fp.getLength(False) / points_density, smooth)
			newRoi = PolygonRoi(fp, Roi.POLYLINE)
			newRois.append(newRoi)
	
			# Delete old ROI
			rm.select(i)
			rm.runCommand("Delete")

	for roi in newRois:
		# Add new ROI
		rm.addRoi(roi)
	
	rm.runCommand("Deselect")

main()
			