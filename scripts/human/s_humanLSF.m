%% s_humanLSF
%
% Calculations illustrating the the human line spread function and OTF.
% The largest effects are caused by chromatic aberration.
%
% Copyright ImagEval Consultants, LLC, 2010.

%% 
ieInit

%% Show the image of a broadband line
imSize = 128;
scene = sceneCreate('lined65',imSize);     % D65 SPD for a thin line
scene = sceneSet(scene,'fov',1);  % Small field of view 
vcReplaceObject(scene);
% sceneWindow;

oi = oiCreate('human');
oi = oiSet(oi,'wave',sceneGet(scene,'wave'));
oi = oiCompute(oi,scene);
vcReplaceObject(oi);
oiWindow;

%% Make OIs for several different wavelengths

scene410 = sceneInterpolateW(scene,410);
oi = oiCreate('human');
oi = oiCompute(oi,scene410);
oi = oiSet(oi,'name','line-410');
vcAddAndSelectObject(oi);
oiWindow;

scene550 = sceneInterpolateW(scene,550);
oi = oiCreate('human');
oi = oiCompute(oi,scene550);
oi = oiSet(oi,'name','line-550');
vcAddAndSelectObject(oi);
oiWindow;

scene690 = sceneInterpolateW(scene,690);
oi = oiCreate('human');
oi = oiCompute(oi,scene690);
oi = oiSet(oi,'name','line-690');
vcAddAndSelectObject(oi);
oiWindow;

%% Calculate the Optical Transfer Function (OTF)  at two wavelengths
% You can do this from the GUI or can make a plot from this function
% The point is that the frequency support at 420 is much smaller than at
% 520nm.

% Create the OTF
pupilRadius = 0.0015;    % Meters
dioptricPower = 1/0.017; % 1/Meters
wStep = 5;
wave = 400:wStep:700;
[OTF2D, frequencySupport, wave] = humanOTF(pupilRadius,dioptricPower,[],wave);

vcNewGraphWin([],'tall');

subplot(2,1,1)
thisWave = 420;
idx = (thisWave - wave(1))/wStep;
mesh(frequencySupport(:,:,1),frequencySupport(:,:,2),fftshift(OTF2D(:,:,idx)))
xlabel('Frequency (cpd)')
ylabel('Frequency (cpd)')
title(sprintf('OTF2D for %.0f',thisWave));

subplot(2,1,2)
thisWave = 520;
idx = (thisWave - wave(1))/wStep;
mesh(frequencySupport(:,:,1),frequencySupport(:,:,2),fftshift(OTF2D(:,:,idx)))
xlabel('Frequency (cpd)')
ylabel('Frequency (cpd)')
title(sprintf('OTF2D for %.0f',thisWave));
%

%% Plot some linespread and OTF functions from the literature
% This is the Westheimer linespread function
xSec = -300:300; 
westheimerOTF = abs(fft(westheimerLSF(xSec)));

%(One cycle spans 10 min of arc, or freq=1 is 6 cyc/deg)
freq = (0:11)*6;
vcNewGraphWin; 
plot(freq,westheimerOTF((1:12))); grid on;
xlabel('Freq (cpd)'); ylabel('Relative contrast');
set(gca,'ylim',[-.1 1.1])
title('Westheimer - does not include wavelength')

%% Ijspeert
age = 40;
pupilDiameter = 3;
pigment = 0.142;
sfRange = (0:60);
deg = (0:.001:.1);
[MTF, PSF, LSF] = ijspeert(age, pupilDiameter, pigment, sfRange, deg2rad(deg));

vcNewGraphWin;
plot(sfRange,MTF); grid on
xlabel('Freq (cpd)'); ylabel('Relative contrast');
set(gca,'ytick',(0:.25:1))
title('Ijspeert - does not include wavelength')

%% Ijspeert slice through pointspread compared with LSF
vcNewGraphWin;
LSF = LSF/max(LSF(:));
PSF = PSF/max(PSF(:));
plot([fliplr(-deg),deg],[fliplr(PSF),PSF], 'k-',[fliplr(-deg),deg],[fliplr(LSF),LSF],'r--')
legend('Normalized PSF','Normalized LSF')
grid on
xlabel('Deg visual angle')
ylabel('Normalized amplitude')

%% End

