% get_brightest

function brightest_coords = get_brightest (image, percentile)
    red = image(:, :, 1);
    red = red(:);
    red_thresh = prctile(red, percentile);
    
    green = image(:, :, 2);
    green = green(:);
    green_thresh = prctile(green, percentile);
    
    blue = image(:, :, 3);
    blue = blue(:);
    blue_thresh = prctile(blue, percentile);
    
    [rows, cols, ~] = size(image);
    index = 1;
    for r = 1:rows
        for c = 1:cols
            if (image(r, c, 1) > red_thresh || image(r, c, 2) > green_thresh || image(r, c, 3) > blue_thresh)
                brightest_coords(index, :) = [r, c];
                index = index + 1;
            end
        end
    end
end