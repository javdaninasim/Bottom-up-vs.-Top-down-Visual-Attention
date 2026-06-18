% Itti-Koch Saliency Model Implementation
% Based on Itti, L., & Koch, C. (2001). Computational modelling of visual attention.

%% Parameters
bottomUpStimuli = [1, 3, 4];
topDownStimuli = [1, 2, 5];

% Saliency model parameters
sigma0 = 1;  % Base sigma for Gaussian pyramids
levels = 9;  % Number of pyramid levels (0-8)
orientations = [0, 45, 90, 135]; % Gabor filter orientations

%% Process Bottom-Up stimuli
fprintf('=== Generating Itti-Koch Saliency Maps for Bottom-Up Stimuli ===\n');
stimuliPath = './Bottom-Up/';

for stimIdx = 1:length(bottomUpStimuli)
    stimNum = bottomUpStimuli(stimIdx);
    
    try
        % Load stimulus image
        stimulusImagePath = fullfile(stimuliPath, sprintf('%d.jpg', stimNum));
        
        if exist(stimulusImagePath, 'file')
            fprintf('Processing Bottom-Up Stimulus %d...\n', stimNum);
            
            % Read and preprocess image
            img = imread(stimulusImagePath);
            if size(img, 3) == 3
                img = double(img);
            else
                img = double(repmat(img, [1, 1, 3]));
            end
            
            % Generate saliency map
            saliencyMap = generateIttiKochSaliency(img, sigma0, levels, orientations);
            
            % Create visualization
            figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
            
            subplot(1, 3, 1);
            imshow(uint8(img));
            title(sprintf('Original - Stimulus %d', stimNum), 'FontSize', 12);
            
            subplot(1, 3, 2);
            imagesc(saliencyMap);
            axis image off;
            colormap(gca, hot);
            colorbar;
            title('Itti-Koch Saliency Map', 'FontSize', 12);
            
            subplot(1, 3, 3);
            imshow(uint8(img));
            hold on;
            
            % Overlay saliency as semi-transparent heatmap
            saliencyNorm = saliencyMap / max(saliencyMap(:));
            saliencyThresh = saliencyNorm > 0.3; % Show top 30% salient regions
            
            heatmapRGB = ind2rgb(uint8(saliencyNorm * 255), hot(256));
            h = imshow(heatmapRGB);
            set(h, 'AlphaData', saliencyThresh * 0.6);
            
            title('Saliency Overlay', 'FontSize', 12);
            hold off;
            
            sgtitle(sprintf('Bottom-Up Stimulus %d - Itti-Koch Saliency Analysis', stimNum), ...
                'FontSize', 14, 'FontWeight', 'bold');
            
            % Save results
            if ~exist('Results-Saliency', 'dir'), mkdir('Results-Saliency'); end
            if ~exist('Results-Saliency/Bottom-Up', 'dir'), mkdir('Results-Saliency/Bottom-Up'); end
            
            outputName = sprintf('Results-Saliency/Bottom-Up/stimulus_%d_itti_koch.png', stimNum);
            saveas(gcf, outputName, 'png');
            print(gcf, sprintf('Results-Saliency/Bottom-Up/stimulus_%d_itti_koch_hires.png', stimNum), ...
                '-dpng', '-r300');
            
            close(gcf);
            fprintf('  Saved: %s\n', outputName);
            
        else
            fprintf('Warning: Stimulus image %d not found in Bottom-Up folder\n', stimNum);
        end
        
    catch ME
        fprintf('Error processing Bottom-Up stimulus %d: %s\n', stimNum, ME.message);
    end
end

%% Process Top-Down stimuli
fprintf('\n=== Generating Itti-Koch Saliency Maps for Top-Down Stimuli ===\n');
stimuliPath = './Top-Down/';

for stimIdx = 1:length(topDownStimuli)
    stimNum = topDownStimuli(stimIdx);
    
    try
        % Load stimulus image
        stimulusImagePath = fullfile(stimuliPath, sprintf('%d.jpg', stimNum));
        
        if exist(stimulusImagePath, 'file')
            fprintf('Processing Top-Down Stimulus %d...\n', stimNum);
            
            % Read and preprocess image
            img = imread(stimulusImagePath);
            if size(img, 3) == 3
                img = double(img);
            else
                img = double(repmat(img, [1, 1, 3]));
            end
            
            % Generate saliency map
            saliencyMap = generateIttiKochSaliency(img, sigma0, levels, orientations);
            
            % Create visualization
            figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
            
            subplot(1, 3, 1);
            imshow(uint8(img));
            title(sprintf('Original - Stimulus %d', stimNum), 'FontSize', 12);
            
            subplot(1, 3, 2);
            imagesc(saliencyMap);
            axis image off;
            colormap(gca, hot);
            colorbar;
            title('Itti-Koch Saliency Map', 'FontSize', 12);
            
            subplot(1, 3, 3);
            imshow(uint8(img));
            hold on;
            
            % Overlay saliency as semi-transparent heatmap
            saliencyNorm = saliencyMap / max(saliencyMap(:));
            saliencyThresh = saliencyNorm > 0.3; % Show top 30% salient regions
            
            heatmapRGB = ind2rgb(uint8(saliencyNorm * 255), hot(256));
            h = imshow(heatmapRGB);
            set(h, 'AlphaData', saliencyThresh * 0.6);
            
            title('Saliency Overlay', 'FontSize', 12);
            hold off;
            
            sgtitle(sprintf('Top-Down Stimulus %d - Itti-Koch Saliency Analysis', stimNum), ...
                'FontSize', 14, 'FontWeight', 'bold');
            
            % Save results
            if ~exist('Results-Saliency/Top-Down', 'dir'), mkdir('Results-Saliency/Top-Down'); end
            
            outputName = sprintf('Results-Saliency/Top-Down/stimulus_%d_itti_koch.png', stimNum);
            saveas(gcf, outputName, 'png');
            print(gcf, sprintf('Results-Saliency/Top-Down/stimulus_%d_itti_koch_hires.png', stimNum), ...
                '-dpng', '-r300');
            
            close(gcf);
            fprintf('  Saved: %s\n', outputName);
            
        else
            fprintf('Warning: Stimulus image %d not found in Top-Down folder\n', stimNum);
        end
        
    catch ME
        fprintf('Error processing Top-Down stimulus %d: %s\n', stimNum, ME.message);
    end
end

fprintf('\n=== Itti-Koch Saliency Analysis Complete ===\n');
fprintf('Results saved in ./Results-Saliency/\n');
