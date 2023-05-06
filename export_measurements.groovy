//SuperFast Cell Measurement Export

// Some kind of file path for the current image
def name = getProjectEntry().getImageName()
name = GeneralTools.getNameWithoutExtension(name)
def path = buildFilePath(PROJECT_BASE_DIR, name + '.csv')

//Convert pixel width/height to microns
double pixelWidth = getCurrentServer().getPixelCalibration().getPixelWidthMicrons()
double pixelHeight = getCurrentServer().getPixelCalibration().getPixelHeightMicrons()


// Get cells and define measurements to export
def cells = getCellObjects()
def measurements = ['Image','Object ID','Name','Class','Parent','ROI',
	'Centroid X µm', 'Centroid Y µm', 'Area'
]

try (def writer = new PrintWriter(path)) {

    // Use StringBuilder so we write a line at a time
    def sb = new StringBuilder()

    // Write header, add Class, Centroid X, Centroid Y columns
    sb.append('Class')
        .append(',')
        .append('Centroid X')
        .append(',)
        .append('Centroid Y')
    for (def measurementName in measurements) {
        sb.append(',')
        sb.append(measurementName)
    }
    writer.println(sb.toString())
    
    
    // Write X/Y coordinates for nucleus centroid, then measurements per cell
    for (def cell in cells) {
        sb.setLength(0)
        sb.append(cell.getPathClass())
        sb.append('\t')
                .append(cell.getNucleusROI().getCentroidX() * pixelWidth)
                .append('\t')
                .append(cell.getNucleusROI().getCentroidY() * pixelHeight)
        for (def measurementName in measurements) {
            sb.append('\t')
            sb.append(cell.getMeasurementList().getMeasurementValue(measurementName))
        }
        writer.println(sb.toString())
    }
    
}

println "Written to $path"