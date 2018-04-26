from ij.gui import GenericDialog

def getOptions():
  gd = GenericDialog("Options")
  gd.addStringField("name", "Untitled")
  gd.addNumericField("alpha", 0.25, 2)  # show 2 decimals
  gd.addCheckbox("optimize", True)
  types = ["8-bit", "16-bit", "32-bit"]
  gd.addChoice("output as", types, types[2])
  gd.addSlider("scale", 1, 100, 100)
  gd.showDialog()
  #
  if gd.wasCanceled():
    print "User canceled dialog!"
    return
  # Read out the options
  name = gd.getNextString()
  alpha = gd.getNextNumber()
  optimize = gd.getNextBoolean()
  output = gd.getNextChoice()
  scale = gd.getNextNumber()
  return name, alpha, optimize, output, scale

options = getOptions()
if options is not None:
  name, alpha, optimize, output, scale = options
  print name, alpha, optimize, output, scale
