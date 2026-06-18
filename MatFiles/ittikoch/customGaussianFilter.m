function filtered = customGaussianFilter(img, sigma)
    if exist('imgaussfilt', 'file') == 2
        filtered = imgaussfilt(img, sigma);
    else
        % Create Gaussian kernel manually
        kernel_size = ceil(6*sigma);
        if mod(kernel_size, 2) == 0, kernel_size = kernel_size + 1; end
        half_size = floor(kernel_size / 2);
        
        [x, y] = meshgrid(-half_size:half_size, -half_size:half_size);
        kernel = exp(-(x.^2 + y.^2) / (2*sigma^2));
        kernel = kernel / sum(kernel(:));
        
        filtered = customConv2(img, kernel);
    end
end
