function result = customConv2(img, kernel)
    % Custom 2D convolution using conv2 (available in base MATLAB)
    % Use 'same' to maintain image size
    result = conv2(img, kernel, 'same');
end