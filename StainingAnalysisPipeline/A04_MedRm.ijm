//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//

//Converts nd2 files to 16-bit TIFF. Also opens up as a dialog.

// --- INPUT ---

//Folder containing images
#@ File (label = "Input/Output Directory", style = "directory", value = "~/ImageAnalysisWorkflow/01_TIFF-Subtract") dir
#@ File (label = "Flat-Field Median Image Directory", style = "directory", value = "~/ImageAnalysisWorkflow/01_TIFF-Subtract") dir_FFMed
#@ double(value=20201009, min=18000000, max=28000000, style="spinner") acquisitionDate
// --- TIFF SPLIT ---
dir = dir + "/";
dir_FFMed = dir_FFMed + "/";
parent_dir = dir
run("Close All");
setBatchMode(true);

processFilesMed(dir);
 
   function processFilesMed(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFilesMed(""+dir+list[i]);
          else {
             path = dir + list[i];
             processFile0FFMedRm(path); //For C=0
             processFile1FFMedRm(path); //For C=1
             processFile2FFMedRm(path); //For C=2
          }
      }
  }
  
  //C=0 function
  function processFile0FFMedRm(path) {
  	parent = File.getParent(path) + "/";
	img = substring(path, lengthOf(parent), lengthOf(path)-4);
       if (endsWith(path, " C=0-DFRm.tif")) {
		//Open image
		open(path);
		//Extract file name
		img = File.nameWithoutExtension();
		open(dir_FFMed + acquisitionDate + " C=0-Avg-Med.tif");
		img_ffmed = File.nameWithoutExtension();
		//Get mean for keeping relative intensity values
		getStatistics(area, mean);
		mean = round(mean);
		run("Calculator Plus", "i1=["+img+".tif] i2=["+img_ffmed+".tif] operation=[Divide: i2 = (i1/i2) x k1 + k2] k1="+mean+" k2=0 create");
		run("Duplicate...", "title=Median");
		//run("Median...", "radius=5");
		//run("Median...", "radius=15");
		//run("Median...", "radius=10");
		run("Median...", "radius=25");
		imageCalculator("Subtract create", "Result","Median");
		//Reset brightness and contrast
		resetMinAndMax();
		//Save Dark-Field Removed (DFRm)
		saveAs ("Tiff", dir + img + "-FFMedRm");
		//Close open images
		run("Close All"); 
      }
  }
   //C=1 function
  function processFile1FFMedRm(path) {
  	parent = File.getParent(path) + "/";
	img = substring(path, lengthOf(parent), lengthOf(path)-4);
       if (endsWith(path, " C=1-DFRm.tif")) {
		//Open image
		open(path);
		//Extract file name
		img = File.nameWithoutExtension();
		open(dir_FFMed + acquisitionDate + " C=1-Avg-Med.tif");
		img_ffmed = File.nameWithoutExtension();
		//Get mean for keeping relative intensity values
		getStatistics(area, mean);
		mean = round(mean);
		run("Calculator Plus", "i1=["+img+".tif] i2=["+img_ffmed+".tif] operation=[Divide: i2 = (i1/i2) x k1 + k2] k1="+mean+" k2=0 create");
		run("Duplicate...", "title=Median");
		//run("Median...", "radius=5");
		//run("Median...", "radius=15");
		//run("Median...", "radius=10");
		run("Median...", "radius=25");
		imageCalculator("Subtract create", "Result","Median");
		//Reset brightness and contrast
		resetMinAndMax();
		//Save Dark-Field Removed (DFRm)
		saveAs ("Tiff", dir + img + "-FFMedRm");
		//Close open images
		run("Close All"); 
      }
  }
   //C=2 function
  function processFile2FFMedRm(path) {
  	parent = File.getParent(path) + "/";
	img = substring(path, lengthOf(parent), lengthOf(path)-4);
       if (endsWith(path, " C=2-DFRm.tif")) {
		//Open image
		open(path);
		//Extract file name
		img = File.nameWithoutExtension();
		open(dir_FFMed + acquisitionDate + " C=2-Avg-Med.tif");
		img_ffmed = File.nameWithoutExtension();
		//Get mean for keeping relative intensity values
		getStatistics(area, mean);
		mean = round(mean);
		run("Calculator Plus", "i1=["+img+".tif] i2=["+img_ffmed+".tif] operation=[Divide: i2 = (i1/i2) x k1 + k2] k1="+mean+" k2=0 create");
		run("Duplicate...", "title=Median");
		//run("Median...", "radius=5");
		//run("Median...", "radius=15");
		//run("Median...", "radius=10");
		run("Median...", "radius=25");
		imageCalculator("Subtract create", "Result","Median");
		//Reset brightness and contrast
		resetMinAndMax();
		//Save Dark-Field Removed (DFRm)
		saveAs ("Tiff", dir + img + "-FFMedRm");
		//Close open images
		run("Close All"); 
      }
  }
 
run("Set Measurements...", "area mean standard min redirect=None decimal=4");
print("All done");
//wait(10*1000);
wait(5*1000);
print("Timer Up");
wait(1*1000);
run("Quit");
