%GlobalVariables
Input =  readtable('~/xml2csv.xlsx');

%Count number of files
FileCount = height(Input);
nFileCount = FileCount;
disp(['Input: ' num2str(nFileCount) ' image sets']);
FileCount = 1:FileCount;
tic();
%Run analysis
for FileX = FileCount
    Input =  readtable('~/xml2csv.xlsx');

    %Get variables
    imgpath = Input.PathUNIX(FileX);
    protein = Input.Protein(FileX);
    %Convert to character
    imgpath = char(imgpath);
    protein = char(protein);
    %Add slash
    imgpath = strcat(imgpath, '/');
    cells = Input.Cells(FileX);
    cells = 1:cells;
    parfor CellX = cells
        cellpath = strcat(imgpath, 'Cell_', num2str(CellX), '/');
        cellpath = char(cellpath);
        disp(['Now processing image ' num2str(FileX) ' of ' num2str(nFileCount) ': ' cellpath protein '.xml']);
    try
        p.spotFlank = 1; % sets the size of the box used to extract data. a value of 1 means a 3x3 box, 2 means 5x5 etc
        p.padamount = 5; % pad frames behind

        p.xmlname = strcat(cellpath, protein, '.xml');
        p.imname = strcat(cellpath, protein, '_MED.tif');
        p.savename = strcat(cellpath, protein, ' spots in tracks statistics');
        p.savename = char(p.savename);
        [p, tracksFromXML] = extractTracksFromXML(p);
        trackDat = extractTrackProperties(p, tracksFromXML);
        %save([p.savename '.mat']); %#ok<PFSV> %Save as a csv and in Matlab Form
        writeTrackCSV(p, trackDat);
        disp(['Successfully done with: ' cellpath protein '.xml']);
    catch
        disp(['Skipped: ' cellpath protein '.xml']);
    end
    end
end
toc()
function [p, trackDat] = extractTracksFromXML(p)
xDoc = xmlread([p.xmlname]);


% Figure out the pixel size
pixelsizefx = xDoc.getElementsByTagName('Settings');
pixelsizefx = pixelsizefx.item(0);
pixelsizefx = pixelsizefx.getElementsByTagName('ImageData');
pixelsizefx = pixelsizefx.item(0);
p.pixsize_x = str2num(char(pixelsizefx.getAttribute('pixelwidth')));
p.pixsize_y = str2num(char(pixelsizefx.getAttribute('pixelheight')));

% identify the filtered tracks
filttracks = xDoc.getElementsByTagName('FilteredTracks');
filttracks = filttracks.item(0);
filttracks = filttracks.getElementsByTagName('TrackID');
numberoffilttracks = filttracks.getLength;
filtered_trackmate_id = [];
for fnum = 0:numberoffilttracks-1
    filtitem = filttracks.item(fnum);
    filtered_trackmate_id(fnum + 1) = str2num(char(filtitem.getAttribute('TRACK_ID')));
end

%Get everything with the tag 'Track'
alltracks = xDoc.getElementsByTagName('Track');
numberoftracks = alltracks.getLength;
%Go through the list of all 'Track' items, finding the list of edges for each one. For each edge, extract the spot ID of the starting and the ending spot.
%disp(['Extracting ' num2str(numberoftracks) ' tracks']);
trackmate_id = [];
acceptedtrack = 1;
for trackno = 0:numberoftracks-1
    trackitem = alltracks.item(trackno);
    
    if ismember(str2num(char(trackitem.getAttribute('TRACK_ID'))), filtered_trackmate_id)
        trackmate_id(acceptedtrack) = str2num(char(trackitem.getAttribute('TRACK_ID')));
        trackmate_name{acceptedtrack} = char(trackitem.getAttribute('name'));
        
        edgeList = trackitem.getElementsByTagName('Edge');
        
        trackedges{acceptedtrack} = [];
        for edgeno = 0:edgeList.getLength-1
            edgeitem = edgeList.item(edgeno);
            
            spotsource = edgeitem.getAttribute('SPOT_SOURCE_ID');
            spottarget = edgeitem.getAttribute('SPOT_TARGET_ID');
            
            trackedges{acceptedtrack} = [trackedges{acceptedtrack}; str2num(char(spotsource)) str2num(char(spottarget))];
        end
        acceptedtrack = acceptedtrack + 1;
    end
end

%Get everything with the tag 'SpotsInFrame'
allframes = xDoc.getElementsByTagName('SpotsInFrame');
numberofframes = allframes.getLength;
allSpots = [];
%Go through the list of all 'SpotsInFrame' items, finding the list of Spots for each one. For each spot, extract: ID, x, y and frame. (for now)
%disp(['Extracting spot information from ' num2str(numberofframes) ' frames']);
for frameno = 0:numberofframes-1
    frameitem = allframes.item(frameno);
    
    spotList = frameitem.getElementsByTagName('Spot');
    framenumber = str2num(char(frameitem.getAttribute('frame')));
    
    for spotno = 0:spotList.getLength-1
        spotitem = spotList.item(spotno);
        
        spotid = spotitem.getAttribute('ID');
        spotx = spotitem.getAttribute('POSITION_X');
        spoty = spotitem.getAttribute('POSITION_Y');
        spotint = spotitem.getAttribute('TOTAL_INTENSITY');
        spotintmean = spotitem.getAttribute('MEAN_INTENSITY');
        
        allSpots = [allSpots; str2num(char(spotid)) str2num(char(spotx)) str2num(char(spoty)) framenumber str2num(char(spotint)) str2num(char(spotintmean))];
    end
end

%disp(['Populating x, y and t for all tracks...']);

spotIDs = allSpots(:,1);
% Look through the track edge information and populate a vector for each track with track time and positions (x, y, frame number).
tracklengths = [];
counter = 1;
for trackno = 1:length(trackedges)
    sourcevector = trackedges{trackno}(:,1);
    targetvector = trackedges{trackno}(:,2);
    
    tracks_xyt{trackno} = [];
    tracks_int{trackno} = [];
    % where does the track start? clearly at the spot that is not a target.
    thisspot = setdiff(sourcevector,targetvector);
    spotpositioninvec = find(spotIDs==thisspot);
    tracks_xyt{trackno} = [tracks_xyt{trackno}; allSpots(spotpositioninvec,2) allSpots(spotpositioninvec,3) allSpots(spotpositioninvec,4)];
    tracks_int{trackno} = allSpots(spotpositioninvec,6);
    for spotno = 1:length(sourcevector)
        thisspot = targetvector(find(sourcevector==thisspot));
        spotpositioninvec = find(spotIDs==thisspot);
        % keyboard;
        tracks_xyt{trackno} = [tracks_xyt{trackno}; allSpots(spotpositioninvec,2) allSpots(spotpositioninvec,3) allSpots(spotpositioninvec,4)];
        tracks_int{trackno}(spotno+1) = allSpots(spotpositioninvec,6);
    end
end

trackDat.xyt = tracks_xyt;
trackDat.names = trackmate_name;
trackDat.id = trackmate_id;
end
function trackIntensities = extractTrackProperties(p, trackDat)
imraw = tiffread2(p.imname);
spotFlank = p.spotFlank;
padamount = p.padamount;

for i = 1:length(imraw)
    im{i} = double(imraw(i).data);
    
    % Make a fake image
    fakeIm{i} = zeros(size(im{i}));
end
clear imraw

imsize = size(im{1});
[Xc Yc] = meshgrid(1:imsize(2),1:imsize(1));

liftim = [];
rtrkno = 1;
for trkno = 1:length(trackDat.xyt)
    x = trackDat.xyt{trkno}(:,1)/p.pixsize_x + 1;
    y = trackDat.xyt{trkno}(:,2)/p.pixsize_y + 1;
    t = trackDat.xyt{trkno}(:,3) + 1;
    
    if length(find([round(x)-spotFlank-1 ; round(y)-spotFlank-1] < 1)) > 0 || length(find([round(x)+spotFlank+1] > imsize(2))) > 0 || length(find([round(y)+spotFlank+1] > imsize(1))) > 0
        %disp(['Track ' trackDat.names{trkno} ' is an edge case'])
    else
        tpaddown = [max(min(t)-padamount,1):max(min(t)-1,1)]';
        padlength = length(tpaddown);
        t = [tpaddown; t];
        x = [repmat(x(1), [padlength 1]) ; x];
        y = [repmat(y(1), [padlength 1]) ; y];
        
        trkIntense = [];
        for i = 1:length(t)
            frameno = t(i);
            framex = round(y(i));
            framey = round(x(i));
            
            fakeIm{frameno}(framex-1:framex+1,framey-1:framey+1) = 1000;
            x - x.coordinate + box - .5
            %subpixelshift
            shiftx = y(i) - framex;
            shifty = x(i) - framey;
            XcCrop = Xc((framex-spotFlank-1):(framex+spotFlank+1),(framey-spotFlank-1):(framey+spotFlank+1));
            YcCrop = Yc((framex-spotFlank-1):(framex+spotFlank+1),(framey-spotFlank-1):(framey+spotFlank+1));
            imCrop = im{frameno}((framex-spotFlank-1):(framex+spotFlank+1),(framey-spotFlank-1):(framey+spotFlank+1));
            imShift = interp2(XcCrop,YcCrop,imCrop,XcCrop + shiftx,YcCrop+shifty);
            midpo = (length(imShift) + 1)/2;
            
            % keyboard
            
            trkIntense(i) = sum(sum(imShift((midpo-spotFlank):(midpo+spotFlank),(midpo-spotFlank):(midpo+spotFlank))));
        end
        
        [trackIntensities{rtrkno}.frameno sortkey] = sort(t);
        trackIntensities{rtrkno}.padlength = padlength;
        trackIntensities{rtrkno}.intensity = trkIntense(sortkey);
        trackIntensities{rtrkno}.x = x(sortkey);
        trackIntensities{rtrkno}.y = y(sortkey);
        trackIntensities{rtrkno}.lifetime = (max(t) - min(t) + 1) - padlength;
        trackIntensities{rtrkno}.trackname = trackDat.names{trkno};
        trackIntensities{rtrkno}.id = trackDat.id(trkno);
        
        liftim = [liftim trackIntensities{rtrkno}.lifetime];
        rtrkno = rtrkno + 1;
    end
end

% Reorder by lifetime
unsortedTrackIntensities = trackIntensities;
[eh sortyval] = sort(liftim,'descend');
for trkno = 1:length(unsortedTrackIntensities)
    trackIntensities{trkno} = unsortedTrackIntensities{sortyval(trkno)};
end
end
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
