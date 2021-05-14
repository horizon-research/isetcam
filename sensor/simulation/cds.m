function sensor = cds(sensor,oi,showBar)

    if ~exist('showBar','var') || isempty(showBar), showBar = ieSessionGet('waitbar'); end

    disp('CDS on')
    % Read a zero integration time image that we subtract from the
    % simulated image.  This removes much of the effect of dsnu.
    integrationTime = sensorGet(sensor,'integration time');
    sensor = sensorSet(sensor,'integration time',0);
    
    if showBar, waitbar(0.6,wBar,'Sensor image: CDS');  end
    cdsVolts = sensorComputeImage(oi,sensor);    %THIS WILL BREAK!!!!
    sensor = sensorSet(sensor,'integration time',integrationTime);
    sensor = sensorSet(sensor,'volts',ieClip(sensor.data.volts - cdsVolts,0,[]));

end