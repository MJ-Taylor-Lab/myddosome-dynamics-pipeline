function trackIntensities = extractTrackProperties(p, trackDat)
imraw = tiffread2(p.imname);
spotFlank = p.spotFlank;
padamount = p.padamount;

for i = 1:length(imraw)
    im{i} = double(imraw(i).data);
    
    % Make a fake image
    fakeIm{i} = zeros(size(im{i}));
end
clear imraw

imsize = size(im{1});
[Xc Yc] = meshgrid(1:imsize(2),1:imsize(1));

liftim = [];
rtrkno = 1;
for trkno = 1:length(trackDat.xyt)
    x = trackDat.xyt{trkno}(:,1)/p.pixsize_x + 1;
    y = trackDat.xyt{trkno}(:,2)/p.pixsize_y + 1;
    t = trackDat.xyt{trkno}(:,3) + 1;
    
    if length(find([round(x)-spotFlank-1 ; round(y)-spotFlank-1] < 1)) > 0 || length(find([round(x)+spotFlank+1] > imsize(2))) > 0 || length(find([round(y)+spotFlank+1] > imsize(1))) > 0
        %disp(['Track ' trackDat.names{trkno} ' is an edge case'])
    else
        tpaddown = [max(min(t)-padamount,1):max(min(t)-1,1)]';
        padlength = length(tpaddown);
        t = [tpaddown; t];
        x = [repmat(x(1), [padlength 1]) ; x];
        y = [repmat(y(1), [padlength 1]) ; y];
        
        trkIntense = [];
        for i = 1:length(t)
            frameno = t(i);
            framex = round(y(i));
            framey = round(x(i));
            
            fakeIm{frameno}(framex-1:framex+1,framey-1:framey+1) = 1000;
            
            %subpixelshift
            shiftx = y(i) - framex;
            shifty = x(i) - framey;
            XcCrop = Xc((framex-spotFlank-1):(framex+spotFlank+1),(framey-spotFlank-1):(framey+spotFlank+1));
            YcCrop = Yc((framex-spotFlank-1):(framex+spotFlank+1),(framey-spotFlank-1):(framey+spotFlank+1));
            imCrop = im{frameno}((framex-spotFlank-1):(framex+spotFlank+1),(framey-spotFlank-1):(framey+spotFlank+1));
            imShift = interp2(XcCrop,YcCrop,imCrop,XcCrop + shiftx,YcCrop+shifty);
            midpo = (length(imShift) + 1)/2;
            
            % keyboard
            
            trkIntense(i) = sum(sum(imShift((midpo-spotFlank):(midpo+spotFlank),(midpo-spotFlank):(midpo+spotFlank))));
        end
        
        [trackIntensities{rtrkno}.frameno sortkey] = sort(t);
        trackIntensities{rtrkno}.padlength = padlength;
        trackIntensities{rtrkno}.intensity = trkIntense(sortkey);
        trackIntensities{rtrkno}.x = x(sortkey);
        trackIntensities{rtrkno}.y = y(sortkey);
        trackIntensities{rtrkno}.lifetime = (max(t) - min(t) + 1) - padlength;
        trackIntensities{rtrkno}.trackname = trackDat.names{trkno};
        trackIntensities{rtrkno}.id = trackDat.id(trkno);
        
        liftim = [liftim trackIntensities{rtrkno}.lifetime];
        rtrkno = rtrkno + 1;
    end
end

% Reorder by lifetime
unsortedTrackIntensities = trackIntensities;
[eh sortyval] = sort(liftim,'descend');
for trkno = 1:length(unsortedTrackIntensities)
    trackIntensities{trkno} = unsortedTrackIntensities{sortyval(trkno)};
end
end
