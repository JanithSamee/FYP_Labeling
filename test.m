% Define the coordinates of the points
points = [0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 1, 0]; % Points are in 3D, but z-coordinate is 0 for simplicity
points_new = [-0.271, 0.5, 0; 0.5, 1.271, 0; 1.271, 0.5, 0; 0.5, -0.271, 0];

% Create a point cloud object
ptCloud = pointCloud(points);
ptCloudnew = pointCloud(points_new);


normals = pcdenoise(ptCloud);
centroid = mean(normals.Location);


normalsnew = pcdenoise(ptCloudnew);
centroidnew = mean(normalsnew.Location);
disp(centroidnew(1))

% Translation Matrix
translation_vector = centroidnew - centroid;
translation_matrix = eye(4);
translation_matrix(1:3, 4) = translation_vector;

% Rotation Matrix (assuming rotation about the z-axis)
delta_x = centroidnew(1) - centroid(1);
delta_y = centroidnew(2) - centroid(2);
theta = atan2(delta_y, delta_x); % Angle of rotation
rotation_matrix = [cos(theta), -sin(theta), 0, 0;
                   sin(theta), cos(theta), 0, 0;
                   0, 0, 1, 0;
                   0, 0, 0, 1];

% Combined Transformation Matrix
combined_matrix = translation_matrix * rotation_matrix;

% Display the results
disp("Translation Matrix:");
disp(translation_matrix);
disp("Rotation Matrix:");
disp(rotation_matrix);
disp("Combined Transformation Matrix:");
disp(combined_matrix);






% 
% [tform, ~, ~] = pcregistericp(ptCloudnew, ptCloud);
% disp(tform);
% % Visualize the point cloud
% figure;
% pcshow(ptCloud,'MarkerSize', 100);
% hold on;
% pcshow(ptCloudnew, 'MarkerSize', 100); % Adjust properties as needed
% hold off;
% title('Rectangular Point Cloud');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% axis equal; % Ensure equal scaling on all axes
% grid on; % Show grid
