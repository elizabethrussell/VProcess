%-------------------------LIM5--------------------------------
% Function: reconstruct an image with a adjustable magnification using
% the D-FFT algorithm.
% We may decrease the perturbation by the zero order by suppressing the
% mean value of the hologram.
%
% Procedure: (l) Read an image file
% (2) Give the parameters asked for on the screen
% (3) Calculate by D-FFT with adjustable magnification
%
% Variables:
% Ih : hologram;
% h : wavelength (mm);
% L : width of the hologram (mm);
% L0 : width of the diffracted object field (mm);
% z0 : recording distance of the hologram (mm);
% zi : reconstruction distance (mm);
% zc : radius of the reconstruction wave's wavefront (mm);
% U0 : complex amplitude in the reconstruction plane;
% pix : pixel pitch of the hologram (mm);
% ipix : pixel pitch in the reconstructed field using S-FFT;
%-------------------------------------------------------------
%clear;close all;
%chemin='C:\';
%[nom,chemin]=uigetfile([chemin,'*.*'],['Choose the hologram to be reconstructed'],100,100);
%I1=imread([chemin,nom]);
I1 = imread('img.jpg');

Ih1=double(I1);
figure;imagesc(I1);colormap(gray);axis equal;axis tight;
title('Digital hologram');
pix=input('Pixel pitch (mm) : ');
h=input('Wavelength (mm) : ');
z0=input('Reconstruction distance z0 (+ for a real image, - for a virtual image) (mm): ');
k=2*pi/h;
[N1,N2]=size(Ih1);
N=min(N1,N2);
Ih=Ih1(1:N,1:N)-mean(mean(Ih1(1:N,1:N)));% suppression of the mean value
L=pix*N;
disp(['Width of sensor : ',num2str(L),' mm']);
pg=input('Filter the 0 order of the hologram (1/0) ? ');
if pg==1,
fm=filter2(fspecial('average',3),Ih); % see section 5.3.4.
Ih=Ih-fm;
end
%--Reconstruction by S-FFT to find center/bandwidth of object
n=-N/2:N/2-1;
x=n*pix;y=x;
[xx,yy]=meshgrid(x,y);
Fresnel=exp(i*k/2/z0*(xx.^2+yy.^2));
f2=Ih.*Fresnel;
Uf=fft2(f2,N,N);
Uf=fftshift(Uf);
ipix=h*abs(z0)/N/pix;
xi=n*ipix;
yi=xi;
figure;imagesc(xi,yi,abs(Uf).^0.75);colormap(gray);axis equal;axis tight;
title('Click on the upper-left and lower-right corner of the object');
XY=ginput(2);
% Center and width of the object
xc=0.5*(XY(1,1)+XY(2,1));
yc=0.5*(XY(1,2)+XY(2,2));
DAX=abs(XY(1,1)-XY(2,1));
DAY=abs(XY(1,2)-XY(2,2));

%--Reconstruction with adjustable magnification
Gyi=min(L/DAX,L/DAY);
Gy=input(['Magnification factor for the reconstruction (ideal : ',num2str(Gyi),') : ']);
zi=-Gy*z0;
zc=1/(1/z0+1/zi);

% Spherical wave calculation
sphere=exp(i*k/2/zc*(xx.^2+yy.^2));

% Illumination of the hologram by a spherical wave
f=Ih.*sphere; % Spectrum of hologram multiplied by spherical wave
TFUf=fftshift(fft2(f,N,N));

% Fourier space
du=1/pix/N;dv=du;
fex=1/pix;fey=1/pix;
fx=[-fex/2:fex/N:fex/2-fex/N];
fy=[-fey/2:fey/N:fey/2-fey/N];
[FX,FY]=meshgrid(fx,fy);

% Spatial frequencies of reference wave
Ur=xc/h/abs(z0);
Vr=yc/h/abs(z0);

% Transfer function
Du=abs(Gy*DAX/h/zi);
Dv=abs(Gy*DAY/h/zi);
Gf=zeros(size(f));
Ir=find(abs(FX-Ur) < Du/2 & abs(FY-Vr) < Dv/2);
Gf(Ir)=exp(-i*k*zi*sqrt(1-(h*(FX(Ir)-Ur)).^2-(h*(FY(Ir)-Vr)).^2));

% Reconstruction
if sign(z0) == -1
	U0=fft2(TFUf.*Gf,N,N);
elseif sign(z0) == +1
	U0=ifft2(TFUf.*Gf,N,N);
end

Gmax=max(max(abs(U0).^0.75));
Gmin=min(min(abs(U0).^0.75));
figure;imagesc(abs(U0).^0.75,[Gmin,Gmax/1]);colormap(gray);
axis equal;axis tight;
xlabel(['Magnification : ',num2str(Gy)]);
title('Image reconstructed by D-FFT');
p=input('Display parameter (>1) : ');

while isempty(p) == 0
	imagesc(abs(U0).^0.75,[Gmin,Gmax/p]),colormap(gray);axis equal;axis
	tight;ylabel('pixels');
	xlabel(['Width of the reconstruction plane =',num2str(L),' mm']);
	title(' Image reconstructed by D-FFT with adjustable magnification ');
	p=input('Display parameter (>1) (0=end) : ');
	if p==0,
		break
	end
end