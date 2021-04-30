path_to_variable = 'D:\shmidt\Dropbox\Arbeit\MPIIB\trackmate_data\MEK16mer\Yevin_20180731_JRT3_03\20180731_JRT3_03_ligand_paper'
path_to_output = 'D:\shmidt\Dropbox\Arbeit\MPIIB\Figures\1B'

reference_track_54 = 'DNA LIGAND_Track_54' 
reference_track_224 = 'DNA LIGAND_Track_244' 

load ([path_to_variable '\track_variables.mat']);
%plot 54
colocolzed_54= dist_assoc_time_analysis_table_filtered(ismember(dist_assoc_time_analysis_table_filtered.TRACK_KEY_ref_track_spots_table, reference_track_54),:);
ligand = all_track_spots(ismember(all_track_spots.TRACK_KEY, reference_track_54),:);
ligand_max_frame = max(ligand.FRAME)
mek =  all_track_spots(ismember(all_track_spots.TRACK_KEY, colocolzed.TRACK_KEY_track_spots_table),:);
ligand_mek = [ligand;mek];
ligand_mek = sortrows(ligand_mek,'FRAME');
ligand_mek = ligand_mek(ligand_mek.FRAME<=ligand_max_frame,:);
to_plot = gramm('x',ligand_mek.POSITION_X,'y', ligand_mek.FRAME, 'z', ligand_mek.POSITION_Y, 'color', ligand_mek.TRACK_KEY);
to_plot.geom_line();
to_plot.geom_label('color', 'k', 'FontSize', 2);
to_plot.set_line_options('base_size', 0.5)
to_plot.set_order_options('x', 0);
to_plot.set_layout_options('legend', false, 'redraw', false)
to_plot.axe_property('YLim', [40 ligand_max_frame] ,'ZLim', [5 8], 'Box', 'on', 'Boxstyle', 'full' ,'DataAspectRatio', [1 5 1], 'view', [75 -25])
to_plot.set_names('x', 'Position X', 'y', 'Frame','z', 'Position Y', 'color', 'Tracks');
to_plot.draw();
to_plot.export('file_name', reference_track_54,'export_path',path_to_output, 'file_type','svg');
close all;

%plot 224
colocolzed = dist_assoc_time_analysis_table_filtered(ismember(dist_assoc_time_analysis_table_filtered.TRACK_KEY_ref_track_spots_table, reference_track_224),:);
ligand = all_track_spots(ismember(all_track_spots.TRACK_KEY, reference_track_224),:);
ligand_min_frame = min(ligand.FRAME)
ligand_max_frame = max(ligand.FRAME)
mek =  all_track_spots(ismember(all_track_spots.TRACK_KEY, colocolzed.TRACK_KEY_track_spots_table),:);
ligand_mek = [ligand;mek];
ligand_mek = sortrows(ligand_mek,'FRAME');
ligand_mek = ligand_mek(ligand_mek.FRAME<=ligand_max_frame,:);
to_plot = gramm('x',ligand_mek.POSITION_X,'y', ligand_mek.FRAME, 'z', ligand_mek.POSITION_Y, 'color', ligand_mek.TRACK_KEY);
to_plot.geom_line();
to_plot.geom_label('color', 'k', 'FontSize', 2);
to_plot.set_line_options('base_size', 0.5)
to_plot.set_order_options('x', 0);
to_plot.set_layout_options('legend', false, 'redraw', false)
to_plot.axe_property('YLim', [ligand_min_frame ligand_max_frame] ,'ZLim', [8 11], 'Box', 'on', 'Boxstyle', 'full' ,'DataAspectRatio', [1 10 1], 'view', [75 -25])
to_plot.set_names('x', 'Position X', 'y', 'Frame','z', 'Position Y', 'color', 'Tracks');
to_plot.set_color_options('map',[ 0 0.6 0.3;1 0 0;0 0 0])
to_plot.draw();
to_plot.export('file_name', reference_track_224,'export_path',path_to_output, 'file_type','svg');
close all;