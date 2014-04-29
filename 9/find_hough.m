pkg load image

orig = imread('img.bmp');

filter_size = 50;
avg_filt = ones(filter_size, filter_size) / (filter_size * filter_size);
blurred = imfilter(orig, avg_filt);

adjusted = !((orig > blurred) & (orig > 10));
adjusted = adjusted .* 1.5;

inner_size = 30;
inner_filter = ones(inner_size, inner_size) / (inner_size * inner_size);
inner = imfilter(adjusted, inner_filter);

disp('Inner');

outer_size = 50;
outer_filter = ones(outer_size, outer_size) / (outer_size * outer_size);
outer = imfilter(adjusted, outer_filter); 

disp('Outer');

result = outer > (inner * 1.5);
result = uint8(result) * 256;

edges = edge(result);

hough_results = houghtf(result, 'circle', [30]);
save('hough_results.mat', 'hough_results');