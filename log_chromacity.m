% log_chromacity

function chromacity = log_chromacity (image)
    [height, width, depth] = size(image);
    chromacity = zeros(height, width, depth);
    for r = 1:height
        for c = 1:width
            x = geomean(squeeze(image(r, c, :)) + 1);
            for i = 1:depth
                if (image(r, c, i) ~= 0)
                    chromacity(r, c, i) = log(image(r, c, i) / x);
                else
                    chromacity(r, c, i) = -100;
                end
            end
        end
    end
end