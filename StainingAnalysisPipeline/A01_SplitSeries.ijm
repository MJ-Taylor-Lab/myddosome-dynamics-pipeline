//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//


//Splits image series into various tiff files

//Folder containing images
#@ File (label = "Input/Output Directory", style = "file") dir

// --- ND2 TO TIFF CONVERSION ---
ext = "nd2";
setBatchMode(true);

//Modify parameters
inFullname = dir;
dir = File.getDirectory(dir);

if (endsWith(inFullname, ext)) {
	    name = File.getName(inFullname);
        lenIndex = lengthOf(name) - 4;
        title = substring(name, 0, lenIndex);
        dir = dir + "/" + title +"/";
        File.makeDirectory(dir);
    splitBioFormatToTif(inFullname, dir);
    print("::: ND2 to TIFF Conversion Finished :::");
}


//Function to convert file type
function splitBioFormatToTif(inFullname, dir) {
    run("Bio-Formats Macro Extensions");
    Ext.setId(inFullname);
    Ext.getSizeT(numT);
    Ext.getSizeC(numC);
    Ext.getSizeZ(numZ);
    Ext.getSeriesCount(numS);

    for (s = 1; s <= numS; s++) {
        coptions = newArray(1, numC, 1);
        toptions = newArray(1, numT, 1);
        zoptions = newArray(1, numZ, 1);
        soptions = s;

        name = File.getName(inFullname);
        lenIndex = lengthOf(name) - 4;
        title = substring(name, 0, lenIndex);

        outName = title + " (series " + leftPad(s, 3) + ")";

        newdir = dir + title + " (series "+ leftPad(s, 3) + ")"+ '/';
        File.makeDirectory(newdir);

        outFullname = newdir + outName + ".tif";
        id = bfImport(inFullname, coptions, zoptions, toptions, soptions);
        selectImage(id);
        saveAs("Tiff", outFullname);
        close();
    }
}

function bfImport(path, channels, z, times, series) {

    run("Bio-Formats Macro Extensions");
    Ext.setId(path);
    dimOrder = "";
    Ext.getDimensionOrder(dimOrder);
    Ext.getSizeC(numC);
    Ext.getSizeT(numT);
    Ext.getSizeZ(numZ);
    Ext.getSeriesName(numS);

    options = "open=[" + path + "] view=[Standard ImageJ] stack_order=" + dimOrder + " virtual specify_range ";
    cOpts = "c_begin=" + channels[0] + " c_end=" + channels[1] + " c_step=" + channels[2];
    zOpts = "z_begin=" + z[0] + " z_end=" + z[1] + " z_step=" + z[2];
    tOpts = "t_begin=" + times[0] + " t_end=" + times[1] + " t_step=" + times[2];
    sOpts = "series_" + series;

    options = options + " " + cOpts + " " + zOpts + " " + tOpts + " " + sOpts;
    print(path + " " + sOpts);
    run("Bio-Formats Importer", options);
    id = getImageID();
    return id;
}


function getExtension(filename) {
    ext = substring(filename, lastIndexOf(filename, ".") + 1);
    return ext;
}

// Converts 'n' to a string, left padding with zeros
// so the length of the string is 'width'
function leftPad(n, width) {
    s = "" + n;
    while (lengthOf(s) < width)
        s = "0" + s;
    return s;
}
print("All done");
wait(4*1000);
print("Timer Up");
wait(1*1000);
run("Quit");
