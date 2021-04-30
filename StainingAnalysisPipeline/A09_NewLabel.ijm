//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//

//Folder containing images
#@ File (label = "Input/Output Directory", style = "directory", value = "~/ImageAnalysisWorkflow/01_TIFF-Subtract") dir

//Parameters
#@ int (label = "Nucleus Channel", value = "0") Marker_Channel
#@ int (label = "Stain Channel", value = "1") Measuring_Channel

// --- TIFF SPLIT ---
dir = dir + "/";
parent_dir = dir
run("Close All");
roiManager("reset");
run("Clear Results");
run("Set Measurements...", "area mean min centroid fit redirect=None decimal=3");

setBatchMode(true);

processSegmentation(dir);

//Segmentation function
function processSegmentation(dir) {
  list = getFileList(dir);
  for (i=0; i<list.length; i++) {
	  if (endsWith(list[i], "/"))
		  processSegmentation(""+dir+list[i]);
	  else {
		path = dir+list[i];
		roiManager("reset");
		close("Results");
		 //if (endsWith(path, " C=0-DFRm-FFMedRm.tif")) {
		 if (endsWith(path, "FilteredNucleus.zip")) {
		 	 //Get parent directory and image name
		 	 parent = File.getParent(path)+"/";
		 	 img = File.getName(parent);
		 	 print(img);
		 	 //img = substring(path, lengthOf(parent), lengthOf(path)-21);
		 	 		 	 
		 	 //Open nucleus
		 	 open(parent + img + " C="+Marker_Channel+"-DFRm-FFMedRm.tif");
		 	 rename("Marker");
		 	 run("Magenta");
		 	 run("Enhance Contrast", "saturated=0.35");
		 	 run("Enhance Contrast", "saturated=0.35");

		 	 //Open stain
		 	 open(parent + img + " C="+Measuring_Channel+"-DFRm-FFMedRm.tif");
		 	 rename("Mask");
		 	 run("Green");
		 	 run("Enhance Contrast", "saturated=0.35");
		 	 run("Enhance Contrast", "saturated=0.35");
		 	 
		 	 //Merge channels
		 	 run("Merge Channels...", "c2=Marker c6=Mask create");
		 	 rename("Composite");
		 	 run("Flatten");
		 	 rename("Watershed");
		 	 
		 	 roiManager("Open", parent + "FilteredCytosol.zip");
		 	 roiManager("Show All without labels");
		 	 roiManager("Set Color", "yellow");
		 	 run("Flatten");
		 	 roiManager("reset");
		 	 rename("WatershedMarked");
		 	 
		 	 roiManager("Open", parent + "FilteredNucleus.zip");
		 	 roiManager("Set Color", "cyan");
		 	 roiManager("Show All with labels");
		 	 
		 	 run("Flatten");
		 	 save(parent + img + " NewBoundaries.tif");
		 	 roiManager("reset");
		 	 run("Clear Results"); 
		 	 run("Close All");	 

		 }
   }
  }
}
print("All done");
wait(2*1000);
print("Timer Up");
wait(1*1000);
run("Quit");

