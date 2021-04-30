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