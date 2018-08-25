function make_invariant_video (image, degrees)
    for i = 1:length(degrees)
        invariant = gs_invariant(image, degrees(i));
        figure(1);
        imshow(exp(invariant) * .75);
        frames(i) = getframe(gcf);
    end
    
    VideoWriter writer ('video.AVI');
    open(writer);
    for i = 1:length(frames)
        writeVideo(writer, frames(i));
    end
    close(writer);
end