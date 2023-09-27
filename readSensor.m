function temp = readSensor(ino, sensor_type, period, set_point)
    rd = readVoltage(ino,'A0');
    elapsed_time = toc; %contador de tempo para plot

    if sensor_type == "LM35"
        temp = (rd - 0.1)*100;

        figure(1)
        %subplot(2,1,1)
        stem(elapsed_time + period, temp, 'filled', 'blue');
        yline(set_point,'-.b');
        hold on
        title("Temperatura medida");
        xlabel("Tempo decorrido [s]");
        ylabel("Temperatura [°C]");
        ylim([0 65]);
    
    else if sensor_type == "NTC"
        %constantes do termistor    
        A = 0.001125308852122;
        B =  0.000234711863267;
        C = 0.000000085663516;
        R1 = 10e03; %resistor divisor de tensão
    
        R2 = R1*((5/rd) - 1); %resistencia calcukada do termistor
        logR2 = log(R2);
        temp = 1/(A + B*logR2 + C*(logR2^3)); %Steinhart-Hart equation
        temp = temp - 273.15; %Kelvin para celsius
        %temp = round(temp,1);
        %fprintf("Temperatura = %d", temp);
        figure(1)
        subplot(4,1,1)
        stem(elapsed_time + period, temp, 'filled', 'blue');
        yline(set_point,'red');
        legend('Sensor', 'Setpoint');
        hold on
        title("Temperatura medida");
        xlabel("Tempo decorrido [s]");
        ylabel("Temperatura [°C]");
        ylim([0 65]);

    else
       error("[readSensor.m] Suporte para sensor %s não disponível ! \n", ...
                                                    sensor_type) 
       %suporte apenas para LM35 and NTC
    end
end

