function CellFx(cells, imgpath, FileX, nFileCount, protein1, protein2, maximum_distance, minimum_association_time, minimum_dwell_time, nbins)
    parfor CellX = cells
        cellpath = strcat(imgpath, 'Cell_', num2str(CellX), '/');
        cellpath = char(cellpath);
        disp(['Now processing image ' num2str(FileX) ' of ' num2str(nFileCount) ': ' cellpath protein1 ' and ' protein2]);
        %try
            output_directory = strcat(protein1, '_', protein2);
            path_to_folder = cellpath;
            disp(strcat('Start with::', path_to_folder));
            reference_trackmatefile = [path_to_folder '/' protein1 '.xml'];
            listtrackmatefile =  {[path_to_folder '/' protein2 '.xml']};
            trackmate_analysis(reference_trackmatefile, listtrackmatefile, output_directory, {protein1, protein2}, maximum_distance, minimum_association_time, minimum_dwell_time, nbins);
            disp(strcat('Done with::', path_to_folder));
        %catch
            disp(['Skipped: ' cellpath protein1 '.xml']);
        %end
    end
end