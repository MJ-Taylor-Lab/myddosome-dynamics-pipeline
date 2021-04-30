%Global variables
maximum_distance = 0.25;
minimum_association_time = 3;
minimum_dwell_time = 2;
nbins = 50;

Input =  readtable('~/ImageAnalysisWorkflow/00_Setup/Colocalization.xlsx');

%Count number of files
FileCount = height(Input);
nFileCount = FileCount;
disp(['Input: ' num2str(nFileCount) ' image sets']);
FileCount = 1:FileCount;

tStart = tic();
%Run analysis
for FileX = FileCount
    %Get variables
    Input =  readtable('~/ImageAnalysisWorkflow/00_Setup/Colocalization.xlsx');
    imgpath = Input.PATH(FileX);
    protein1 = Input.PROTEIN1(FileX);
    protein2 = Input.PROTEIN2(FileX);
    
    %Convert to character
    imgpath = char(imgpath);
    protein1 = char(protein1);
    protein2 = char(protein2);
    %Add slash
    imgpath = strcat(imgpath, '/');
    cells = Input.CELLS(FileX);
    cells = 1:cells;
 parfor CellX = cells
        cellpath = strcat(imgpath, 'Cell_', num2str(CellX), '/');
        cellpath = char(cellpath);
        disp(['Now processing image ' num2str(FileX) ' of ' num2str(nFileCount) ': ' cellpath protein1 ' and ' protein2]);
        try
            output_directory = strcat(protein1, '_', protein2);
            path_to_folder = cellpath;
            disp(strcat('Start with::', path_to_folder));
            reference_trackmatefile = [path_to_folder '/' protein1 '.xml'];
            listtrackmatefile =  {[path_to_folder '/' protein2 '.xml']};
            trackmateAnalysisUNIX(reference_trackmatefile, listtrackmatefile, output_directory, {protein1, protein2}, maximum_distance, minimum_association_time, minimum_dwell_time, nbins);
            disp(strcat('Done with::', path_to_folder));
        catch
            disp(['Skipped: ' cellpath protein1 '.xml']);
        end
 end
end
tElapsed = toc(tStart)