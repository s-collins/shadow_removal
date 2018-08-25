function invariant = gs_invariant (image, theta)
    % Calculate band-ratio chromaticity by dividing two of the color bands
    % by the third band. This effectively removes intensity information.
    green_band = 2;
    band_ratio_chromaticity = chromaticity(double(image), green_band);
    log_chromaticity = log(band_ratio_chromaticity);
    
    % Project the log_chromaticities onto the vector with direction given
    % by theta
    [nrows, ncols, ~] = size(log_chromaticity);
    invariant = zeros(nrows, ncols);
    v = [cosd(theta), sind(theta)];
    for r = 1:nrows
        for c = 1:ncols
            pixel = squeeze(log_chromaticity(r, c, :));
            invariant(r, c) = dot(pixel, v);
        end
    end
end

function c = chromaticity (image, d)
    [nrows, ncols, ~] = size(image);
    c = zeros(nrows, ncols, 2);
    index = 1;
    for i = 1:3
        if (i ~= d)
            c(:, :, index) = image(:, :, i) ./ image(:, :, d);
            index = index + 1;
        end
    end
end

