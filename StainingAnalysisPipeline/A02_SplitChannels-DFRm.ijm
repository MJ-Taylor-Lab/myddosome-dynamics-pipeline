//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//

//Converts nd2 files to 16-bit TIFF. Also opens up as a dialog.

// --- INPUT ---

//Folder containing images
#@ File (label = "Input/Output Directory", style = "file") dir

//Folder containing dark frame images
#@ File (label = "Dark-Frame Directory", style = "directory") dir_df

//Parameters
#@ String (label = "LUT C=0", value = "Yellow") LUT_0
#@ String (label = "Dark-Field Image Name C=0", value = "AVG_20190715 Cy5 Dark-Field.nd2 - C=0.tif") df_0

#@ String (label = "LUT C=1", value = "Green") LUT_1
#@ String (label = "Dark-Field Image Name C=1", value = "AVG_20190715 GFP Dark-Field.nd2 - C=0.tif") df_1

#@ String (label = "LUT C=2", value = "Magenta") LUT_2
#@ String (label = "Dark-Field Image Name C=2", value = "AVG_20190715 RFP Dark-Field.nd2 - C=0.tif") df_2

//Modify parameters
inFullname = dir;
dir = File.getDirectory(dir);
dir_df = dir_df + "/";
run("Close All");
setBatchMode(true);


print(inFullname);
open(inFullname);
getDimensions(w, h, numC, slices, frames);
name = File.getName(inFullname);
lenIndex = lengthOf(name) - 4;
title = substring(name, 0, lenIndex);
print(title);
run("Make Composite", "display=Composite");
if (numC == 3) {
    run("Split Channels");
    for (c = 1; c <= numC; c++) {
        imgName = "C" + c + "-" + title + ".tif";
        selectImage(imgName);
        outName = title + " C=" + toString(c - 1);

        outFullname = dir + outName + ".tif";
        resetMinAndMax();
        saveAs("Tiff", outFullname);

        close();
    }



    function getFromFileList(ext, fileList) {
        selectedFileList = newArray(fileList.length);
        ext = toLowerCase(ext);
        j = 0;
        for (i = 0; i < fileList.length; i++) {
            extHere = toLowerCase(getExtension(fileList[i]));
            if (extHere == ext) {
                selectedFileList[j] = fileList[i];
                j++;
            }
        }
        selectedFileList = Array.trim(selectedFileList, j);
        return selectedFileList;
    }

    function getExtension(filename) {
        ext = substring(filename, lastIndexOf(filename, ".") + 1);
        return ext;
    }

    print("::: TIFF Splitting Finished :::");

    processFilesDFRm(dir);

    function processFilesDFRm(dir) {
        list = getFileList(dir);
        for (i = 0; i < list.length; i++) {
            if (endsWith(list[i], "/"))
                processFilesDFRm("" + dir + list[i]);
            else {
                path = dir + list[i];
                processFile0DFRm(path); //For C=0
                processFile1DFRm(path); //For C=1
                processFile2DFRm(path); //For C=2
            }
        }
    }

    //C=0 function
    function processFile0DFRm(path) {
        parent = File.getParent(path) + "/";
        img = substring(path, lengthOf(parent), lengthOf(path) - 4);
        if (endsWith(path, " C=0.tif")) {
            //Open image
            open(path);
            //Extract file name
            img = File.nameWithoutExtension();
            open(dir_df + df_0);
            //REMOVE DARK-FIELD
            print("Removing Dark-Field (C=0) from " + img);
            imageCalculator("Subtract create stack", img + ".tif", df_0);
            //Change LUT
            run(LUT_0);
            //Reset brightness and contrast
            resetMinAndMax();
            //Save Dark-Field Removed (DFRm)
            saveAs("Tiff", dir + img + "-DFRm");
            //Close open images
            run("Close All");

        }
    }

    //C=1 function
    function processFile1DFRm(path) {
        parent = File.getParent(path) + "/";
        img = substring(path, lengthOf(parent), lengthOf(path) - 4);
        if (endsWith(path, " C=1.tif")) {
            //Open image
            open(path);
            //Extract file name
            img = File.nameWithoutExtension();
            open(dir_df + df_1);
            //REMOVE DARK-FIELD
            print("Removing Dark-Field (C=1) from " + img);
            imageCalculator("Subtract create stack", img + ".tif", df_1);
            //Change LUT
            run(LUT_1);
            //Reset brightness and contrast
            resetMinAndMax();
            //Save Dark-Field Removed (DFRm)
            saveAs("Tiff", dir + img + "-DFRm");
            //Close open images
            run("Close All");

        }
    }

    //C=2 function
    function processFile2DFRm(path) {
        parent = File.getParent(path) + "/";
        img = substring(path, lengthOf(parent), lengthOf(path) - 4);
        if (endsWith(path, " C=2.tif")) {
            //Open image
            open(path);
            //Extract file name
            img = File.nameWithoutExtension();
            open(dir_df + df_2);
            //REMOVE DARK-FIELD
            print("Removing Dark-Field (C=2) from " + img);
            imageCalculator("Subtract create stack", img + ".tif", df_2);
            //Change LUT
            run(LUT_2);
            //Reset brightness and contrast
            resetMinAndMax();
            //Save Dark-Field Removed (DFRm)
            saveAs("Tiff", dir + img + "-DFRm");
            //Close open images
            run("Close All");
        }
    }
    run("Close All");
print("All done");
wait(4*1000);
print("Timer Up");
wait(1*1000);
run("Quit");