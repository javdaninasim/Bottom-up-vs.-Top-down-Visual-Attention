function cs_map = centerSurroundDifference(center, surround)
    % Create center-surround difference map
    % Resize surround to match center
    [h, w] = size(center);
    surround_resized = imresize(surround, [h, w], 'bilinear');
    
    % Compute absolute difference
    cs_map = abs(center - surround_resized);
end