% Enhanced Scanpath Analysis with Prominent Saccades
% Parameters
screenWidth = 1920;
screenHeight = 1080;
edfNumber = 1; 

fixationMinSize = 20;    
fixationMaxSize = 100;  
saccadeLineWidth = 3;        % Increased line width for better visibility
saccadeAlpha = 0.8;          % Increased alpha for better visibility
arrowSize = 15;              % Size of arrowheads
saccadeColorGradient = true; % Color saccades by sequence

bottomUpStimuli = [1, 3, 4];
topDownStimuli = [1, 2, 5];




%% Process Bottom-Up Data for EDF 1 - All Stimuli
fprintf('=== Processing Bottom-Up Scanpaths with Enhanced Saccades for EDF 1 - All Stimuli ===\n');
bottomUpPath = './Bottom-Up/Data/';
stimuliPath = './Bottom-Up/';

filename = fullfile(bottomUpPath, sprintf('%d.edf', edfNumber));

if exist(filename, 'file')
    try
        fprintf('Processing Bottom-Up EDF %d...\n', edfNumber);
        mat = Edf2Mat(filename);
        events = mat.RawEdf.FEVENT;
        
        for stimIdx = 1:length(bottomUpStimuli)
            stimNum = bottomUpStimuli(stimIdx);
            
            try
                fprintf('  Processing Stimulus %d...\n', stimNum);
                
                startStimulusMsg = sprintf('StartStimulus %d', stimNum);
                startStimulusIdx = [];
                
                for i = 1:length(events)
                    if ~isempty(events(i).message) && contains(events(i).message, startStimulusMsg)
                        startStimulusIdx = i;
                        break;
                    end
                end
                
                if isempty(startStimulusIdx)
                    fprintf('    Warning: StartStimulus %d not found in EDF %d\n', stimNum, edfNumber);
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
                    fprintf('    Warning: No EndStimulus found after StartStimulus %d in EDF %d\n', stimNum, edfNumber);
                    continue;
                end
                
                startTime = events(startStimulusIdx).sttime;
                endTime = events(startResponseIdx).sttime;
                
                fixSequence = [];
                
                for i = 1:length(events)
                    if strcmp(events(i).codestring, 'STARTFIX') && ...
                       events(i).sttime >= startTime && events(i).sttime <= endTime
                        
                        endFixIdx = [];
                        for j = (i+1):length(events)
                            if strcmp(events(j).codestring, 'ENDFIX') && ...
                               events(j).sttime > events(i).sttime && ...
                               events(j).sttime <= endTime
                                endFixIdx = j;
                                break;
                            end
                        end
                        
                        if ~isempty(endFixIdx)
                            x = double(events(i).gstx);
                            y = double(events(i).gsty);
                            duration = double(events(endFixIdx).entime) - double(events(i).sttime);
                            fixTime = double(events(i).sttime);
                            
                            if x > 0 && x <= screenWidth && y > 0 && y <= screenHeight && ...
                               ~isnan(x) && ~isnan(y) && duration > 0
                                fixSequence(end+1, :) = [x, y, duration, fixTime];
                            end
                        end
                    end
                end
                
                if ~isempty(fixSequence)
                    [~, sortIdx] = sort(fixSequence(:, 4));
                    fixSequence = fixSequence(sortIdx, :);
                    
                    fprintf('    Found %d fixations in sequence\n', size(fixSequence, 1));
                    
                    figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
                    
                    stimulusImagePath = fullfile(stimuliPath, sprintf('%d.jpg', stimNum));
                    
                    if exist(stimulusImagePath, 'file')
                        try
                            stimulusImg = imread(stimulusImagePath);
                            if size(stimulusImg, 1) ~= screenHeight || size(stimulusImg, 2) ~= screenWidth
                                stimulusImg = imresize(stimulusImg, [screenHeight, screenWidth]);
                            end
                            imshow(stimulusImg);
                            hold on;
                        catch ME
                            fprintf('    Error loading stimulus image, using blank background\n');
                            imshow(ones(screenHeight, screenWidth, 3));
                            hold on;
                        end
                    else
                        fprintf('    Stimulus image not found, using blank background\n');
                        imshow(ones(screenHeight, screenWidth, 3));
                        hold on;
                    end
                    
                    % Calculate saccade metrics
                    saccadeData = [];
                    if size(fixSequence, 1) > 1
                        for i = 1:(size(fixSequence, 1)-1)
                            x1 = fixSequence(i, 1);
                            y1 = fixSequence(i, 2);
                            x2 = fixSequence(i+1, 1);
                            y2 = fixSequence(i+1, 2);
                            
                            % Calculate saccade amplitude (distance)
                            amplitude = sqrt((x2-x1)^2 + (y2-y1)^2);
                            % Calculate saccade angle
                            angle = atan2(y2-y1, x2-x1) * 180/pi;
                            
                            saccadeData(end+1, :) = [x1, y1, x2, y2, amplitude, angle, i];
                        end
                    end
                    
                    % Draw enhanced saccades with arrows and color gradient
                    if ~isempty(saccadeData)
                        maxAmplitude = max(saccadeData(:, 5));
                        
                        for i = 1:size(saccadeData, 1)
                            x1 = saccadeData(i, 1);
                            y1 = saccadeData(i, 2);
                            x2 = saccadeData(i, 3);
                            y2 = saccadeData(i, 4);
                            amplitude = saccadeData(i, 5);
                            saccadeIdx = saccadeData(i, 7);
                            
                            % Color based on sequence or amplitude
                            if saccadeColorGradient
                                % Color gradient from red to blue based on sequence
                                colorIntensity = (i-1) / max(1, size(saccadeData, 1)-1);
                                saccadeColor = [1-colorIntensity, 0, colorIntensity];
                            else
                                % Color based on amplitude (short=green, long=red)
                                normalizedAmp = amplitude / maxAmplitude;
                                saccadeColor = [normalizedAmp, 1-normalizedAmp, 0];
                            end
                            
                            % Line width based on amplitude
                            currentLineWidth = saccadeLineWidth + (amplitude / maxAmplitude) * 2;
                            
                            % Draw arrow
                            drawArrow(x1, y1, x2, y2, saccadeColor, currentLineWidth, arrowSize);
                            
                            % Add saccade number at midpoint
                            midX = (x1 + x2) / 2;
                            midY = (y1 + y2) / 2;
                            text(midX, midY, num2str(i), 'HorizontalAlignment', 'center', ...
                                 'VerticalAlignment', 'middle', 'FontSize', 8, 'FontWeight', 'bold', ...
                                 'Color', 'white', 'BackgroundColor', [saccadeColor 0.8]);
                                 
                        end
                    end
                    
                    % Draw fixations on top
                    minDuration = min(fixSequence(:, 3));
                    maxDuration = max(fixSequence(:, 3));
                    
                    for i = 1:size(fixSequence, 1)
                        x = fixSequence(i, 1);
                        y = fixSequence(i, 2);
                        duration = fixSequence(i, 3);
                        
                        if maxDuration > minDuration
                            normalizedDuration = (duration - minDuration) / (maxDuration - minDuration);
                        else
                            normalizedDuration = 0.5;
                        end
                        circleSize = fixationMinSize + normalizedDuration * (fixationMaxSize - fixationMinSize);
                        
                        % Color changes from cyan (early) to magenta (late) to contrast with saccades
                        colorIntensity = (i-1) / max(1, size(fixSequence, 1)-1);
                        circleColor = [colorIntensity, 1-colorIntensity, 1];
                        
                        % Draw fixation circle with thick border
                        theta = linspace(0, 2*pi, 50);
                        circleX = x + (circleSize/2) * cos(theta);
                        circleY = y + (circleSize/2) * sin(theta);
                        
                        % Draw filled circle
                        fill(circleX, circleY, circleColor, 'EdgeColor', 'black', 'LineWidth', 2);
                        
                        % Add fixation number
                        text(x, y, num2str(i), 'HorizontalAlignment', 'center', ...
                             'VerticalAlignment', 'middle', 'FontSize', 12, 'FontWeight', 'bold', ...
                             'Color', 'black');
                    end
                    
                    title(sprintf('Bottom-Up Scanpath with Enhanced Saccades: EDF %d - Stimulus %d\n(%d fixations, %d saccades)', ...
                        edfNumber, stimNum, size(fixSequence, 1), size(saccadeData, 1)), 'FontSize', 14);
                    
                    % Enhanced legend
                    legend({'Saccades (red→blue sequence)', 'Fixations (cyan→magenta sequence)'}, ...
                           'Location', 'northeast', 'FontSize', 10);
                    
                    % Add saccade statistics text
                    if ~isempty(saccadeData)
                        meanAmplitude = mean(saccadeData(:, 5));
                        maxAmp = max(saccadeData(:, 5));
                        minAmp = min(saccadeData(:, 5));
                        
                        statsText = sprintf('Saccade Stats:\nMean: %.1f px\nMax: %.1f px\nMin: %.1f px', ...
                                          meanAmplitude, maxAmp, minAmp);
                        
                        text(50, 50, statsText, 'FontSize', 10, 'Color', 'white', ...
                             'BackgroundColor', [0 0 0 0.7], 'VerticalAlignment', 'top');
                    end
                    
                    % Save results
                    if ~exist('Results-Scanpath2', 'dir'), mkdir('Results-Scanpath2'); end
                    if ~exist('Results-Scanpath2/Bottom-Up', 'dir'), mkdir('Results-Scanpath2/Bottom-Up'); end
                    
                    outputName = sprintf('Results-Scanpath2/Bottom-Up/EDF%d_Stim%d_enhanced_scanpath.png', edfNumber, stimNum);
                    saveas(gcf, outputName, 'png');
                    print(gcf, sprintf('Results-Scanpath2/Bottom-Up/EDF%d_Stim%d_enhanced_scanpath_hires.png', edfNumber, stimNum), ...
                        '-dpng', '-r300');
                    
                    close(gcf);
                    fprintf('    Saved: %s\n', outputName);
                else
                    fprintf('    No valid fixations found for stimulus %d in EDF %d\n', stimNum, edfNumber);
                end
                
            catch ME
                fprintf('    Error processing stimulus %d in EDF %d: %s\n', stimNum, edfNumber, ME.message);
            end
        end
        
    catch ME
        fprintf('Error processing Bottom-Up EDF file %d.edf: %s\n', edfNumber, ME.message);
    end
else
    fprintf('Bottom-Up EDF file %d.edf not found in %s\n', edfNumber, bottomUpPath);
end

%% Process Top-Down Data for EDF 1 - All Stimuli
fprintf('\n=== Processing Top-Down Scanpaths with Enhanced Saccades for EDF 1 - All Stimuli ===\n');
topDownPath = './Top-Down/Data/';
stimuliPath = './Top-Down/';

filename = fullfile(topDownPath, sprintf('%d.edf', edfNumber));

if exist(filename, 'file')
    try
        fprintf('Processing Top-Down EDF %d...\n', edfNumber);
        mat = Edf2Mat(filename);
        events = mat.RawEdf.FEVENT;
        
        for stimIdx = 1:length(topDownStimuli)
            stimNum = topDownStimuli(stimIdx);
            
            try
                fprintf('  Processing Stimulus %d...\n', stimNum);
                
                startStimulusMsg = sprintf('StartStimulus %d', stimNum);
                startStimulusIdx = [];
                
                for i = 1:length(events)
                    if ~isempty(events(i).message) && contains(events(i).message, startStimulusMsg)
                        startStimulusIdx = i;
                        break;
                    end
                end
                
                if isempty(startStimulusIdx)
                    fprintf('    Warning: StartStimulus %d not found in EDF %d\n', stimNum, edfNumber);
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
                    fprintf('    Warning: No StartResponse found after StartStimulus %d in EDF %d\n', stimNum, edfNumber);
                    continue;
                end
                
                startTime = events(startStimulusIdx).sttime;
                endTime = events(startResponseIdx).sttime;
                
                fixSequence = [];
                
                for i = 1:length(events)
                    if strcmp(events(i).codestring, 'STARTFIX') && ...
                       events(i).sttime >= startTime && events(i).sttime <= endTime
                        
                        endFixIdx = [];
                        for j = (i+1):length(events)
                            if strcmp(events(j).codestring, 'ENDFIX') && ...
                               events(j).sttime > events(i).sttime && ...
                               events(j).sttime <= endTime
                                endFixIdx = j;
                                break;
                            end
                        end
                        
                        if ~isempty(endFixIdx)
                            x = double(events(i).gstx);
                            y = double(events(i).gsty);
                            duration = double(events(endFixIdx).entime) - double(events(i).sttime);
                            fixTime = double(events(i).sttime);
                            
                            if x > 0 && x <= screenWidth && y > 0 && y <= screenHeight && ...
                               ~isnan(x) && ~isnan(y) && duration > 0
                                fixSequence(end+1, :) = [x, y, duration, fixTime];
                            end
                        end
                    end
                end
                
                if ~isempty(fixSequence)
                    [~, sortIdx] = sort(fixSequence(:, 4));
                    fixSequence = fixSequence(sortIdx, :);
                    
                    fprintf('    Found %d fixations in sequence\n', size(fixSequence, 1));
                    
                    figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
                    
                    stimulusImagePath = fullfile(stimuliPath, sprintf('%d.jpg', stimNum));
                    
                    if exist(stimulusImagePath, 'file')
                        try
                            stimulusImg = imread(stimulusImagePath);
                            if size(stimulusImg, 1) ~= screenHeight || size(stimulusImg, 2) ~= screenWidth
                                stimulusImg = imresize(stimulusImg, [screenHeight, screenWidth]);
                            end
                            imshow(stimulusImg);
                            hold on;
                        catch ME
                            fprintf('    Error loading stimulus image, using blank background\n');
                            imshow(ones(screenHeight, screenWidth, 3));
                            hold on;
                        end
                    else
                        fprintf('    Stimulus image not found, using blank background\n');
                        imshow(ones(screenHeight, screenWidth, 3));
                        hold on;
                    end
                    
                    % Calculate saccade metrics
                    saccadeData = [];
                    if size(fixSequence, 1) > 1
                        for i = 1:(size(fixSequence, 1)-1)
                            x1 = fixSequence(i, 1);
                            y1 = fixSequence(i, 2);
                            x2 = fixSequence(i+1, 1);
                            y2 = fixSequence(i+1, 2);
                            
                            % Calculate saccade amplitude (distance)
                            amplitude = sqrt((x2-x1)^2 + (y2-y1)^2);
                            % Calculate saccade angle
                            angle = atan2(y2-y1, x2-x1) * 180/pi;
                            
                            saccadeData(end+1, :) = [x1, y1, x2, y2, amplitude, angle, i];
                        end
                    end
                    
                    % Draw enhanced saccades with arrows and color gradient
                    if ~isempty(saccadeData)
                        maxAmplitude = max(saccadeData(:, 5));
                        
                        for i = 1:size(saccadeData, 1)
                            x1 = saccadeData(i, 1);
                            y1 = saccadeData(i, 2);
                            x2 = saccadeData(i, 3);
                            y2 = saccadeData(i, 4);
                            amplitude = saccadeData(i, 5);
                            saccadeIdx = saccadeData(i, 7);
                            
                            % Color based on sequence or amplitude
                            if saccadeColorGradient
                                % Color gradient from red to blue based on sequence
                                colorIntensity = (i-1) / max(1, size(saccadeData, 1)-1);
                                saccadeColor = [1-colorIntensity, 0, colorIntensity];
                            else
                                % Color based on amplitude (short=green, long=red)
                                normalizedAmp = amplitude / maxAmplitude;
                                saccadeColor = [normalizedAmp, 1-normalizedAmp, 0];
                            end
                            
                            % Line width based on amplitude
                            currentLineWidth = saccadeLineWidth + (amplitude / maxAmplitude) * 2;
                            
                            % Draw arrow
                            drawArrow(x1, y1, x2, y2, saccadeColor, currentLineWidth, arrowSize);
                            
                            % Add saccade number at midpoint
                            midX = (x1 + x2) / 2;
                            midY = (y1 + y2) / 2;
                            text(midX, midY, num2str(i), 'HorizontalAlignment', 'center', ...
                                 'VerticalAlignment', 'middle', 'FontSize', 8, 'FontWeight', 'bold', ...
                                 'Color', 'white', 'BackgroundColor', [saccadeColor 0.8]);
                              
                        end
                    end
                    
                    % Draw fixations on top
                    minDuration = min(fixSequence(:, 3));
                    maxDuration = max(fixSequence(:, 3));
                    
                    for i = 1:size(fixSequence, 1)
                        x = fixSequence(i, 1);
                        y = fixSequence(i, 2);
                        duration = fixSequence(i, 3);
                        
                        if maxDuration > minDuration
                            normalizedDuration = (duration - minDuration) / (maxDuration - minDuration);
                        else
                            normalizedDuration = 0.5;
                        end
                        circleSize = fixationMinSize + normalizedDuration * (fixationMaxSize - fixationMinSize);
                        
                        % Color changes from cyan (early) to magenta (late) to contrast with saccades
                        colorIntensity = (i-1) / max(1, size(fixSequence, 1)-1);
                        circleColor = [colorIntensity, 1-colorIntensity, 1];
                        
                        % Draw fixation circle with thick border
                        theta = linspace(0, 2*pi, 50);
                        circleX = x + (circleSize/2) * cos(theta);
                        circleY = y + (circleSize/2) * sin(theta);
                        
                        % Draw filled circle
                        fill(circleX, circleY, circleColor, 'EdgeColor', 'black', 'LineWidth', 2);
                        
                        % Add fixation number
                        text(x, y, num2str(i), 'HorizontalAlignment', 'center', ...
                             'VerticalAlignment', 'middle', 'FontSize', 12, 'FontWeight', 'bold', ...
                             'Color', 'black');
                    end
                    
                    title(sprintf('Top-Down Scanpath with Enhanced Saccades: EDF %d - Stimulus %d\n(%d fixations, %d saccades)', ...
                        edfNumber, stimNum, size(fixSequence, 1), size(saccadeData, 1)), 'FontSize', 14);
                    
                    % Enhanced legend
                    legend({'Saccades (red→blue sequence)', 'Fixations (cyan→magenta sequence)'}, ...
                           'Location', 'northeast', 'FontSize', 10);
                    
                    % Add saccade statistics text
                    if ~isempty(saccadeData)
                        meanAmplitude = mean(saccadeData(:, 5));
                        maxAmp = max(saccadeData(:, 5));
                        minAmp = min(saccadeData(:, 5));
                        
                        statsText = sprintf('Saccade Stats:\nMean: %.1f px\nMax: %.1f px\nMin: %.1f px', ...
                                          meanAmplitude, maxAmp, minAmp);
                        
                        text(50, 50, statsText, 'FontSize', 10, 'Color', 'white', ...
                             'BackgroundColor', [0 0 0 0.7], 'VerticalAlignment', 'top');
                    end
                    
                    % Save results
                    if ~exist('Results-Scanpath2', 'dir'), mkdir('Results-Scanpath2'); end
                    if ~exist('Results-Scanpath2/Top-Down', 'dir'), mkdir('Results-Scanpath2/Top-Down'); end
                    
                    outputName = sprintf('Results-Scanpath2/Top-Down/EDF%d_Stim%d_enhanced_scanpath.png', edfNumber, stimNum);
                    saveas(gcf, outputName, 'png');
                    print(gcf, sprintf('Results-Scanpath2/Top-Down/EDF%d_Stim%d_enhanced_scanpath_hires.png', edfNumber, stimNum), ...
                        '-dpng', '-r300');
                    
                    close(gcf);
                    fprintf('    Saved: %s\n', outputName);
                else
                    fprintf('    No valid fixations found for stimulus %d in EDF %d\n', stimNum, edfNumber);
                end
                
            catch ME
                fprintf('    Error processing stimulus %d in EDF %d: %s\n', stimNum, edfNumber, ME.message);
            end
        end
        
    catch ME
        fprintf('Error processing Top-Down EDF file %d.edf: %s\n', edfNumber, ME.message);
    end
else
    fprintf('Top-Down EDF file %d.edf not found in %s\n', edfNumber, topDownPath);
end

fprintf('\n=== Enhanced Scanpath Analysis with Saccades Complete for EDF 1 ===\n');
fprintf('Enhanced scanpaths with prominent saccades saved in:\n');
fprintf('  ./Results-Scanpath2/Bottom-Up/ (stimuli: %s)\n', mat2str(bottomUpStimuli));
fprintf('  ./Results-Scanpath2/Top-Down/ (stimuli: %s)\n', mat2str(topDownStimuli));
fprintf('Files named as: EDF1_Stim[X]_enhanced_scanpath.png\n');

fprintf('\nEnhancements added:\n');
fprintf('  - Saccades with directional arrows\n');
fprintf('  - Color-coded saccade sequence (red→blue)\n');
fprintf('  - Variable line width based on saccade amplitude\n');
fprintf('  - Saccade numbering at midpoints\n');
fprintf('  - Saccade statistics (mean, max, min amplitude)\n');
fprintf('  - Enhanced fixation visualization (filled circles)\n');
fprintf('  - Improved color contrast between saccades and fixations\n');