function sensor = analogGain(sensor)
        
% We check for an analog gain and offset.  For many years there was
% no analog gain parameter. This was added in January, 2008 when
% simulating some real devices. The manufacturers were clamping at
% zero and using the analog gain like wild men, rather than
% exposure duration. If these parameters are not set, they default
% to 1 (gain) and 0 (offset).
%
% Also, some people use gain as a multipler and some as a divider.
% Sorry for that.  Here you can see the formula.  We divide by the
% gain.
        
ag = sensorGet(sensor,'analogGain');
ao = sensorGet(sensor,'analogOffset');
if ag ~=1 || ao ~= 0
    if strcmp(responseType,'log')
        % We added a warning for the 'log' sensor type. Offset
        % and gain for a log sensor is a strange thing to do.
        warning('log sensor with gain/Offset');
    end
    volts = sensorGet(sensor,'volts');
    
    % Some people prefer a gain and offset formula like this:
    %
    %    volts/ag + ao
    %
    % If you are one of those people, then when you set the ISETCam
    % analog offset level parameter think of the formula as
    %
    %   volts/ag + ao = volts/ag + (ao'/ag) 
    %
    % where ao' is the ISETCam analog offset. Your analog offset
    % (ao) should be equal to the ISETCam analog offset (ao')
    % divided by the gain (ao'/ag).  Thus, the ISETCam analog
    % offset should be ao' = ao*ag.
    %
    volts = (volts + ao)/ag;   
    sensor = sensorSet(sensor,'volts',volts);
end

end
