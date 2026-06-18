function gabor_kernel = createGaborFilter(orientation)
    sigma_x = 2; sigma_y = 2;
    wavelength = 8;
    
    % Convert orientation to radians
    theta = orientation * pi / 180;
    
    % Create coordinate matrices
    [x, y] = meshgrid(-8:8, -8:8);
    
    % Rotate coordinates
    x_rot = x * cos(theta) + y * sin(theta);
    y_rot = -x * sin(theta) + y * cos(theta);
    
    % Create Gabor kernel
    gaussian = exp(-(x_rot.^2/(2*sigma_x^2) + y_rot.^2/(2*sigma_y^2)));
    sinusoid = cos(2*pi*x_rot/wavelength);
    
    gabor_kernel = gaussian .* sinusoid;
    gabor_kernel = gabor_kernel - mean(gabor_kernel(:)); % Zero mean
end
