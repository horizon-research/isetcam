function sensor = quantization(sensor)

switch lower(sensorGet(sensor,'quantization method'))
    case 'analog'
        % If the quantization method is Analog, then the data are
        % stored only in data.volts.  We used to run this line.
        % sensor = sensorSet(sensor,'volts',analog2digital(sensor,'analog'));
    case 'linear'
        sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'linear'));
    case 'sqrt'
        sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'sqrt'));
    case 'lut'
        warning('sensorComputeNoise:LUT','LUT quantization not yet implemented.')
    case 'gamma'
        warning('sensorComputeNoise:Gamma','Gamma quantization not yet implemented.')
    otherwise
        sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'linear'));
end

end
