classdef WebcamVisionService < handle
    % WEBCAMVISIONSERVICE
    % 
    % objectDetection detects objects of the following classes:
    % Aeroplane, bicycle, bird, boat, bottle, bus, car, cat, chair, cow, 
    % dining table, dog, horse, motorbike, person, potted plant, sheep, 
    % sofa, train, tv monitor 
    
    properties (SetAccess = private)
        
        output
        image
        image_rendered
        
    end
    
    properties (Access = private)
        
        root_url = 'http://cloudvis.qut.edu.au/'
        camera
        algorithm
        fig
        results
        activation_threshold = 0.1
        multiplier
        save_dir = '/home/james/Dropbox/PhD/Faster-RCNN'
    end
    
    methods
        
        function obj = WebcamVisionService(varargin)
            
            p = inputParser;
            p.CaseSensitive = false;
            p.PartialMatching = false;
            addParameter(p,'algorithm','objectDetection',@ischar);
            
            parse(p,varargin{:});            
            
            fields = fieldnames(p.Results); 

            for i = 1:numel(fields)
            	obj.(fields{i}) = p.Results.(fields{i});
            end
            
            wcl = webcamlist;
            
            if isempty(wcl)
                error('MATLAB:WebcamVisionService','No webcams found');
            end
            
            obj.camera = webcam;
            
        end
        
        function algorithms = getServiceOptions(obj)
            
            algorithms = fieldnames(webread('http://cloudvis.qut.edu.au'));
            
        end
        
        function setAlgorithm(obj,algorithm)
            
            obj.algorithm = algorithm;
            
        end
            
        
        function singleimage(obj)
            
            obj.image = snapshot(obj.camera);
               
            if ~isdir('~/.tmp/')
                mkdir('~/.tmp/');
            end
            
            imwrite(obj.image, '~/.tmp/image.png');
            imageFile = fopen('~/.tmp/image.png');
            imageFile = fread(imageFile,Inf,'*uint8');

            obj.results = urlreadpost([obj.root_url obj.algorithm],{'image',imageFile});
            
            obj.post_process();
            
        end
        
        function post_process(obj)
            
            switch obj.algorithm
                
                case 'objectDetection'
                    
                    obj.parseObjDetResults();

                    obj.renderObjDetImage();        

                    obj.saveObjDetRendered();
                    
                otherwise
                    
                    fprintf('Post processing has not been implemented for the current algorithm\n');
                    
            end
            
        end
        
        function continuous(obj)
            
            obj.fig = figure;
            
            warning('off','images:initSize:adjustingMag');
            
            while (1)
                
                obj.singleimage();
                
                imshow(obj.image_rendered);
                
            end

            
        end
        
        function parseObjDetResults(obj)
            
            results_cell = strsplit(obj.results,{'{','"',':',' ',',','[',']','}'});
            results_cell = results_cell(2:end-1);
            
            for i = 1:length(results_cell)
                if ~isnan(str2double(results_cell{i}))
                    results_cell{i} = str2double(results_cell{i});
                end
            end
            
            count = 1;
            bb_count = 1;
            obj.output = {};
            
            for i = 1:length(results_cell)
                if ischar(results_cell{i})
                    class = results_cell{i};
                    bb_count = 1;
                else
                    switch count
                        case 1
                            obj.output.(class)(bb_count).bb.tl.x = results_cell{i};                            
                                                        
                        case 2
                            obj.output.(class)(bb_count).bb.tl.y = results_cell{i};                            
                            
                        case 3
                            obj.output.(class)(bb_count).bb.br.x = results_cell{i};
                            
                        case 4
                            obj.output.(class)(bb_count).bb.br.y = results_cell{i};
                            
                        case 5
                            obj.output.(class)(bb_count).confidence = results_cell{i};
                            count = 1;
                            bb_count = bb_count + 1;
                            continue
                    end
                    
                    count = count + 1;
                end
            end
            
        end
        
        function renderObjDetImage(obj)
            
            obj.image_rendered = obj.image;
            
            if ~iscell(obj.output)
                
                fields = fieldnames(obj.output);

                colours = 'ymcrgbw';

                for i = 1:length(fields)

                    for j = 1:length(obj.output.(fields{i}))

                        if obj.output.(fields{i})(j).confidence > obj.activation_threshold

                            width = obj.output.(fields{i})(j).bb.br.x - obj.output.(fields{i})(j).bb.tl.x;
                            height = obj.output.(fields{i})(j).bb.br.y - obj.output.(fields{i})(j).bb.tl.y;

                            rectangle = int32([obj.output.(fields{i})(j).bb.tl.x obj.output.(fields{i})(j).bb.tl.y width height]);

                            obj.image_rendered = insertShape(obj.image_rendered, 'rectangle', rectangle, 'color',colours(i),'opacity', obj.output.(fields{i})(j).confidence);
                            obj.image_rendered = insertText(obj.image_rendered, rectangle(1:2), [fields{i} ': ' num2str(obj.output.(fields{i})(j).confidence)],'BoxOpacity',0.2,'boxcolor',colours(i),'textcolor',colours(i));

                        end

                    end

                end
                
            end
            
            
        end
        
        function saveObjDetRendered(obj)
                        
            if ~isdir(obj.save_dir)
                mkdir(obj.save_dir);
            end
            
            imwrite(obj.image_rendered,[obj.save_dir '/trial-' num2str(now) '.png']);
            
        end
        
    end
end