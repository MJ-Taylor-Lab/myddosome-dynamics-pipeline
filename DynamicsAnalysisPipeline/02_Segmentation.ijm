//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//

//Segments cells using watershed segmentation. Also opens up as a dialog.
//Note: Sometimes FIJI interprets the mask as the region where there's no cells
//To correct this, set: Invert LUT as true (checked)


// --- INPUT ---

//Folder containing images
#@ File (label = "Input directory", style = "directory", value = "~/ImageAnalysisWorkflow/02_Segmentation") dir

//Parameters
#@ Boolean (label = "Run segmentation on C=0", value = true) runSegmentationC0
#@ Boolean (label = "Run segmentation on C=1", value = true) runSegmentationC1
#@ Boolean (label = "Run segmentation, only one channel available", value = false) runSegmentation

// --- SEGMENT --
dir = dir + "/";
requires("1.33s"); 
setBatchMode(true);

//Reset ROI
roiManager("reset");
run("Clear Results");

//Get file list
count = 0;
countFiles(dir);
n = 0;

//Apply segmentation function
processFiles(dir);

print(count+" files processed");

run("Options...", "iterations=1 count=1 black");

// --- FUNCTIONS ---

//File list function
function countFiles(dir) {
  list = getFileList(dir);
  for (i=0; i<list.length; i++) {
	  if (endsWith(list[i], "/"))
		  countFiles(""+dir+list[i]);
	  else
		  count++;
  }
}

//Segmentation function
function processFiles(dir) {
  list = getFileList(dir);
  for (i=0; i<list.length; i++) {
	  if (endsWith(list[i], "/"))
		  processFiles(""+dir+list[i]);
	  else {
		 showProgress(n++, count);
		 path = dir+list[i];
		 if (runSegmentationC0 == true)
		 	processSegmentation0(path); //Images with more than one channel. Segment using C=0
		 if (runSegmentationC1 == true)
		 	processSegmentation1(path); //Images with more than one channel. Segment using C=1
		 if (runSegmentation == true)
		 	processSegmentation1ch(path); //Images with only one channel. Doesn't contain "C=" in file name
	  }
  }
}

//C=0 function
function processSegmentation0(path) {
   if (endsWith(path, " C=0-DFRm.tif")) {
		//Get parent directory and image name
		parent = File.getParent(path) + "/";
		img = substring(path, lengthOf(parent), lengthOf(path)-13);
		
		//Open Image
		open(parent + img + " C=0-DFRm.tif");

			//INPUT
		run("Grouped Z Project...", "projection=[Max Intensity] group="+nSlices);
		rename("Input");
		run("Enhance Contrast", "saturated=0.33");
		run("Gamma...", "value=0.33");
		run("Gaussian Blur...", "sigma=1 scaled");
		run("Gamma...", "value=0.33");
		run("Enhance Contrast", "saturated=0.35");
		run("8-bit");

		//MARKER
		run("Extended Min & Max", "operation=[Extended Maxima] dynamic=30 connectivity=4");
		rename("Marker");
		run("Invert LUT");

		//MASK
		selectWindow("Input");
		run("Duplicate...", "title=MaskInv");
		run("Maximum...", "radius=10");
		run("Gaussian Blur...", "sigma=2 scaled");
		run("Maximum...", "radius=5");
		run("Gamma...", "value=1");
		run("Enhance Contrast", "saturated=0.35");
		run("Gamma...", "value=1");
		run("Enhance Contrast", "saturated=0.35");
		run("Make Binary");
		run("Duplicate...", "title=MaskReg");
		run("Maximum...", "radius=10");
		selectWindow("Input");
		run("Invert");
		run("Invert LUT");
		
		//WATERSHED
		
		run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskReg binary calculate use");
		setMinAndMax(0, 1);
		setOption("ScaleConversions", true);
		run("8-bit");
		run("Analyze Particles...", "size=25-Infinity display clear add");
		close("Watershed");

		regCount = roiManager("count");

		selectWindow("MaskInv");
		run("Invert");
		run("Invert LUT");
		run("Maximum...", "radius=10");

		run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskInv binary calculate use");
		setMinAndMax(0, 1);
		setOption("ScaleConversions", true);
		run("8-bit");
		run("Analyze Particles...", "size=25-Infinity display clear add");
		rename("Watershed");

		invCount = roiManager("count");

		if(regCount > invCount){
			close("Watershed");
			//MASK
			selectWindow("MaskReg");
			
			run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskReg binary calculate use");
			setMinAndMax(0, 1);
			setOption("ScaleConversions", true);
			run("8-bit");
			run("Analyze Particles...", "size=25-Infinity display clear add");
			rename("Watershed");

			selectWindow("MaskReg");
			rename("Mask");
		} else {
			selectWindow("MaskInv");
			rename("Mask");
			close("MaskReg");
		}
		
		array1 = newArray("0");;
		for (i=1;i<roiManager("count");i++){
			array1 = Array.concat(array1,i);
		}
		
		//Save ROI
		roiManager("select", array1);
		run("Select All");
		imgOnly = substring(path, lengthOf(parent), lengthOf(path)-17);
		roiManager("Save", parent + img + ".zip");
		
		//Save segmentation images
		selectWindow("Input");
		save(parent + img + "_SegInput.tif");
		selectWindow("Marker");
		save(parent + img + "_SegMarker.tif");
		selectWindow("Mask");
		save(parent + img + "_SegMask.tif");
		selectWindow("Watershed");
		save(parent + img + "_SegWatershed.tif");

		//Overlay
		selectWindow("Input");
		roiManager("Show All with labels");
		run("Invert");
		run("8 ramps (RdYlBu)");
		run("Enhance Contrast", "saturated=0.35");
		roiManager("Set Color", "magenta");
		roiManager("Set Line Width", 4);
		selectWindow("Input");
		run("Flatten");
		save(parent + img + "_SegOverlay.tif");
		run("Close All");
		roiManager("reset");
		run("Clear Results");
   }
}

//C=1 function
function processSegmentation1(path) {
   if (endsWith(path, " C=1-DFRm.tif")) {
		//Get parent directory and image name
		parent = File.getParent(path) + "/";
		img = substring(path, lengthOf(parent), lengthOf(path)-13);
		
		//Open Image
		open(parent + img + " C=1-DFRm.tif");

			//INPUT
		run("Grouped Z Project...", "projection=[Max Intensity] group="+nSlices);
		rename("Input");
		run("Enhance Contrast", "saturated=0.33");
		run("Gamma...", "value=0.33");
		run("Gaussian Blur...", "sigma=1 scaled");
		run("Gamma...", "value=0.33");
		run("Enhance Contrast", "saturated=0.35");
		run("8-bit");

		//MARKER
		run("Extended Min & Max", "operation=[Extended Maxima] dynamic=30 connectivity=4");
		rename("Marker");
		run("Invert LUT");

		//MASK
		selectWindow("Input");
		run("Duplicate...", "title=MaskInv");
		run("Maximum...", "radius=10");
		run("Gaussian Blur...", "sigma=2 scaled");
		run("Maximum...", "radius=5");
		run("Gamma...", "value=1");
		run("Enhance Contrast", "saturated=0.35");
		run("Gamma...", "value=1");
		run("Enhance Contrast", "saturated=0.35");
		run("Make Binary");
		run("Duplicate...", "title=MaskReg");
		run("Maximum...", "radius=10");
		selectWindow("Input");
		run("Invert");
		run("Invert LUT");
		
		//WATERSHED
		
		run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskReg binary calculate use");
		setMinAndMax(0, 1);
		setOption("ScaleConversions", true);
		run("8-bit");
		run("Analyze Particles...", "size=25-Infinity display clear add");
		close("Watershed");

		regCount = roiManager("count");

		selectWindow("MaskInv");
		run("Invert");
		run("Invert LUT");
		run("Maximum...", "radius=10");

		run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskInv binary calculate use");
		setMinAndMax(0, 1);
		setOption("ScaleConversions", true);
		run("8-bit");
		run("Analyze Particles...", "size=25-Infinity display clear add");
		rename("Watershed");

		invCount = roiManager("count");

		if(regCount > invCount){
			close("Watershed");
			//MASK
			selectWindow("MaskReg");
			
			run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskReg binary calculate use");
			setMinAndMax(0, 1);
			setOption("ScaleConversions", true);
			run("8-bit");
			run("Analyze Particles...", "size=25-Infinity display clear add");
			rename("Watershed");

			selectWindow("MaskReg");
			rename("Mask");
		} else {
			selectWindow("MaskInv");
			rename("Mask");
			close("MaskReg");
		}
		
		array1 = newArray("0");;
		for (i=1;i<roiManager("count");i++){
			array1 = Array.concat(array1,i);
		}
		
		//Save ROI
		roiManager("select", array1);
		run("Select All");
		imgOnly = substring(path, lengthOf(parent), lengthOf(path)-17);
		roiManager("Save", parent + img + ".zip");
		
		//Save segmentation images
		selectWindow("Input");
		save(parent + img + "_SegInput.tif");
		selectWindow("Marker");
		save(parent + img + "_SegMarker.tif");
		selectWindow("Mask");
		save(parent + img + "_SegMask.tif");
		selectWindow("Watershed");
		save(parent + img + "_SegWatershed.tif");

		//Overlay
		selectWindow("Input");
		roiManager("Show All with labels");
		run("Invert");
		run("8 ramps (RdYlBu)");
		run("Enhance Contrast", "saturated=0.35");
		roiManager("Set Color", "magenta");
		roiManager("Set Line Width", 4);
		selectWindow("Input");
		run("Flatten");
		save(parent + img + "_SegOverlay.tif");
		run("Close All");
		roiManager("reset");
		run("Clear Results");
   }
}

//Only one channel function
function processSegmentation1ch(path) {
   if (endsWith(path, "-DFRm.tif")) {
		//Get parent directory and image name
		parent = File.getParent(path) + "/";
		img = substring(path, lengthOf(parent), lengthOf(path)-9);
		
		//Open Image
		open(parent + img + "-DFRm.tif");
		
			//INPUT
		run("Grouped Z Project...", "projection=[Max Intensity] group="+nSlices);
		rename("Input");
		run("Enhance Contrast", "saturated=0.33");
		run("Gamma...", "value=0.33");
		run("Gaussian Blur...", "sigma=1 scaled");
		run("Gamma...", "value=0.33");
		run("Enhance Contrast", "saturated=0.35");
		run("8-bit");

		//MARKER
		run("Extended Min & Max", "operation=[Extended Maxima] dynamic=30 connectivity=4");
		rename("Marker");
		run("Invert LUT");

		//MASK
		selectWindow("Input");
		run("Duplicate...", "title=MaskInv");
		run("Maximum...", "radius=10");
		run("Gaussian Blur...", "sigma=2 scaled");
		run("Maximum...", "radius=5");
		run("Gamma...", "value=1");
		run("Enhance Contrast", "saturated=0.35");
		run("Gamma...", "value=1");
		run("Enhance Contrast", "saturated=0.35");
		run("Make Binary");
		run("Duplicate...", "title=MaskReg");
		run("Maximum...", "radius=10");
		selectWindow("Input");
		run("Invert");
		run("Invert LUT");
		
		//WATERSHED
		
		run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskReg binary calculate use");
		setMinAndMax(0, 1);
		setOption("ScaleConversions", true);
		run("8-bit");
		run("Analyze Particles...", "size=25-Infinity display clear add");
		close("Watershed");

		regCount = roiManager("count");

		selectWindow("MaskInv");
		run("Invert");
		run("Invert LUT");
		run("Maximum...", "radius=10");

		run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskInv binary calculate use");
		setMinAndMax(0, 1);
		setOption("ScaleConversions", true);
		run("8-bit");
		run("Analyze Particles...", "size=25-Infinity display clear add");
		rename("Watershed");

		invCount = roiManager("count");

		if(regCount > invCount){
			close("Watershed");
			//MASK
			selectWindow("MaskReg");
			
			run("Marker-controlled Watershed", "input=Input marker=Marker mask=MaskReg binary calculate use");
			setMinAndMax(0, 1);
			setOption("ScaleConversions", true);
			run("8-bit");
			run("Analyze Particles...", "size=25-Infinity display clear add");
			rename("Watershed");

			selectWindow("MaskReg");
			rename("Mask");
		} else {
			selectWindow("MaskInv");
			rename("Mask");
			close("MaskReg");
		}
		
		array1 = newArray("0");;
		for (i = 1; i < roiManager("count"); i++){
			array1 = Array.concat(array1, i);
		}
		
		//Save ROI
		roiManager("select", array1);
		run("Select All");
		imgOnly = substring(path, lengthOf(parent), lengthOf(path)-9);
		roiManager("Save", parent + imgOnly + ".zip");
		
		//Save segmentation images
		selectWindow("Input");
		save(parent + img + "_SegInput.tif");
		selectWindow("Marker");
		save(parent + img + "_SegMarker.tif");
		selectWindow("Mask");
		save(parent + img + "_SegMask.tif");
		selectWindow("Watershed");
		save(parent + img + "_SegWatershed.tif");

		//Overlay
		selectWindow("Input");
		roiManager("Show All with labels");
		run("Invert");
		run("8 ramps (RdYlBu)");
		run("Enhance Contrast", "saturated=0.35");
		roiManager("Set Color", "magenta");
		roiManager("Set Line Width", 4);
		selectWindow("Input");
		run("Flatten");
		save(parent + img + "_SegOverlay.tif");
		run("Close All");
		roiManager("reset");
		run("Clear Results");
   }
}
