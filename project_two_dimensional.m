% project_two_dimensional

function projection = project_two_dimensional (image, projector)
    [height, width, ~] = size(image);
    projection = zeros(height, width, 2);
    for r = 1:height
        for c = 1:width
            projection(r, c, :) = projector * squeeze(image(r, c, :));
        end
    end
end