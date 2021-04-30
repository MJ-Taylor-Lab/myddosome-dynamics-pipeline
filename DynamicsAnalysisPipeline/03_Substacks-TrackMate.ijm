//   To cite this work, please use:
// 
//   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
//        physical threshold to trigger IL1R Myddosome signaling.
//        J. Cell Biol. https://doi.org/10.1083/jcb.202012071
//

//Creates substacks from the segmentation results
//Runs TrackMate on substacks

// --- INPUT ---
#@ File (label = "Input directory", style = "directory", value = "~/ImageAnalysisWorkflow/03_Substacks-TrackMate") dir

#@ Boolean (label = "Run calibration (fill out C=0)", value = false) runCalibration
#@ Boolean (label = "Run one protein only, no C's (fill out C=0)", value = false) runProtein
#@ Boolean (label = "Run Protein 0", value = false) runProtein0
#@ String (label = "Protein C=0 Name", value = "IL-1") protein0
#@ String (label = "Protein C=0 Threshold", value = "10") protein0_threshold

#@ Boolean (label = "Run Protein 1", value = true) runProtein1
#@ String (label = "Protein C=1 Name", value = "MyD88") protein1
#@ String (label = "Protein C=1 Threshold", value = "10") protein1_threshold

#@ Boolean (label = "Run Protein 2", value = false) runProtein2
#@ String (label = "Protein C=2 Name", value = "IRAK1") protein2
#@ String (label = "Protein C=2 Threshold", value = "12") protein2_threshold


// --- SUBSTACKS ---
// "BatchROI"
   run("Set Measurements...", "area mean standard min redirect=None decimal=3");
   dir = dir + "/";
   requires("1.33s"); 
   setBatchMode(true);
   roiManager("reset");
   
   //Get file list
   count = 0;
   countFiles(dir);
   n = 0;
   processFiles(dir);
   print(count+" files processed");
   
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

   //Substacks function
   function processFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             if (runCalibration == true)
             	processFileCalibration(path); //Run calibration
             if (runProtein == true)
             	processFileProtein(path); //Run for one channel available
             if (runProtein0 == true)
             	processFileProtein0(path); //Run C=0
             if (runProtein1 == true)
             	processFileProtein1(path); //Run C=1
             if (runProtein2 == true)
             	processFileProtein2(path); //Run C=2

          }
      }
  }

  //Calibration function
  function processFileCalibration(path) {
       if (endsWith(path, "-MedRm.tif")) {
			//SETUP
			//Count number of cells
			cells = 1;
			//Get parent directory and image name
			parent = File.getParent(path) + "/";
			img = substring(path, lengthOf(parent), lengthOf(path)-10);
			
			//MEDIAN
			print("Working on " + img + " (Substacks and TrackMate)");
			//Loop for cutting out cells using ROI
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				//Open image
				open(parent + img + "-DFRm.tif");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				//Run TrackMate
				run('TrackMate', "use_gui=false "
   				+ "save_to=["+ parent + "/Cell_" + n + "/" + protein0 + ".xml] "
   				+ "display_results=false "
			  	+ "radius=.22 "
			    + "threshold=" + protein0_threshold + " "
		  		+ "subpixel=true "
		    	+ "median=false "
		    	+ "channel=1 "
		    	+ "max_distance=.44 "
				+ "max_gap_distance=.66 "
		    	+ "max_frame_gap=3 " );

		    	close();
		    	
           		//Save median
           		open(parent + img + "-MedRm.tif");
           		File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein0 + "_MED");
			}
			//Calculate area and intensity of last frame for all cells
			print("Measurements of " + img + " " + protein0 +" Median");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=" + nSlices + "-" + nSlices);
			close("Old.tif");
			roiManager("reset");
			run("Select All");
			run("Measure");
			run("Select All");
			save(parent + img + " "+ protein0 + "_MED_Measurements.txt");
			close("Results");
			run("Close All");
       }
  }

  //Function for one channel available
  function processFileProtein(path) {
       if (endsWith(path, ".zip")) {
			//SETUP
			//Open ROI
			roiManager("Open", path);
			//Count number of cells
			cells = roiManager("count");
			//Get parent directory and image name
			parent = File.getParent(path) + "/";
			img = substring(path, lengthOf(parent), lengthOf(path)-4);
			
			//DARK-FIELD
			print("Working on " + img + " (Dark-Field)");
			//Open image
			open(parent + img + "-DFRm.tif");
			//Loop for cutting out cells using ROI and running TrackMate
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				//Cut out cell and save
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein0);
				//Run TrackMate
				run('TrackMate', "use_gui=false "
   				+ "save_to=["+ parent + "/Cell_" + n + "/" + protein0 + ".xml] "
   				+ "display_results=false "
			  	+ "radius=.25 "
			    + "threshold=" + protein0_threshold + " "
		  		+ "subpixel=true "
		    	+ "median=false "
		    	+ "channel=1 "
		    	+ "max_distance=.5 "
				+ "max_gap_distance=.75 "
		    	+ "max_frame_gap=3 " );
           		save(parent + "Cell_" + n + "/" + protein0 + ".tif");
           		selectWindow(protein0 + ".tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein0 +" Dark-Field");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein0 + "_DF_Measurements.txt");
			close("Results");

			//MEDIAN
			print("Working on " + img + " (Median)");
			//Open image
			open(parent + img + "-MedRm.tif");
			//Loop for cutting out cells using ROI
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein0 + "_MED");
           		selectWindow(protein0 + "_MED.tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein0 +" Median");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein0 + "_MED_Measurements.txt");
			close("Results");
			roiManager("reset");
			run("Close All");
       }
  }

  //Function for C=0
  function processFileProtein0(path) {
       if (endsWith(path, ".zip")) {
			//SETUP
			//Open ROI
			roiManager("Open", path);
			//Count number of cells
			cells = roiManager("count");
			//Get parent directory and image name
			parent = File.getParent(path) + "/";
			img = substring(path, lengthOf(parent), lengthOf(path)-4);
			
			//DARK-FIELD
			print("Working on " + img + " (C=0, Dark-Field)");
			//Open image
			open(parent + img + " C=0-DFRm.tif");
			//Loop for cutting out cells using ROI and running TrackMate
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				//Cut out cell and save
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein0);
				//Run TrackMate
				run('TrackMate', "use_gui=false "
   				+ "save_to=["+ parent + "/Cell_" + n + "/" + protein0 + ".xml] "
   				+ "display_results=false "
			  	+ "radius=.25 "
			    + "threshold=" + protein0_threshold + " "
		  		+ "subpixel=true "
		    	+ "median=false "
		    	+ "channel=1 "
		    	+ "max_distance=.5 "
				+ "max_gap_distance=.75 "
		    	+ "max_frame_gap=3 " );
           		save(parent + "Cell_" + n + "/" + protein0 + ".tif");
           		selectWindow(protein0 + ".tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein0 +" Dark-Field");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein0 + "_DF_Measurements.txt");
			close("Results");

			//MEDIAN
			print("Working on " + img + " (C=0, Median)");
			//Open image
			open(parent + img + " C=0-MedRm.tif");
			//Loop for cutting out cells using ROI
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein0 + "_MED");
           		selectWindow(protein0 + "_MED.tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein0 +" Median");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein0 + "_MED_Measurements.txt");
			close("Results");
			roiManager("reset");
			run("Close All");
       }
  }

  //Function for C=1
  function processFileProtein1(path) {
       if (endsWith(path, ".zip")) {
			//SETUP
			//Open ROI
			roiManager("Open", path);
			//Count number of cells
			cells = roiManager("count");
			//Get parent directory and image name
			parent = File.getParent(path) + "/";
			img = substring(path, lengthOf(parent), lengthOf(path)-4);
			
			//DARK-FIELD
			print("Working on " + img + " (C=1, Dark-Field)");
			//Open image
			open(parent + img + " C=1-DFRm.tif");
			//Loop for cutting out cells using ROI and running TrackMate
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				//Cut out cell and save
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein1);
				//Run TrackMate
				run('TrackMate', "use_gui=false "
   				+ "save_to=["+ parent + "/Cell_" + n + "/" + protein1 + ".xml] "
   				+ "display_results=false "
			  	+ "radius=.25 "
			    + "threshold=" + protein1_threshold + " "
		  		+ "subpixel=true "
		    	+ "median=false "
		    	+ "channel=1 "
		    	+ "max_distance=.5 "
				+ "max_gap_distance=.75 "
		    	+ "max_frame_gap=3 " );
           		save(parent + "Cell_" + n + "/" + protein1 + ".tif");
           		selectWindow(protein1 + ".tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein1 +" Dark-Field");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein1 + "_DF_Measurements.txt");
			close("Results");

			//MEDIAN
			print("Working on " + img + " (C=1, Median)");
			//Open image
			open(parent + img + " C=1-MedRm.tif");
			//Loop for cutting out cells using ROI
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein1 + "_MED");
           		selectWindow(protein1 + "_MED.tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein1 +" Median");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein1 + "_MED_Measurements.txt");
			close("Results");
			roiManager("reset");
			run("Close All");
       }
  }

  //Function for C=2
  function processFileProtein2(path) {
       if (endsWith(path, ".zip")) {
			//SETUP
			//Open ROI
			roiManager("Open", path);
			//Count number of cells
			cells = roiManager("count");
			//Get parent directory and image name
			parent = File.getParent(path) + "/";
			img = substring(path, lengthOf(parent), lengthOf(path)-4);
			
			//DARK-FIELD
			print("Working on " + img + " (C=2, Dark-Field)");
			//Open image
			open(parent + img + " C=2-DFRm.tif");
			//Loop for cutting out cells using ROI and running TrackMate
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				//Cut out cell and save
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein2);
				//Run TrackMate
				run('TrackMate', "use_gui=false "
   				+ "save_to=["+ parent + "/Cell_" + n + "/" + protein2 + ".xml] "
   				+ "display_results=false "
			  	+ "radius=.25 "
			    + "threshold=" + protein2_threshold + " "
		  		+ "subpixel=true "
		    	+ "median=false "
		    	+ "channel=1 "
		    	+ "max_distance=.5 "
				+ "max_gap_distance=.75 "
		    	+ "max_frame_gap=3 " );
           		save(parent + "Cell_" + n + "/" + protein2 + ".tif");
           		selectWindow(protein2 + ".tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein2 +" Dark-Field");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein2 + "_DF_Measurements.txt");
			close("Results");

			//MEDIAN
			print("Working on " + img + " (C=2, Median)");
			//Open image
			open(parent + img + " C=2-MedRm.tif");
			//Loop for cutting out cells using ROI
			for (x=0; x<cells; x++) {
				n=x+1;
				print("Processing " + n +" of " + cells + " cells");
				roiManager("Select", x);
				run("Duplicate...", "title=Cell_"+ n +" duplicate");
				File.makeDirectory(parent + "/Cell_" + n +"/");
				saveAs("Tiff", parent + "Cell_" + n + "/"+ protein2 + "_MED");
           		selectWindow(protein2 + "_MED.tif");
           		close();
			}
			//Calculate area and intensity of first frame for all cells
			print("ROI measurements of " + img + " " + protein2 +" Median");
			rename("Old.tif");
			run("Select All");
			run("Duplicate...", "title=New.tif duplicate range=1-1");
			close("Old.tif");
			roiManager("Deselect");
			roiManager("measure");
			run("Select All");
			save(parent + img + " "+ protein2 + "_MED_Measurements.txt");
			close("Results");

			roiManager("reset");
			run("Close All");
       }
  }

print("All done");
