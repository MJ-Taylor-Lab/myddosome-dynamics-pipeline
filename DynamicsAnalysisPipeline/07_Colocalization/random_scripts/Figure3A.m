FRAMEWINDOW = 500;
LIGANDSUMAFTERFRAMES = 20;
MEKSUMAFTERFRAMES = 6;

path_to_data = 'D:\shmidt\Dropbox\Arbeit\MPIIB\trackmate_data';
path_to_output = 'D:\shmidt\Dropbox\Arbeit\MPIIB\Figures\3A';

cell13_1 = 'Yevin_20180815_02_13_mer_cell1\20180815 _02_cell1_647';
cell13_2 = 'Yevin_20180815_02_13_mer_cell2\20180815_02_cell2_647';
cell13_3 = '20180815 JRT3(cl019) 13mer_03 cell2\20180815 JRT3(cl019) 13mer_03_cell2 lig_v2';
cell13_4 = '20180815 JRT3(cl019) 13mer_03_cell1\20180815 JRT3(cl019) 13mer_03_cell1 lig';
cell13_5 = '20180815 JRT3(cl019) 13mer_03_cell4\20180815 JRT3(cl019) 13mer_03_cell4 lig';
cell13_6 = '20180815 JRT3(cl019) 13mer_04_cell4\20180815 JRT3(cl019) 13mer_04_cell4 lig';
cells13 = {cell13_1, cell13_2, cell13_3, cell13_4, cell13_5, cell13_6};

cell16_1 = 'Yevin_20180731_JRT3_03\20180731_JRT3_03_ligand_paper';
cell16_2 = 'Yevin_20180816_01_16_mer_cell1\20180816_JRT3_ligand';
cell16_3 = 'Yevin_20180816_01_16_mer_cell2\20180816_01_cell2_647';
cell16_4 = 'Yevin_20180816_01_16_mer_Cell3\20180816_ligand';
cell16_5 = 'Yevin_20180816_03_16_mer_cell3\20180816_JRT3_ligand_647';
cells16 = {cell16_1, cell16_2, cell16_3, cell16_4, cell16_5};
mek_13 = [path_to_data '\' 'MEK13mer' '\'];
mek_16 = [path_to_data '\' 'MEK16mer' '\'];

track_spots = [];
spots = [];
count_zero_lig13 = [];
count_zero_mek13 = [];
cells13 = strcat(mek_13,cells13);
system_13 = '13';
for num = 1:length(cells13)
    
    load ([cells13{num} '\' 'track_variables.mat']);
    all_track_spots =addvars(all_track_spots, repmat(cells13(num), height(all_track_spots), 1), repmat({system_13}, height(all_track_spots), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    min_frame_ligand = min(all_track_spots(ismember(all_track_spots.CHANNEL_NUMBER, 1),:).FRAME);
    all_track_spots.FRAME = all_track_spots.FRAME - min_frame_ligand;
    all_track_spots = all_track_spots(all_track_spots.FRAME < FRAMEWINDOW,:);
    frames = 0:FRAMEWINDOW-1;
    frames = frames(~ismember(frames, all_track_spots.FRAME));
    count_zero_lig13 = [count_zero_lig13 ; length(frames)];
    track_spots = [track_spots; all_track_spots];
    
    all_spots =addvars(all_spots, repmat(cells13(num), height(all_spots), 1), repmat({system_13}, height(all_spots), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    all_spots.FRAME = all_spots.FRAME - min_frame_ligand;
    all_spots = all_spots(all_spots.FRAME>=0,:);
    all_spots = all_spots(all_spots.FRAME<FRAMEWINDOW,:);
    frames = 0:FRAMEWINDOW-1;
    frames = frames(~ismember(frames, all_spots.FRAME));
    count_zero_mek13 = [count_zero_mek13; length(frames)];
    spots = [spots; all_spots];
end

count_zero_lig16 = [];
count_zero_mek16 = [];
cells16 = strcat(mek_16,cells16);
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
track_spots_1.GroupCount(track_spots_1.GroupCount>LIGANDSUMAFTERFRAMES,:) = LIGANDSUMAFTERFRAMES;
track_spots_1.Properties.VariableNames{5} = 'NUMBEROFSPOTS';
track_spots_1 = grpstats(track_spots_1, {'CHANNEL_NUMBER','CELL_NAME','SYSTEM_NAME','NUMBEROFSPOTS'});
  
figure()
to_plot = gramm('x', [zeros(length(cells16),1);zeros(length(cells13),1);track_spots_1.NUMBEROFSPOTS], 'y',[count_zero_lig16;count_zero_lig13;track_spots_1.GroupCount] , 'color',[repmat({'16'},length(cells16),1);repmat({'13'},length(cells13),1);track_spots_1.SYSTEM_NAME]);
to_plot.stat_summary('type', 'sem','geom',{'bar','black_errorbar'},'bin_in', LIGANDSUMAFTERFRAMES,'dodge', 1);
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'Frequency','x','Spots in frame');
to_plot.set_layout_options('legend', false, 'redraw', false);
to_plot.axe_property('YLim', [0 250], 'XLim', [0 LIGANDSUMAFTERFRAMES]);
to_plot.draw();
to_plot.export('file_name', 'ligand_spots_in_frame','export_path',path_to_output, 'file_type','svg');
close all;

spots_2 = spots(ismember(spots.CHANNEL_NUMBER, 2),:);
spots_2 = spots_2(:,{'CHANNEL_NUMBER','FRAME', 'CELL_NAME','SYSTEM_NAME','ID'});
spots_2 = grpstats(spots_2, {'CHANNEL_NUMBER', 'FRAME','CELL_NAME','SYSTEM_NAME'});
spots_2.GroupCount(spots_2.GroupCount>MEKSUMAFTERFRAMES,:) = MEKSUMAFTERFRAMES;
spots_2.Properties.VariableNames{5} = 'NUMBEROFSPOTS';
spots_2 = grpstats(spots_2, {'CHANNEL_NUMBER','CELL_NAME','SYSTEM_NAME','NUMBEROFSPOTS'});

figure()
to_plot = gramm('x', [zeros(length(cells16),1);zeros(length(cells13),1);spots_2.NUMBEROFSPOTS], 'y',[count_zero_mek16;count_zero_mek13;spots_2.GroupCount] , 'color',[repmat({'16'},length(cells16),1);repmat({'13'},length(cells13),1);spots_2.SYSTEM_NAME]);
to_plot.stat_summary('type', 'sem','geom',{'bar','black_errorbar'},'bin_in', MEKSUMAFTERFRAMES,'dodge', 1);
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'Frequency','x','Spots in frame');
to_plot.set_layout_options('legend', false, 'redraw', false);
to_plot.axe_property('YLim', [0 180], 'XLim', [0 MEKSUMAFTERFRAMES]);
to_plot.draw();
to_plot.export('file_name', 'mek_spots_in_frame','export_path',path_to_output, 'file_type','svg');
close all;