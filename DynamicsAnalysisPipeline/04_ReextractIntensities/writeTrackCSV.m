function writeTrackCSV(p,trackIntensities)
delete([p.savename '.csv']);
fileID = fopen([p.savename '.csv'],'w');


fprintf(fileID,'%s, %s \n ', 'XML','Image Name');
fprintf(fileID,'%s, %s \n ', p.xmlname,p.imname);
fprintf(fileID,'\n');

% Need to go track-by-track, print Track Name, Frame no. Intensity
fprintf(fileID,'%s, %s, %s, %s, %s, %s, %s \n ', 'Serial No.','Track Name', 'Frame No.', 'Relative t', 'Intensity', 'Position X','Position Y');
fprintf(fileID,'\n');

for trkno = 1:length(trackIntensities)
    fprintf(fileID,'%d, %s \n', trkno, trackIntensities{trkno}.trackname);
    
    t = trackIntensities{trkno}.frameno;
    relt = t - t(trackIntensities{trkno}.padlength + 1);
    for tno = 1:length(t)
        fprintf(fileID, '%d, ,%d,%d,%f,%f,%f \n', trkno, t(tno),relt(tno),trackIntensities{trkno}.intensity(tno), trackIntensities{trkno}.x(tno)*0.1466667-0.1466667, trackIntensities{trkno}.y(tno)*0.1466667-0.1466667);
    end
end

fclose(fileID);
end