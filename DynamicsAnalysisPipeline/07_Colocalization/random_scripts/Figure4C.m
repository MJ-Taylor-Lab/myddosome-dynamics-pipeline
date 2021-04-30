path_to_data = 'D:\shmidt\Dropbox\Arbeit\MPIIB\trackmate_data';
path_to_output = 'D:\shmidt\Dropbox\Arbeit\MPIIB\Figures\4C';

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

tracks = [];
cells13 = strcat(erk_13,cells13);
system_13 = '13';
for num = 1:length(cells13)
    
    load ([cells13{num} '\' 'track_variables.mat']);
    all_tracks =addvars(all_tracks, repmat(cells13(num), height(all_tracks), 1), repmat({system_13}, height(all_tracks), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    tracks = [tracks; all_tracks];
    
end

cells16 = strcat(erk_16,cells16);
system_16 = '16';
for num = 1:length(cells16)
    load ([cells16{num} '\' 'track_variables.mat']);
    all_tracks =addvars(all_tracks, repmat(cells16(num), height(all_tracks), 1), repmat({system_16}, height(all_tracks), 1), 'NewVariableNames',{'CELL_NAME', 'SYSTEM_NAME'});
    tracks = [tracks; all_tracks];
    
end

all_tracks_channel2 = tracks(ismember(tracks.CHANNEL_NUMBER, 2),:);
all_tracks_channel2 = all_tracks_channel2(:,{'COLOCALIZATION','CELL_NAME','SYSTEM_NAME','NUMBER_SPOTS'});
all_tracks_channel2_col = all_tracks_channel2(ismember(all_tracks_channel2.COLOCALIZATION, 'YES'),:);
all_tracks_channel2_col = grpstats(all_tracks_channel2_col, {'COLOCALIZATION','CELL_NAME', 'SYSTEM_NAME'});
all_tracks_channel2 = all_tracks_channel2(:,{'CELL_NAME','SYSTEM_NAME','NUMBER_SPOTS'});
all_tracks_channel2_all = grpstats(all_tracks_channel2, {'CELL_NAME', 'SYSTEM_NAME'});all_tracks_channel2_all.CELL_NAME;

for k=1:length(all_tracks_channel2_all.CELL_NAME)
    cell=all_tracks_channel2_all.CELL_NAME{k};
    try
        all_tracks_channel2_all(ismember(all_tracks_channel2_all.CELL_NAME,cell),:).GroupCount = all_tracks_channel2_col(ismember(all_tracks_channel2_col.CELL_NAME,cell),:).GroupCount /all_tracks_channel2_all(ismember(all_tracks_channel2_all.CELL_NAME,cell),:).GroupCount
    catch
        all_tracks_channel2_all(ismember(all_tracks_channel2_all.CELL_NAME,cell),:).GroupCount =0;
    end
end

figure(1)
to_plot = gramm('x', all_tracks_channel2_all.SYSTEM_NAME, 'y',all_tracks_channel2_all.GroupCount);
to_plot.stat_summary('type', 'sem','geom',{'bar','black_errorbar'});
to_plot.axe_property('YLim', [0 0.025] );
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'COLOCALIZED','x','DNA');
to_plot.set_layout_options('legend', false, 'redraw', false);
to_plot.draw();
to_plot.export('file_name', 'ERK_percentage','export_path',path_to_output, 'file_type','svg');
close all;