//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//

//Folder containing images
#@ File (label = "Input/Output Directory", style = "directory", value = "~/ImageAnalysisWorkflow/01_TIFF-Subtract") dir

//Parameters
#@ int (label = "Marker Channel", value = "0") Marker_Channel
#@ int (label = "Mask Channel", value = "2") Mask_Channel
#@ int (label = "Measuring Channel", value = "1") Measuring_Channel

// --- TIFF SPLIT ---
dir = dir + "/";
parent_dir = dir
run("Close All");
roiManager("reset");
run("Clear Results");
run("Set Measurements...", "area mean min centroid fit redirect=None decimal=4");

setBatchMode(true);

processSegmentation(dir);

//Segmentation function
function processSegmentation(dir) {
    list = getFileList(dir);
    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], "/"))
            processSegmentation(dir + list[i]);
        else {
            path = dir + list[i];
            roiManager("reset");
            close("Results");
            IJ.redirectErrorMessages();
            if (endsWith(path, " C=0-DFRm-FFMedRm.tif")) {
                IJ.redirectErrorMessages();
                //Get parent directory and image name
                parent = File.getParent(path) + "/";
                img = substring(path, lengthOf(parent), lengthOf(path) - 21);
                print("Working on " + img);
                //Make marker
                open(parent + img + " C=" + Marker_Channel + "-DFRm-FFMedRm.tif");
                rename("Original-Marker");
                run("mpl-inferno");
                run("Median...", "radius=5");
                run("Enhance Contrast", "saturated=0.35");
                run("8-bit");
                run("Extended Min & Max", "operation=[Extended Minima] dynamic=50 connectivity=4");
                run("Watershed");
                rename("Marker");
                run("Invert LUT");
                run("Invert");

                //Save marker ROI
                run("Analyze Particles...", "display clear add");
                array1 = newArray("0");
                for (i = 1; i < roiManager("count"); i++) {
                    array1 = Array.concat(array1, i);
                }
                //Save ROI
                roiManager("select", array1);
                run("Select All");
                roiManager("Save", parent + "Marker.zip");
                save(parent + img + " Marker.tif");
                close("Original-Marker");

                //Record nucleus info
                open(parent + img + " C=" + Measuring_Channel + "-DFRm-FFMedRm.tif");
                roiManager("Show All");
                run("Clear Results");
                roiManager("Measure");
                saveAs("Results", parent + "Nucleus.csv");
                roiManager("reset");
                run("Clear Results");

                //Mask
                open(parent + img + " C=" + Mask_Channel + "-DFRm-FFMedRm.tif");
                rename("Input");
                run("Enhance Contrast", "saturated=0.35");
                run("Median...", "radius=7.5");
                run("Maximum...", "radius=5");
                run("Extended Min & Max", "operation=[Extended Minima] dynamic=4 connectivity=4");
                rename("Mask");
                run("Invert LUT");
                run("Invert");
                run("Fill Holes");
                save(parent + img + " Mask.tif");

                //Watershed
                selectWindow("Input");
                run("Invert LUT");
                run("Invert");
                run("8-bit");
                run("mpl-inferno");
                save(parent + img + " Input.tif");

                run("Marker-controlled Watershed", "input=Input marker=Marker mask=Mask binary calculate use");
                rename("Watershed");
                run("Duplicate...", "title=Colors");
                selectWindow("Watershed");

                setMinAndMax(0, 1);
                setOption("ScaleConversions", true);
                run("8-bit");
                run("Analyze Particles...", "size=0-Infinity display clear add");
                
                if (File.exists(parent + "Watershed.zip")) {} else {
                    //Watershed ROI
                    array1 = newArray("0");
                    for (i = 1; i < roiManager("count"); i++) {
                        array1 = Array.concat(array1, i);
                    }

                    //Save ROI
                    roiManager("select", array1);
                    run("Select All");
                    roiManager("Save", parent + "Watershed.zip");
                }

                //Record nucleus info
                open(parent + img + " C=" + Measuring_Channel + "-DFRm-FFMedRm.tif");
                rename("ToMeasure");
                roiManager("Show All")
                run("Clear Results");
                roiManager("Measure");
                saveAs("Results", parent + "Cytosol.csv");

                selectWindow("Colors");
                run("8-bit");
                run("glasbey");
                save(parent + img + " Watershed.tif");
                roiManager("reset");
                run("Clear Results");
                run("Close All");
            }

        }
    }
}
print("All done");
wait(8*1000);
print("Timer Up");
wait(1*1000);
run("Quit");
