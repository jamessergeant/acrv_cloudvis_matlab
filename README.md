# webcam_cloudvis
MATLAB class for sending webcam images to ACRV Cloud Robotic Vision System

## Example use

Setup:
```
% can provide a string input for other algorithms, default is 'objectDetection' which utilises Faster-RCNN
% Currently only parsing of the objectDetection algorithm results is implemented
% save_dir for saving of rendered image
% confidence_threshold for ignoring regions upon rendering with classification values less than this
acrvs = ACRVCloudVisionService('algorithm','objectDetection','save_dir','path/to/save/dir','confidence_threshold',0.1);
```

Files:
```
% to send a single file
acrvs.fileImage('/path/to/file.png'); % or jpg

% to send all image files (png or jpg only)
acrvs.fileDirectory('/path/to/dir')
```

Webcam:
```
% initialise webcam, webcamSingleImage also calls this function if not initialised
acrvs.initWebcam();

% to send a single image
acrvs.webcamSingleImage();

% to continually send images, Ctrl+C to terminate
acrvs.webcamContinuous();
```

Properties:
```
% the original image is stored in
acrvs.image

% results are stored in the struct
acrvs.output

% an image showing results with confidence
acrvs.image_rendered
```
