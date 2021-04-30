FRAMEWINDOW = 800;
GRB2SUMAFTERFRAMES = 20;
ERKSUMAFTERFRAMES = 6;

path_to_data = 'C:\Users\alex\Dropbox\Arbeit\MPIIB\trackmate_data';
path_to_output = 'C:\Users\alex\Dropbox\Arbeit\MPIIB\Figures\4A';

cell13_1 = '20190219 Grb2 ERK 13mer_01_cell1_Grb2';
cell13_2 = '20190304 Grb2 ERK 13mer_01_cell1_Grb2';
cell13_3 = '20190304 Grb2 ERK 13mer_01_cell2_Grb2';
cell13_4 = '20190304 Grb2 ERK 13mer_01_cell3_Grb2';
cell13_5 = '20190304 Grb2 ERK 13mer_01_cell4_Grb2';
cell13_6 = '20190304 Grb2 ERK 13mer_01_cell5_Grb2';
cells13 = {cell13_1, cell13_2, cell13_3, cell13_4, cell13_5, cell13_6};

cell16_1 = '20190328 Grb2 ERK 16mer_01_cell3_Grb2';
cell16_2 = '20190328 Grb2 ERK 16mer_01_cell2_Grb2';
cell16_3 = '20190328 Grb2 ERK 16mer_01_cell1_Grb2';
cell16_4 = '20190313 Grb2 ERK 16mer_03_cell2_Grb2';
cell16_5 = '20190313 Grb2 ERK 16mer_01_cell2_Grb2';
cell16_6 = '20190313 Grb2 ERK 16mer_01_cell1_Grb2';
cells16 = {cell16_1, cell16_2, cell16_3, cell16_4, cell16_5, cell16_6};
erk_13 = [path_to_data '\' 'ERK13mer' '\'];
erk_16 = [path_to_data '\' 'ERK16mer' '\'];

track_spots = [];
spots = [];
count_zero_grb213 = [];
count_zero_erk13 = [];
cells13 = strcat(erk_13,cells13);
system_13 = '13';
for num = 1:length(cells13)
    
    load ([cells13{num} '\' 'track_variables.mat']);
    all_track_spots =addvars(all_track_spots, repmat(cells13(num), height(all_track_spots), 1), repmat({system_13}, height(all_track_spots), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    min_frame_ligand = min(all_track_spots(ismember(all_track_spots.CHANNEL_NUMBER, 1),:).FRAME);
    all_track_spots.FRAME = all_track_spots.FRAME - min_frame_ligand;
    all_track_spots = all_track_spots(all_track_spots.FRAME < FRAMEWINDOW,:);
    frames = 0:FRAMEWINDOW-1;
    frames = frames(~ismember(frames, all_track_spots.FRAME));
    count_zero_grb213 = [count_zero_grb213 ; length(frames)];
    track_spots = [track_spots; all_track_spots];
    
    all_spots =addvars(all_spots, repmat(cells13(num), height(all_spots), 1), repmat({system_13}, height(all_spots), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    all_spots.FRAME = all_spots.FRAME - min_frame_ligand;
    all_spots = all_spots(all_spots.FRAME>=0,:);
    all_spots = all_spots(all_spots.FRAME<FRAMEWINDOW,:);
    frames = 0:FRAMEWINDOW-1;
    frames = frames(~ismember(frames, all_spots.FRAME));
    count_zero_erk13 = [count_zero_erk13; length(frames)];
    spots = [spots; all_spots];
end

count_zero_lig16 = [];
count_zero_mek16 = [];
cells16 = strcat(erk_16,cells16);
system_16 = '16';
for num = 1:length(cells16)
    load ([cells16{num} '\' 'track_variables.mat']);
    all_track_spots =addvars(all_track_spots, repmat(cells16(num), height(all_track_spots), 1), repmat({system_16}, height(all_track_spots), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    min_frame_ligand = min(all_track_spots(ismember(all_track_spots.CHANNEL_NUMBER, 1),:).FRAME);
    all_track_spots.FRAME = all_track_spots.FRAME - min_frame_ligand;
    all_track_spots = all_track_spots(all_track_spots.FRAME < FRAMEWINDOW,:);
    frames = 0:FRAMEWINDOW-1;
    frames = frames(~ismember(frames, all_track_spots.FRAME));
    count_zero_lig16 = [count_zero_lig16 ; length(frames)];
    track_spots = [track_spots; all_track_spots];
    
    all_spots =addvars(all_spots, repmat(cells16(num), height(all_spots), 1), repmat({system_16}, height(all_spots), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    all_spots.FRAME = all_spots.FRAME - min_frame_ligand;
    all_spots = all_spots(all_spots.FRAME>=0,:);
    all_spots = all_spots(all_spots.FRAME<FRAMEWINDOW,:);
    frames = 0:FRAMEWINDOW-1;
    frames = frames(~ismember(frames, all_spots.FRAME));
    count_zero_mek16 = [count_zero_mek16; length(frames)];
    spots = [spots; all_spots];
    
end

track_spots_1 = track_spots(ismember(track_spots.CHANNEL_NUMBER, 1),:);
track_spots_1 = track_spots_1(:,{'CHANNEL_NUMBER','FRAME', 'CELL_NAME','SYSTEM_NAME','ID'});
track_spots_1 = grpstats(track_spots_1, {'CHANNEL_NUMBER', 'FRAME','CELL_NAME','SYSTEM_NAME'});
track_spots_1.GroupCount(track_spots_1.GroupCount>GRB2SUMAFTERFRAMES,:) = GRB2SUMAFTERFRAMES;
track_spots_1.Properties.VariableNames{5} = 'NUMBEROFSPOTS';
track_spots_1 = grpstats(track_spots_1, {'CHANNEL_NUMBER','CELL_NAME','SYSTEM_NAME','NUMBEROFSPOTS'});
  
figure()
to_plot = gramm('x', [zeros(length(cells16),1);zeros(length(cells13),1);track_spots_1.NUMBEROFSPOTS], 'y',[count_zero_lig16;count_zero_grb213;track_spots_1.GroupCount] , 'color',[repmat({'16'},length(cells16),1);repmat({'13'},length(cells13),1);track_spots_1.SYSTEM_NAME]);
to_plot.stat_summary('type', 'sem','geom',{'bar','black_errorbar'},'bin_in', GRB2SUMAFTERFRAMES,'dodge', 1);
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'Frequency','x','Spots in frame');
to_plot.set_layout_options('legend', false, 'redraw', false);
to_plot.axe_property('YLim', [0 200], 'XLim', [0 GRB2SUMAFTERFRAMES]);
to_plot.draw();
to_plot.export('file_name', 'grb2_spots_in_frame','export_path',path_to_output, 'file_type','svg');
close all;

spots_2 = spots(ismember(spots.CHANNEL_NUMBER, 2),:);
spots_2 = spots_2(:,{'CHANNEL_NUMBER','FRAME', 'CELL_NAME','SYSTEM_NAME','ID'});
spots_2 = grpstats(spots_2, {'CHANNEL_NUMBER', 'FRAME','CELL_NAME','SYSTEM_NAME'});
spots_2.GroupCount(spots_2.GroupCount>ERKSUMAFTERFRAMES,:) = ERKSUMAFTERFRAMES;
spots_2.Properties.VariableNames{5} = 'NUMBEROFSPOTS';
spots_2 = grpstats(spots_2, {'CHANNEL_NUMBER','CELL_NAME','SYSTEM_NAME','NUMBEROFSPOTS'});

figure()
to_plot = gramm('x', [zeros(length(cells16),1);zeros(length(cells13),1);spots_2.NUMBEROFSPOTS], 'y',[count_zero_mek16;count_zero_erk13;spots_2.GroupCount] , 'color',[repmat({'16'},length(cells16),1);repmat({'13'},length(cells13),1);spots_2.SYSTEM_NAME]);
to_plot.stat_summary('type', 'sem','geom',{'bar','black_errorbar'},'bin_in', ERKSUMAFTERFRAMES,'dodge', 1);
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'Frequency','x','Spots in frame');
%to_plot.set_layout_options('legend', false, 'redraw', false);
to_plot.axe_property('YLim', [0 300], 'XLim', [0 ERKSUMAFTERFRAMES]);
to_plot.draw();
to_plot.export('file_name', 'erk_spots_in_frame','export_path',path_to_output, 'file_type','svg');
close all;