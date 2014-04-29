pkg load image

orig = imread('img.bmp');

%find likely nuclei
filter_size = 50;
avg_filt = ones(filter_size, filter_size) / (filter_size * filter_size);
blurred = imfilter(orig, avg_filt);
likely = !((orig > blurred) & (orig > 10));
likely = likely .* 1;
disp('Likely');

%nearby pixel average
inner_size = 30;
inner_filter = ones(inner_size, inner_size) / (inner_size * inner_size);
inner = imfilter(likely, inner_filter);
disp('Inner');

%slightly farther pixel average
outer_size = 50;
outer_filter = ones(outer_size, outer_size) / (outer_size * outer_size);
outer = imfilter(likely, outer_filter); 
disp('Outer');

%find pixels who radiate (more likely to be nucleus)
result = outer > (inner * 1.5);
result = uint8(result) * 256;

%edge detect
edges = edge(result);
imwrite(edges, 'edges.png');

%calculate hough_results
%hough_results = houghtf(result, 'circle', [30]);
%save('hough_results.mat', 'hough_results');