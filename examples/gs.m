ieInit;
ieSessionSet('wait bar','off');

iSize  = 128;
nLines = 4;
fov    = 3;
scene  = sceneCreate('star pattern',iSize,'ee',nLines);
%fname  = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
%scene  = sceneFromFile(fname,'rgb');
scene  = sceneSet(scene,'fov',fov);
oi     = oiCreate;

% Create a sensor whose field of view matches the scene size
sensor    = sensorCreate;
pixelSize = [1.4 1.4]*1e-6;    % Pixel size of 1.4 um
sensor    = sensorSet(sensor,'pixel size constant fill factor',pixelSize);
sensor    = sensorSet(sensor,'fov',sceneGet(scene,'fov')/2,oi);
sz        = sensorGet(sensor,'size');

% Exposure time.
expTime = 1e-3;    % Millisecond regime
%expTime = 1/60;    % Default

% How ofter do we simulate a capture?
simExpTime  = 1e-4;
sensor  = sensorSet(sensor,'exp time',simExpTime);

% How many total captures do we need? Number of rows plus enough additional
% captures for last row
nFrames = round(expTime/simExpTime);

% Store the sensor volts from each capture separately, before we assemble.
v  = zeros(sz(1),sz(2),nFrames);

% degree per second.
rate = 30000;
%rate = 0;

ieAddObject(scene);
%sceneWindow;

oi = oiCompute(oi,scene);
ieAddObject(oi);
%oiWindow;

%% Make the pattern with sceneRotate, then acquire with sensorCompute
w = waitbar(0,'Rotating scenes');
S = 160;   % This is the size of the cropped oi

fps = 7;
vcNewGraphWin; colormap(gray); axis image; axis off
noiseFreeV = zeros(sz);
parfor ii=1:nFrames
    waitbar(ii/nFrames,w,sprintf('Scene %i',ii));

    % Rotation shrink the image at the boundary by adding in zero values
    % where there is an unknown extrapolation.  We remove this by the
    % cropping below.
    deg = ii*simExpTime*rate;
    s = sceneRotate(scene,deg);
    % ieAddObject(s); sceneWindow;

    % Compute and crop to keep just the center
    toi = oiCompute(oi,s);
    cp = oiGet(toi,'center pixel');
    rect = round([cp(1) - S/2,  cp(2) - S/2,   S,   S]);
    oiC = oiCrop(toi,rect);
    % ieAddObject(oiC); oiWindow;

    % Create noise-free captures first, no clipping, gain, CDS, etc.
    tSensor = sensorSet(sensor,'noise flag',-1);
    tSensor = sensorCompute(tSensor,oiC);

    v(:,:,ii) = sensorGet(tSensor,'volts');

    % This contains the noise free final voltages; should be be used in
    % sequential mode.
    %noiseFreeV = noiseFreeV + v(:,:,ii);
    %imagesc(noiseFreeV); pause(1/fps);
end
close(w)

% only for parfor mode, add individual captures together.
noiseFreeV = sum(v, 3);
imagesc(noiseFreeV);

% now add all the noises
sensor = sensorSet(sensor, 'volts', noiseFreeV);
% this sets the real exposure time, which is used to calculate noises
sensor  = sensorSet(sensor,'exp time',expTime);
% this is the flag used by sensorAddNoise
sensor = sensorSet(sensor,'noise flag',2);
sensor = sensorAddNoise(sensor);

% simulate analog gain
sensor=analogGain(sensor);
% simulate clipping
sensor = clipping(sensor);
% simulate quantization; this doesn't quite affect volts, just the dv part
sensor = quantization(sensor);
% simulate CDS
sensor = cds(sensor,oi);

noisyV = sensorGet(sensor, 'volts');
imagesc(noisyV);

%% Image process and then show the final color image
ip = ipCreate;

ip = ipCompute(ip,sensor);
ieAddObject(ip);
%ipWindow;
