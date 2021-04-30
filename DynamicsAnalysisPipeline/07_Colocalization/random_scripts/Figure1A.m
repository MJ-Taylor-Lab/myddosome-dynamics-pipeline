path_to_variable = 'D:\shmidt\Dropbox\Arbeit\MPIIB\trackmate_data\MEK16mer\Yevin_20180731_JRT3_03\20180731_JRT3_03_ligand_paper'
path_to_output = 'D:\shmidt\Dropbox\Arbeit\MPIIB\Figures\1A'
MIN_TIME = 30

load ([path_to_variable '\track_variables.mat']);

%plot ligand dwelltime
ligand = all_track_spots(ismember(all_track_spots.CHANNEL_NUMBER, 1),:);
ligand = join(ligand,  all_tracks, 'Keys', {'TRACK_KEY', 'CHANNEL_NUMBER'});
ligand = ligand(ligand.TIME_CALIBRATED>=MIN_TIME,:);

ligand_plot= gramm('x', ligand.POSITION_X, 'y', ligand.POSITION_Y, 'color', ligand.NUMBER_SPOTS, 'group', ligand.TRACK_KEY);
ligand_plot.geom_line();
ligand_plot.set_continuous_color('colormap', 'jet')
ligand_plot.set_line_options('base_size', 0.1 )
ligand_plot.set_names('x', 'Position X', 'y', 'Position Y', 'Color', 'Dwelltime');
ligand_plot.axe_property('YLim', [0 16.47], 'XLim', [0 16.47], 'DataAspectRatio', [1 1 1])
ligand_plot.draw();
ligand_plot.export('file_name', 'ligand_tracks_dwelltime','export_path',path_to_output, 'file_type','svg');
close all;

%plot mek dwelltime
mek = all_track_spots(ismember(all_track_spots.CHANNEL_NUMBER, 2),:);
mek = join(mek,  all_tracks, 'Keys', {'TRACK_KEY', 'CHANNEL_NUMBER'});
mek_plot= gramm('x', mek.POSITION_X, 'y', mek.POSITION_Y, 'color', mek.NUMBER_SPOTS, 'group', mek.TRACK_KEY);
mek_plot.geom_line();
mek_plot.set_continuous_color('colormap', 'jet')
mek_plot.set_line_options('base_size',0.1 )
mek_plot.set_names('x', 'Position X', 'y', 'Position Y', 'Color', 'Dwelltime');
mek_plot.axe_property('YLim', [0 16.47], 'XLim', [0 16.47], 'DataAspectRatio', [1 1 1])
mek_plot.draw();
mek_plot.export('file_name', 'mek_tracks_dwelltime','export_path',path_to_output, 'file_type','svg');
close all;

%plot ligand mek merged dwelltime 
merged_plot= gramm('x', [ligand.POSITION_X; mek.POSITION_X], 'y', [ligand.POSITION_Y; mek.POSITION_Y], 'color', [ligand.CHANNEL_NUMBER; mek.CHANNEL_NUMBER], 'group', [ligand.TRACK_KEY; mek.TRACK_KEY]);
merged_plot.geom_line();
merged_plot.set_line_options('base_size',0.1 )
merged_plot.set_names('x', 'Position X', 'y', 'Position Y', 'Color', 'Dwelltime');
merged_plot.axe_property('YLim', [0 16.47], 'XLim', [0 16.47], 'DataAspectRatio', [1 1 1])
merged_plot.draw();
merged_plot.export('file_name', 'lig_mek_merged_tracks_dwelltime','export_path',path_to_output, 'file_type','svg');
close all;