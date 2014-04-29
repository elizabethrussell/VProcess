img = imread('img.bmp');
rgb = repmat(img, [1 1 3]);
edges = imread('edges.png');
rgb(:,:,1) = edges * 256;

imshow(rgb);

input('Press [enter] to quit');
