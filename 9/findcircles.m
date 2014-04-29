pkg load image

orig = uint8(imread('adjusted.png')) * 256;

inner_size = 30;
inner_filter = ones(inner_size, inner_size) / (inner_size * inner_size);
inner = imfilter(orig, inner_filter);

disp('Inner');

outer_size = 50;
outer_filter = ones(outer_size, outer_size) / (outer_size * outer_size);
outer = imfilter(orig, outer_filter); 

result = outer > (inner * 1.5);
result = uint8(result);

%filter_size = 50;
%avg_filt = ones(filter_size, filter_size) / (filter_size * filter_size);
%blurred = imfilter(orig, avg_filt);

%adjusted = !((orig > blurred) & (orig > 10));
%adjusted = adjusted .* 1.5;

edges = edge(result);

hresults = houghtf(result, 'circle', [30]);
save('hresults.mat', 'hresults');

imwrite(orig, 'orig.png');
imwrite(inner, 'inner.png');
imwrite(outer, 'outer.png');
imwrite(result, 'result.png');
%imwrite(edges, 'edge.png');
%imwrite(adjusted, 'adjusted.png');
