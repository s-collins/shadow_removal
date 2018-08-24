% COPYRIGHT (C) 2018 University of Akron Robotics Team. All rights reserved.
% File Name : remove_shadows.m
% Author    : Sean Collins
% Email     : sgc29@zips.uakron.edu
% Date      : 23 August 2018
% Purpose   : Defines an abstract base class for Image objects.  Also defines

%% Cleanup Workspace
close all
clear
clc

%% Open the Image
raw_image = imread('images/rocks.png');
figure
imshow(raw_image);
[nrows, ncols, ~] = size(raw_image);

%% Identify brightest pixels
% Drew et al. uses the top 1 percent in their paper "Recovery of Chromaticity
% Image Free from Shadows via Illumination Invariance"
percent = 1; % percentage of brightest pixels
grayscale_image = rgb2gray(raw_image);
threshold = prctile(reshape(grayscale_image, [], 1), 100 - percent);

index = 1;
for r = 1:nrows
    for c = 1:ncols
        if (grayscale_image(r, c) > threshold)
            coords_of_brightest(index, :) = [r, c];
            index = index + 1;
        end
    end
end

%% Calculate the chromaticity
% Finlayson et al. divide by geometric mean of the color channel values in their
% paper "Intrinsic Image by Entropy Minimization". This has the effect of
% removing Lambertian shading and removing the overall light intensity.
%
% "chromaticity" - an objective specification of the quality of color,
%                  independent of its luminance
double_image = double(raw_image);
for r = 1:nrows
    for c = 1:ncols
        geo_mean(r, c) = geomean(squeeze(double_image(r, c, :))) + 1;

        for channel = 1:3
            if (double_image(r, c, channel) ~= 0)
                chromaticity(r, c, channel) = double_image(r, c, channel) / geo_mean(r, c);
            else
                chromaticity(r, c, channel) = 0.001;
            end
        end
    end
end

%% Calculage the log chromaticity
log_chromaticity = log(chromaticity);

%% Rotate the log chromaticity into 2-D chromaticity space (X)
% Finlayson et al. use the plane perpendicular to u = 1/sqrt(3)[1, 1, 1]'
% as the 2D space
U = [2/3, -1/3, -1/3; 0, -1/2, 1/2]; % projector
X = zeros(nrows, ncols, 2);
for r = 1:nrows
    for c = 1:ncols
        X(r, c, :) = U * squeeze(log_chromaticity(r, c, :));
    end
end

%% Determine the direction (theta) in which to project in the plane
% Loop through the angles from 1 to 180 degrees, project X in this
% direction, then calculate the entropy of this projection. Minimum
% entropy corresponds to the optimal theta value.
figure
for angle = 1:180
    angle
    % Calculate the grayscale image along 1D projection line orthogonal
    % to the lighting direction
    I = X(:, :, 1) * cosd(angle) + X(:, :, 2) * sind(angle);
    I = I(:);
    
    % Create a histogram to aid in the calculation of entropy
    bin_width = std(I) / 10;
    minimum = min(I);
    maximum = max(I);
    h = histogram(I, minimum:bin_width:maximum);
    probability = h.Values / length(I);
    
    % Calculate the entropy
    sum = 0;
    for bin = 1:h.NumBins
        if (probability(bin) ~= 0)
            sum = sum + probability(bin) * log(probability(bin));
        end
    end
    entropy(angle) = -sum;
end
[~, theta] = min(entropy);

%% Project onto the line in theta direction
theta = 110;
coeff = [cosd(theta), sind(theta); -sind(theta), cosd(theta)];
for r = 1:nrows
    for c = 1:ncols
        %X_prime(r, c, :) = inv(coeff) \ [-X(r, c, 1) * cosd(theta) - X(r, c, 2) * sind(theta); 0];
        %X_prime(r, c, :) = squeeze(X_prime(r, c, :));
        magnitude = X(r, c, 1) * cosd(theta) + X(r, c, 2) * sind(theta);
        X_prime(r, c, 1) = magnitude * cosd(theta);
        X_prime(r, c, 2) = magnitude * sind(theta);
    end
end

%% Comparing
% figure, plot(X(:, :, 1), X(:, :, 2), 'o');
% xlim([-5, 5]);
% ylim([-10, 10]);
% figure, plot(X_prime(:, :, 1), X_prime(:, :, 2), 'o');
% xlim([-5, 5]);
% ylim([-10, 10]);

%% Reconstruct chromaticity
reconstructed = zeros(nrows, ncols, 3);
for r = 1:nrows
    for c = 1:ncols
        rgb = U' * (squeeze(X_prime(r, c, :)));
        reconstructed(r, c, :) = exp(rgb);
    end
end

figure, imshow(reconstructed * .5);

