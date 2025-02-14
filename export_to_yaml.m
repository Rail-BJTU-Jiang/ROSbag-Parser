% write a matlab script to export the calibration data to a yaml file that can be load by opencv
% the yaml file will be saved in the same folder as the calibration data
% the yaml file will be named as 'calibration.yaml'
% the yaml file will contain the following data:
% %YAML:1.0
% camera_matrix: !!opencv-matrix
%    rows: 3
%    cols: 3
%    dt: d
%    data: [ 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 ]
% dist_coeff: !!opencv-matrix
%    rows: 1
%    cols: 5
%    dt: d
%    data: [ 0.0, 0.0, 0.0, 0.0, 0.0 ]
% image_width: 640
% image_height: 480
% %End of the file

% get the calibration data
function export_to_yaml(cameraParams, varargin)
    K = cameraParams.K;
    rad_dist = cameraParams.RadialDistortion;
    % if the camera has tangential distortion
    try
        tang_dist = cameraParams.TangentialDistortion;
    catch
        tang_dist = [0, 0];
    end
    dist = [rad_dist(1), rad_dist(2), tang_dist(1), tang_dist(2), rad_dist(3)];
    height = cameraParams.ImageSize(1);
    width = cameraParams.ImageSize(2);
    % write out the yaml file
    file = fopen('calibration.yaml', 'w');
    fprintf(file, '%%YAML:1.0\n');
    fprintf(file, 'camera_matrix: !!opencv-matrix\n');
    fprintf(file, '   rows: 3\n');
    fprintf(file, '   cols: 3\n');
    fprintf(file, '   dt: d\n');
    % 12.12f
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f ]\n', K(1, 1), K(1, 2), K(1, 3), K(2, 1), K(2, 2), K(2, 3), K(3, 1), K(3, 2), K(3, 3));
    fprintf(file, 'dist_coeff: !!opencv-matrix\n');
    fprintf(file, '   rows: 1\n');
    fprintf(file, '   cols: 5\n');
    fprintf(file, '   dt: d\n');
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f, %12.12f, %12.12f ]\n', dist(1), dist(2), dist(3), dist(4), dist(5));
    fprintf(file, 'image_width: %d\n', width);
    fprintf(file, 'image_height: %d\n', height);
    fprintf(file, '%%End of the file\n');
    fclose(file);
end