# @String(label="Command: ",description="Name field") command

from ij import IJ

IJ.doCommand(command)

print("executed command "+command)
