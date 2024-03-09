data = struct('time', '','chair','','stool','','table','','wall','');

for i = 1:size(labels, 1)
    time = labels.Time(i);
    data(i).time = char(time);
    data(i).chair=labels.chair{i};
    data(i).stool=labels.stool{i};
    data(i).table=labels.table{i};
    data(i).wall=labels.wall{i};
end
disp(data);
% % Convert the structure to a JSON xstring
jsonStr = jsonencode(data);
% 
% % Write the JSON string to a file
filename = 'data_2.json';
fid = fopen(filename, 'w');
fprintf(fid, '%s', jsonStr);
fclose(fid);

disp(['JSON data has been saved to ', filename]);
