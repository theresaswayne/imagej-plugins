from ij import IJ
from ij.plugin.filter import RankFilters

imp=IJ.getImage()
ip=imp.getProcessor().convertToFloat()

radius=2
RankFilters().rank(ip, radius, RankFilters.MEDIAN)

imp2=ImagePlus(imp.title+" median filtered",ip)
imp2.show()
