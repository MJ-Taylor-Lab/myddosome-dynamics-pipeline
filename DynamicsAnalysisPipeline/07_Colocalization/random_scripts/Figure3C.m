LIGANDSUMAFTERFRAMES = 20
MEKSUMAFTERFRAMES = 6
%%%%%%%%%%%%%%%%%%%%13 MER

path_to_data = 'D:\shmidt\Dropbox\Arbeit\MPIIB\trackmate_data';
path_to_output = 'D:\shmidt\Dropbox\Arbeit\MPIIB\Figures\3C';

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
to_plot.axe_property('YLim', [0 0.03] );
to_plot.set_line_options('base_size', 0.2)
to_plot.set_names('y', 'COLOCALIZED','x','DNA');
to_plot.set_layout_options('legend', false, 'redraw', false);
to_plot.draw();
to_plot.export('file_name', 'mek_percentage','export_path',path_to_output, 'file_type','svg');
close all;