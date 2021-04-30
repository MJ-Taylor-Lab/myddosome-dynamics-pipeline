//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//

//Generates a shading image for later flat-field correction

//Folder containing images
#@ File(label = "Images Directory", style = "directory", value = "~/ImageAnalysisWorkflow/01_TIFF-Subtract") dir
#@ File (label = "Flat-Field Median Image Directory", style = "directory", value = "~/ImageAnalysisWorkflow/01_TIFF-Subtract") dir_FFMed
//Number of channels
#@ double(value=3, min=1, max=100, style="spinner") numC
//Date
#@ double(value=20201009, min=18000000, max=28000000, style="spinner") acquisitionDate

// --- TIFF SPLIT ---
dir = dir + "/";
dir_FFMed = dir_FFMed + "/";
numC = numC - 1;

run("Close All");
setBatchMode(true);

for (c = 0; c <= numC; c++) {
    processFilesFF(dir);
    run("Images to Stack", "name=Stack title=[] use");
    run("Z Project...", "projection=[Average Intensity]");
    saveAs("Tiff", dir_FFMed + acquisitionDate + " C=" + c + "-Avg");
    run("Median...", "radius=100");
    saveAs("Tiff", dir_FFMed + acquisitionDate + " C=" + c + "-Avg-Med");
    run("Close All");
}

function processFilesFF(dir) {
    list = getFileList(dir);
    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], "/"))
            processFilesFF(dir + list[i]);
        else
        if (endsWith(list[i], " C=" + c + "-Avg.tif")) {
            if (indexOf(list[i], acquisitionDate) >= 0) {
                open(dir + list[i]);
            }
        }
    }
}
print("All done");
wait(4*1000);
print("Timer Up");
wait(1*1000);
run("Quit");