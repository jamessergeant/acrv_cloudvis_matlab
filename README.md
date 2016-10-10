# webcam_cloudvis
MATLAB class for sending webcam images to ACRV Cloud Robotic Vision System

## Example use

```
% can provide a string input for other algorithms, default is 'objectDetection' which utilises Faster-RCNN
% Currently only objectDetection results parsing is implemented
wvs = WebcamVisionService('algorithm','objectDetection','save_dir','path/to/save/dir'); 

% to send a single image
wvs.singleimage()

% to continually send images, Ctrl+C to terminate
wvs.continuous()

% the original image is stored in
wvs.image

% results are stored in the struct
wvs.output

% an image showing results with confidence
wvs.image_rendered
```
