% Parameters
screenWidth = 1920;
screenHeight = 1080;
sigma = 50;

% Create Gaussian kernel
kernelSize = round(6*sigma);
if mod(kernelSize, 2) == 0, kernelSize = kernelSize + 1; end
halfSize = floor(kernelSize / 2);
[xGrid, yGrid] = meshgrid(-halfSize:halfSize, -halfSize:halfSize);
gaussKernel = exp(-(xGrid.^2 + yGrid.^2) / (2*sigma^2));
gaussKernel = gaussKernel / sum(gaussKernel(:));

heatmapAlpha = 0.6;
heatmapThreshold = 0.01; 
bottomUpStimuli = [1, 3, 4];
topDownStimuli = [1,2,5];

% Bottom-Up Data
fprintf('=== Processing Bottom-Up Data ===\n');
bottomUpPath = './Bottom-Up/Data/';
stimuliPath = './Bottom-Up/'; 


edfFiles = dir([bottomUpPath '*.edf']);

for fileIdx = 1:length(edfFiles)
    try
        [~, filename_only, ~] = fileparts(edfFiles(fileIdx).name);
        edfNumber = str2double(filename_only);
        
        fprintf('Processing Bottom-Up EDF %d...\n', edfNumber);
        filename = fullfile(bottomUpPath, edfFiles(fileIdx).name);
        mat = Edf2Mat(filename);
        events = mat.RawEdf.FEVENT;
        
        for stimIdx = 1:length(bottomUpStimuli)
            stimNum = bottomUpStimuli(stimIdx);
            
            try
                startStimulusMsg = sprintf('StartStimulus %d', stimNum);
                startStimulusIdx = [];
                
                for i = 1:length(events)
                    if ~isempty(events(i).message) && contains(events(i).message, startStimulusMsg)
                        startStimulusIdx = i;
                        break;
                    end
                end
                
                if isempty(startStimulusIdx)
                    fprintf('Warning: StartStimulus %d not found in EDF %d\n', stimNum, edfNumber);
                    continue;
                end
                
                endStimulusMsg = sprintf('EndStimulus %d', stimNum);
                startResponseIdx = [];
                for i = (startStimulusIdx + 1):length(events)
                    if ~isempty(events(i).message) && contains(events(i).message, endStimulusMsg)
                        startResponseIdx = i;
                        break;
                    end
                end
                
                if isempty(startResponseIdx)
                    error('No EndStimulus found after StartStimulus %d in EDF %d', stimNum, edfNumber);
                end
                

                startTime = events(startStimulusIdx).sttime;
                endTime = events(startResponseIdx).sttime;
                
                fprintf('  Stimulus %d: Time range %.2f to %.2f ms\n', stimNum, startTime, endTime);
                

                startSaccIdx = [];
                endSaccIdx = [];
                
                for i = 1:length(events)
                    if strcmp(events(i).codestring, 'STARTSACC') && ...
                       events(i).sttime >= startTime && events(i).sttime <= endTime
                        startSaccIdx(end+1) = i;
                    elseif strcmp(events(i).codestring, 'ENDSACC') && ...
                           events(i).sttime >= startTime && events(i).sttime <= endTime
                        endSaccIdx(end+1) = i;
                    end
                end
                
                validPairs = [];
                for startIdx = 1:length(startSaccIdx)
                    startSaccTime = events(startSaccIdx(startIdx)).sttime;
                    
                    for endIdx = 1:length(endSaccIdx)
                        endSaccTime = events(endSaccIdx(endIdx)).sttime;
                        if endSaccTime > startSaccTime
                            % Check if both STARSacc and ENDSacc are within our time window
                            if startSaccTime >= startTime && endSaccTime <= endTime
                                validPairs(end+1, :) = [startSaccIdx(startIdx), endSaccIdx(endIdx)];
                            end
                            break;
                        end
                    end
                end
                
                if isempty(validPairs)
                    fprintf('  Warning: No valid saccad pairs found for stimulus %d in EDF %d\n', stimNum, edfNumber);
                    continue;
                end
                

                saccX = [];
                saccY = [];
                saccDuration = [];
                
                for pairIdx = 1:size(validPairs, 1)
                    startSaccEvent = events(validPairs(pairIdx, 1));
                    endSaccEvent = events(validPairs(pairIdx, 2));
                    
                    x = double(startSaccEvent.gstx);
                    y = double(startSaccEvent.gsty);
                    duration = double(endSaccEvent.entime) - double(startSaccEvent.sttime);

                    if x > 0 && x <= screenWidth && y > 0 && y <= screenHeight && ...
                       ~isnan(x) && ~isnan(y) && duration > 0
                        saccX(end+1) = x;
                        saccY(end+1) = y;
                        saccDuration(end+1) = duration;
                    end
                end
                
                fprintf('  Found %d valid saccad for stimulus %d\n', length(saccX), stimNum);
                
                if ~isempty(saccX)
                    heatmapMatrix = zeros(screenHeight, screenWidth);
                    
                    for i = 1:length(saccX)
                        x = round(saccX(i));
                        y = round(saccY(i));
                        if x >= 1 && x <= screenWidth && y >= 1 && y <= screenHeight
                            heatmapMatrix(y, x) = heatmapMatrix(y, x) + saccDuration(i);
                        end
                    end
                    
                    heatmapBlurred = conv2(heatmapMatrix, gaussKernel, 'same');
                    
                    if max(heatmapBlurred(:)) > 0
                        heatmapNormalized = heatmapBlurred / max(heatmapBlurred(:));
                    else
                        heatmapNormalized = heatmapBlurred;
                    end
                    
                    stimulusImagePath = fullfile(stimuliPath, sprintf('%d.jpg', stimNum));

                    stimulusFound = true;

                    
                    figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
                    
                    if ~isempty(stimulusImagePath) && exist(stimulusImagePath, 'file')
                        try
                            stimulusImg = imread(stimulusImagePath);
                            
                            if size(stimulusImg, 1) ~= screenHeight || size(stimulusImg, 2) ~= screenWidth
                                stimulusImg = imresize(stimulusImg, [screenHeight, screenWidth]);
                            end
                            
                            imshow(stimulusImg);
                            hold on;
                            
                            heatmapMask = heatmapNormalized > heatmapThreshold;
                            heatmapRGB = ind2rgb(uint8(heatmapNormalized * 255), jet(256));
                            
                            alphaChannel = heatmapMask * heatmapAlpha;
                            
                            h = imshow(heatmapRGB);
                            set(h, 'AlphaData', alphaChannel);
                            
                            title(sprintf('Bottom-Up: EDF %d - Stimulus %d (%d saccads) - Overlay', ...
                                edfNumber, stimNum, length(saccX)), 'FontSize', 14);
                            
                        catch ME
                            fprintf('  Error loading stimulus image: %s\n', ME.message);
                            fprintf('  Creating heatmap without background.\n');
                            
                           
                            imagesc(log(heatmapBlurred + 1));
                            axis image off;
                            colormap jet;
                            title(sprintf('Bottom-Up: EDF %d - Stimulus %d (%d saccads) - Heatmap Only', ...
                                edfNumber, stimNum, length(saccX)), 'FontSize', 14);
                        end
                    else
                        imagesc(log(heatmapBlurred + 1));
                        axis image off;
                        colormap jet;
                        title(sprintf('Bottom-Up: EDF %d - Stimulus %d (%d saccads) - Heatmap Only', ...
                            edfNumber, stimNum, length(saccX)), 'FontSize', 14);
                    end
                    
                    colorbar;
                    
                    % Save results
                    if ~exist('Results-Sacc', 'dir'), mkdir('Results-Sacc'); end
                    if ~exist('Results-Sacc/Bottom-Up', 'dir'), mkdir('Results-Sacc/Bottom-Up'); end
                    
                    outputName = sprintf('Results-Sacc/Bottom-Up/%d-%d_overlay.png', edfNumber, stimNum);
                    saveas(gcf, outputName, 'png');
                    
                    print(gcf, sprintf('Results-Sacc/Bottom-Up/%d-%d_overlay_hires.png', edfNumber, stimNum), ...
                        '-dpng', '-r300');
                    
                    close(gcf);
                    
                    fprintf('  Saved: %s\n', outputName);
                    
                end
                
            catch ME
                fprintf('Error processing stimulus %d in EDF %d: %s\n', stimNum, edfNumber, ME.message);
            end
        end
        
    catch ME
        fprintf('Error processing EDF file %s: %s\n', edfFiles(fileIdx).name, ME.message);
    end
end


fprintf('\n=== Processing Complete ===\n');
fprintf('Results saved in ./Results/Bottom-Up/\n');
fprintf('Files saved as: [EDF_number]-[stimulus_number]_overlay.png\n');


















% Top-Down Data
fprintf('=== Processing Top-Down Data ===\n');
topDownPath = './Top-Down/Data/';
stimuliPath = './Top-Down/'; 


edfFiles = dir([topDownPath '*.edf']);

for fileIdx = 1:length(edfFiles)
    try
        [~, filename_only, ~] = fileparts(edfFiles(fileIdx).name);
        edfNumber = str2double(filename_only);
        
        fprintf('Processing Top-Down EDF %d...\n', edfNumber);
        filename = fullfile(topDownPath, edfFiles(fileIdx).name);
        mat = Edf2Mat(filename);
        events = mat.RawEdf.FEVENT;
        
        for stimIdx = 1:length(topDownStimuli)
            stimNum = topDownStimuli(stimIdx);
            
            try
                startStimulusMsg = sprintf('StartStimulus %d', stimNum);
                startStimulusIdx = [];
                
                for i = 1:length(events)
                    if ~isempty(events(i).message) && contains(events(i).message, startStimulusMsg)
                        startStimulusIdx = i;
                        break;
                    end
                end
                
                if isempty(startStimulusIdx)
                    fprintf('Warning: StartStimulus %d not found in EDF %d\n', stimNum, edfNumber);
                    continue;
                end
                
                endStimulusMsg = sprintf('StartResponse %d', stimNum);
                startResponseIdx = [];
                for i = (startStimulusIdx + 1):length(events)
                    if ~isempty(events(i).message) && contains(events(i).message, endStimulusMsg)
                        startResponseIdx = i;
                        break;
                    end
                end
                
                if isempty(startResponseIdx)
                    error('No EndStimulus found after StartStimulus %d in EDF %d', stimNum, edfNumber);
                end
                

                startTime = events(startStimulusIdx).sttime;
                endTime = events(startResponseIdx).sttime;
                
                fprintf('  Stimulus %d: Time range %.2f to %.2f ms\n', stimNum, startTime, endTime);
                

                startSaccIdx = [];
                endSaccIdx = [];
                
                for i = 1:length(events)
                    if strcmp(events(i).codestring, 'STARTSACC') && ...
                       events(i).sttime >= startTime && events(i).sttime <= endTime
                        startSaccIdx(end+1) = i;
                    elseif strcmp(events(i).codestring, 'ENDSACC') && ...
                           events(i).sttime >= startTime && events(i).sttime <= endTime
                        endSaccIdx(end+1) = i;
                    end
                end
                
                validPairs = [];
                for startIdx = 1:length(startSaccIdx)
                    startSaccTime = events(startSaccIdx(startIdx)).sttime;
                    
                    for endIdx = 1:length(endSaccIdx)
                        endSaccTime = events(endSaccIdx(endIdx)).sttime;
                        if endSaccTime > startSaccTime
                            % Check if both STARTSACC and ENDSACC are within our time window
                            if startSaccTime >= startTime && endSaccTime <= endTime
                                validPairs(end+1, :) = [startSaccIdx(startIdx), endSaccIdx(endIdx)];
                            end
                            break;
                        end
                    end
                end
                
                if isempty(validPairs)
                    fprintf('  Warning: No valid saccads pairs found for stimulus %d in EDF %d\n', stimNum, edfNumber);
                    continue;
                end
                

                saccX = [];
                saccY = [];
                saccDuration = [];
                
                for pairIdx = 1:size(validPairs, 1)
                    startSaccEvent = events(validPairs(pairIdx, 1));
                    endSaccEvent = events(validPairs(pairIdx, 2));
                    
                    x = double(startSaccEvent.gstx);
                    y = double(startSaccEvent.gsty);
                    duration = double(endSaccEvent.entime) - double(startSaccEvent.sttime);

                    if x > 0 && x <= screenWidth && y > 0 && y <= screenHeight && ...
                       ~isnan(x) && ~isnan(y) && duration > 0
                        saccX(end+1) = x;
                        saccY(end+1) = y;
                        saccDuration(end+1) = duration;
                    end
                end
                
                fprintf('  Found %d valid saccads for stimulus %d\n', length(saccX), stimNum);
                
                if ~isempty(saccX)
                    heatmapMatrix = zeros(screenHeight, screenWidth);
                    
                    for i = 1:length(saccX)
                        x = round(saccX(i));
                        y = round(saccY(i));
                        if x >= 1 && x <= screenWidth && y >= 1 && y <= screenHeight
                            heatmapMatrix(y, x) = heatmapMatrix(y, x) + saccDuration(i);
                        end
                    end
                    
                    heatmapBlurred = conv2(heatmapMatrix, gaussKernel, 'same');
                    
                    if max(heatmapBlurred(:)) > 0
                        heatmapNormalized = heatmapBlurred / max(heatmapBlurred(:));
                    else
                        heatmapNormalized = heatmapBlurred;
                    end
                    
                    stimulusImagePath = fullfile(stimuliPath, sprintf('%d.jpg', stimNum));
                
                    figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
                    
                    if ~isempty(stimulusImagePath) && exist(stimulusImagePath, 'file')
                        try
                            stimulusImg = imread(stimulusImagePath);
                            
                            if size(stimulusImg, 1) ~= screenHeight || size(stimulusImg, 2) ~= screenWidth
                                stimulusImg = imresize(stimulusImg, [screenHeight, screenWidth]);
                            end
                            
                            imshow(stimulusImg);
                            hold on;
                            
                            heatmapMask = heatmapNormalized > heatmapThreshold;
                            heatmapRGB = ind2rgb(uint8(heatmapNormalized * 255), jet(256));
                            
                            alphaChannel = heatmapMask * heatmapAlpha;
                            
                            h = imshow(heatmapRGB);
                            set(h, 'AlphaData', alphaChannel);
                            
                            title(sprintf('Top-Down: EDF %d - Stimulus %d (%d saccads) - Overlay', ...
                                edfNumber, stimNum, length(saccX)), 'FontSize', 14);
                            
                        catch ME
                            fprintf('  Error loading stimulus image: %s\n', ME.message);
                            fprintf('  Creating heatmap without background.\n');
                            
                            imagesc(log(heatmapBlurred + 1));
                            axis image off;
                            colormap jet;
                            title(sprintf('Top-Down: EDF %d - Stimulus %d (%d saccads) - Heatmap Only', ...
                                edfNumber, stimNum, length(saccX)), 'FontSize', 14);
                        end
                    else
                        imagesc(log(heatmapBlurred + 1));
                        axis image off;
                        colormap jet;
                        title(sprintf('Top-Down: EDF %d - Stimulus %d (%d saccads) - Heatmap Only', ...
                            edfNumber, stimNum, length(saccX)), 'FontSize', 14);
                    end
                    
                    colorbar;
                    
                    % Save results
                    if ~exist('Results', 'dir'), mkdir('Results'); end
                    if ~exist('Results/Top-Down', 'dir'), mkdir('Results/Top-Down'); end
                    
                    outputName = sprintf('Results/Top-Down/%d-%d_overlay.png', edfNumber, stimNum);
                    saveas(gcf, outputName, 'png');
                    
                    print(gcf, sprintf('Results/Top-Down/%d-%d_overlay_hires.png', edfNumber, stimNum), ...
                        '-dpng', '-r300');
                    
                    close(gcf);
                    
                    fprintf('  Saved: %s\n', outputName);
                    
                end
                
            catch ME
                fprintf('Error processing stimulus %d in EDF %d: %s\n', stimNum, edfNumber, ME.message);
            end
        end
        
    catch ME
        fprintf('Error processing EDF file %s: %s\n', edfFiles(fileIdx).name, ME.message);
    end
end


fprintf('\n=== Processing Complete ===\n');
fprintf('Results saved in ./Results/Top-Down/\n');
fprintf('Files saved as: [EDF_number]-[stimulus_number]_overlay.png\n');