MAX_DWELLTIME_SEC = 200
%%%%%%%%%%%%%%%%%%%%13 MER

path_to_data = 'D:\shmidt\Dropbox\Arbeit\MPIIB\trackmate_data';
path_to_output = 'D:\shmidt\Dropbox\Arbeit\MPIIB\Figures\3D';

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

tracks = [];
cells13 = strcat(mek_13,cells13);
system_13 = '13';
for num = 1:length(cells13)
    
    load ([cells13{num} '\' 'track_variables.mat']);
    all_tracks =addvars(all_tracks, repmat(cells13(num), height(all_tracks), 1), repmat({system_13}, height(all_tracks), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    tracks = [tracks; all_tracks];
    
end

cells16 = strcat(mek_16,cells16);
system_16 = '16';
for num = 1:length(cells16)
    load ([cells16{num} '\' 'track_variables.mat']);
    all_tracks =addvars(all_tracks, repmat(cells16(num), height(all_tracks), 1), repmat({system_16}, height(all_tracks), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    tracks = [tracks; all_tracks];
end
tracks = tracks(ismember(tracks.CHANNEL_NUMBER, 2),:);

tracks_13 = tracks(ismember(tracks.SYSTEM_NAME,'13'),:);
tracks_13 = tracks_13(tracks_13.TIME_CALIBRATED<=MAX_DWELLTIME_SEC,:)


figure()
to_plot = gramm('x', round(tracks_13.TIME_CALIBRATED,0), 'y',tracks_13.LINEARITY_OF_FORWARD_PROGRESSION, 'color', tracks_13.SYSTEM_NAME);
to_plot.stat_summary('type', 'sem','geom',{'bar','black_errorbar'}, 'dodge', 1);
to_plot.axe_property('XLim', [0 50], 'YLim', [0 1] );
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'Linearity','x','Lifetime (sec)');
to_plot.draw();
to_plot.export('file_name', 'linear_13','export_path',path_to_output, 'file_type','svg');
%close all;

tracks_16 = tracks(ismember(tracks.SYSTEM_NAME,'16'),:);
tracks_16 = tracks_16(tracks_16.TIME_CALIBRATED<=MAX_DWELLTIME_SEC,:)

figure()
to_plot = gramm('x', round(tracks_16.TIME_CALIBRATED,0), 'y',tracks_16.LINEARITY_OF_FORWARD_PROGRESSION, 'color', tracks_16.SYSTEM_NAME);
to_plot.stat_summary('type', 'sem','geom',{'bar','black_errorbar'}, 'dodge', 1);
to_plot.axe_property('XLim', [0 inf],'YLim', [0 1] );
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'Linearity','x','Lifetime (sec)');
to_plot.draw();
to_plot.export('file_name', 'linear_16','export_path',path_to_output, 'file_type','svg');
%close all;
