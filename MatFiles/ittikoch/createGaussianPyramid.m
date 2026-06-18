function pyramid = createGaussianPyramid(img, levels, sigma0)
   pyramid = cell(levels + 1, 1);
    pyramid{1} = img;
    
    current = img;
    for i = 2:levels + 1
        % Apply Gaussian blur and downsample
        blurred = customGaussianFilter(current, sigma0);
        current = imresize(blurred, 0.5, 'bilinear');
        pyramid{i} = current;
    end
    
end