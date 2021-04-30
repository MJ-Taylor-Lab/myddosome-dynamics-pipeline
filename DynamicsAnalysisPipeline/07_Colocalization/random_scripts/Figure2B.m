path_to_variable = 'C:\Users\alex\Dropbox\Arbeit\MPIIB\trackmate_data\ERK16mer\20180718-02-cell1-grb2_paper'
path_to_output = 'C:\Users\alex\Dropbox\Arbeit\MPIIB\Figures\2B'

reference_track_375 = 'GRB2_Track_375' 
other_track_375 = 'ERK_Track_333'

load ([path_to_variable '\track_variables.mat']);
%plot 375
figure()
colocolzed = dist_assoc_time_analysis_table_filtered(ismember(dist_assoc_time_analysis_table_filtered.TRACK_KEY_ref_track_spots_table, reference_track_375),:);
colocolzed = colocolzed(ismember(colocolzed.TRACK_KEY_track_spots_table, other_track_375),:)
ligand = all_track_spots(ismember(all_track_spots.TRACK_KEY, reference_track_375),:);
ligand_max_frame = max(ligand.FRAME)
mek =  all_track_spots(ismember(all_track_spots.TRACK_KEY, colocolzed.TRACK_KEY_track_spots_table),:);
ligand_mek = [ligand;mek];
ligand_mek = sortrows(ligand_mek,'FRAME');
ligand_mek = ligand_mek(ligand_mek.FRAME<=ligand_max_frame,:);
to_plot = gramm('x',ligand_mek.POSITION_X,'y', ligand_mek.FRAME, 'z', ligand_mek.POSITION_Y, 'color', ligand_mek.TRACK_KEY);
to_plot.geom_line();
to_plot.geom_label('color', 'k', 'FontSize', 2);
to_plot.set_line_options('base_size', 0.5)
to_plot.set_order_options('color', 0);
to_plot.set_layout_options('legend', false, 'redraw', false)
to_plot.axe_property('YLim', [250 inf], 'Box', 'on', 'Boxstyle', 'full' ,'DataAspectRatio', [1 20 1], 'view', [75 -25])
to_plot.axe_property( 'Box', 'on', 'Boxstyle', 'full' ,'DataAspectRatio', [1 20 1], 'view', [75 -25])
to_plot.set_names('x', 'Position X', 'y', 'Frame','z', 'Position Y', 'color', 'Tracks');
to_plot.draw();
to_plot.export('file_name', reference_track_375,'export_path',path_to_output, 'file_type','svg');%close all;

figure()
reference_track_4 = 'GRB2_Track_4' 

%plot 375
colocolzed = dist_assoc_time_analysis_table_filtered(ismember(dist_assoc_time_analysis_table_filtered.TRACK_KEY_ref_track_spots_table, reference_track_4),:);
ligand = all_track_spots(ismember(all_track_spots.TRACK_KEY, reference_track_4),:);
ligand_max_frame = max(ligand.FRAME)
mek =  all_track_spots(ismember(all_track_spots.TRACK_KEY, colocolzed.TRACK_KEY_track_spots_table),:);
ligand_mek = [ligand;mek];
ligand_mek = sortrows(ligand_mek,'FRAME');
ligand_mek = ligand_mek(ligand_mek.FRAME<=ligand_max_frame,:);
to_plot = gramm('x',ligand_mek.POSITION_X,'y', ligand_mek.FRAME, 'z', ligand_mek.POSITION_Y, 'color', ligand_mek.TRACK_KEY);
to_plot.geom_line();
to_plot.geom_label('color', 'k', 'FontSize', 2);
to_plot.set_line_options('base_size', 0.5)
to_plot.set_order_options('color', 0);
to_plot.set_layout_options('legend', false, 'redraw', false)
to_plot.axe_property('YLim', [0 inf], 'ZLim', [6 10], 'Box', 'on', 'Boxstyle', 'full' ,'DataAspectRatio', [1 20 1], 'view', [75 -25])
to_plot.axe_property( 'Box', 'on', 'Boxstyle', 'full' ,'DataAspectRatio', [1 50 4], 'view', [75 -25])
to_plot.set_names('x', 'Position X', 'y', 'Frame','z', 'Position Y', 'color', 'Tracks');
to_plot.set_color_options('map',[ 0 0.6 0.3;1 0 0;1 0 0])
to_plot.draw();
to_plot.export('file_name', reference_track_4,'export_path',path_to_output, 'file_type','svg');
close all;