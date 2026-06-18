function saliencyMap = generateIttiKochSaliency(img, sigma0, levels, orientations)
img = double(img) / 255;
    
    if size(img, 3) == 3
        % Create intensity image (luminance)
        I = 0.299 * img(:,:,1) + 0.587 * img(:,:,2) + 0.114 * img(:,:,3);
        
        % Create color opponent channels (normalized)
        sum_rgb = img(:,:,1) + img(:,:,2) + img(:,:,3);
        sum_rgb(sum_rgb == 0) = 1; % Avoid division by zero
        
        R = img(:,:,1) ./ sum_rgb;
        G = img(:,:,2) ./ sum_rgb;
        B_color = img(:,:,3) ./ sum_rgb;
        Y = (R + G) / 2;
        
        % Color opponent channels
        RG = R - G;
        BY = B_color - Y;
    else
        % Grayscale image
        I = img;
        RG = zeros(size(I));
        BY = zeros(size(I));
    end
    
    %% 1. Create Gaussian pyramids for each feature
    I_pyramid = createGaussianPyramid(I, levels, sigma0);
    RG_pyramid = createGaussianPyramid(RG, levels, sigma0);
    BY_pyramid = createGaussianPyramid(BY, levels, sigma0);
    
    %% 2. Create orientation pyramids using Gabor filters
    O_pyramids = cell(length(orientations), 1);
    for o = 1:length(orientations)
        O_pyramids{o} = createOrientationPyramid(I, levels, sigma0, orientations(o));
    end
    
    %% 3. Create center-surround feature maps
    % Get reference size (from level 3 for consistency)
    [ref_h, ref_w] = size(I_pyramid{4}); % level 3 (index 4)
    
    % Intensity center-surround
    I_cs_maps = [];
    for c = 2:4  % center scales (reduced range for stability)
        for s = c+3:c+4  % surround scales (delta = 3 or 4)
            if s <= levels && c+1 <= length(I_pyramid) && s+1 <= length(I_pyramid)
                cs_map = centerSurroundDifference(I_pyramid{c+1}, I_pyramid{s+1});
                % Resize to reference size
                cs_map_resized = imresize(cs_map, [ref_h, ref_w]);
                if isempty(I_cs_maps)
                    I_cs_maps = cs_map_resized;
                else
                    I_cs_maps = cat(3, I_cs_maps, cs_map_resized);
                end
            end
        end
    end
    
    % Color center-surround
    RG_cs_maps = [];
    BY_cs_maps = [];
    for c = 2:4
        for s = c+3:c+4
            if s <= levels && c+1 <= length(RG_pyramid) && s+1 <= length(RG_pyramid)
                rg_cs = centerSurroundDifference(RG_pyramid{c+1}, RG_pyramid{s+1});
                by_cs = centerSurroundDifference(BY_pyramid{c+1}, BY_pyramid{s+1});
                
                % Resize to reference size
                rg_cs_resized = imresize(rg_cs, [ref_h, ref_w]);
                by_cs_resized = imresize(by_cs, [ref_h, ref_w]);
                
                if isempty(RG_cs_maps)
                    RG_cs_maps = rg_cs_resized;
                    BY_cs_maps = by_cs_resized;
                else
                    RG_cs_maps = cat(3, RG_cs_maps, rg_cs_resized);
                    BY_cs_maps = cat(3, BY_cs_maps, by_cs_resized);
                end
            end
        end
    end
    
    % Orientation center-surround
    O_cs_maps = cell(length(orientations), 1);
    for o = 1:length(orientations)
        O_cs_maps{o} = [];
        for c = 2:4
            for s = c+3:c+4
                if s <= levels && c+1 <= length(O_pyramids{o}) && s+1 <= length(O_pyramids{o})
                    o_cs = centerSurroundDifference(O_pyramids{o}{c+1}, O_pyramids{o}{s+1});
                    % Resize to reference size
                    o_cs_resized = imresize(o_cs, [ref_h, ref_w]);
                    
                    if isempty(O_cs_maps{o})
                        O_cs_maps{o} = o_cs_resized;
                    else
                        O_cs_maps{o} = cat(3, O_cs_maps{o}, o_cs_resized);
                    end
                end
            end
        end
    end
    
    %% 4. Create conspicuity maps
    % Get original image size for final resizing
    [orig_h, orig_w] = size(I);
    
    % Intensity conspicuity
    I_conspicuity = zeros(orig_h, orig_w);
    if ~isempty(I_cs_maps)
        for i = 1:size(I_cs_maps, 3)
            map_resized = imresize(I_cs_maps(:,:,i), [orig_h, orig_w]);
            I_conspicuity = I_conspicuity + normalizeMap(map_resized);
        end
    end
    I_conspicuity = normalizeMap(I_conspicuity);
    
    % Color conspicuity
    C_conspicuity = zeros(orig_h, orig_w);
    if ~isempty(RG_cs_maps) && ~isempty(BY_cs_maps)
        for i = 1:size(RG_cs_maps, 3)
            rg_resized = imresize(RG_cs_maps(:,:,i), [orig_h, orig_w]);
            by_resized = imresize(BY_cs_maps(:,:,i), [orig_h, orig_w]);
            C_conspicuity = C_conspicuity + normalizeMap(rg_resized) + normalizeMap(by_resized);
        end
    end
    C_conspicuity = normalizeMap(C_conspicuity);
    
    % Orientation conspicuity
    O_conspicuity = zeros(orig_h, orig_w);
    for o = 1:length(orientations)
        if ~isempty(O_cs_maps{o})
            for i = 1:size(O_cs_maps{o}, 3)
                o_resized = imresize(O_cs_maps{o}(:,:,i), [orig_h, orig_w]);
                O_conspicuity = O_conspicuity + normalizeMap(o_resized);
            end
        end
    end
    O_conspicuity = normalizeMap(O_conspicuity);
    
    %% 5. Combine into final saliency map
    saliencyMap = (I_conspicuity + C_conspicuity + O_conspicuity) / 3;
    saliencyMap = normalizeMap(saliencyMap);
    
    % Apply final smoothing
    saliencyMap = customGaussianFilter(saliencyMap, 2);
end
