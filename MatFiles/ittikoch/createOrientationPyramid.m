function pyramid = createOrientationPyramid(img, levels, sigma0, orientation)
pyramid = cell(levels + 1, 1);
    
    % Create custom Gabor filter (since gabor() might not be available)
    gabor_filter = createGaborFilter(orientation);
    
    % Apply to base image
    gabor_response = customConv2(img, gabor_filter);
    pyramid{1} = abs(gabor_response);
    
    % Create pyramid
    current = pyramid{1};
    for i = 2:levels + 1
        blurred = customGaussianFilter(current, sigma0);
        current = imresize(current, 0.5, 'bilinear');
        pyramid{i} = current;
    end
end