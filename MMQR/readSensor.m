 function temp = readSensor(ino, sensor_type)
    rd = readVoltage(ino,'A0');
    if sensor_type == "LM35"
        disp(rd)
        temp = rd*10;
        %temp = rd;
    else if sensor_type == "NTC"
        %constantes do termistor    
        Temp0 = 295.15; %25°C em K
        B = 4300;       %coeficiente beta do NTC 10k
        R1 = 10e03; %resistor divisor de tensão
        R = (rd*R1)/(5 - rd);
        temp = 1/((1/Temp0)+(1/B)*log(R/R1));
        temp = temp - 273.15;
    else
       error("[readSensor.m] Suporte para sensor %s não disponível ! \n", ...
                                                    sensor_type) 
       %suporte apenas para LM35 and NTC
    end
end

