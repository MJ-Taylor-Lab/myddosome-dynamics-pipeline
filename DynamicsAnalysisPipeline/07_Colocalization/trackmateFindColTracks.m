function filterTable = trackmateFindColTracks(filterTable, group);
    init_len = height(filterTable(ismember(filterTable.GROUP, group),:));

    track_key = filterTable(ismember(filterTable.GROUP, group),:).TRACK_KEY_track_spots_table;
    if length(track_key)==1;
        track_key =track_key{1};
    end
    len = height(filterTable(ismember(filterTable.TRACK_KEY_track_spots_table, track_key),:));
    filterTable(ismember(filterTable.TRACK_KEY_track_spots_table, track_key),:).GROUP = repmat(group, len, 1);
    
    track_key = filterTable(ismember(filterTable.GROUP, group),:).TRACK_KEY_ref_track_spots_table;
    if length(track_key)==1;
        track_key =track_key{1};
    end
    len = height(filterTable(ismember(filterTable.TRACK_KEY_ref_track_spots_table, track_key),:));
    filterTable(ismember(filterTable.TRACK_KEY_ref_track_spots_table, track_key),:).GROUP = repmat(group, len, 1);

    end_len = height(filterTable(ismember(filterTable.GROUP, group),:));
    
    if init_len == end_len;
        return
    end
    trackmateFindColTracks(filterTable, group);
end