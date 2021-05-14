function sensor = clipping(sensor)

vSwing = sensorGet(sensor,'pixel voltage swing');
sensor = sensorSet(sensor,'volts',ieClip(sensorGet(sensor,'volts'),0,vSwing));

end
