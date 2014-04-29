clear; clc; close all;
%fpath = '/home/users/ben';
%[name, fpath] = uigetfile([fpath,'*.*'], ['Choose a hologram'], 100,100);
%I1 = imread([fpath, name]);
%name = uigetfile;
I1 = imread('img.jpg');
figure; imagesc(I1); colormap(gray); axis equal; axis tight; title('Digital hologram');

Ih1 = double(I1) - mean(mean(double(I1)));

[N1, N2] = size(Ih1); % get size of hologram

N = min(N1, N2); % restrict hologram size to smallest square
Ih = Ih1(1:N, 1:N); % copy only relevant square

%%% Get input %%%
%pix = input('Pixel pitch (mm): ');
%h = input('Wavelength (mm): ');
%z0 = input('Reconstruction distance z0 (+ for a real image, - for a virtual image) (mm): ');
pix = .0022;
h = .000592;
z0 = 1;

L = pix*N;

%%%S-FFT begin

n = -N/2:N/2-1; %make n range
x = n*pix; y = x;
[xx, yy] = meshgrid(x,y);
k = 2 * pi / h;
Fresnel = exp(1i*k/2/z0 * (xx.^2 + yy.^2));
f2 = Ih .* Fresnel;
Uf = fft2(f2, N, N);
Uf = fftshift(Uf);
size(Uf)
ipix = h * abs(z0)/N/pix;
x = n*ipix;
y = x;
[xx, yy] = meshgrid(x,y);
phase = exp(1i*k*z0)/(i*h*z0)*exp(1i*k/2/z0*(xx.^2 + yy.^2));
size(phase)
U0 = Uf.* pinv(phase);

%%%S-FFT end

If = abs(U0) .^ 0.75;
Gmax = max(max(If));
Gmin = min(min(If));
L0 = abs(h*z0*N/L);
disp(['Width of the reconstruction plane =', num2str(L0),' mm']);
figure; imagesc(If, [Gmin, Gmax]), colormap(gray); axis equal; axis tight; ylabel('pixels');
xlabel(['Width of the reconstruction plane=', num2str(L), ' mm']);
title('Image reconstructed by S-FFT');
p = input('Display parameter (>1): ');

while isempty(p) == 0
	imagesc(If, [Gmin Gmax/p]), colormap(gray); axis equal; axis tight; ylabel('pixels');
	xlabel(['Width of the reconstruction plane = ', num2str(L), ' mm']);
	title(' Image reconstructed by S-FFT ');
	p = input('Display parameter (>1) (0=end): ');
	if p == 0,
		break
	end
end