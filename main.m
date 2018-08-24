clc
clear
close all

% Shadow Removal

% Open the image
image = imread('rocks.92.png');
image = imgaussfilt(image, 1);
imshow(image)
image = double(image);

% Find the brightest pixels
brightest_coords = get_brightest(image, 99);

% Calculate the log of chromaticity for each pixel
chromaticity = log_chromacity(image);

% Project into 2D space
U = [2/3, -1/3, -1/3; 0, -.5, 0.5];
X = project_two_dimensional(chromaticity, U);

entropies = zeros(1, 180);
figure
for j = 1:180
    % Project onto line
    j
    theta = j * pi() / 180;
    index = 1;
    [rows, cols, ~] = size(X);
    line = zeros(1, rows * cols);
    for r = 1:rows
        for c = 1:cols
            line(index) = X(r,c,1) * cos(theta) + X(r,c,2) * sin(theta);
            index = index + 1;
        end
    end
    
    percentiles = prctile(line, [10, 90]);
    next = 1;
    for i = 1:length(line)
        if (line(i) > percentiles(1) && line(i) < percentiles(2))
            line2(next) = line(i);
            next = next + 1;
        end
    end

    line = line2;
    bin_width = std(line) / 5;
    minimum = min(line);
    maximum = max(line);
    h = histogram(line, minimum:bin_width:maximum, 'Normalization', 'probability');
    sum = 0;
    for bin = 1:h.NumBins
        p = h.Values(bin);
        if (p ~= 0)
            sum = sum + p * log(p);
        end
    end
    entropies(j) = -sum;

end

% Extract angle with minimum entropy
[m,angle] = min(entropies);

% Project onto the theta vector
[rows, cols, ~] = size(X);
angle = angle * pi() / 180;
coeff = [cos(angle), sin(angle); -sin(angle), cos(angle)];
for r = 1:rows
    for c = 1:cols
        X_prime(r, c, :) = inv(coeff) \ [-X(r, c, 1) * cos(angle) - X(r, c, 2) * sin(angle); 0];
        X_prime(r, c, :) = squeeze(X_prime(r, c, :));
    end
end

orthogonal = [cos(angle + pi() / 2); sin(angle + pi() / 2)]; % TODO: Calculate correct coefficient...

% Figure out how much offset to add.
%  - Find a vector from original X to X' (for each of the brightest pixels)
%  - Take dot product of this vector and "orthogonal"
%  - Find the average of these dot products
%  - Use this average as the magnitude of the "orthogonal" vector
%  - Adjust the X' by adding the "orthogonal" vector
[n, ~] = size(brightest_coords);
for i = 1:n
    r = brightest_coords(i, 1);
    c = brightest_coords(i, 2);
    x = X(r, c, 1) - X_prime(r, c, 1);
    y = X(r, c, 2) - X_prime(r, c, 2);
    dot_product(i) = dot([x, y], orthogonal);
end
magnitude = mean(dot_product);

% Reconstruct
[rows, cols, depth] = size(image);
reconstructed = zeros(rows, cols, depth);
for r = 1:rows
    for c = 1:cols
        rgb = U' * (squeeze(X_prime(r, c, :)) + magnitude * orthogonal);
        reconstructed(r, c, :) = exp(rgb);
    end
end

figure, imshow(reconstructed);