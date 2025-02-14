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
function export_stereo_to_yaml(stereoParams)
    K1 = stereoParams.CameraParameters1.K;
    rad_dist = stereoParams.CameraParameters1.RadialDistortion;
    % if the camera has tangential distortion
    try
        tang_dist = stereoParams.CameraParameters1.TangentialDistortion;
    catch
        tang_dist = [0, 0];
    end
    dist1 = [rad_dist(1), rad_dist(2), tang_dist(1), tang_dist(2), rad_dist(3)];

    K2 = stereoParams.CameraParameters2.K;
    rad_dist = stereoParams.CameraParameters2.RadialDistortion;
    % if the camera has tangential distortion
    try
        tang_dist = stereoParams.CameraParameters2.TangentialDistortion;
    catch
        tang_dist = [0, 0];
    end
    dist2 = [rad_dist(1), rad_dist(2), tang_dist(1), tang_dist(2), rad_dist(3)];

    R = stereoParams.PoseCamera2.R;
    T = stereoParams.PoseCamera2.Translation;

    if strcmp(stereoParams.WorldUnits,'mm') || strcmp(stereoParams.WorldUnits,'millimeters')
        T = T / 1000;
    end

    % write out the yaml file
    file = fopen('calibration.yaml', 'w');
    fprintf(file, '%%YAML:1.0\n');
    fprintf(file, 'K1: !!opencv-matrix\n');
    fprintf(file, '   rows: 3\n');
    fprintf(file, '   cols: 3\n');
    fprintf(file, '   dt: d\n');
    % 12.12f
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f ]\n', K1(1, 1), K1(1, 2), K1(1, 3), K1(2, 1), K1(2, 2), K1(2, 3), K1(3, 1), K1(3, 2), K1(3, 3));
    fprintf(file, 'D1: !!opencv-matrix\n');
    fprintf(file, '   rows: 1\n');
    fprintf(file, '   cols: 5\n');
    fprintf(file, '   dt: d\n');
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f, %12.12f, %12.12f ]\n', dist1(1), dist1(2), dist1(3), dist1(4), dist1(5));


    fprintf(file, 'K2: !!opencv-matrix\n');
    fprintf(file, '   rows: 3\n');
    fprintf(file, '   cols: 3\n');
    fprintf(file, '   dt: d\n');
    % 12.12f
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f ]\n', K2(1, 1), K2(1, 2), K2(1, 3), K2(2, 1), K2(2, 2), K2(2, 3), K2(3, 1), K2(3, 2), K2(3, 3));
    fprintf(file, 'D2: !!opencv-matrix\n');
    fprintf(file, '   rows: 1\n');
    fprintf(file, '   cols: 5\n');
    fprintf(file, '   dt: d\n');
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f, %12.12f, %12.12f ]\n', dist2(1), dist2(2), dist2(3), dist2(4), dist2(5));

    fprintf(file, 'R: !!opencv-matrix\n');
    fprintf(file, '   rows: 3\n');
    fprintf(file, '   cols: 3\n');
    fprintf(file, '   dt: d\n');
    % 12.12f
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f, %12.12f ]\n', R(1, 1), R(1, 2), R(1, 3), R(2, 1), R(2, 2), R(2, 3), R(3, 1), R(3, 2), R(3, 3));
    fprintf(file, 'T: !!opencv-matrix\n');
    fprintf(file, '   rows: 1\n');
    fprintf(file, '   cols: 3\n');
    fprintf(file, '   dt: d\n');
    fprintf(file, '   data: [ %12.12f, %12.12f, %12.12f ]\n', T(1), T(2), T(3));
    fprintf(file, '%%End of the file\n');
    fclose(file);
end