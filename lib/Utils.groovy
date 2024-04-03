public class Utils {
    public static Object formatParamsForInclusion(label, value) {
        if(value != null && !value.isEmpty()) {
            return [(label): value]
        }
        return
    }

    public static String formatFastq1InputForStar(flowCellLaneLibraries) {
        def fastq1s = []
        flowCellLaneLibraries.each { flowCellLaneLibrary ->
            if (flowCellLaneLibrary.fastq1) {
                fastq1s.add(flowCellLaneLibrary.fastq1)
            }
            else {
                throw new Exception("There is no fastq1 defined for library: " + flowCellLaneLibrary.library)
            }
        }

        return fastq1s.join(",")
    }

    public static String formatFastq2InputForStar(flowCellLaneLibraries) {
        def fastq2s = []
        flowCellLaneLibraries.each { flowCellLaneLibrary ->
            if (flowCellLaneLibrary.fastq2) {
                fastq2s.add(flowCellLaneLibrary.fastq2)
            }
            else {
                throw new Exception("There is no fastq2 defined for library: " + flowCellLaneLibrary.library)
            }
        }

        return fastq2s.join(",")
    }

    public static String formatReadGroupInputForStar(sequencingCenter, sequencingPlatform, sampleId, flowCellLaneLibraries) {
        def readGroups = defineReadGroups(sequencingCenter, sequencingPlatform, sampleId, flowCellLaneLibraries)
        return readGroups.join(" , ")
    }
    
    public static defineReadGroups(sequencingCenter, defaultSequencingPlatform, sampleId, flowCellLaneLibraries) {
        // Set up default values 
        def defaultFlowCell = "FlowCell"
        def defaultLane = "Lane"
        def defaultLibraryPrefix = "Library"
        def defaultDate = new Date().format('yyyy-MM-dd')
 
        def readGroups = []
        flowCellLaneLibraries.eachWithIndex { flowCellLaneLibrary, index ->
            // Set up the values need to build the tags            
            def flowCell = flowCellLaneLibrary.flowCell ? flowCellLaneLibrary.flowCell : defaultFlowCell
            def lane = flowCellLaneLibrary.lane ? flowCellLaneLibrary.lane : defaultLane
            def library = flowCellLaneLibrary.library ? flowCellLaneLibrary.library : defaultLibraryPrefix + index
            def dateString = flowCellLaneLibrary.runDate ? flowCellLaneLibrary.runDate : defaultDate
            def sequencingPlatform = flowCellLaneLibrary.sequencingPlatform ? flowCellLaneLibrary.sequencingPlatform : defaultSequencingPlatform

            // Create the tags 
            def readGroupTags = []
            readGroupTags.add("ID:" + flowCell + "." + lane  + "." + library)
            readGroupTags.add("CN:" + sequencingCenter)
            readGroupTags.add("PL:" + sequencingPlatform)
            readGroupTags.add("PU:" + flowCell + "." + lane  + "." + library)
            readGroupTags.add("LB:" + library)
            readGroupTags.add("SM:" + sampleId)
            readGroupTags.add('"DT:' + dateString + '"')

            // Create the read group to the 
            readGroups.add(readGroupTags.join(" "))
        }

        return readGroups
    }
}